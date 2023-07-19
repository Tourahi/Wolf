ffi = assert require 'ffi'
ffiCast = ffi.cast
{
  :unpack
  :pack
  :insert
} = table

_handles = {}
_refCount = 0
_options = {

}

_cbCast = (cb_type, handler) -> ffiCast('GCallback', ffiCast(cb_type, handler))

_do_dispatch = (data, ...) ->
  tonumber = tonumber
  refID = tonumber ffiCast 'gint', data
  handle = _handles[refID]
  if handle
    handler = handle.handler
    handlerArgs = handle.args

    if type(handler) == 'number'
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
    else
      -- unregister
      return

  false

_dispatch = (data, ...) ->
  print "here"
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






  void2: _cbCast 'GVCallback2', (a1, data) ->  _dispatch data, a1
  

}