local M = {}

function M.plus(x)
    x = tonumber(x)
    return function(y)
        return x + y
    end
end

function M.minus(x)
    x = tonumber(x)
    return function(y)
        return y - x
    end
end

function M.multiplyBy(x)
    x = tonumber(x)
    return function(y)
        return x * y
    end
end

function M.divideBy(x)
    x = tonumber(x)
    return function(y)
        return y / x
    end
end

function M.bind(func, ...)
    local args = { ... }
    return function()
        return func(table.unpack(args))
    end
end

function M.format(fmt)
    fmt = tostring(fmt)
    return function(...)
        return string.format(fmt, ...)
    end
end

function M.compose(f, g)
    return function(...)
        return g(f(...))
    end
end

function M.discard(f)
    return function(...)
        return f((...))
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