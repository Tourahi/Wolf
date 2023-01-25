ffi = assert require 'ffi'
C, ffi_cast = ffi.C, ffi.cast
pack, unpack = table.pack, table.unpack

defs = {}

snakeCase = (s) ->
  s = s\gsub '%l%u', (match) ->
    match\gsub '%u', (upper) -> '_' .. upper\lower!
  s = s\gsub '^%u%u%l', (pfx) -> pfx\sub(1,1)\lower! .. '_' .. pfx\sub(2)
  s\lower!

forceTypeInit = (name) ->
  sName = snakeCase name

{

  define: (name, spec, constructor, opts = {}) ->
    base = nil
    if name\find '#', 1
      name, baseName = name\match '(%S+)%s+#%s+(%S+)'
      base = defs[baseName]
      unless base
      error "Unknown base '#{baseName}' specified for '#{name}'"

    gtype = forceTypeInit name
}