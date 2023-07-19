ffi = require 'ffi'
callbacks = require 'ljitblibs.callbacks'

dispatch = (hndl, arg) ->
  cb  = ffi.cast 'GVCallback2', callbacks.void2
  cb callbacks.castArg(arg), callbacks.castArg(hndl.id)


  
describe 'register(handler, description, handler, ...)', ->
  it 'creates a handler that can be dispatched to', -> 
    handler = spy.new -> nil
    handle = callbacks.register handler, 'test'
    dispatch handle, 123
    assert.spy(handler).was_called!

  it 'Allows multiple callbacks', ->
    handler = spy.new -> nil
    handle = callbacks.register handler, 'test'
    dispatch handle, 123
    dispatch handle, 123
    dispatch handle, 123
    assert.spy(handler).was_called 3

  it "Passes additional args", ->
    handler = spy.new -> nil
    handle = callbacks.register handler, 'test', 1, 2, "a"
    dispatch handle, 1999
    assert.spy(handler).was_called_with callbacks.castArg(1999), 1, 2, "a"
  
  context 'life cycle management', ->
    it 'Anchors a handler so it does not get collected by gc', ->
      holder = setmetatable { handler: -> }, __mode: 'v'
      callbacks.register holder.handler, 'test'
      collectgarbage!
      assert.is_not_nil holder.handler

    describe 'unregister a handle', ->
      it 'Uregisters a handler', ->
        handler = spy.new -> nil
        handle = callbacks.register handler, 'test'
        callbacks.unregister handle
        dispatch handle, 1999
        assert.spy(handler).was_not_called!