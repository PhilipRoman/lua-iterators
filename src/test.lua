local iterator = require 'iterator'
local f = require 'functions'

local a = iterator.values { "foo", "bar", "baz", "coffee", "abc", "abcd" }
                  :map(string.upper)
                  :where(function(x) return #x == 3 end)
                  :map(f.format "(%s)")
                  :concat(", ")
print(a)

local b = iterator.generate(math.random)
                  :limit(1000)
                  :map(f.plus(0.544))
                  :product()
print(b)

local factorial = iterator.range(1, 6):product()
print(factorial)
