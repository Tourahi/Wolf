ffi = assert require 'ffi'
appRoot, argv = ...

table = table

export Dump = (o) -> print G_log.t(o)


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
    assert fd\write(bCode)
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
    G_log.trace 'byteCodeLoader : ' .. name
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
              
      status, _module = pcall(require, reqName)
      
      if status == false
        if _module\match 'module.*not found'
          relativePath = reqName\gsub '%.', pathSeparator
          path = table.concat {appRoot, 'src'..pathSeparator..'lib', relativePath}, pathSeparator
          if ffi.C.g_file_test(path, ffi.C.G_FILE_TEST_IS_DIR) ~= 0
            _module = autoModule reqName
          else
            error _module, 2
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
  require 'ljitblibs.cdefs.glib'

  wolf = autoModule 'wolf'

  args = parseArgs argv


  if args.compile then compile(args)

  base = assert require 'lib.ljitblibs.base'
  -- TEST 
  glib = assert require 'lib.ljitblibs.cdefs.gobject'
  def = {
    properties: {
      name: => print "lol"
    }
  
    intern: (name, only_if_exists = false) ->
      print "intern"
  
    from_value: (value) ->
      print "AtomStruct(value)"
  
  }

  --base.define 'GdkAtom', def, (t, name) -> t.intern(name)



stat, err = pcall main

if not stat
  print err
  error err