{View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class AskView extends View
  callback: null
  @content: ->
    @div class: 'ask-view', =>
      @div class: 'block', =>
        @label =>
          @span class: 'settings-name', outlet: 'caption'
        @subview 'command', new TextEditorView(mini: true)

  initialize: ->
    atom.commands.add @element,
      'core:confirm': @accept
      'core:cancel': @cancel

    @panel ?= atom.workspace.addModalPanel(item: this)

  accept: (event) =>
    if (c = @command.getText()) isnt ''
      @callback? c

    @command.setText('')
    event.stopPropagation()
    @hide()

  ask: (caption, @callback) =>
    @caption.text(caption)
    @show()
    @command.focus()

  show: =>
    @panel.show()

  hide: =>
    @panel.hide()

  cancel: (event) =>
    @hide()
    event.stopPropagation()

  dispose: ->
    @panel.destroy()
