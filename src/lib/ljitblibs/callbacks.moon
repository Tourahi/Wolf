ffi = assert require 'ffi'
ffiCast = ffi.cast
{
  :unpack
  :pack
  :insert
} = table

_handles = {}
_refCount = 0
_weakHandlerIdCnt = 0
_options = {

}

_unrefedHandlers = setmetatable {}, __mode: 'v' -- weak val
_unrefedArgs = setmetatable {}, __mode: 'k' -- weak keys


_cbCast = (cb_type, handler) -> ffiCast('GCallback', ffiCast(cb_type, handler))


_unregister = (handle) ->
  error "callbacks.unregister! : Missing arg #1 (handle)", 2 unless handle
  return false unless _handles[handle.id]
  _unrefedHandlers[handle.handler] = nil if type(handle.handler) == 'number'
  _handles[handle.id] = nil
  true

_do_dispatch = (data, ...) ->
  tonumber = tonumber
  refID = tonumber ffiCast 'gint', data
  handle = _handles[refID]
  if handle
    handler = handle.handler
    handlerArgs = handle.args

    if type(handler) == 'number'
      return -- TODO
      -- handler = unrefedHandlers[handler]
      -- handler_args = unrefedArgs[handler]

    if handler
      args = pack ...

      if _options.dispatcher
        insert args, 1, handler
        insert args, 2, handle.desc
        args.n += 2
        handler = _options.dispatcher

      for i = 1, handlerArgs.n
        args[args.n + i] = handlerArgs[i]

      status, ret = pcall handler, unpack(args, 1, args.n + handlerArgs.n)
      return ret == true if status
      _options.onErr "callbacks: error in '#{handle.desc}' handler: '#{ret}'"
    else
      _unregister handle

  false

_dispatch = (data, ...) ->
  status, ret = pcall _do_dispatch, data, ...
  unless status
    _options.onErr "callbacks: error in dispatch: '#{ret}'"
    return false
  ret


{

  castArg: (arg) -> ffi.cast 'gpointer', arg

  register: (handler, desc, ...) ->
    _refCount += 1

    handle = {
      :handler
      :desc
      id: _refCount
      args: pack ...
    }

    _handles[handle.id] = handle
    handle

  unregister: _unregister

  
  unrefHandle: (handle) ->
    handler = handle.handler
    if type(handler) != 'number'
      _weakHandlerIdCnt += 1
      _unrefedHandlers[_weakHandlerIdCnt] = handler
      _unrefedArgs[handler] = handle.args
      handle.handler = _weakHandlerIdCnt
      handle.args = nil
      handler


  void2: _cbCast 'GVCallback2', (a1, data) ->  _dispatch data, a1
  

}