Spine    = require "spine"
Maquette = require "maquette"
Mapper   = require "./mapper"


class AddFiltersController extends Spine.Controller
  logPrefix: "(ElBorracho:AddFilters)"

  showAddFilters: =>
    height = @el.get(0).scrollHeight + 100
    width  = 241
    top    = 35
    @el.css {height: 0, width: 0, top: 60, backgroundColor: "black"}
    @el.animate {width, speed: 180}
       .animate {height, top, speed: 300, backgroundColor: "white"}
    @addFiltersMask.fadeIn 200

  hideAddFilters: =>
    @el.animate height: 0, top: 61, speed: 300, backgroundColor: "black"
       .animate width: 0, speed: 180
    @addFiltersMask.fadeOut 500

  add: (e) ->
    {type, value} = (($ e.target).closest ".filter").data()
    record        = new @Filter {type, value}
    record.save()
    @hideAddFilters()

  events:
    "click .showadd":                     "showAddFilters"
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
