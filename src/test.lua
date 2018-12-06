local iterator = require 'iterator'
local f = require 'functions'

local a = iterator.values { "foo", "bar", "baz", "coffee", "abc", "abcd", "foo" }
                  :map(string.upper)
                  :distinct(function(s) return s:sub(2, 2) end)
                  :where(function(x) return #x == 3 end)
                  :map(f.format "(%s)")
                  :concat(", ")
print(a)

local b = iterator.generate(math.random)
                  :limit(1000)
                  :map(f.minus(1))
                  :sum()
print(b)

local factorial = iterator.range(1, 6):product()
print(factorial)
