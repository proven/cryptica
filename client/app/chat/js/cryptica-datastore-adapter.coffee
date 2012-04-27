###
Our communication layer with the Cryptica service.
###

define ['use!libs/socket.io', 'emberdata'], (io) ->

  DS.CrypticaAdapter = DS.Adapter.extend

    init: () ->
      @_super.apply(@, arguments)

      @socket = io.connect('http://localhost:3000')

      # Note that we don't have to wait to receive `'connect'` before we start
      # setting up our listeners or even start emitting.
      @socket.on 'connect', ->
        console.log 'socket connected'

      # Create listeners for the notifications that the service might push down
      # to us.
      @socket.on 'newMessages', @notify_messagesReceived

    notify_messagesReceived: (messages) ->
        console.log 'received new messages'
        console.log messages
        App.store.loadMany App.Message, messages

    find: (store, type, id) ->
      console.log 'calling find'
      @socket.emit 'find', id, (data) ->
        store.load type, id, data

    findAll: (store, type) ->
      console.log 'calling findAll'
      @socket.emit 'findAll', (data) ->
        store.loadMany type, data

###
    createRecord: (store, type, record) ->
      console.log 'DS.CrypticaAdapter#createRecord'
      console.log arguments
      store.didCreateRecord record, {userID:'moi22', content:'devoid22'}
###
###
    var root = this.rootForType(type);

    var data = {};
    data[root] = record.toJSON();

    this.ajax(this.buildURL(root), "POST", {
      data: data,
      success: function(json) {
        this.sideload(store, type, json, root);
        store.didCreateRecord(record, json[root]);
      }
    });
  },

  createRecords: function(store, type, records) {
    if (get(this, 'bulkCommit') === false) {
      return this._super(store, type, records);
    }

    var root = this.rootForType(type),
        plural = this.pluralize(root);

    var data = {};
    data[plural] = records.map(function(record) {
      return record.toJSON();
    });

    this.ajax(this.buildURL(root), "POST", {
      data: data,

      success: function(json) {
        this.sideload(store, type, json, plural);
        store.didCreateRecords(type, records, json[plural]);
      }
    });
  },

  updateRecord: function(store, type, record) {
    var id = get(record, 'id');
    var root = this.rootForType(type);

    var data = {};
    data[root] = record.toJSON();

    this.ajax(this.buildURL(root, id), "PUT", {
      data: data,
      success: function(json) {
        this.sideload(store, type, json, root);
        store.didUpdateRecord(record, json && json[root]);
      }
    });
  },

  updateRecords: function(store, type, records) {
    if (get(this, 'bulkCommit') === false) {
      return this._super(store, type, records);
    }

    var root = this.rootForType(type),
        plural = this.pluralize(root);

    var data = {};
    data[plural] = records.map(function(record) {
      return record.toJSON();
    });

    this.ajax(this.buildURL(root, "bulk"), "PUT", {
      data: data,
      success: function(json) {
        this.sideload(store, type, json, plural);
        store.didUpdateRecords(records, json[plural]);
      }
    });
  },

  deleteRecord: function(store, type, record) {
    var id = get(record, 'id');
    var root = this.rootForType(type);

    this.ajax(this.buildURL(root, id), "DELETE", {
      success: function(json) {
        if (json) { this.sideload(store, type, json); }
        store.didDeleteRecord(record);
      }
    });
  },

  deleteRecords: function(store, type, records) {
    if (get(this, 'bulkCommit') === false) {
      return this._super(store, type, records);
    }

    var root = this.rootForType(type),
        plural = this.pluralize(root);

    var data = {};
    data[plural] = records.map(function(record) {
      return get(record, 'id');
    });

    this.ajax(this.buildURL(root, 'bulk'), "DELETE", {
      data: data,
      success: function(json) {
        if (json) { this.sideload(store, type, json); }
        store.didDeleteRecords(records);
      }
    });
  },

  find: function(store, type, id) {
    var root = this.rootForType(type);

    this.ajax(this.buildURL(root, id), "GET", {
      success: function(json) {
        store.load(type, json[root]);
        this.sideload(store, type, json, root);
      }
    });
  },

  findMany: function(store, type, ids) {
    var root = this.rootForType(type), plural = this.pluralize(root);

    this.ajax(this.buildURL(root), "GET", {
      data: { ids: ids },
      success: function(json) {
        store.loadMany(type, ids, json[plural]);
        this.sideload(store, type, json, plural);
      }
    });
  },

  findAll: function(store, type) {
    var root = this.rootForType(type), plural = this.pluralize(root);

    this.ajax(this.buildURL(root), "GET", {
      success: function(json) {
        store.loadMany(type, json[plural]);
        this.sideload(store, type, json, plural);
      }
    });
  },

  findQuery: function(store, type, query, recordArray) {
    var root = this.rootForType(type), plural = this.pluralize(root);

    this.ajax(this.buildURL(root), "GET", {
      data: query,
      success: function(json) {
        recordArray.load(json[plural]);
        this.sideload(store, type, json, plural);
      }
    });
  },

  // HELPERS

  plurals: {},

  // define a plurals hash in your subclass to define
  // special-case pluralization
  pluralize: function(name) {
    return this.plurals[name] || name + "s";
  },

  rootForType: function(type) {
    if (type.url) { return type.url; }

    // use the last part of the name as the URL
    var parts = type.toString().split(".");
    var name = parts[parts.length - 1];
    return name.replace(/([A-Z])/g, '_$1').toLowerCase().slice(1);
  },

  ajax: function(url, type, hash) {
    hash.url = url;
    hash.type = type;
    hash.dataType = 'json';
    hash.contentType = 'application/json';
    hash.context = this;

    if (hash.data && type !== 'GET') {
      hash.data = JSON.stringify(hash.data);
    }

    jQuery.ajax(hash);
  },

  sideload: function(store, type, json, root) {
    var sideloadedType, mappings;

    for (var prop in json) {
      if (!json.hasOwnProperty(prop)) { continue; }
      if (prop === root) { continue; }

      sideloadedType = type.typeForAssociation(prop);

      if (!sideloadedType) {
        mappings = get(this, 'mappings');

        ember_assert("Your server returned a hash with the key " + prop + " but you have no mappings", !!mappings);

        sideloadedType = get(get(this, 'mappings'), prop);

        ember_assert("Your server returned a hash with the key " + prop + " but you have no mapping for it", !!sideloadedType);
      }

      this.loadValue(store, sideloadedType, json[prop]);
    }
  },

  loadValue: function(store, type, value) {
    if (value instanceof Array) {
      store.loadMany(type, value);
    } else {
      store.load(type, value);
    }
  },

  buildURL: function(record, suffix) {
    var url = [""];

    if (this.namespace !== undefined) {
      url.push(this.namespace);
    }

    url.push(this.pluralize(record));
    if (suffix !== undefined) {
      url.push(suffix);
    }

    return url.join("/");
  }
});
###