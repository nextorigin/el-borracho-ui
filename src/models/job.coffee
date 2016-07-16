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

    @refresh allJobs, clear: true

  @error: (err) => @trigger "error", err


module.exports = Job
