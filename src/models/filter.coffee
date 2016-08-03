Spine = require "spine"


class Filter extends Spine.Model
  @configure "Filter",
    "type",
    "value"

  @states: ->
    stateFilters = @findAllByAttribute "type", "state"
    (filter.value for filter in stateFilters)

  @queues: ->
    queueFilters = @findAllByAttribute "type", "queue"
    (filter.value for filter in queueFilters)

  @data: ->
    dataFilters = @findAllByAttribute "type", "data"
    (filter.value for filter in dataFilters)

  @id: ->
    idFilter = @findByAttribute "type", "id"
    idFilter?.value


module.exports = Filter
