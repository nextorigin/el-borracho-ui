Spine    = require "spine"
Maquette = require "maquette"
Mapper   = require "./mapper"


class FiltersController extends Spine.Controller
  logPrefix: "(ElBorracho:Filters)"

  showAddFilters: ->
    ($ ".add.filters").add(".addfilters-mask").fadeIn 200

  hideAddFilters: ->
    ($ ".add.filters").add(".addfilters-mask").fadeOut 200

  add: (e) ->
    {type, value} = ($ e.target).data()
    record        = new @Store {type, value}
    record.save()

  delete: (e) ->
    {id} = ($ e.target).data()
    record = @Store.find id
    record.destroy()

  events:
    "tap .current.filters .add":        "showAddFilters"
    "tap .addfilters-mask":             "hideAddFilters"
    "tap .add.filters .filter":         "add"
    "tap .current.filters .delete":     "delete"

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
