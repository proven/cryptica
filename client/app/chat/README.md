# Client App Notes

## Try it out

Run the test server:

    > coffee server

In your browser, go to [http://localhost:3000](http://localhost:3000)

Witness the awesome messages start showing up.

## Technology Stack

### Communcation

* Socket.io
  * required by the local service

### MVC framework

* [Ember.js](http://emberjs.com/)
* using [Ember-Data](https://github.com/emberjs/data)
* with [Ember-RouteManager](https://github.com/ghempton/ember-routemanager) and [Ember-Layout](https://github.com/ghempton/ember-layout)
  * [read about them](http://codebrief.com/2012/02/anatomy-of-a-complex-ember-js-app-part-i-states-and-routes/)
  * and about [stateful routes](http://codebrief.com/2012/03/make-the-most-of-your-routes/) in general

### Browser package manager

* [RequireJS](http://requirejs.org/)
  * `text` plugin
  * `cs` plugin (CoffeeScript)

### Helpers

* jQuery
* Underscore