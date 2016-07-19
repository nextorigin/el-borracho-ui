Spine    = require "spine"
Maquette = require "maquette"
Mapper   = require "./mapper"


class JobsController extends Spine.Controller
  logPrefix: "(ElBorracho:Jobs)"

  selectJobOrExtendJobSelection: (e) ->
    job = e.target.id
    @pause() unless @paused()
    return @select job if @selecting
    @extendJobSelectionTo job

  extendJobSelectionTo: (job) ->

  paused: -> @loadingspinner.is ".paused"

  togglePause: (e) ->
    return @pause() unless @paused()
    @updateEvery20Seconds()

  pause: ->
    @debug "pausing"
    clearInterval @_updateTimer if @_updateTimer?
    @loadingspinner.addClass ".paused"

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
    "tap .stats .downarrow":              "showStatsAndStats"
    "tap .loadingspinner":                "togglePause"
    "tap .filters .add":                  "addFilter"
    "tap .filter .delete":                "deleteFilter"
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
    @debug "constructing"
    super

    @Store     = require "../models/job"
    @Queue     = require "../models/queue"
    @view      = require "../views/jobs"
    @jobView   = require "../views/job"

    @Store.baseUrl = baseUrl
    @projector or= Maquette.createProjector()
    @jobMap      = new Mapper [], @jobView

    @Store.on "error", ->
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

    @updateEvery20Seconds()

  render: =>
    @debug "rendering"

    jobs    = @Store.all()
    totalJobs = jobs.length
    height  = @el.height()
    width   = @el.width()
    rows    = Math.floor height / @rowHeight
    columns = Math.floor width / @columnWidth

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


module.exports = JobsController
