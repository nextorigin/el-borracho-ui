Spine    = require "spine"


ENTER = 13
ESC   = 27


class EditableFilter extends Spine.Controller
  cancel: ->
    @destroy()
    @callback new Error "canceled"

  save: ->
    @destroy()
    @callback null, @input.val()

  preventBubble: (e) ->
    e.stopPropagation()

  kbSaveOrCancel: (e) ->
    switch e.which
      when ENTER then @save()
      when ESC   then @cancel()

  events:
    "click .cancel":         "cancel"
    "click .ok":             "save"
    "click":                 "preventBubble"
    "keydown input":         "kbSaveOrCancel"

  constructor: (options, @callback) ->
    @sibling    = options.el
    options.el  = options.el.clone()
    super options

    @adjustCss()
    @addInput()
    @insertSelf()
    @focus()

  adjustCss: ->
    @el.addClass "editable"

  addInput: ->
    @input = $ '<input type="text" />'
    (@el.find ".value").replaceWith @input

  insertSelf: ->
    @el.insertAfter @sibling

  destroy: ->
    @el.remove()

  focus: ->
    @input.focus()


module.exports = EditableFilter
