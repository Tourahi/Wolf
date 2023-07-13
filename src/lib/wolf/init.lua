local ffi = assert(require('ffi'))
local appRoot, argv = ...
local table = table
Dump = function(o)
  return print(G_log.t(o))
end
local parseArgs
parseArgs = function(argsV)
  local opts = {
    ['--compile'] = 'compile',
    ['-c'] = 'compile',
    ['--spec'] = 'spec',
    ['-s'] = 'spec'
  }
  local args = { }
  for _, arg in ipairs(argsV) do
    local opt = opts[arg]
    if opt then
      args[opt] = true
    else
      args[#args + 1] = arg
    end
  end
  if args.help and not args.spec then
    print(help)
    os.exit(0)
  end
  return args
end
local compile
compile = function(args)
  G_log.trace('Compilling...')
  for i = 2, #args do
    local file = args[i]
    local target = file:gsub('%.%w+$', '.bc')
    G_log.info('Compiling ' .. file)
    local f = assert(loadfile(file))
    local bCode = string.dump(f, false)
    local fd = assert(io.open(target, 'wb'))
    assert(fd:write(bCode))
    fd:close()
  end
  return G_log.trace('Compilling Done.')
end
local setPackagePath
setPackagePath = function(...)
  local paths = { }
  for _, path in ipairs({
    ...
  }) do
    paths[#paths + 1] = appRoot .. '/' .. path .. '/?.lua'
    paths[#paths + 1] = appRoot .. '/' .. path .. '/?/init.lua'
  end
  local basePath = package.path:gsub('%./%?%.lua;', '')
  package.path = table.concat(paths, ';') .. ';' .. basePath
end
local byteCodeLoader
byteCodeLoader = function()
  local path = package.path:gsub('.lua', '.bc')
  local bases = { }
  for base in path:gmatch('[^;]+') do
    table.insert(bases, #bases + 1, base)
  end
  return function(name)
    G_log.trace('byteCodeLoader : ' .. name)
    name = name:gsub('%.', '/')
    for i = 1, #bases do
      local target = bases[i]:gsub('?', name)
      local f = loadfile(target)
      if f then
        return f
      end
    end
    return nil
  end
end
local jit = jit
local pathSeparator = jit.os == 'Windows' and '\\' or '/'
local autoModule
autoModule = function(name)
  return setmetatable({ }, {
    __index = function(t, key)
      local reqName = name .. '.' .. key:gsub('%l%u', function(match)
        return match:gsub('%u', function(upper)
          return '_' .. upper:lower()
        end)
      end):lower()
      local status, _module = pcall(require, reqName)
      if status == false then
        if _module:match('module.*not found') then
          local relativePath = reqName:gsub('%.', pathSeparator)
          local path = table.concat({
            appRoot,
            'src' .. pathSeparator .. 'lib',
            relativePath
          }, pathSeparator)
          if ffi.C.g_file_test(path, ffi.C.G_FILE_TEST_IS_DIR) ~= 0 then
            _module = autoModule(reqName)
          else
            error(_module, 2)
          end
        else
          error(_module, 2)
        end
      end
      t[key] = _module
      return _module
    end
  })
end
local runSpec
runSpec = function(_argv)
  print('specing !!')
  setPackagePath('src/lib/ext/spec-tools')
  local busted = assert(loadfile(appRoot .. '/src/lib/ext/spec-tools/busted/boot'))
  Dump({
    table.unpack(_argv, 3, #_argv)
  })
  Dump(_argv)
  _G.arg = {
    table.unpack(_argv, 3, #_argv)
  }
  return busted()
end
local main
main = function()
  setPackagePath('src', 'src/lib')
  assert(require('lib.wolf.pre'))
  assert(require('lib.wolf.moonSupport'))
  table.insert(package.loaders, 2, byteCodeLoader())
  require('ljitblibs.cdefs.glib')
  local wolf = autoModule('wolf')
  local args = parseArgs(argv)
  if args.compile then
    compile(args)
  end
  if args.spec then
    return runSpec(argv)
  end
end
local stat, err = pcall(main)
if not stat then
  print(err)
  return error(err)
end
