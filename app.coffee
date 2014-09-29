express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
stylus = require 'stylus'

routes = require './routes'

# Setting
app = express()
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

# Middleware
app.use favicon(path.join(__dirname, 'public/images/favicon.ico'))
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser()

# Dynamic routing
app.get '/', routes.index
app.post '/api', routes.api
app.get '/api/:name', routes.api

# Static routing
app.use '/static/stylesheets', stylus.middleware(
  src: path.join(__dirname, 'public/stylus')
  dest: path.join(__dirname, 'public/stylesheets')
)
app.use '/static', express.static(path.join(__dirname, 'public'))

# Error handling
app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next err

if app.get('env') is 'development'
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render 'error',
      message: err.message,
      error: err

app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render 'error',
    message: err.message,
    error: {}

module.exports = app

