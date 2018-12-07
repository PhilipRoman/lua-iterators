local iterator = require 'iterator'
local F = require 'functions'

local a = iterator.values { "foo", "bar", "baz", "coffee", "abc", "abcd", "foo" }
                  :map(string.upper)
                  :distinct(F.method('sub', 2, 2))
                  :where(F(string.len):is(3))
                  :map(F.format "(%s)")
                  :concat(", ")
print(a)

local b = iterator.generate(math.random)
                  :limit(1000)
                  :map(F - 1)
                  :sum()
print(b)

local factorial = iterator.range(1, 6):product()
print(factorial)
