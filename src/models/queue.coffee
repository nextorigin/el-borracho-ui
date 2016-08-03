Spine = require "spine"


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

  @names: ->
    (queue.name() for queue in @all())

  name: (name) ->
    @id = name if name
    @id


module.exports = Queue
