Spine    = require "spine"
Maquette = require "maquette"
Mapper   = require "./mapper"


class QueueFiltersController extends Spine.Controller
  logPrefix: "(ElBorracho:QueueFilters)"

  constructor: ->
    @log "constructing"

    super

    @Store      = require "../models/queue"
    @view       = require "../views/filters"
    @filterView = require "../views/filter"

    @projector or= Maquette.createProjector()
    @filterMap   = new Mapper [], @filterView

    @Store.on "error", @error
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

  render: =>
    @log "rendering"
    queues  = @Store.names()
    filters = ({type: "queue", id: "queue-#{value}", value} for value in queues)

    @filterMap.update filters
    @view {filters: @filterMap.components}

  error: (args...) => @trigger "error", args...


module.exports = QueueFiltersController
