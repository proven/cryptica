/*
The bootstrap file that gets everything going.
*/

// Define libraries
require.config({
  baseUrl: 'js/',
  paths: {
    jquery: 'libs/jquery-1.7.2.min',
    ember: 'libs/ember-0.9.7.1',
    emberdata: 'libs/ember-data',
    CoffeeScript: 'libs/require/CoffeeScript',
    text: 'libs/require/text',
    cs: 'libs/require/cs',
    order: 'libs/require/order',
    use: 'libs/require/use',
    bootstrap: '/css/bootstrap/js/bootstrap'
  },
  use: {
    'libs/socket.io': {
      attach: 'io'
    },
    'libs/underscore.min': {
      attach: '_'
    }
  },
  priority: ['jquery'],
  deps: [
    'jquery',
    'ember',
    'emberdata',
    'use!libs/underscore.min',
    'bootstrap'
  ]
});

// Get our app running
require([
  'cs!app'
  ]);
