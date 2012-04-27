###
Create the Ember app and get it going.
###

define ['order!jquery', 'order!ember', 'order!emberdata', 'cs!cryptica-datastore-adapter'], ($) ->

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

  # Main view
  App.MyView = Em.View.extend()

  # Create our Message object model
  App.Message = DS.Model.extend
    userID: DS.attr('string')
    message: DS.attr('string')

  # The messages controller that dictates what messages will be shown in the view
  App.messages = Em.ArrayController.create

    # This field is non-standard, but it saves us from having to repeat the type
    # name a bunch of times below -- just use @type instead.
    type: App.Message

    content: []

    init: ->
      # Start out by getting all records from the server
      @set 'content', App.store.findAll(@type)
      @_super()

    # Get called whenever the content changes.
    arrayDidChange: (start, removeCount, addCount) ->
      @_super.apply(@, arguments)

      # Some very rudimentary message count limiting
      length = @get('content').get('length')
      if length > 10
        @get('content').removeAt 0, 5
      console.log 'arrayDidChange: ' + @get('content').get('length')

  # The messages list view
  App.MessagesView = Em.View.extend
    templateName: 'chat-messages'
    messagesBinding: 'App.messages'


  return window.App = App
