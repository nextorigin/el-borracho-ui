Spine    = require "spine"
Maquette = require "maquette"
Mapper   = require "./mapper"


class DialogBox extends Spine.Controller
  logPrefix: "(ElBorracho:DialogBox)"

  cancel: (e) ->
    $dialog = ($ e.target).closest ".dialog"
    {id}    = $dialog.data()
    record  = @Store.find id
    record.destroy()

  preventBubble: (e) ->
    e.stopPropagation()

  events:
    "click .cancel":         "cancel"
    "click":                 "preventBubble"

  constructor: -> # implied ({@message})
    super

    @Store       = require "../models/dialog"
    @view        = require "../views/dialog-box"
    @dialogView  = require "../views/dialog"

    @projector or= Maquette.createProjector()
    @dialogMap   = new Mapper [], @dialogView

    @Store.on "error", @error
    @Store.on "change", @projector.scheduleRender

    @projector.append @el[0], @render
    @projector.scheduleRender()

  render: =>
    @log "rendering"
    dialogs = @Store.all()

    @dialogMap.update dialogs
    @view {dialogs: @dialogMap.components}

  add: (message) ->
    record = new @Store {message}
    record.save()

  error: (args...) => @trigger "error", args...


module.exports = DialogBox
