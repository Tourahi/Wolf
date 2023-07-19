local moons = assert(require('moonscript'))
moons.errs = assert(require('moonscript.errors'))
local lineTables = assert(require('moonscript.line_tables'))
local lLoadFile = loadfile
local lpcall = pcall
local tostring = tostring
local table = table
moon = assert(require('moon'))
loadfile = function(filename, mode, env)
  filename = tostring(filename)
  if filename:match('%.moon$') then
    local status, ret = moons.loadfile(filename)
    if not status then
      return nil, filename .. ': ' .. ret
    end
    return status, ret
  else
    return lLoadFile(filename, mode, env)
  end
end
local errHandler
errHandler = function(err)
  if type(err) ~= 'string' then
    return err
  end
  if not err:match('%.moon') then
    return err
  end
  local moonFile = err:match('^%[string "([^"]+%.moon)"%]') or err:match('^([^%s]+%.moon)')
  if not moonFile then
    return err
  end
  if not lineTables[moonFile] then
    lpcall(moons.loadfile, moonFile)
  end
  local trace = debug.traceback("", 2)
  trace = trace:match('%s*(.+)%s*$')
  local rewritten = moons.errs.rewrite_traceback(trace, err)
  return rewritten or err
end
pcall = function(f, ...)
  local rets = table.pack(xpcall(f, errHandler, ...))
  return table.unpack(rets, 1, rets.n)
end
