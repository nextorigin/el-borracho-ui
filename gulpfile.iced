mkdirp  = require "mkdirp"
path    = require "path"
gulp    = require "gulp"
Plugins = require "gulp-load-plugins"
Combine = require "stream-combiner"
bify    = require "browserify"
bifyshm = require "browserify-global-shim"
preppy  = require "prependify"
source  = require "vinyl-source-stream"
wtfy    = require "watchify"
chalk   = require "chalk"
del     = require "del"
pkg     = require "./package"


plugins     = Plugins()
{log}       = plugins.util
{src, dest} = gulp


config =
  builddirs: [
    "build/*"
    "public/js/*"
    "public/css/*"
  ]
  css:
    src:  "css/*.css"
    dest: "public/css/"
  styl:
    src:  "css/*.styl"
    dest: "public/css"
  js:
    src:  "src/**/*.js"
    dest: "build/js/"
  pug:
    runtime: "\nvar h = require('maquette').h;\n"
    marshalDataset: false
    src:  "src/views/**/*.jade"
    dest: "build/js/views/"
  coffee:
    src:  "src/**/*.+(coffee|iced)"
    dest: "build/js/"
  browserify:
    # expose:
    #   "iced-coffee-script": null
      # "spine":              null
    libs: [
      "build/js/el-borracho-ui.js"
    ]
    dest: "public/js/"


notifier = plugins.notify.onError title: "el-borracho - error", message: "<%= error.message %>"

copyCSS = new Combine [
  plugins.changed config.css.dest
  dest config.css.dest
]

compileStyl = new Combine [
  plugins.changed config.styl.dest, extension: ".css"
  plugins.sourcemaps.init()
  plugins.stylus().on "error", notifier
  plugins.autoprefixer()
  plugins.sourcemaps.write()
  dest config.styl.dest
]

copyJS = new Combine [
  plugins.changed config.js.dest
  dest config.js.dest
]

compilePug = new Combine [
  plugins.changed config.pug.dest, extension: ".js"
  plugins.pugHyperscript({runtime: config.pug.runtime}).on "error", notifier
  dest config.pug.dest
]

compileCoffee = new Combine [
  plugins.changed config.coffee.dest, extension: ".js"
  plugins.sourcemaps.init()
  plugins.icedCoffee(bare: true, runtime: "browserify").on "error", notifier
  plugins.sourcemaps.write()
  dest config.coffee.dest
]

makewatcher = (src) ->
  events  = "add,change,unlink,addDir,unlinkDir,error".split ","
  watcher = plugins.watch src
  for event in events then do (event) ->
    watcher.on event, (path) -> log "#{event}:", path
  watcher

bundleAll = (watch = false) ->
  watch = watch is true
  b     = bify config.browserify.libs, fullPaths: watch, standalone: "ElBorrachoUI", debug: true, cache: {}, packageCache: {}
  shim  = bifyshm.configure "jquery": "$", appliesTo: includeExtensions: ['.js']

  b.plugin preppy, "window.require = "
  b.require file, expose: (name or file) for file, name of config.browserify.expose
  b.transform shim, global: true
  if watch
    log "watching"
    b = wtfy b

  bundle = ->
    log "bundling"
    b.bundle()
      .on "error", notifier
      .pipe source "el-borracho-ui.js"
      .pipe dest config.browserify.dest
  lasttime = 0

  b.on "update", bundle
  b.on "time", (time) -> lasttime = time
  b.on "bytes", (bytes) ->
    log "Bundled " + (chalk.cyan (Math.round bytes/1024) + "Kb") + " after " + chalk.magenta "#{lasttime}ms"

  bundle()

clean = (cb) -> del config.builddirs, cb

server = null
serve = ->
  server = plugins.liveServer pkg.bin, env: NODE_ENV: "development"
  server.start()

liveReload = ->
  server.notify()

gulp.task "css:copy", ->
  src   config.css.src
  .pipe copyCSS

gulp.task "css:watch", ->
  src   config.css.src
  .pipe makewatcher config.css.src
  .pipe copyCSS

gulp.task "styl", ->
  src   config.styl.src
  .pipe compileStyl

gulp.task "styl:watch", ->
  src   config.styl.src
  .pipe makewatcher config.styl.src
  .pipe compileStyl

gulp.task "css", ["css:copy", "styl"]

gulp.task "pug", ->
  src   config.pug.src
  .pipe compilePug

gulp.task "pug:watch", ->
  src   config.pug.src
  .pipe makewatcher config.pug.src
  .pipe compilePug

gulp.task "coffee", ->
  src   config.coffee.src
  .pipe compileCoffee

gulp.task "coffee:watch", ->
  src   config.coffee.src
  .pipe makewatcher config.coffee.src
  .pipe compileCoffee

gulp.task "js:copy", ->
  src   config.js.src
  .pipe copyJS

gulp.task "js:watch", ->
  src   config.js.src
  .pipe makewatcher config.js.src
  .pipe copyJS

gulp.task "js", ["js:copy", "pug", "coffee"], bundleAll
gulp.task "watchify", -> bundleAll true

gulp.task "build", ["styl", "css", "js"]
gulp.task "clean", clean
gulp.task "watch", ["styl:watch", "pug:watch", "js:watch", "coffee:watch", "watchify"]

gulp.task "serve", serve
gulp.task "live", ["watch", "serve"]

gulp.task "default", ["build"]
