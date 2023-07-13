types = assert require 'ljitblibs.gobject.type'
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

-- o: _meta
dispatchProperty = (o, prop, k, v) ->
  if type(prop) == 'string'
    k = k\gsub '_', '-'
    return o\get_typed k, prop unless v != nil
    o\set_typed k, prop, v.value
  else
    if v != nil
      setter = prop.set
      error "Attempt to set read-only property: '#{k}'" unless setter
      setter o, v.value
    else
      return prop o if type(prop) == 'function'
      return prop.get o
      
dispatch = (def, base, o, k, v, instanceCast) ->
  o = instanceCast(o) if instanceCast
  prop = def.properties[k]
  if prop
    return dispatchProperty o, prop, k, v

  unless v != nil
    defV = rawget def, k
    if defV
      if instanceCast and type(defV) == 'function'
        return (instance, ...) -> defV o, ...
      return defV

  -- parent/base
  if base
    -- defs[name] = {
    --   base: base -- parent
    --   metatype: meta_t, -- meta tab
    --   def: spec, -- type def
    --   cast: not options.no_cast and cast -- cast
    --   :options
    -- }
    dispatch base.def, base.base, o, k, v, base.cast


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
    local _meta
    _meta = spec.meta or {}

    with _meta
      -- when the key being read does not exist in spec -> metatab
      .__index = (o, k) -> dispatch spec, base, ctype if gtype 
      .__newindex = (o, k, v) -> dispatch spec, base, o, k, value: v
    
    -- Creates a ctype object 
    ffi.metatype name,_meta

    spec.properties or= {}
    setConstants spec
    spec.__type = name

    if gtype and types.query(gtype).class_size != 0
      typeClass = tyoes.classRef gtype
      -- signals
      types.classUnRef typeClass


  autoLoading: (name, def) ->
    setConstants def
    setmetatable def, __index: (t, k) -> autoRequire name, k




}