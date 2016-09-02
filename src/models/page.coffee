Spine = require "spine"


class Page extends Spine.Model
  @configure "Page",
    "current",
    "max"

  @setup: ->
    record = @first() or new Page current: 1, max: 1
    record.save() if record.isNew()


module.exports = Page
