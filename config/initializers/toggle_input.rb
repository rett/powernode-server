class ToggleInput < Formtastic::Inputs::BooleanInput
  def to_html
    input_wrapping do
      hidden_field_html << label_with_checkbox << check_box_html
    end
  end

  def label_with_checkbox
    builder.label(method, label_text, label_html_options)
  end

  def label_html_options
    prev = super
    input_html_options.merge(prev.merge(:class => 'label', :for  => input_html_options[:id]))
  end
end
