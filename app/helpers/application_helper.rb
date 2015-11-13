module ApplicationHelper
  def bootstrap_class_for flash_type
    { success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info' }[flash_type.to_sym] || flash_type.to_s
  end

  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, precision: 0) : number_to_currency(discount.amount)) + ' off'
  end

  def glyph(name, classes = '')
    content_tag :i, nil, class: "glyphicon glyphicon-#{name} #{classes}"
  end

  def fa(name, classes = '')
    content_tag :i, nil, class: "fa fa-#{name} #{classes}"
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} dismissable") do
        concat content_tag(:button, 'x', class: 'close', data: { dismiss: 'alert' })
        concat content_tag(:h4, msg_type.titleize)
        concat message
      end)
    end
    nil
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
    link_to(name, '#', class: 'add_fields', data: { id: id, fields: fields.gsub('\n', '') })
  end

  def render_markdown(content)
    Kramdown::Document.new(content).to_html
  end
end
