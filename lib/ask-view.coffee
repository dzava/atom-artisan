{View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class AskView extends View
  @content: ->
    @div class: 'ask-view', =>
      @div class: 'block', =>
        @label =>
          @div class: 'settings-name', 'Name'
        @subview 'command', new TextEditorView(mini: true)

  initialize: (@callback) ->
    atom.commands.add @element,
      'core:confirm': @accept
      'core:cancel': @cancel

    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @command.focus()

  accept: (event) =>
    if (c = @command.getText()) isnt ''
      @callback c

    @panel?.hide()
    event.stopPropagation()
    @dispose()

  cancel: (event) =>
    @panel?.hide()
    event.stopPropagation()
    @dispose()

  dispose: ->
    @panel.destroy()
