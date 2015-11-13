# Bower resources
#= require jquery/dist/jquery
#= require jquery-ui/jquery-ui
#= require jquery-ujs/src/rails
#= require bootstrap
#= require bootstrap-multiselect/dist/js/bootstrap-multiselect
#= require bootstrap-markdown/js/bootstrap-markdown
#= require admin-lte/dist/js/app
#= require admin-lte/plugins/slimScroll/jquery.slimscroll
#= require CodeMirror/lib/codemirror
#= require CodeMirror/mode/shell/shell
#= require moment/moment
#= require eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min
#= require marked/lib/marked

# Project resources
#= require accounts
#= require node_instances
#= require node_module_categories
#= require node_modules
#= require node_templates
#= require nodes
#= require provider_regions
#= require provider_volumes
#= require registrations
#= require users
#= require cocoon
#= require d3
#= require local_time
#= require_self

@AdminLTEOptions =
  controlSidebarOptions: {}

# Codemirror editor
@codemirror_options =
  lineNumbers: true,
  mode: 'shell',
  tabSize: 2,
  viewportMargin: 1000
$(document).bind 'codemirror.init', (e, obj) =>
  $("form .codemirror").each ->
    CodeMirror.fromTextArea(this, codemirror_options)

@nowDate = new Date
@datetimepicker_options =
  format: 'YYYY-MM-DD hh:mm A',
  minDate: new Date(nowDate.getFullYear(), nowDate.getMonth(), nowDate.getDate(), 0, 0, 0, 0),
  sideBySide: true
$(document).bind 'datetimepicker.init', (e, obj) =>
  $('input[type=datetime]').each ->
    $(this).datetimepicker(datetimepicker_options)

# Markdown editor
@markdown_options =
  height: 300,
  resize: 'vertical'
marked.setOptions
  renderer: new (marked.Renderer)
  gfm: true
  tables: true
  breaks: true
  pedantic: false
  sanitize: true
  smartLists: true
  smartypants: true
$(document).bind 'markdown.init', (e, obj) =>
  $('form .markdown').each ->
    $(this).markdown(markdown_options)

# Multiselect form control
@multiselect_options =
  buttonClass: 'form-control',
  enableFiltering: true,
  includeSelectAllOption: true,
  maxHeight: 200
$(document).bind 'multiselect.init', (e, obj) =>
  $('form .multiselect').each ->
    $(this).multiselect('destroy')
    $(this).multiselect(multiselect_options)

# Load javascript
load_javascript = (controller, action) ->
  action = 'edit' if action in ['create', 'new', 'update']
  $.event.trigger("#{controller}.load")
  $.event.trigger("#{action}_#{controller}.load")
  $.event.trigger('codemirror.init')
  $.event.trigger('datetimepicker.init')
  $.event.trigger('markdown.init')
  $.event.trigger('multiselect.init')

# Cocoon after-insert hook
$(document).bind 'cocoon:after-insert', (e, inserted_item) =>
  CodeMirror.fromTextArea(inserted_item.find('.codemirror').get(0), codemirror_options)
  inserted_item.find('.markdown').markdown(markdown_options)
  $.event.trigger('multiselect.init')

# Document ready
$(document)
  # Spin modal refresh button on click
  .on 'click', '.refresh-button', (e) ->
    $(this).addClass('fa-spin')
  .ready ->
    # Load page specific javascript
    load_javascript($('body').data('controller'), $('body').data('action'))
    # Set active menu
    $('ul.treeview-menu li.active').parents('li.treeview').addClass('active')
    # Convert datetime form fields to UTC
    $('form').submit ->
      $('input[type=datetime]').each ->
        input_time = new Date($(this).val())
        utctime = moment(input_time).format()
        if utctime == 'Invalid date'
          $(this).val('')
        else
          $(this).val(utctime)
