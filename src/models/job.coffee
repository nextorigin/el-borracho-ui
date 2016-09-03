Spine  = require "spine"
errify = require "errify"
Queue  = require "./queue"
Filter = require "./filter"
{Ajax} = Spine


class Job extends Spine.Model
  @configure "Job",
    "queue",
    "q_id",
    "state",
    "data",
    "progress",
    "stacktrace",
    "attempts",
    "attemptsMade",
    "timestamp",
    "date",
    "delay"

  @filters:
    queues: []
    states: []
    data:   []
    ids:    []

  @updateFilters: =>
    queues          = Filter.queues()
    @filters.queues = queueFilters?.length and queueFilters or Queue.names()
    @filters.states = Filter.states()
    @filters.ids    = Filter.ids()
    @filters.data   = Filter.data()

  @fetchFiltered: ->
    @trigger "fetchFiltered"
    ideally         = errify @error
    allJobs         = []

    @updateFilters()

    for queue in @filters.queues
      base = "#{@baseUrl}/#{queue}"

      if @filters.ids.length then for id in @filters.ids
        url = "#{base}/#{id}"
        await Ajax.awaitGet {url}, defer err, jobs
        allJobs = allJobs.concat jobs unless err

      else if @filters.states.length then for state in @filters.states
        url = "#{base}/#{state}"
        await Ajax.awaitGet {url}, ideally defer jobs
        allJobs = allJobs.concat jobs

      else
        url = base
        await Ajax.awaitGet {url}, ideally defer jobs
        allJobs = allJobs.concat jobs

    @refresh allJobs, clear: true

  @filterData: (key, value) ->
    matcher = new RegExp value
    @select (record) -> record.data[key]?.toString().match matcher

  @error: (err) => @trigger "error", err

  @stateOrder: [
    "active"
    "wait"
    "completed"
    "delayed"
    "failed"
    "stuck"
  ]

  @byId = (a, b) ->
    if      a.q_id > b.q_id then 1
    else if a.q_id < b.q_id then -1
    else                     0

  @byVal: (a, aVal, b, bVal) ->
    # throw new Error if a.id.toString() is "2783"
    if aVal is bVal then @byId a, b
    else
      if      aVal > bVal then 1
      else if aVal < bVal then -1

  @comparator: (a, b) =>
    queues = @filters.queues.length and @filters.queues
    states = @filters.states.length and @filters.states

    if states
      aState = @stateOrder.indexOf a.state
      bState = @stateOrder.indexOf b.state
      @byVal a, aState, b, bState
    else if queues
      aQueue = queues.indexOf a.queue
      bQueue = queues.indexOf b.queue
      @byVal a, aQueue, b, bQueue
    else 0

  constructor: (attributes) ->
    attributes.q_id = attributes.id
    attributes.id   = "#{attributes.queue}-#{attributes.id}"
    attributes.progress     ?= 0
    attributes.attempts     ?= "?"
    attributes.attemptsMade ?= "?"
    super attributes

  timestamp: (timestamp) ->
    @date = new Date timestamp

  dataFormattedForDisplay: =>
    ("#{key}: #{value}" for key, value of @data).join ", "

  destroy: (callback) ->
    ideally   = errify callback
    {baseUrl} = @constructor
    url       = "#{baseUrl}/#{@queue}/#{@q_id}"
    data      = _method: "delete"
    await Ajax.awaitPost {url, data}, ideally defer()
    super
    callback()

  promote: (callback) ->
    ideally   = errify callback
    {baseUrl} = @constructor
    url       = "#{baseUrl}/#{@queue}/#{@q_id}/pending"
    await Ajax.awaitGet {url}, ideally defer()
    callback()


module.exports = Job
