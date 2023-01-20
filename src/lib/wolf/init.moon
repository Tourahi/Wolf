ffi = assert require 'ffi'
appRoot, argv = ...


setPackagePath = (...) ->
  paths = {}
  for _, path in ipairs {...}
    paths[#paths + 1] = appRoot .. '/' .. path .. '/?.lua'
    paths[#paths + 1] = appRoot .. '/' .. path .. '/?/init.lua'

  basePath = package.path\gsub '%./%?%.lua;', ''
  -- add the paths to package.path
  package.path = table.concat(paths, ';') .. ';' .. basePath

  


main = ->
  setPackagePath 'src'
  assert require 'lib.wolf.moonSupport'


main!