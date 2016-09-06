Spine    = require "spine"
Maquette = require "maquette"


class ElBorrachoUI extends Spine.Controller
  logPrefix: "(ElBorracho)"

  constructor: ({@baseUrl}) ->
    super
    @baseUrl   or=  "/jobs"
    @log "constructing for url: #{@baseUrl}"

    Dialogs      = require "./controllers/dialog-box"
    Stats        = require "./controllers/stats"
    Queues       = require "./controllers/queues"
    Filters      = require "./controllers/filters"
    AddFilters   = require "./controllers/add-filters"
    QFilters     = require "./controllers/queue-filters"
    Jobs         = require "./controllers/jobs"
    Pages        = require "./controllers/pages"

    @projector   = Maquette.createProjector()

    @dialogs     = new Dialogs      {@projector, el: "body"}
    @stats       = new Stats        {@projector, el: ".stats"}
    @queues      = new Queues       {@projector, el: ".teaser", @baseUrl}
    @filters     = new Filters      {@projector, el: ".current.filters"}
    @addfilters  = new AddFilters   {@projector, el: ".add.filters"}
    @qfilters    = new QFilters     {@projector, el: ".add.filters .queue.filters"}
    @jobs        = new Jobs         {@projector, el: ".jobs", @baseUrl}
    @pages       = new Pages        {@projector, el: "body"}

    @bindEvents()
    @start()

  bindEvents: ->
    @dialogs.on     "error", @error
    @stats.on       "error", @error
    @queues.on      "error", @error
    @filters.on     "error", @error
    @addfilters.on  "error", @error
    @qfilters.on    "error", @error
    @jobs.on        "error", @error
    @pages.on       "error", @error

    @filters.Store.on "change", @jobs.refresh

  start: ->
    @queues.updateEvery15Seconds()
    @jobs.updateEvery20Seconds()

  error: (args...) =>
    console.error args...

    [err]   = args
    message = switch
      when err instanceof Error and err.xhr?.readyState is 0 and err.message.trim() is "" or "error"
        "Network error"
      else
        err.toString()

    @dialogs.add message


module.exports = ElBorrachoUI
