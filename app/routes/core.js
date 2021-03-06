'use strict';

module.exports = function(app){
  var core = require('../../app/controllers/core.controller');
  app.route('/').get(core.index);
  app.route('/_apis').get(core.endpoints);
  app.route('/_apis/login/auth').post(core.authenticateLogin);
  app.route('/_apis/login/create').post(core.createLogin);
  
  var oe = require('../../app/controllers/omniEdu.controller');
  app.route('/_apis/oe/lesson/:id').get(oe.getLesson);
  app.route('/_apis/oe/course/:id').get(oe.getCourse);

  var qq = require('../../app/controllers/quickQuestion.controller');
  app.route('/_apis/qq/question/:id').get(qq.getQuestion);
  app.route('/_apis/qq/questions').post(qq.newQuestions);
  /* to do
  app.route('/_apis/qq/search').post(qq.searchQuestions);
  app.route('/_apis/qq/reply/:id').post(qq.replyQuestion);
  */
};
