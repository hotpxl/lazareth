
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index.html');
  // res.render('index', { title: 'Express' });
};
