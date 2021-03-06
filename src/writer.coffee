{EventEmitter} = require 'events'

_ = require 'underscore'
{WriterNSQDConnection} = require './nsqdconnection'

###
Publish messages to nsqds.

Usage:

w = new Writer '127.0.0.1', 4150
w.connect()

w.on Writer.READY, ->
  # Send a single message
  w.publish 'sample_topic', 'one'
  # Send multiple messages
  w.publish 'sample_topic', ['two', 'three']
w.on Writer.CLOSED, ->
  console.log 'Writer closed'
###
class Writer extends EventEmitter

  # Writer events
  @READY: 'ready'
  @CLOSED: 'closed'

  constructor: (@nsqdHost, @nsqdPort) ->

  connect: ->
    @conn = new WriterNSQDConnection @nsqdHost, @nsqdPort, 30
    @conn.connect()

    @conn.on WriterNSQDConnection.READY, =>
      @emit Writer.READY

    @conn.on WriterNSQDConnection.CLOSED, =>
      @emit Writer.CLOSED

  ###
  Publish a message or a list of messages to the connected nsqd. The contents
  of the messages should either be strings or buffers with the payload encoded.

  Arguments:
    topic: A valid nsqd topic.
    msgs: A string, a buffer, or a list of string/buffers.
  ###
  publish: (topic, msgs) ->
    unless @conn?
      throw new Error "No active Writer connection to send messages."
    msgs = [msgs] unless _.isArray msgs
    @conn.produceMessages topic, msgs

  close: ->
    @conn.destroy()

module.exports = Writer
