/*
The bootstrap file that gets everything going.
*/

// Define libraries
require.config({
  baseUrl: 'js/',
  paths: {
    jquery: 'libs/jquery-1.7.2.min',
    ember: 'libs/ember-latest',
    emberdata: 'libs/ember-data',
    emberlayout: 'libs/ember-layout',
    emberroutemanager: 'libs/ember-routemanager',
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
  priority: ['jquery', 'ember'],
  deps: [
    'jquery',
    'ember',
    'emberdata',
    'emberlayout',
    'emberroutemanager',
    'use!libs/underscore.min',
    'bootstrap'
  ]
});

// Get our app running
require(['cs!app/app'], function() {
});
