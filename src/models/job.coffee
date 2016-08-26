Spine  = require "spine"
errify = require "errify"
Queue  = require "./queue"
Filter = require "./filter"
{Ajax} = Spine


awaitGet = (options, callback) ->
  await Ajax.awaitGet options, defer status, xhr, statusText, data
  return callback statusText, data, xhr unless status is "success"
  callback null, data, xhr


class Job extends Spine.Model
  @configure "Job",
    "queue",
    "q_id",
    "state",
    "data",
    "progress",
    "stacktrace"

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

  @fetchFiltered: ->
    @trigger "fetchFiltered"
    ideally         = errify @error
    allJobs         = []

    @updateFilters()

    for queue in @filters.queues
      base = "#{@baseUrl}/#{queue}"

      if @filters.ids.length then for id in @filters.ids
        url = "#{base}/#{id}"
        await awaitGet {url}, defer err, jobs
        allJobs = allJobs.concat jobs unless err

      else if @filters.states.length then for state in @filters.states
        url = "#{base}/#{state}"
        await awaitGet {url}, ideally defer jobs
        allJobs = allJobs.concat jobs

      else
        url = base
        await awaitGet {url}, ideally defer jobs
        allJobs = allJobs.concat jobs

    @refresh allJobs, clear: true

  @filterData: (key, value) ->
    @select (record) -> record.data[key].match new RegExp value

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
    super attributes

  dataFormattedForDisplay: =>
    ("#{key}: #{value}" for key, value of @data).join ", "

module.exports = Job
