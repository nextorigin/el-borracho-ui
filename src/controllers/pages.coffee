Spine    = require "spine"
Maquette = require "maquette"


class PagesController extends Spine.Controller
  logPrefix: "(ElBorracho:Pages)"

  previous: (e) ->
    page = @Store.first()
    page.current-- if page.current > 0
    page.save()

  next: (e) ->
    page = @Store.first()
    page.current++ if page.current < page.max
    page.save()

  goToPage: (e) ->
    page = @Store.first()
    page.current = Number ($ e.target).text()
    page.save()

  events:
    "click .previous":          "previous"
    "click .next":              "next"
    "click .numbers a":         "goToPage"

  constructor: ({baseUrl}) ->
    @log "constructing"

    super

    @Store      = require "../models/page"
    @view       = require "../views/pages"

    @Store.setup()
    @projector or= Maquette.createProjector()

    @Store.on "error", @error
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

  render: =>
    @log "rendering"
    page = @Store.first()
    @view {page}

  error: (args...) => @trigger "error", args...


module.exports = PagesController
