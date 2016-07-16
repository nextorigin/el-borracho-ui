Spine    = require "spine"
Maquette = require "maquette"


class QueuesController extends Spine.Controller
  logPrefix: "(ElBorracho:Queues)"

  events:
    "tap .teaser .downarrow":              "showStatsAndStats"

  constructor: ({baseUrl}) ->
    @debug "constructing"

    super

    @Store = require "../models/queue"
    @view  = require "../views/stats"

    @Store.baseUrl = baseUrl
    @projector or= Maquette.createProjector()

    @Store.on "error", ->
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

    @updateEvery15Seconds()

  render: =>
    @debug "rendering"
    queues = @Store.all()

    totals = {}
    for queue in queues
      for state, total of queue.attributes() when state not in ["name", "id"]
        totals[state] ?= 0
        totals[state] += total

    @view totals

  updateEvery15Seconds: ->
    @_updateTimer = setInterval (=> @Store.fetch()), 15 * 1000
    @Store.fetch()

  pause: ->
    @debug "pausing"
    clearInterval @_updateTimer if @_updateTimer?


module.exports = QueuesController
