require 'action_view'
require 'active_record'
require 'active_support/time_with_zone'

module FoundationFormBuilder
  class Rails < ActionView::Helpers::FormBuilder

    # Renders a form field with label wrapped in an appropriate +<div>+, with another +<div>+ for errors if necessary.
    #
    # @param field_name [String, Symbol] Name of the field to render
    # @param label [String, Symbol] Override text for the +<label>+ element
    # @param type [Symbol] Override type of field to render.
    #   Known values are +:date+, +:email+, +:password+, +:select+, +:textarea+, and +:time_zone+. Anything else is rendered as a text field.
    # @param values [Array] Name-value pairs for +<option>+ elements. Only meaningful with +type:+ +:select+.
    # @param field [Hash] Options to pass through to the underlying Rails form helper. For +type:+ +:time_zone+, +:priority_zones+ is also understood.
    # @return [SafeBuffer] The rendered HTML
    def input_div(field_name, label: nil, type: nil, values: nil, field: {})
      raise ArgumentError, ':values is only meaningful with type: :select' if values && type != :select
      @template.content_tag :div, class: classes_for(field_name) do
        [
          label(field_name, label),
          input_for(field_name, type, field, values: values),
          errors_for(field_name)
        ].compact.join("\n").html_safe
      end
    end

    private

    def classes_for(field_name)
      [field_name, error_class(field_name)]
    end

    def error_class(field_name)
      errors[field_name].present? ? :error : nil
    end

    # Renders a +<span>+ with errors if there are any for the specified field, or returns +nil+ if not.
    #
    # @param field_name [String, Symbol] Name of the field to check for errors
    # @return [SafeBuffer, nil] The rendered HTML or nil
    def errors_for(field_name)
      error_messages = errors[field_name]
      if error_messages.present?
        @template.content_tag :span, class: :error do
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
          numeric: :number_field,
          password: :password_field,
          textarea: :text_area,
        }

        field_method = method_mappings[type] || :text_field

        self.send field_method, field_name, field_options
      end
    end

    # Infers the type of field to render based on the field name.
    #
    # @param [String, Symbol] the name of the field
    # @return [Symbol] the inferred type
    def infer_type(field_name)
      case field_name
      when :email, :time_zone
        field_name
      when %r{(\b|_)password(\b|_)}
        :password
      else
        type_mappings = {text: :textarea}

        db_type = @object.column_for_attribute(field_name).type
        case db_type
        when :text
          :textarea
        when :decimal, :integer, :float
          :numeric
        else
          db_type
        end
      end
    end
  end
end
