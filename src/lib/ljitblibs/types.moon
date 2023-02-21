Type = assert require 'lib.ljitblibs.gobject.type'
ffi = assert require 'ffi'
assert require 'lib.ljitblibs.cdefs.gtk'

C, ffiCast, ffiString = ffi.C, ffi.cast, ffi.string

casts = {}
baseTypes = {}

for baseType in *{
  'gchar', 'glong', 'gulong', 'gint', 'guint', 'gint64', 'guint64', 'gboolean',
  'gpointer', 'guint64', 'gdouble', 'GObject'
}
  ctype = ffi.typeof baseType
  gtype = Type.fromName baseType
  casts[tonumber gtype] = (v) -> ffiCast ctype, v
  baseTypes[baseType] = gtype

luaConverters = {
  gboolean: (v) -> v != 0 -- 0 false else is true

  'gchar*': (v) ->
    return nil if v == nil
    s = ffiString v
    C.g_free v
    s
}


{
  :baseTypes

  luaValue: (type, v) ->
    return nil if v == nil
    converter = luaConverters[type]
    return converter v if converter
    v

  cast: (gtype, v) ->
    c = casts[tonumber gtype]
    c and c(v) or v

  registerCast: (name, gtype, ctype) ->
    ctype = ffi.typeof ctype if type(ctype) == 'string'
    cast = (v) -> ffiCast ctype, v
    casts[tonumber gtype] = cast
    casts[name] = cast

  castWidgetPtr: (ptr) ->
    return nil if ptr == nil
    name =  ffiString C.gtk_widget_get_name ptr
    cast = casts[name]
    cast and cast(ptr) or ptr

}