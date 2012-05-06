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
    createdDate: DS.attr('date')


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

    createNew: (messageText) ->
      console.log 'saving new message: ' + messageText
      message =
        userID: App.mainController.get 'username'
        message: messageText
        createdDate: new Date()
      App.store.createRecord App.Message, message
      App.store.commit()


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

      # Scroll the messages list to the bottom to start.
      # TODO: Make this work consistently.
      $messagesList = @$('.messages-list')
      $messagesList.scrollTop($messagesList[0].scrollHeight)

    submitMessage: (event) ->
      event.preventDefault()
      if not @get 'newMessage'
        return
      App.routeManager.send 'createNewMessage', @get 'newMessage'
      @set 'newMessage', ''

    messagesDidChange: (->
        # When a messages is added, scroll to the bottom if the scroll position
        # is already at (or very near) the bottom. Don't jump the user down if
        # they're reading messages above.
        $messagesList = @$('.messages-list')
        return if not $messagesList? or $messagesList.length == 0
        lastItemHeight = $messagesList.find('.chat-message-item:last').outerHeight()
        atBottom = (($messagesList[0].scrollHeight - $messagesList.scrollTop() - lastItemHeight) <= $messagesList.outerHeight())
        if atBottom then _.defer => $messagesList.scrollTop($messagesList[0].scrollHeight)
      ).observes 'messages.@each'

  App.MessageItemView = Ember.View.extend
    isoCreatedDate: (->
        @get('content').get('createdDate').toISOString()
      ).property('content.createdDate')

    didInsertElement: ->
      @$('.chat-message-date').timeago()





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

      createNewMessage: (manager, messageText) ->
        App.messages.createNew messageText


  App.routeManager.start()


  return window.App = App
