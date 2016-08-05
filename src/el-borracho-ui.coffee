Spine    = require "spine"
__       = require "spine-awaitajax"
__       = require "spine-awaitajax/spine.awaitajax"
Maquette = require "maquette"
Graph    = require "el-borracho-graph/realtime-graph"
# jQuery   = require "jquery"
# window.jQuery = jQuery


###
TODO:
  style header with stats ✓
  style jobs in columns
    line wrap?
    stacktrace?
    promote/delete buttons
    fix wrapper height ✓
    progress bar background
  multi-select
  style labels with colors and delete button ✓
    fix completed delete button ✓
  style add dialog ✓
    redo animations in css ✓
  style loading icon ✓
    add pulse animation when refreshing ✓

  fix compressible
    add test
  fix sse-stream headers by adding Client::headers()
    add test for headers
  add graph CSS
    later figure out how much we can strip
  fix axis/grid
    do we really need a separate element
  theme graph with much prettier colors
  fix legend

###


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

    @graph       = new Graph        {@projector, el: "#realtime", baseUrl: ""}
    @queues      = new Queues       {@projector, el: ".teaser", baseUrl}
    @filters     = new Filters      {@projector, el: ".current.filters"}
    @addfilters  = new AddFilters   {@projector, el: ".add.filters"}
    @qfilters    = new QFilters     {@projector, el: ".add.filters .queue.filters"}
    @jobs        = new Jobs         {@projector, el: ".jobs", baseUrl}

    @graph.on       "error", @error
    @queues.on      "error", @error
    @filters.on     "error", @error
    @addfilters.on  "error", @error
    @qfilters.on    "error", @error
    @jobs.on        "error", @error

    @filters.Store.on "change", @jobs.refresh

$ ->
  window.elBorracho = new ElBorracho el: "body" unless window.elBorracho

