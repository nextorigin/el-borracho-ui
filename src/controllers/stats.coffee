Spine    = require "spine"
Maquette = require "maquette"


class StatsController extends Spine.Controller
  logPrefix: "(ElBorracho:Stats)"

  showStatsAndStats: ->
    return @show() unless @el.hasClass "show"
    @hide()

  events:
    "click .downarrow":              "showStatsAndStats"

  constructor: ({baseUrl}) ->
    @log "constructing"

    super

  show: ->
    @el.addClass "show"
    @trigger "show"

  hide: ->
    @el.removeClass "show"
    @trigger "hide"

  error: (args...) => @trigger "error", args...


module.exports = StatsController
