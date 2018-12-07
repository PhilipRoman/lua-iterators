local M = {}

local metatable = {
    __call = function(self, ...)
        assert(select('#', ...) > 0)
        local func = M.compose(...)
        return setmetatable({}, {
            __call = function(self, ...) return func(...) end,
            __index = M
        })
    end,
    __add = function(self, value) return M(function(x) return x + value end) end,
    __sub = function(self, value) return M(function(x) return x - value end) end,
    __mul = function(self, value) return M(function(x) return x * value end) end,
    __div = function(self, value) return M(function(x) return x / value end) end,
    __len = function(self) return M(function(x) return #x end) end,
}

setmetatable(M, metatable)

function M.eval(...)
    return M.compose(...)
end

function M.is(self, x)
    return function(...)
        return x == self(...)
    end
end

function M.method(name, ...)
    local args = {...}
    return function(object)
        return object[name](object, table.unpack(args))
    end
end

function M.bind(self, ...)
    local given = { ... }
    return M(function(...)
        local args = {}
        local index = 1
        for i = 1, #given do
            local value = given[i]
            if value == nil then
                value = select(index, ...)
                index = index + 1
            end
            args[i] = value
        end
        return self(table.unpack(args))
    end)
end

function M.format(fmt)
    fmt = tostring(fmt)
    return function(...)
        return string.format(fmt, ...)
    end
end

function M.compose(f, g)
    if g == nil then
        return f 
    end
    return function(...)
        return g(f(...))
    end
end

function M.select(self, ...)
    local indices = {...}
    return function(...)
        local args = {}
        for i = 1, #indices do
            local index = indices[i]
            table.insert(args, select(index, ...))
        end
        return self(table.unpack(args))
    end
end

function M.constant(...)
    local values = { ... }
    return function()
        return table.unpack(values)
    end
end

local IDENTITY = function(...)
    return ...
end

function M.identity()
    return IDENTITY
end

function M.either(...)
    local fs = { ... }
    return function(...)
        for _, v in ipairs(fs) do
            local value = v(...)
            if value ~= nil then
                return value
            end
        end
    end
end

return M
