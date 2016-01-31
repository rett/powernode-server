class NodeTemplatesController < ApplicationController
  load_resource except: [:create, :import]
  authorize_resource

  before_action { add_breadcrumb @node_template if @node_template.try(:persisted?) }
  before_action :load_objects, only: [:create, :edit, :new, :update]

  respond_to :html

  def export
    if request.get?
      render 'export'
    elsif request.post? && params[:export]
      json_data = Jbuilder.encode do |json|
        json.node_template(@node_template, :id,
                                           :node_platform_id,
                                           :name,
                                           :description,
                                           :admin_user,
                                           :public)
        if can?(:manage, @node_template.node_architecture)
          json.node_architecture(@node_template.node_architecture, :id,
                                                                   :name,
                                                                   :description,
                                                                   :enabled,
                                                                   :public)
        end
        if can?(:manage, @node_template.node_platform)
          json.node_platform(@node_template.node_platform, :id,
                                                           :node_architecture_id,
                                                           :name,
                                                           :description,
                                                           :enabled,
                                                           :public)
        end
        node_module_category_ids = []
        node_module_dependency_ids = []
        node_module_ids = params[:export][:node_modules]
        json.node_modules(node_module_ids.reject(&:empty?)) do |node_module_id|
          if (node_module = NodeModule.accessible_by(@current_ability, :read).find_by(id: node_module_id))
            node_module_category_ids << node_module.node_module_category_id
            node_module_category_ids << node_module.node_module_category.config_category_id
            node_module_category_ids << node_module.node_module_category.instance_category_id
            node_module_dependency_ids << node_module.node_module_dependencies
            json.node_module(node_module, :id,
                                          :node_module_category_id,
                                          :node_platform_id,
                                          :name,
                                          :description,
                                          :configurable,
                                          :enabled,
                                          :file_spec,
                                          :immutable,
                                          :provisional,
                                          :reboot_required,
                                          :required,
                                          :priority,
                                          :init_restart,
                                          :init_start,
                                          :init_stop,
                                          :dependency_spec,
                                          :package_spec,
                                          :mask,
                                          :public,
                                          :variety)
          end
        end
        json.node_module_categories(node_module_category_ids.flatten.uniq) do |node_module_category_id|
          if (node_module_category = NodeModuleCategory.accessible_by(@current_ability, :read).find_by(id: node_module_category_id))
            if can?(:manage, node_module_category)
              json.node_module_category(node_module_category, :id,
                                                              :config_category_id,
                                                              :instance_category_id,
                                                              :name,
                                                              :description,
                                                              :priority,
                                                              :enabled,
                                                              :public,
                                                              :variety)
            end
          end
        end
        json.node_module_dependencies(node_module_dependency_ids.flatten.uniq) do |node_module_dependency_id|
          if (node_module_dependency = NodeModuleDependency.accessible_by(@current_ability, :read).find_by(id: node_module_dependency_id))
            if can?(:manage, node_module_dependency)
              json.node_module_dependency(node_module_dependency, :id,
                                                                  :node_module_id,
                                                                  :node_module_dependency_id)
            end
          end
        end
      end
      send_data(json_data, :disposition => 'attachment',
                           :encoding => 'utf8',
                           :filename => "#{@node_template.name}.json",
                           :type => 'text/json; charset=utf-8; header=present')
    end
  end

  def import
    if params[:node_template]
      if (import_params = ActionController::Parameters.new(JSON.parse(params[:node_template][:file].read, { symbolize_names: true })))
        if import_params[:node_architecture]
          node_architecture = NodeArchitecture.find_or_initialize_by(id: import_params[:node_architecture][:id])
          if node_architecture.new_record? && can?(:update, node_architecture)
            import_params[:node_architecture].merge!(account_id: @current_account.id)
            unless (node_architecture.update_attributes(node_architecture_params(import_params)))
              flash['danger'] ||= I18n.t('flash.node_templates.import.danger_node_architecture')
            end
          end
        end
        if import_params[:node_platform]
          node_platform = NodePlatform.find_or_initialize_by(id: import_params[:node_platform][:id])
          if can?(:update, node_platform)
            import_params[:node_platform].merge!(account_id: @current_account.id)
            unless (node_platform.update_attributes(node_platform_params(import_params)))
              flash['danger'] ||= I18n.t('flash.node_templates.import.danger_node_platform')
            end
          end
        end
        if import_params[:node_template]
          @node_template = NodeTemplate.find_or_initialize_by(id: import_params[:node_template][:id])
          if can?(:update, @node_template)
            import_params[:node_template].merge!(account_id: @current_account.id, enabled: params[:node_template][:enabled])
            unless (@node_template.update_attributes(node_template_params(import_params)))
              flash['danger'] ||= I18n.t('flash.node_templates.import.danger_node_template')
            end
          end
        end
        if import_params[:node_module_categories] && import_params[:node_module_categories].is_a?(Array)
          import_params[:node_module_categories].each do |node_module_category_attributes|
            node_module_category_attributes = ActionController::Parameters.new(node_module_category_attributes)
            node_module_category = NodeModuleCategory.find_or_initialize_by(id: node_module_category_attributes[:node_module_category][:id])
            if can?(:update, node_module_category)
              node_module_category_attributes[:node_module_category].merge!(account_id: @current_account.id)
              unless (node_module_category.update_attributes(node_module_category_params(node_module_category_attributes)))
                flash['danger'] ||= I18n.t('flash.node_templates.import.danger_node_module_categories')
              end
            end
          end
        end
        if import_params[:node_modules] && import_params[:node_modules].is_a?(Array)
          import_params[:node_modules].each do |node_module_attributes|
            node_module_attributes = ActionController::Parameters.new(node_module_attributes)
            node_module = NodeModule.find_or_initialize_by(id: node_module_attributes[:node_module][:id])
            node_module.account_id = @current_account.id
            if can?(:update, node_module)
              node_module_attributes[:node_module].merge!(account_id: @current_account.id)
              if (node_module.update_attributes(node_module_params(node_module_attributes)))
                @node_template.node_modules << node_module if !@node_template.node_modules.include?(node_module)
              else
                flash['danger'] ||= I18n.t('flash.node_templates.import.danger_node_modules')
              end
            end
          end
        end
        if import_params[:node_module_dependencies] && import_params[:node_module_dependencies].is_a?(Array)
          import_params[:node_module_dependencies].each do |node_module_dependency_attributes|
            node_module_dependency_attributes = ActionController::Parameters.new(node_module_dependency_attributes)
            node_module = NodeModule.accessible_by(@current_ability, :manage).find_by(id: node_module_dependency_attributes['node_module_dependency']['node_module_id'])
            dependant_module = NodeModule.accessible_by(@current_ability, :read).find_by(id: node_module_dependency_attributes['node_module_dependency']['node_module_dependency_id'])
            if node_module && dependant_module && can?(:manage, node_module) && can?(:read, dependant_module)
              unless node_module.dependant_modules.include?(dependant_module) || node_module.dependant_modules << dependant_module
                flash['danger'] ||= I18n.t('flash.node_templates.import.danger_node_module_dependencies') #'Error loading Node Module Dependency'
              end
            end
          end
        end
      end
    end
    flash['success'] = I18n.t('flash.node_templates.import.success', node_template: @node_template) if flash['danger'].nil?
    respond_with @node_template ||= NodeTemplate.new
  end

  def index
    @search = @node_templates.search(params[:q])
    @node_templates = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @node_templates
  end

  def show
    respond_with @node_template
  end

  def new
    respond_with @node_template
  end

  def create
    @node_template = NodeTemplate.create(node_template_params.merge({ account_id: @current_account.id }))
    respond_with @node_template
  end

  def update
    @node_template.update_attributes(node_template_params)
    respond_with @node_template
  end

  def destroy
    @node_template.destroy
    respond_with @node_template
  end

  def perform_operation
    @action = params[:action]
    @operation = params[:operation]
    sanitized_operation = "#{@action}_#{@operation}".gsub(/\W/, '').downcase
    self.send(sanitized_operation) if self.respond_to?(sanitized_operation)
  end

  def update_platform_items
    if (node_platform =  NodePlatform.find_by(id: params[:node_platform_id]))
      @available_node_modules = node_platform.node_modules.accessible_by(@current_ability, :use).subscription_variety
    else
      @available_node_modules = []
    end
  end

  private

  def load_objects
    @available_node_modules = @node_template.try(:node_platform) ? @node_template.node_platform.node_modules.accessible_by(@current_ability, :use).subscription_variety : []
    @available_node_platforms = NodePlatform.accessible_by(@current_ability, :use)
  end

  def node_architecture_params(attributes)
    attributes.require(:node_architecture).permit! if can?(:manage, NodeArchitecture)
  end

  def node_platform_params(attributes)
    attributes.require(:node_platform).permit! if can?(:manage, NodePlatform)
  end

  def node_module_params(attributes)
    attributes.require(:node_module).permit! if can?(:manage, NodeModule)
  end

  def node_module_category_params(attributes)
    attributes.require(:node_module_category).permit! if can?(:manage, NodeModuleCategory)
  end

  def node_module_dependency_params(attributes)
    attributes.require(:node_module_dependency).permit! if can?(:manage, NodeModule)
  end

  def node_template_params(attributes = params)
    permitted_params = [{ node_module_ids: [],
                          pages_attributes: [:id,
                                             :name,
                                             :title,
                                             :_destroy] },
                        :admin_user,
                        :description,
                        :enabled,
                        :name,
                        :node_platform_id]
    permitted_params += [:public] if can?(:publish, NodeTemplate)
    if can?(:manage, NodeTemplate)
      attributes.require(:node_template).permit!
    else
      attributes.require(:node_template).permit(*permitted_params)
    end
  end

end
