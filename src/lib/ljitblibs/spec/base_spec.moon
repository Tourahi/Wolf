ffi = require 'ffi'
base = require 'lib.ljitblibs.base'

Dump base
describe "moonscript tests", ->
  it "runs", ->
    ffi.cdef 'typedef struct {} my_type;'
    base.define 'my_type', {my_method: -> 'ret' }
  
    assert.are.equal true, true
    