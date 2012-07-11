redis = require 'redis'
hat = require('hat')

module.exports = class FnordMetric
  constructor: (@config = {}) ->
    @prefix = @config.prefix or 'fnordmetric'
    @rack = hat.rack()
    @r = redis.createClient()

  event: (e) ->
    uuid = @rack()
    e._namespace = @config.namespace if @config.namespace
    @r.set "#{@prefix}-event-#{uuid}", JSON.stringify e
    @r.expire "#{@prefix}-event-#{uuid}", 60
    @r.lpush "#{@prefix}-queue", uuid

  emit: (type, e = {}) ->
    e._type = type
    @event e

  pageview: (url, session) ->
    e = url: url 
    e._session = session if session?    
    @emit '_pageview', e

  setName: (name, session) ->
    @emit '_set_name',
      name: name
      _session: session

  setPicture:  (url, session) ->
    @emit '_set_picture',
      url: url
      _session: session