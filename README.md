[![Build Status](https://travis-ci.org/marnen/foundation_form_builder.svg)](https://travis-ci.org/marnen/foundation_form_builder)
[![Code Climate](https://codeclimate.com/github/marnen/foundation_form_builder/badges/gpa.svg)](https://codeclimate.com/github/marnen/foundation_form_builder)
[![Test Coverage](https://codeclimate.com/github/marnen/foundation_form_builder/badges/coverage.svg)](https://codeclimate.com/github/marnen/foundation_form_builder)

# FoundationFormBuilder

## What is this gem for?

[Foundation](http://foundation.zurb.com) is an excellent CSS framework, and provides some [lovely components](http://foundation.zurb.com/docs/components/forms.html) for working with forms. Unfortunately, using them with Rails can be a bit of a hassle, as Foundation wants each form input to be wrapped in a `<div>`, with another `<div>` for errors.

In addition, I wanted to use something like [Formtastic](http://github.com/justinfrench/formtastic) to DRY up my form field markup, but writing new renderers for Formtastic is non-trivial, and I wanted something a bit simpler anyway, so I rolled my own. If you want to build pretty forms with a simple `FormBuilder` interface and all the Foundation goodness, this gem is for you!

FoundationFormBuilder is a work in progress. I welcome bug reports and pull requests! It's only tested on Rails 4.2 and Ruby 2.2 so far, but I'd love to support older versions of both Rails and Ruby if it's not too difficult to do so.

## Sounds great! How do I use it?

Install the gem in the usual way:
```ruby
gem 'foundation_form_builder'
```
Then put the following in your `application.rb` file:
```ruby
config.action_view.default_form_builder = FoundationFormBuilder::Rails
```
This tells Rails to use `FoundationFormBuilder::Rails` for all forms. If you don't want to do that, then specify it for the particular form you'd like to use it on.

### Simple usage

```ruby
form_for @user do |f|
  f.input_div :email
end
```
will create something like
```html
<form action='users/1' and='all the other standard Rails attributes :)'>
  <div class='email'> <!-- adds class 'error' too if there are validation errors -->
    <label for='user_email'>Email</label>
    <input type='email' id='user_email' name='user[email]' />
    <!-- if there are validation errors, also the following: -->
    <span class='error'>can't be blank</div>
  </div>
</form>
```

Note that `FoundationFormBuilder::Rails` uses the Rails form helper functions to render the fields, and that it tries to infer the most appropriate form helper type, as follows.

| Condition                               | Default form helper |
| ----                                    | ----                |
| Field name is `email`                   | `email_field`       |
| Field name is `time_zone`               | `time_zone_select`  |
| Field name contains the word `password` | `password_field`    |
| Field maps to numeric column in DB      | `number_field`      |
| Field maps to `date` column in DB       | `date_field`        |
| Field maps to `text` column in DB       | `text_area`         |
| Otherwise                               | `text_field`        |

Since `FoundationFormBuilder::Rails` is a subclass of the standard Rails `ActionView::Helpers::FormBuilder`, all the usual Rails `FormBuilder` helpers are also available. You'll probably need to use `f.submit` at least; we're not doing anything special with submit buttons at the moment.

### Advanced usage

`input_div` takes several options if you want to override its defaults.

| Option    | Value                                                                                                                                                                                                                  |
| ------    | ------                                                                                                                                                                                                                 |
| `:field`  | Hash of options to pass through to the underlying Rails form helper                                                                                                                                                    |
| `:label`  | Text for label                                                                                                                                                                                                         |
| `:type`   | Explicit form helper type; overrides inferred types (see above). Significant values are `:date`, `:email`, `:numeric`, `:password`, `:select`, `:textarea`, and `:time_zone`; `:text` or anything else will generate a text field. |
| `:values` | Values for `<option>` elements; only meaningful with `type: :select`.                                                                                                                                                  |

The following example shows all of these options in use.

```ruby
f.input_div :size, label: 'My size is:', type: :select, values: [['Small', 1], ['Large', 2]], field: {prompt: 'Choose a size'}
```

It renders as:
```html
<div class='size'> <!-- and class 'error' if necessary -->
  <label for='product_size'>My size is:</label>
  <select name='product[size]' id='product_size'>
    <option>Choose a size</option>
    <option value='1'>Small</option>
    <option value='2'>Large</option>
  </select>
  <!-- error span if necessary, as above -->
</div>
```
