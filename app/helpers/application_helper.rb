module ApplicationHelper
  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, precision: 0) : number_to_currency(discount.amount)) + ' off'
  end

  def glyph(name, classes = '')
    content_tag :i, nil, class: "glyphicon glyphicon-#{name} #{classes}"
  end

  def fa(name, classes = '')
    content_tag :i, nil, class: "fa fa-#{name} #{classes}"
  end

  def flash_icon(type)
    { danger:   'fa fa-ban',
      info:     'fa fa-info',
      success:  'fa fa-check',
      warning:  'fa fa-warning'}[type.to_sym] || type.to_s
  end

  def flash_notification
    if (message = flash[:danger] || flash[:danger] || flash[:info] || flash[:success])
      alert_type = flash.keys[0].to_s
      javascript_tag %Q{$.notify({icon:"#{flash_icon(alert_type)}", title:"<strong>#{I18n.t("flash.headers.#{alert_type}")}</strong>", message:"<p>#{message}</p>"}, {mouse_over:"pause", newest_on_top:true, type:"#{alert_type}"});}
    end
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
