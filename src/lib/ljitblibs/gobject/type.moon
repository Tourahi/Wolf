ffi = assert require 'ffi'
assert require 'lib.ljitblibs.cdefs.gobject'

C, ffiString = ffi.C, ffi.string

{
  -- Doc! https://developer-old.gnome.org/gobject/stable/gobject-Type-Information.html

  name: (gtype) ->
    _name = C.g_type_name gtype
    if _name != nil then return ffiString _name
    else return nil

  fromName: (name) ->
    gtype = C.g_type_from_name name
    gtype != 0 and gtype or nil
    
  classRef: (gtype) -> C.g_type_class_ref gtype
  
  classUnRef: (typeClass) -> C.g_type_class_unref typeClass

  isA: (gtype, isType) -> C.g_type_is_a(gtype, isType) != 0

  defaultInterfaceRef: (gtype) -> C.g_type_default_interface_ref gtype

  defaultINterfaceUnRef: (giface) -> C.g_type_default_interface_unref giface

  query: (gtype) ->
    queryType = ffi.new 'GTypeQuery'
    C.g_type_query gtype, queryType
    queryType

}