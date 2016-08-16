Spine    = require "spine"
Maquette = require "maquette"
Graph    = require "el-borracho-graph/realtime-graph"
History  = require "el-borracho-graph/history-graph"


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

    @graph       = new Graph        {@projector, el: "#realtime", baseUrl: ""}
    @history     = new History      {@projector, el: "#history", baseUrl: "/stats"}

    @graph.on       "error", @error
    @history.on     "error", @error

    @history.Store.fetch()

  show: ->
    @el.addClass "show"
    @graph.start()

  hide: ->
    @el.removeClass "show"
    @graph.stop()

  error: (args...) => @trigger "error", args...


module.exports = StatsController
