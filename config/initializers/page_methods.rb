module PageMethods
  extend ActiveSupport::Concern

  def page
    self.name ? Page.find_by_name(self.slug) : nil
  end

  def slug
    self.name ? "#{self.class.name}_#{self.name.gsub(/[^A-Za-z0-9\s-]/, '').gsub(/\s+/, '_')}" : nil
  end
end

ActiveRecord::Base.send(:include, PageMethods)
