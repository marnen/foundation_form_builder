require 'spec_helper'

describe FoundationFormBuilder, type: :view do
  let(:view) { ActionView::Base.new }
  let(:object_name) { Faker::Lorem.words(rand 1..3).join('_') }
  let(:object) { double(object_name.camelize).as_null_object }
  subject(:builder) { FoundationFormBuilder.new object_name, object, view, {} }

  it { should be_a_kind_of ActionView::Helpers::FormBuilder }

  describe '#input_div' do
    let(:field_name) { Faker::Lorem.words(rand 1..3).join('_').to_sym }
    let(:input_id) { [object_name, field_name].join '_' }
    let(:input_name) { "#{object_name}[#{field_name}]" }
    let(:wrapper) { "div.#{field_name}" }
    let(:options) { {} }
    subject(:input_div) { builder.input_div field_name, options }

    it { should be_html_safe }

    it 'wraps the whole thing in a div with a class named for the field' do
      expect(input_div).to have_tag wrapper, count: 1
    end

    describe 'errors' do
      context 'nil' do
        it 'does not render an error element' do
          expect(input_div).not_to have_tag "#{wrapper} .error"
        end
      end

      context 'present' do
        RSpec::Matchers.define :indifferent do |field_name|
          match {|actual| actual.to_s == field_name.to_s }
        end

        let(:error_messages) { Faker::Lorem.sentences(3) }
        let(:errors) { instance_double ActiveModel::Errors }

        before(:each) do
          allow(errors).to receive(:[]).with(indifferent field_name).and_return error_messages
          allow(object).to receive(:errors).and_return errors
        end

        it 'renders an error element' do
          expect(input_div).to have_tag "#{wrapper} .error", text: %r{#{error_messages.join '.*'}}m
        end
      end
    end

    describe 'field options' do
      let(:key) { Faker::Lorem.words(1).first.to_s }
      let(:value) { Faker::Lorem.sentence }
      let(:options) { {field: {key => value}} }

      it 'passes options through to the field' do
        expect(input_div).to have_tag "#{wrapper} input##{input_id}[#{key}='#{value}']"
      end
    end

    describe 'label' do
      context 'label text specified' do
        let(:label_text) { Faker::Lorem.sentence }
        let(:options) { {label: label_text} }

        it 'uses the specified text for the label' do
          expect(input_div).to have_tag "#{wrapper} label[for='#{input_id}']", text: label_text
        end
      end

      context 'otherwise' do
        it 'uses the humanized field name as the label text' do
          expect(input_div).to have_tag "#{wrapper} label[for='#{input_id}']", text: field_name.to_s.humanize
        end
      end
    end

    describe 'values' do
      context 'not a select' do
        let(:options) { {values: []} }

        it 'raises an error if supplied' do
          expect { input_div }.to raise_error ArgumentError
        end
      end

      context 'explicit select' do
        let(:values) { (1..3).collect { [Faker::Lorem.sentence, rand(100)] } }
        let(:options) { {type: :select, values: values} }

        it 'passes the values to the select' do
          expect(input_div).to have_tag "#{wrapper} select##{input_id}" do
            values.each do |value|
              name, id = value
              with_tag "option[value='#{id}']", text: name
            end
          end
        end
      end
    end

    describe 'field type' do
      context 'specified' do
        context ':textarea' do
          let(:options) { {type: :textarea} }

          it 'renders a text area' do
            expect(input_div).to have_tag "#{wrapper} textarea##{input_id}"
          end
        end
      end

      context 'inferred' do
        let(:column) { instance_double ActiveRecord::ConnectionAdapters::Column }

        before(:each) do
          allow(column).to receive(:type).and_return type
          allow(object).to receive(:column_for_attribute).with(field_name).and_return column
        end

        context 'date' do
          let(:type) { :date }

          it 'renders a date field' do
            expect(input_div).to have_tag "#{wrapper} input##{input_id}[type='date']"
          end
        end

        context 'string' do
          let(:type) { :string }

          context 'field name is "email"' do
            let(:field_name) { :email }

            it 'renders an email field' do
              expect(input_div).to have_tag "#{wrapper} input##{input_id}[type='email']"
            end
          end

          context 'field name contains "password"' do
            let(:field_name) { :"#{Faker::Lorem.words(1).first}_password_#{Faker::Lorem.words(1).first}" }

            it 'renders a password field' do
              expect(input_div).to have_tag "#{wrapper} input##{input_id}[type='password']"
            end
          end

          context 'field name is "time_zone"' do
            let(:field_name) { :time_zone }

            it 'renders a time zone selector' do
              expect(input_div).to have_tag "#{wrapper} select##{input_id}" do
                ActiveSupport::TimeZone.all.each do |zone|
                  with_tag %Q{option[value="#{zone.name}"]}, text: zone
                end
              end
            end
          end

          context 'otherwise' do
            it 'renders a text field' do
              expect(input_div).to have_tag "#{wrapper} input##{input_id}[type='text']"
            end
          end
        end

        context 'text' do
          let(:type) { :text }

          it 'renders a text area' do
            expect(input_div).to have_tag "#{wrapper} textarea##{input_id}"
          end
        end
      end
    end
  end
end