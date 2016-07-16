require('es5-shimify')

require('spine')
# require('spine/lib/local')
# require('spine/lib/manager')
# require('spine/lib/route')

require('./lib/spine.ajax')
# require('./lib/spine.awaitajax')

Maquette = require "maquette"


class ElBorracho extends Spine.Controller
  constructor: ->
    Queues   = require "./controllers/queues"
    Filters  = require "./controllers/filters"
    QFilters = require "./controllers/queue-filters"
    Jobs     = require "./controllers/jobs"

    @projector = Maquette.createProjector()

    @queues   = new Queues {@projector, el: ".teaser"}
    @filters  = new Filters {@projector, el: ".current.filters"}
    @qfilters = new QFilters {@projector, el: ".add.filters .queue-filters"}
    @jobs     = new Jobs {@projector, el: ".jobs"}

    @filters.Store.on "change", @jobs.refresh

$ ->
  window.elBorracho = new ElBorracho el: "body" unless window.elBorracho

