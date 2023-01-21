ffi = assert require 'ffi'
appRoot, argv = ...

table = table


setPackagePath = (...) ->
  paths = {}
  for _, path in ipairs {...}
    paths[#paths + 1] = appRoot .. '/' .. path .. '/?.lua'
    paths[#paths + 1] = appRoot .. '/' .. path .. '/?/init.lua'

  basePath = package.path\gsub '%./%?%.lua;', ''
  -- add the paths to package.path
  package.path = table.concat(paths, ';') .. ';' .. basePath

-- See : https://pgl.yoyo.org/luai/i/package.loaders
byteCodeLoader = () ->
  path = package.path\gsub '.lua', '.bc'
  bases = {}
  for base in path\gmatch '[^;]+'
    table.insert bases, #bases + 1, base

  return (name) ->
    print 'Debug: bLoader : ' .. name
    name = name\gsub '%.', '/'
    for i = 1, #bases
      target = bases[i]\gsub '?', name
      f = loadfile target
      if f then return f
    return nil

jit = jit
pathSeparator = jit.os == 'Windows' and '\\' or '/'

autoModule = (name) ->
  return setmetatable name, {
    __index: (t, key) ->
      name = "wolf"
      reqName = name .. '.' .. key\gsub('%l%u', (match) ->
        return match\gsub('%u', (upper) ->
          '_' .. upper\lower!))\lower!
      
      status, _module = pcall require, reqName
      if not status
        relativePath = reqName\gsub '%.', pathSeparator
        path = table.concat {appRoot, 'src'..pathSeparator..'lib', relativePath}, pathSeparator
        -- TODO glib bindings
        -- if ffi.C.g_file_test(path, ffi.C.G_FILE_TEST_IS_DIR) ~= 0
        --   _module = autoModule reqName
        -- else
        --   error _module, 2
      else
          error _module, 2
      t[key] = _module
      _module
  }

main = ->
  setPackagePath 'src'
  -- add custom moon support
  assert require 'lib.wolf.moonSupport'
  table.insert package.loaders, 2, byteCodeLoader!

  --autoModule 'wolf'

stat, err = pcall main

if not stat
  print err
  error err