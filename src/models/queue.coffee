Spine = require "spine"
__    = require "spine-awaitajax"
__    = require "spine-awaitajax/spine.awaitajax"


class Queue extends Spine.Model
  @configure "Queue",
    "name",
    "wait",
    "active",
    "delayed",
    "completed",
    "failed",
    "stuck"

  @extend Spine.Model.Ajax
  @url: "/jobs"

  @createFromEvent: (e) =>
    try
      @refresh e.data
    catch e
      return @trigger "error", e

  @names: ->
    (queue.name() for queue in @all())

  name: (name) ->
    @id = name if name
    @id


module.exports = Queue
