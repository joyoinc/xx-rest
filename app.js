
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var http = require('http');
var path = require('path');
var UserProvider = require('./userProvider-mem.js').UserProvider

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);
app.get('/users', user.list);
app.post('/iuser/auth', function(req, res){
  var userProvider = new UserProvider()
  var login = req.param('login')
  var passwd = req.param("passwd")
  userProvider.authiUser({ login:login, passwd:passwd }
    , function(err, result) {
      if(err) throw err
      else {
        res.send(result)
      }
  })
})
app.get('/iuser/list', function(req, res){
  var userProvider = new UserProvider()
  userProvider.iUserList(function(err, result) {
      if(err) throw err
      else res.send(result)
  })
})
app.get('/iuser/add/:login/:email/:passwd', function(req, res){
  var userProvider = new UserProvider()
  var login = req.param('login')
  var email = req.param('email')
  var passwd = req.param('passwd')
  userProvider.addiUser({login:login,email:email,passwd:passwd}
    , function(err, result) {
      if(err) throw err
      else res.send(result)
  })

})

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
