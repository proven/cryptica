# Client App Notes

## Try it out

Run the test server:

    > coffee server

In your browser, go to [http://localhost:3000](http://localhost:3000)

Witness the awesome messages start showing up.

## Notes

* The templates shouldn't all be in index.html, but I'm not yet sure about external templates. It's a bit unpleasant to load them with RequireJS (exacerbated by CoffeeScript), but I'm not sure (yet) how/if to do it with Brunch or whatever.

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
  
* Probably should switch to [Brunch](http://brunch.io/). Probably right about the time we start needing to compile Stylus/LESS (or sooner).

### Helpers

* jQuery
* Underscore

## Lessons learned

* Camel-case fields in the model must be underscore'd (i.e., `Ember.String.decamelize`) in the service API. (Or at least passed into `store.load`.)
  * We need to decide what our standard is going to be. 

## Potentially useful links

* UI toolkits

  * [ember-bootstrap](https://github.com/jzajpt/ember-bootstrap): "A set of UI elements styled using Twitter Boostrap toolkit to use with Ember.js"

  * [flame.js](https://github.com/flamejs/flame.js): "widget/UI library for Ember.js". Interesting, but I really don't like how it encourages hardcoding the layout into the JS code (although there is a pull request for better Handlebars integration).

  * [Using Ember.js with jQuery UI](http://www.lukemelia.com/blog/archives/2012/03/10/using-ember-js-with-jquery-ui/): The links at the bottom are the particularly interesting part -- the rest is general Ember stuff.

* Testing

  * [Testing Ember and the Runloop](http://www.thesoftwaresimpleton.com/blog/2012/04/03/testing-ember-and-the-runloop/)


* [emberjs-addons](https://github.com/emberjs-addons) github organization. Still a lot of projects that use Sproutcore terminology, but it looks like many are for Ember.

* [Mobile Kit for Ember](https://github.com/ppcano/ember-mk) (which requires [ember-touch](https://github.com/ppcano/sproutcore-touch) for touches and gestures).

* Automatic documentation generators

  * [JSDoc](https://github.com/jsdoc3/jsdoc): Maybe having a pretty comment-to-documentation tools will help us to do both better. (Markdown plugin ftw. Take a look at Ember's API docs.)
    * To use JSDoc with CoffeeScript, create comment blocks like so (note the asterisk):

      ```  
      ###*
      This function does something
      @param {int} pname Pass a number
      ###
      ```
  
  * [dox](https://github.com/visionmedia/dox) uses JSDoc-ish tags and produces JSON that can be converted into HTML or whatever.
    * [codex](https://github.com/logicalparadox/codex) is a static site generator that can consume dox output to create a site. [codex-hub](http://alogicalparadox.com/codex-hub/) is a template for doing that (in a github-pages-friendly way). 
  * [docco](http://jashkenas.github.com/docco/) is also very popular (and pretty cool). But it seems to be more for making pretty code tours than for documenting APIs and whatnot. And if I have to choose between two… well, reading raw source suffices for code tours.