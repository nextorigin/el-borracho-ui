Spine    = require "spine"
Maquette = require "maquette"
errify   = require "errify"
Mapper   = require "./mapper"


debounce = (fn, timeout, timeoutID = -1) -> ->
  if timeoutID > -1 then window.clearTimeout timeoutID
  timeoutID = window.setTimeout fn, timeout


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
  showDetail: (e) ->
    $job = ($ e.target).closest ".job"
    $job.toggleClass "expanded"

  pulseSpinner: =>
    @loadingspinner.addClass("pulse")
                   .delay(320).queue -> ($ @).removeClass("pulse").dequeue()
                   .delay(240).queue -> ($ @).addClass("pulse").dequeue()
                   .delay(320).queue -> ($ @).removeClass("pulse").dequeue()
                   .delay(240).queue -> ($ @).addClass("pulse").dequeue()
                   .delay(320).queue -> ($ @).removeClass("pulse").dequeue()

  events:
    "click .job":                         "showControlsOrSelect"
    "click .job .delete":                 "delete"
    "click .job .promote":                "makePending"
    "click .job .id":                     "showDetail"
    "dblclick .job":                      "showDetail"

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

    @projector or= Maquette.createProjector()
    @jobMap      = new JobMapper [], @jobView

    @Store.on "refresh", @pulseSpinner
    @Store.on "refresh", @projector.scheduleRender
    @Store.on "error", @error
    @Store.on "change", @projector.scheduleRender
    @projector.append @el[0], @render

    @debouncedRender = debounce @projector.scheduleRender, 125
    ($ window).resize @debouncedRender

    @loadingspinner = $ ".loadingspinner"

  rowHeight: 64
  columnWidth: 343 + 22

  render: =>
    @log "rendering"

    jobs = @Store.filtered()

    totalJobs = jobs.length
    height  = @el.height()
    width   = @el.width()
    columnWidth = @columnWidth
    columnWidth = width if width < columnWidth
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

    page          = @Page.first()
    {current,max} = page
    page.current  = pages if page.current > pages
    page.max      = pages
    page.save() if page.current isnt current or page.max isnt max

    start         = (page.current - 1) * visible
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
