Spine    = require "spine"
Maquette = require "maquette"
errify   = require "errify"
Mapper   = require "./mapper"
Editable = require "./editable-filter"


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

    (@el.find ".editable").remove()

  add: (e) ->
    $el           = ($ e.target).closest ".filter"
    {type, value} = $el.data()
    return @addData $el if type is "data"
    return @addId $el   if type is "id"
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
    items.push type: "data", value: ""
    items.push type: "id", value: ""
    record.save() for item in items when record = new @Store item
    return

  addEditable: (type, el) ->
    ideally = errify ->

    await new Editable {el}, ideally defer value
    record = new @Filter {type, value}
    record.save()
    @hideAddFilters()

  addData: ($el) ->
    @addEditable "data", $el

  addId: ($el) ->
    @addEditable "id", $el

  error: (args...) => @trigger "error", args...


module.exports = AddFiltersController
