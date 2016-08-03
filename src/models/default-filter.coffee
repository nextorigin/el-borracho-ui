Filter = require "./filter"


class DefaultFilter extends Filter
  @configure "DefaultFilter",
    "type",
    "value"


module.exports = DefaultFilter
