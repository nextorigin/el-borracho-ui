Spine = require "spine"


class Dialog extends Spine.Model
  @configure "Dialog",
    "message",
    "timestamp",
    "date"

  timestamp: ->
    @date = new Date


module.exports = Dialog
