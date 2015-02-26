require 'action_view'
require 'active_record'
require 'active_support/time_with_zone'

class FoundationFormBuilder < ActionView::Helpers::FormBuilder
  def input_div(field_name, label: nil, type: nil, values: nil, field: {})
    raise ArgumentError, ':values is only meaningful with type: :select' if values && type != :select
    @template.content_tag :div, class: field_name do
      [
        label(field_name, label),
        input_for(field_name, type, field, values: values),
        error_div(field_name)
      ].compact.join("\n").html_safe
    end
  end

  private

  def error_div(field_name)
    error_messages = errors[field_name]
    if error_messages.present?
      @template.content_tag :div, class: :error do
        error_messages.join(@template.tag :br).html_safe
      end
    else
      nil
    end
  end

  def errors
    @errors ||= @object.errors
  end

  def input_for(field_name, type, field_options, values: nil)
    type ||= infer_type field_name

    case type
    when :select
      select field_name, values, field_options
    when :time_zone
      priority_zones = field_options.delete(:priority_zones)
      time_zone_select field_name, priority_zones, field_options
    else
      method_mappings = {
        date: :date_field,
        email: :email_field,
        password: :password_field,
        textarea: :text_area,
      }

      field_method = method_mappings[type] || :text_field

      self.send field_method, field_name, field_options
    end
  end

  def infer_type(field_name)
    case field_name
    when :email, :time_zone
      field_name
    when %r{(\b|_)password(\b|_)}
      :password
    else
      type_mappings = {text: :textarea}

      db_type = @object.column_for_attribute(field_name).type
      type_mappings[db_type] || db_type
    end
  end
end