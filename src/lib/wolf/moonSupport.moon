moons = assert require 'moonscript'
moons.errs = assert require 'moonscript.errors'
lineTables = assert require 'moonscript.line_tables'

lLoadFile = loadfile
lpcall = pcall

tostring = tostring
table = table

export moon, loadfile, pcall
moon = assert require 'moon'

-- Supports both lua and moon
loadfile = (filename, mode, env) ->
  filename = tostring filename
  if filename\match '%.moon%'
    status, ret = moons.loadfile filename
    if not status then return nil, filename..': '..ret
    return status, ret
  else return lLoadFile(filename, mode, env)


errHandler = (err) ->
  if type(err) ~= 'string' then return err
  if not err\match('%.moon') then return err
  moonFile = err\match('^%[string "([^"]+%.moon)"%]') or err\match('^([^%s]+%.moon)')
  if not moonFile then return err

  if not lineTables[moonFile] then lpcall moons.loadfile, moonFile
  
  trace = debug.traceback "", 2
  trace = trace\match '%s*(.+)%s*$'
  rewritten = moons.errors.rewrite_traceback trace, err

  rewritten or err

pcall = (f, ...) -> 
  rets = table.pack xpcall(f, errHandler, ...)
  table.unpack rets, 1, rets.n