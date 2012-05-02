###
Create the Ember app and get it going.
###

define ['jquery', 'cs!app/cryptica-datastore-adapter'], ($) ->

  # Create the Cryptica-specific adapater and the datastore that uses it
  adapter = DS.CrypticaAdapter.create()
  store = DS.Store.create
                    revision: 4
                    adapter: adapter

  # Create the Ember application
  App = Ember.Application.create

    store: store
    adapter: adapter

    ready: ->
      @_super()


  ###
  Models
  TODO: Separate files
  ###

  # Create our Message object model
  App.Message = DS.Model.extend
    userID: DS.attr('string')
    message: DS.attr('string')


  ###
  Controllers
  TODO: Separate files
  ###

  # TODO: Does this make sense?
  App.mainController = Ember.Object.create
    username: null


  # The messages controller that dictates what messages will be shown in the view
  App.messages = Ember.ArrayController.create

    # This field is non-standard, but it saves us from having to repeat the type
    # name a bunch of times below -- just use @type instead.
    type: App.Message

    content: []

    init: ->
      @_super()
      # Start out by getting all records from the server
      @set 'content', App.store.findAll(@type)

    # Gets called whenever the content changes.
    arrayDidChange: (start, removeCount, addCount) ->
      @_super.apply @, arguments

      # Some very rudimentary message count limiting
      length = @get('content').get('length')
      if length > 10
        # Maybe instead of calling this directly in this event handler we should
        # queue it until after Ember has finished its render cycle with:
        # `Ember.run.schedule('render', ...)`?
        @get('content').removeAt 0, 5


  ###
  Views
  TODO: Separate files
  ###

  # The top level layout view
  App.mainView = Ember.View.create
    templateName: 'main'

  App.mainView.appendTo 'body'

  App.LoginView = Ember.View.extend
    templateName: 'login'

    username: null
    usernameError: (-> return not @get 'username').property 'username'

    didInsertElement: ->
      # _.defer is not strictly needed here -- it seems to function correctly
      # without it. It is needed in other views, though, so I'm putting it here
      # for consistency.
      _.defer(=> @$('input[type=text]:first').focus())

    submitLogin: (event) ->
      event.preventDefault()
      console.log 'submitLogin clicked'
      return if @get 'usernameError'
      App.routeManager.send 'login', @


  # The messages list view
  App.MessagesView = Ember.View.extend
    templateName: 'chat-messages'
    messagesBinding: 'App.messages'

    newMessage: null

    didInsertElement: ->
      # I don't know why the _.defer is necessary, but it seems to be. Otherwise
      # the focus just won't be set.
      _.defer(=> @$('input[type=text]:first').focus())

      placeFooter = ->
        windowHeight = $(window).height()
        footerHeight = @$("#message-compose").height()
        offset = parseInt(windowHeight) - parseInt(footerHeight)
        @$("#message-compose").css "top", offset

      $(window).resize -> placeFooter()

      placeFooter()
      @$("#message-compose").css "display", "inline"

    submitMessage: (event) ->
      event.preventDefault()
      if not @get 'newMessage'
        return
      console.log 'saving new message: ' + @get 'newMessage'
      message =
        userID: App.mainController.get 'username'
        message: @get 'newMessage'
      App.store.createRecord App.Message, message
      App.store.commit()
      @set 'newMessage', ''


  ###
  Route/State Manager(s)
  TODO: Separate files?
  ###

  App.routeManager = Ember.RouteManager.create
    rootView: App.mainView

    login: Ember.LayoutState.create
      viewClass: App.LoginView
      route: '' # root
      login: (manager, context) ->
        username = context.get 'username'
        console.log 'login username: ' + username
        App.mainController.set 'username', username
        App.routeManager.set 'location', 'messages'

    about: Ember.LayoutState.create
      viewClass: Ember.View.extend
        templateName: 'about'
      route: 'about'


    messages: Ember.LayoutState.create
      viewClass: App.MessagesView
      route: 'messages'


  App.routeManager.start()


  return window.App = App
