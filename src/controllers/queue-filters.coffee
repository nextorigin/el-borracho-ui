Spine    = require "spine"
Maquette = require "maquette"


class QueueFiltersController extends Spine.Controller
  logPrefix: "(ElBorracho:QueueFilters)"

  constructor: ->
    @debug "constructing"

    super

    @Store      = require "../models/queue"
    @view       = require "../views/filters"
    @filterView = require "../views/filter"

    @projector or= Maquette.createProjector()
    @filterMap   = new Mapper [], @filterView

    @Store.on "error", ->
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

    @default()

  render: =>
    @debug "rendering"
    queues  = @Queue.names()
    filters = ({type: "queue", value} for value in queues)

    @filterMap.update filters
    @view {filters: @filterMap.components}


module.exports = QueueFiltersController
