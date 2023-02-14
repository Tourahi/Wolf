base = assert require 'lib.ljitblibs.base'
assert require 'lib.ljitblibs.cdefs.gobject'
ffi = assert require 'ffi'
C = ffi.C

base.autoLoading 'gobject', {
  gcPtr: (o) ->
    return nil if o == nil
    
    if C.g_object_is_floating(o) != 0
      C.g_object_ref_sink(o)

  refPtr: (o) ->
    return nil if o == nil
      
    C.g_object_ref o
    ffi.gc(o, C.g_object_unref)
}