Spine    = require "spine"
Maquette = require "maquette"
errify   = require "errify"
Mapper   = require "./mapper"


class JobMapper extends Mapper
  identify: (record) -> record.queue + record.id


disable = (element) ->
  ($ element).attr disabled: "disabled"


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
  showControlsOrSelect: (e) ->
    $job = ($ e.target).closest ".job"
    $job.siblings().removeClass "focus"
    $job.addClass "focus"

  delete: (e) ->
    ideally = errify @error
    $job = ($ e.target).closest ".job"
    {id} = $job.data()
    record = @Store.find id
    await record.destroy ideally defer()
    disable e.target

  makePending: (e) ->
    ideally = errify @error
    $job = ($ e.target).closest ".job"
    {id} = $job.data()
    record = @Store.find id
    await record.promote ideally defer()
    disable e.target

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
    "click .job":                         "showControlsOrSelect"
    "tap .job":                           "showControlsOrSelect"
    "click .job .delete":                 "delete"
    "tap .job .delete":                   "delete"
    "click .job .promote":                "makePending"
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
    @Page      = require "../models/page"
    @view      = require "../views/jobs"
    @jobView   = require "../views/job"

    @Store.baseUrl = baseUrl
    @Page.setup()
    @page = @Page.first()

    @projector or= Maquette.createProjector()
    @jobMap      = new JobMapper [], @jobView

    @Store.on "refresh", @pulseSpinner
    @Store.on "refresh", @projector.scheduleRender
    @Store.on "error", @error
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

    @loadingspinner = $ ".loadingspinner"

    @updateEvery20Seconds()

  rowHeight: 64
  columnWidth: 343 + 22

  render: =>
    @log "rendering"

    jobs = []
    if @Store.filters.data.length then for data in @Store.filters.data
      [key, value] = data.split ":"
      key          = key.trim()
      value        = value.trim()
      jobs         = jobs.concat @Store.filterData key, value
    else
      jobs = @Store.all()

    totalJobs = jobs.length
    height  = @el.height()
    width   = @el.width()
    rows    = Math.floor height / @rowHeight
    columns = Math.ceil (width + 22) / columnWidth
    visible = rows * Math.floor (width + 22) / columnWidth

    renderTotal = pages = 0
    renderMax   = rows * columns

    if totalJobs > visible
      renderTotal = renderMax
      pages       = Math.ceil totalJobs / visible
    else
      renderTotal = totalJobs
      pages       = 1

    {current,max} = @page
    @page.current = pages if @page.current > pages
    @page.max     = pages
    @page.save() if @page.current isnt current or @page.max isnt max

    start         = (@page.current - 1) * visible
    end           = start + (renderTotal - 1)

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
