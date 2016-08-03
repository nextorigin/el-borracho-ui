Spine    = require "spine"
Maquette = require "maquette"
Mapper   = require "./mapper"


class FiltersController extends Spine.Controller
  logPrefix: "(ElBorracho:Filters)"

  delete: (e) ->
    {id} = (($ e.target).closest ".filter").data()
    record = @Store.find id
    record.destroy()

  events:
    "click .filter .delete":          "delete"

  constructor: ({baseUrl}) ->
    @log "constructing"

    super

    @Store      = require "../models/filter"
    @view       = require "../views/filters"
    @filterView = require "../views/filter"

    @projector or= Maquette.createProjector()
    @filterMap   = new Mapper [], @filterView

    @Store.on "error", @error
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

    @default()

  render: =>
    @log "rendering"
    filters = @Store.all()

    @filterMap.update filters
    @view {filters: @filterMap.components}

  default: ->
    @Store.destroyAll()
    active = new @Store type: "state", value: "active"
    wait   = new @Store type: "state", value: "wait"
    active.save()
    wait.save()

  error: (args...) => @trigger "error", args...


module.exports = FiltersController
