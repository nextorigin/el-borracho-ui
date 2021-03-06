Spine    = require "spine"
Maquette = require "maquette"


class QueuesController extends Spine.Controller
  logPrefix: "(ElBorracho:Queues)"

  constructor: ({baseUrl}) ->
    @log "constructing"

    super

    @Store = require "../models/queue"
    @view  = require "../views/stats"

    @Store.baseUrl = baseUrl
    @projector or= Maquette.createProjector()

    @Store.on "error", @error
    @Store.on "refresh", @projector.scheduleRender
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

  render: =>
    @log "rendering"
    queues = @Store.all()

    totals = {}
    for queue in queues
      for state, total of queue.attributes() when state not in ["name", "id"]
        totals[state] ?= 0
        totals[state] += total

    totals = {active: "...", wait: "...", completed: "...", delayed: "...", failed: "...", stuck: "..."} unless Object.keys(totals).length
    @view {totals}

  updateEvery15Seconds: ->
    @_updateTimer = setInterval (=> @Store.fetch()), 15 * 1000
    @Store.fetch()

  pause: ->
    @log "pausing"
    clearInterval @_updateTimer if @_updateTimer?

  error: (args...) => @trigger "error", args...


module.exports = QueuesController
