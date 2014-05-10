express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'

app = express()

app.set 'port', process.env.PORT || 8000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'
app.engine 'html', require('ejs').renderFile
app.use express.favicon('public/images/favicon.ico')
app.use express.logger 'dev'
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use '/static', require('stylus').middleware(
  src: path.join __dirname, 'public'
)
app.use '/static', express.static(path.join(__dirname, 'public'))

if 'development' == app.get 'env'
  app.use express.errorHandler()

app.get '/', routes.index
app.get '/api/:name', routes.api

module.exports = do =>
  http.createServer(app).listen app.get('port'), ->
    console.log 'Express server listening on port ' + app.get 'port'
    return

