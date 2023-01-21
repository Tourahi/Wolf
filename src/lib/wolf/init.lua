local ffi = assert(require('ffi'))
local appRoot, argv = ...
local table = table
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
    print('Debug: bLoader : ' .. name)
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
  return setmetatable(name, {
    __index = function(t, key)
      name = "wolf"
      local reqName = name .. '.' .. key:gsub('%l%u', function(match)
        return match:gsub('%u', function(upper)
          return '_' .. upper:lower()
        end)
      end):lower()
      local status, _module = pcall(require, reqName)
      if not status then
        local relativePath = reqName:gsub('%.', pathSeparator)
        local path = table.concat({
          appRoot,
          'src' .. pathSeparator .. 'lib',
          relativePath
        }, pathSeparator)
      else
        error(_module, 2)
      end
      t[key] = _module
      return _module
    end
  })
end
local main
main = function()
  setPackagePath('src')
  assert(require('lib.wolf.moonSupport'))
  return table.insert(package.loaders, 2, byteCodeLoader())
end
local stat, err = pcall(main)
if not stat then
  print(err)
  return error(err)
end
