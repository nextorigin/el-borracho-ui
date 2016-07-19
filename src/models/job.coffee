Spine  = require "spine"
Queue  = require "./queue"
Filter = require "./filter"
{Ajax} = Spine


class Job extends Spine.Model
  @configure "Job",
    "queue",
    "state",
    "data",
    "progress",
    "stacktrace"

  @filter:
    queues: []
    states: []
    data:   []
    id:     null

  @fetchFiltered: ->
    ideally        = errify @error
    queueFilters   = Filter.queues()
    @filter.queues = queueFilters?.length and queueFilters or Queue.names()
    @filter.states = Filter.states()
    @filter.id     = Filter.id()
    allJobs        = []

    for queue in @filter.queues
      base = "#{@baseUrl}#{@url}"

      if id = @filter.id
        url = "#{base}/#{id}"
        await Ajax.awaitGet {url}, ideally defer jobs
        allJobs = allJobs.concat jobs

      else if @filter.states.length then for state in @filter.states
        url = "#{base}/#{state}"
        await Ajax.awaitGet {url}, ideally defer jobs
        allJobs = allJobs.concat jobs

      else
        url = base
        await Ajax.awaitGet {url}, ideally defer jobs
        allJobs = allJobs.concat jobs

    allJobs = @sort allJobs
    @refresh allJobs, clear: true

  @filterData: (key, value) ->
    @select (record) -> record.data[key].match new RegExp value

  @error: (err) => @trigger "error", err

  @stateOrder: [
    "active"
    "completed"
    "delayed"
    "failed"
    "wait"
    "stuck"
  ]

  @sort: (jobs) ->
    queues = @filter.queues.length and @filter.queues
    states = @filter.states.length and @filter.states

    byId = (a, b) ->
      aId = a.id
      bId = b.id
      if      a.id > b.id then 1
      else if a.id < b.id then -1
      else                     0

    byVal = (a, aVal, b, bVal) ->
      if aVal is bVal then byId a, b
      else
        if      aVal > bVal then 1
        else if aVal < bVal then -1

    jobs.sort (a, b) ->
      if states
        aState = @stateOrder.indexOf a.state
        bState = @stateOrder.indexOf b.state
        byVal a, aState, b, bState
      else if queues
        aQueue = queues.indexOf a.queue
        bQueue = queues.indexOf b.queue
        byVal a, aQueue, b, bQueue
      else 0

module.exports = Job
