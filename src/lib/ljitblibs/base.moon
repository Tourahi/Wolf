types = assert require 'lib.ljitblibs.gobject.type'
ffi = assert require 'ffi'
C, ffiCast = ffi.C, ffi.cast
pack, unpack = table.pack, table.unpack

defs = {}

snakeCase = (s) ->
  s = s\gsub '%l%u', (match) ->
    match\gsub '%u', (upper) -> '_' .. upper\lower!
  s = s\gsub '^%u%u%l', (pfx) -> pfx\sub(1,1)\lower! .. '_' .. pfx\sub(2)
  s\lower!

forceTypeInit = (name) ->
  sName = snakeCase name
  typeF = "#{sName}_get_type"
  ffi.cdef "GType #{typeF}();"
  status, gtype = pcall -> C[typeF]!
  status and gtype or nil 



setConstants = (def) ->
  if def.consts
    pfx = def.consts.prefix or ''
    for c in *def.consts
      full = "#{pfx}#{c}"
      def[c] = C[full]
      def[full] = C[full]

autoRequire = (module, name) ->
  assert require "lib.ljitblibs.#{module}.#{snakeCase name}"

    
{

  define: (name, spec, constructor, opts = {}) ->
    base = nil
    if name\find '#', 1
      name, baseName = name\match '(%S+)%s+#%s+(%S+)'
      base = defs[baseName]
      unless base
        error "Unknown base '#{baseName}' specified for '#{name}'"

    --Dump base
    gtype = forceTypeInit name
    ctype = ffi.typeof "#{name} *"
    cast = (o) -> ffiCast ctype, o
    
    types.registerCast name, gtype,ctype if gtype

  autoLoading: (name, def) ->
    setConstants def
    setmetatable def, __index: (t, k) -> autoRequire name, k




}