Spine = require "spine"
Queue = require "./queue"
Job   = require "./job"


class Tubes extends Spine.Module
  @extend Spine.Events

  @url: "/sse/multiplex"

  @streamsForFilters: ->
    Job.updateFilters()
    {filters} = Job

    streams = for queue in filters.queues
      base = "/sse/#{queue}"

      if filters.ids.length then for id in filters.ids
        "#{base}/#{id}"
      else if filters.states.length then for state in filters.states
        "#{base}/#{state}"
      else
        base

    if filters.states.length and not streams.length
      base = "/sse"
      streams = for state in filters.states
        "#{base}/#{state}"

    streams.push "/sse"
    streams

  @listen: (streams = @streamsForFilters()) ->
    @source = new EventSource "#{@baseUrl}#{@url}?streams=#{streams}"
    @source.addEventListener "jobs",    Job.createFromEvent
    @source.addEventListener "counts",  Queue.createFromEvent
    @source.addEventListener "error",   @error

  @stop: =>
    return unless @source
    @source.removeEventListener "jobs",    Job.createFromEvent
    @source.removeEventListener "counts",  Queue.createFromEvent
    @source.removeEventListener "error",   @error
    @source.close()
    delete @source

  @refresh: =>
    streams = @streamsForFilters()
    return if streams is @streams
    @stop()
    @listen streams
    @streams = streams

  @error: (args...) => @trigger "error", args...


module.exports = Tubes
