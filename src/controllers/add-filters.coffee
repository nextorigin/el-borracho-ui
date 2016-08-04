Spine    = require "spine"
Maquette = require "maquette"
Mapper   = require "./mapper"


class AddFiltersController extends Spine.Controller
  logPrefix: "(ElBorracho:AddFilters)"

  showAddFilters: =>
    @el.add @showadd
       .add @addFiltersMask
       .addClass "show"

  hideAddFilters: =>
    @el.add @showadd
       .add @addFiltersMask
       .removeClass "show"

  add: (e) ->
    {type, value} = (($ e.target).closest ".filter").data()
    record        = new @Filter {type, value}
    record.save()
    @hideAddFilters()

  events:
    "click .filter":                      "add"

  constructor: ({baseUrl}) ->
    @log "constructing"

    super

    @Store      = require "../models/default-filter"
    @Filter     = require "../models/filter"
    @view       = require "../views/filters"
    @filterView = require "../views/filter"

    @projector or= Maquette.createProjector()
    @filterMap   = new Mapper [], @filterView

    @Store.on "error", @error
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

    @showadd = $ ".showadd"
    @showadd.click @showAddFilters
    @addFiltersMask = $ ".addfilters-mask"
    @addFiltersMask.click @hideAddFilters

    @default()

  render: =>
    @log "rendering"
    filters = @Store.all()

    @filterMap.update filters
    @view {filters: @filterMap.components}

  default: ->
    @Store.destroyAll()
    states = "active wait completed delayed failed stuck".split " "
    items  = ({type: "state", value} for value in states)
    items.push type: "data"
    items.push type: "id"
    record.save() for item in items when record = new @Store item
    return


  error: (args...) => @trigger "error", args...


module.exports = AddFiltersController
