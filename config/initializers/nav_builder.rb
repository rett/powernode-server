class NavBuilder < Navigasmic::Builder::ListBuilder

  attr_accessor :icon

  def item(label, *args, &block)
    @icon = args.last[:icon]
    super
  end

  private

  def label_for(label, link, is_nested = false, options = {})
    label = @context.instance_exec(label, options, !!link, is_nested, &@config.label_generator).html_safe if label.present?
    label = content_tag(:i, '', class: "fa fa-#{@icon}") + label if @icon.present?
    label = @context.instance_exec(label, link, options.delete(:link_html) || {}, is_nested, &@config.link_generator).html_safe if link.present?
    label
  end
end
