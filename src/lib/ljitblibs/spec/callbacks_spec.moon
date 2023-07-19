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