Spine = require "spine"


class Filter extends Spine.Model
  @configure "Filter",
    "type",
    "value"

  @states: ->
    stateFilters = @findAllByAttribute "type", "state"
    (filter.state for filter in stateFilters)

  @queues: ->
    queueFilters = @findAllByAttribute "type", "queue"
    (filter.value for filter in queueFilters)

  @id: ->
    idFilter = @findByAttribute "type", "id"
    idFilter?.value


module.exports = Filter
