// var list     = require('./lib/list.js');
// var inject   = require('./lib/inject.js');
// var concat   = require('./lib/concat.js');
// var template = require('./lib/template.js');

module.exports.template = require('./lib/list.js').template;
module.exports.inject   = require('./lib/inject.js').inject;
module.exports.concat   = require('./lib/concat.js').concat;
module.exports.list     = require('./lib/template.js').list;
