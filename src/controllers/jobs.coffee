Spine    = require "spine"
Maquette = require "maquette"
Mapper   = require "./mapper"


class JobMapper extends Mapper
  identify: (record) -> record.queue + record.id


class JobsController extends Spine.Controller
  logPrefix: "(ElBorracho:Jobs)"

  selectOrExtendSelection: (e) ->
    job = e.target.id
    @pause() unless @paused()
    return @select job if @selecting
    @extendJobSelectionTo job

  extendSelectionTo: (job) ->

  paused: -> @loadingspinner.is ".paused"

  togglePause: (e) ->
    return @pause() unless @paused()
    @updateEvery20Seconds()

  pause: ->
    @log "pausing"
    clearInterval @_updateTimer if @_updateTimer?
    @loadingspinner.addClass ".paused"

  selectAllOfQueue: ->
  selectAllOfState: ->
  beginFadeToSelected: ->
  endFadeToSelected: ->
  showControlsOrSelect: ->

  delete: ->
  makePending: ->

  confirmMultiAction: ->
  cancelMultiAction: ->

  showStackTrace: ->
  showDetail: ->

  pulseSpinner: =>
    @loadingspinner.addClass("pulse")
                   .delay(320).queue -> ($ @).removeClass("pulse").dequeue()
                   .delay(240).queue -> ($ @).addClass("pulse").dequeue()
                   .delay(320).queue -> ($ @).removeClass("pulse").dequeue()
                   .delay(240).queue -> ($ @).addClass("pulse").dequeue()
                   .delay(320).queue -> ($ @).removeClass("pulse").dequeue()
  ###

  longpress to select many
  longpress job
    this turns on multi select
    subsequent taps add to selection
    subsequent long press extends selection through target
    tapping action on any job triggers action for all selected jobs
  longpress label
    selects all of label type
    does not enable multi select
    enables *ByState and *ByQueue operations
    cant remove any label when any label is selected

  ###

  events:
    "tap .loadingspinner":                "togglePause"
    "longpress .filter.queue":            "selectAllOfQueue"
    "longpress .filter.state":            "selectAllOfState"
    "touchstart .job":                    "beginFadeToSelected"
    "touchend .job":                      "endFadeToSelected"
    "longpress .job":                     "selectOrExtendSelection"
    "tap .job":                           "showControlsOrSelect"
    "tap .job .delete":                   "delete"
    "tap .job .promote":                  "makePending"
    "tap .job .confirmorcancel .confirm": "confirmMultiAction"
    "tap .job .confirmorcancel .cancel":  "cancelMultiAction"
    "tap .job.failed .stacktrace":        "showStackTrace"
    "doubletap .job":                     "showDetail"

  constructor: ({baseUrl}) ->
    @log "constructing"
    super

    @Store     = require "../models/job"
    @Queue     = require "../models/queue"
    @view      = require "../views/jobs"
    @jobView   = require "../views/job"

    @Store.baseUrl = baseUrl
    @projector or= Maquette.createProjector()
    @jobMap      = new JobMapper [], @jobView

    @Store.on "refresh", @pulseSpinner
    @Store.on "error", @error
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

    @loadingspinner = $ ".loadingspinner"

    @updateEvery20Seconds()

  rowHeight: 64
  columnWidth: 350
  currentPage: 1

  render: =>
    @log "rendering"

    jobs    = @Store.all()
    totalJobs = jobs.length
    height  = @el.height()
    width   = @el.width()
    rows    = Math.floor height / @rowHeight
    columns = Math.ceil width / @columnWidth

    renderTotal = remaining = pages = 0
    renderMax   = rows * columns

    if totalJobs > renderMax
      renderTotal = renderMax
      pages       = Math.ceil totalJobs / renderMax
    else
      renderTotal = totalJobs
      pages       = 1

    @currentPage = pages if @currentPage > pages
    @pages       = pages
    start        = (@currentPage - 1) * renderMax
    end          = start + (renderTotal - 1)

    @jobMap.update jobs[start..end]
    @view {jobs: @jobMap.components}

  updateEvery20Seconds: ->
    @_updateTimer = setInterval @update, 20 * 1000
    @update()

  update: =>
    @Store.fetchFiltered()

  refresh: =>
    @pause()
    @updateEvery20Seconds()

  error: (args...) => @trigger "error", args...


module.exports = JobsController
