Spine    = require "spine"
__       = require "spine-awaitajax"
__       = require "spine-awaitajax/spine.awaitajax"
Maquette = require "maquette"


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

  fix sse-stream ✓
    add test ✓
  add graph CSS ✓
    later figure out how much we can strip
  fix axis/grid ✓
    do we really need a separate element ✓
  theme graph with much prettier colors ✓
  fix legend ✓

  job sort always leaving something at index 1
  pagination

  /:queue/:count streams ?

  /:queue/:state streams
    then /:queue/?states=[...] can be combos of state streams
      normalize order of array in originalUrl so that caching works (sort then toString)


  webfont substitutes for helvetica ✓

  ipad styling
    give filter labels more room less margin ✓
    graphs overflow stats bounding box ✓
    more specific flex CSS ✓
      reduce loading icon margin ✓
      reduce border margin try to fit two whole columns in portrait ✓
      provide hint of color for job state when column overflows container
      reduce label margins so 4 filter labels can fit in portrait ✓

###


class ElBorrachoUI extends Spine.Controller
  logPrefix: "(ElBorracho)"

  error: (args...) -> console.error args...

  constructor: ({@baseUrl}) ->
    super
    @baseUrl   or=  "/jobs"
    @log "constructing for url: #{@baseUrl}"

    Stats        = require "./controllers/stats"
    Queues       = require "./controllers/queues"
    Filters      = require "./controllers/filters"
    AddFilters   = require "./controllers/add-filters"
    QFilters     = require "./controllers/queue-filters"
    Jobs         = require "./controllers/jobs"

    @projector   = Maquette.createProjector()

    @stats       = new Stats        {@projector, el: ".stats"}
    @queues      = new Queues       {@projector, el: ".teaser", @baseUrl}
    @filters     = new Filters      {@projector, el: ".current.filters"}
    @addfilters  = new AddFilters   {@projector, el: ".add.filters"}
    @qfilters    = new QFilters     {@projector, el: ".add.filters .queue.filters"}
    @jobs        = new Jobs         {@projector, el: ".jobs", @baseUrl}

    @bindEvents()
    @start()

  bindEvents: ->
    @stats.on       "error", @error
    @queues.on      "error", @error
    @filters.on     "error", @error
    @addfilters.on  "error", @error
    @qfilters.on    "error", @error
    @jobs.on        "error", @error

    @filters.Store.on "change", @jobs.refresh

  start: ->
    @queues.updateEvery15Seconds()


module.exports = ElBorrachoUI
