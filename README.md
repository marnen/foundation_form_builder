# FoundationFormBuilder

## What is this gem for?

[Foundation](http://foundation.zurb.com) is an excellent CSS framework, and provides some [lovely components](http://foundation.zurb.com/docs/components/forms.html) for working with forms. Unfortunately, using them with Rails can be a bit of a hassle, as Foundation wants each form input to be wrapped in a `<div>`, with another `<div>` for errors.

In addition, I wanted to use something like [Formtastic](http://github.com/justinfrench/formtastic) to DRY up my form field markup, but writing new renderers for Formtastic is non-trivial, and I wanted something a bit simpler anyway, so I rolled my own.

This gem is a work in progress. I welcome bug reports and pull requests! It's only tested on Rails 4.2 and Ruby 2.2 so far, but I'd love to support older versions of both Rails and Ruby if it's not too difficult to do so.

## Sounds great! How do I use it?

Install the gem, then put the following in your `application.rb` file:
```ruby
config.action_view.default_form_builder = FoundationFormBuilder
```
This tells Rails to use the gem for all forms. If you don't want to do that, then specify it for the particular form you'd like to use it on.

### Simple usage

```ruby
form_for @user do |f|
  f.input_div :email
end
```
will create something like
```html
<form action='users/1' and='all the other standard Rails attributes :)'>
  <div class='email'>
    <label for='user_email'>Email</label>
    <input type='email' id='user_email' name='user[email]' />
    <!-- if there are validation errors, also the following: -->
    <div class='error'>can't be blank</div>
  </div>
</form>
```

Note that `FoundationFormBuilder` uses the Rails form helper functions to render the fields, and that it is somewhat smart in its choice of helpers. It uses `email_field` automatically if the name of the field is `email`; similarly, it uses `password_field` for any field whose name *contains* `password`. If the name of the field is `time_zone`, it renders a Rails `time_zone_select`. If the field corresponds to a `text` column in the database, it calls `text_area`; for a `date` column, it uses `date_field`. Otherwise, a plain `text_field` is used.


Since `FoundationFormBuilder` is a subclass of the standard Rails `ActionView::Helpers::FormBuilder`, all the usual Rails `FormBuilder` helpers are also available. You'll probably need to use `f.submit` at least; we're not doing anything special with submit buttons at the moment.

### Advanced usage

`input_div` takes several options if you want to override its defaults. `:label` overrides the label text, while `:type` overrides the inferred type (known values are `:date`, `:email`, `:password`, `:select`, `:textarea`, and `:time_zone`; anything else is understood as a text field). `:field` takes a hash of options which are passed through to the underlying Rails form helper.

If `type: :select` is specified, then the values for the `select`options must be specified in `:values`, like this:

```ruby
f.input_div :size, label: 'My size is:', type: :select, values: [['Small', 1], ['Large', 2]], field: {prompt: 'Choose a size'}
```

which produces:
```html
<div class='size'>
  <label for='product_size'>My size is:</label>
  <select name='product[size]' id='product_size'>
    <option>Choose a size</option>
    <option value='1'>Small</option>
    <option value='2'>Large</option>
  </select>
  <!-- error div if necessary, as above -->
</div>
```
