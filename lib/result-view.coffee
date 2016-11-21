{$, View} = require 'atom-space-pen-views'

module.exports =
class ResultView extends View
  @content: ->
    @div class: 'inset-panel panel-bottom native-key-bindings artisan result-view', tabindex: -1, =>
      @div class: 'panel-heading', =>
        @span outlet: 'header'
        @span class: 'artisan-close-icon', outlet: 'closeIcon'
      @div class: 'panel-body padded results', outlet: 'resultsContainer', =>
        @pre '', outlet: 'result'
      @div class: 'artisan-resize-handle', outlet: 'resizeHandle'

  initialize: () ->
    @on 'mousedown', '.artisan-resize-handle', (e) => @onResizeStart(e)
    @closeIcon.on('click', (e) => @close())
    @panel = atom.workspace.addBottomPanel(item: this)
    @height('40vh')

  update: (content, heading) ->
    @result.text(content) if content
    @header.text(heading) if heading

    return this

  onResizeStart: (e) =>
    $(document).on('mousemove', @resize)
    $(document).on('mouseup', @onResizeStop)
    e.preventDefault()

  onResizeStop: (e) =>
    $(document).off('mousemove', @resize)
    $(document).off('mouseup', @onResizeStop)
    e.preventDefault()

  resize: ({pageY, which}) =>
    return @onResizeStop() unless which is 1
    height = @outerHeight() + @offset().top - pageY
    @height(height)

  show: =>
    @panel.show()

  close: =>
    @panel.hide()

  dispose: =>
    @panel?.destroy()
