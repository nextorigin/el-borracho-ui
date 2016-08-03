Spine    = require "spine"
__       = require "spine-awaitajax"
__       = require "spine-awaitajax/spine.awaitajax"
Maquette = require "maquette"


class ElBorracho extends Spine.Controller
  logPrefix: "(ElBorracho)"

  error: (args...) -> console.error args...

  constructor: ->
    super
    @log "constructing"

    baseUrl      = "/jobs"

    Queues       = require "./controllers/queues"
    Filters      = require "./controllers/filters"
    AddFilters   = require "./controllers/add-filters"
    QFilters     = require "./controllers/queue-filters"
    Jobs         = require "./controllers/jobs"

    @projector   = Maquette.createProjector()

    @queues      = new Queues       {@projector, el: ".teaser", baseUrl}
    @filters     = new Filters      {@projector, el: ".current.filters"}
    @addfilters  = new AddFilters   {@projector, el: ".add.filters"}
    @qfilters    = new QFilters     {@projector, el: ".add.filters .queue.filters"}
    @jobs        = new Jobs         {@projector, el: ".jobs", baseUrl}

    @queues.on      "error", @error
    @filters.on     "error", @error
    @addfilters.on  "error", @error
    @qfilters.on    "error", @error
    @jobs.on        "error", @error

    @filters.Store.on "change", @jobs.refresh

$ ->
  window.elBorracho = new ElBorracho el: "body" unless window.elBorracho

