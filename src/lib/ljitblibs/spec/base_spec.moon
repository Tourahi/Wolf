ffi = require 'ffi'
base = require 'ljitblibs.base'

Dump base
describe "moonscript tests", ->
  it "runs", ->
    -- ffi.cdef 'typedef struct {} my_type;'
    -- base.define 'my_type', {my_method: -> 'ret' }
    -- o = ffi.new 'my_type'
    -- assert.equal 'ret', o\my_method!
    