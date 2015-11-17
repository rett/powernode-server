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

  def flash_messages
    messages = ''
    if flash['notice'].present?
      flash['success'] = flash['notice']
      flash.delete('notice')
    end
    if flash['alert'].present?
      flash['danger'] = flash['alert']
      flash.delete('alert')
    end
    flash.discard.each do |type, message|
      messages << %Q{$.notify({icon:"#{flash_icon(type)}", title:"<strong>#{I18n.t("flash.headers.#{type}")}</strong>", message:"<p>#{message}</p>"}, {mouse_over:"pause", newest_on_top:true, placement: {from: "top", align: "left"}, type:"#{type}"});}
    end
    messages.html_safe
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
