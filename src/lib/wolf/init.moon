ffi = assert require 'ffi'
appRoot, argv = ...

table = table

Dump = assert(require('moon').p)


parseArgs = (argsV) ->
  opts = {
    ['--compile']: 'compile',
    ['-c']: 'compile'
  }

  args = {}

  for _, arg in ipairs argsV
    opt = opts[arg]
    if opt
      args[opt] = true
    else
      args[#args + 1] = arg

  if args.help and not args.spec
    print help -- TODO
    os.exit 0

  args

compile = (args) ->
  for i = 2, #args
    file = args[i]
    target = file\gsub '%.%w+$', '.bc'
    G_log.info 'Compiling ' .. file
    f = assert loadfile(file)
    bCode = string.dump f, false
    fd = assert io.open(target, 'wb')
    assert fd\write bCode
    fd\close!

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
  return setmetatable {}, {
    __index: (t, key) ->
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
  setPackagePath 'src', 'src/lib'
  -- add custom moon support
  assert require 'lib.wolf.pre'
  assert require 'lib.wolf.moonSupport'
  table.insert package.loaders, 2, byteCodeLoader!

  args = parseArgs argv

  Dump args

  if args.compile then compile(args)

  

  --wolf = autoModule 'wolf'

  --print wolf.base

stat, err = pcall main

if not stat
  print err
  error err