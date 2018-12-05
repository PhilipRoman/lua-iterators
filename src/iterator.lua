local M = {}

local function checkIterator(x)
    if type(x) ~= "table" or getmetatable(x).__index ~= M then
        error(tostring(x) .. " is not an iterator!")
    end
end

local function checkFunction(x)
    if type(x) ~= "function" then
        error(tostring(x) .. " is not a callback!")
    end
end

local function check(iterator, callback)
    checkIterator(iterator)
    checkFunction(callback)
end

---@param name string
---@param func function
---@param parent table
function M.iterator(parent, name, func)
    local newName = parent and (parent.name .. "|" .. name) or name
    return setmetatable({
        name = newName,
        parent = parent
    }, {
        __call = function(self, callback)
            check(self, callback)
            func(self, callback)
        end,
        __index = M,
        __tostring = function(self)
            return self.name
        end,
        __newindex = function(tb, index, value)
            if index == "abort" then
                assert(value)
                rawset(tb, "abort", value)
                if tb.parent then
                    tb.parent.abort = value
                end
            else
                error("can't set property " .. tostring(index) .. " of " .. tostring(tb) .. " to " .. value)
            end
        end
    })
end

function M.pairs(tb)
    return M.iterator(nil, "pairs", function(self, callback)
        check(self, callback)
        for k, v in pairs(tb) do
            if self.abort then
                return
            end
            callback(k, v)
        end
    end)
end

function M.ipairs(tb)
    return M.iterator(nil, "ipairs", function(self, callback)
        check(self, callback)
        for i, v in ipairs(tb) do
            if self.abort then
                return
            end
            callback(i, v)
        end
    end)
end

function M.values(tb)
    return M.iterator(nil, "values", function(self, callback)
        check(self, callback)
        for _, v in pairs(tb) do
            if self.abort then
                return
            end
            callback(v)
        end
    end)
end

function M.of(func)
    return M.iterator(nil, "of", function(self, callback)
        check(self, callback)
        -- can't do varargs in for loop
        for v1, v2, v3, v4, v5, v6, v7, v8 in func do
            if self.abort then
                return
            end
            callback(v1, v2, v3, v4, v5, v6, v7, v8)
        end
    end)
end

function M.generate(source)
    checkFunction(source)
    return M.iterator(nil, "of", function(self, callback)
        check(self, callback)
        -- can't do varargs in for loop
        while true do
            if self.abort then
                return
            end
            callback(source())
        end
    end)
end

function M.range(from, to, step)
    from = tonumber(from)
    to = tonumber(to)
    step = tonumber(step) or 1
    return M.iterator(nil, "of", function(self, callback)
        check(self, callback)
        -- can't do varargs in for loop
        for i = from, to, step do
            if self.abort then
                return
            end
            callback(i)
        end
    end)
end

function M.forEach(self, callback)
    check(self, callback)
    self(callback)
end

function M.map(self, mapper)
    check(self, mapper)
    return M.iterator(self, "map", function(self1, callback)
        check(self1, callback)
        self:forEach(function(...)
            callback(mapper(...))
        end)
    end)
end

function M.limit(self, n)
    checkIterator(self)
    n = tonumber(n)
    if n < 0 then
        error("limit must not be negative")
    end
    return M.iterator(self, "limit", function(self1, callback)
        check(self1, callback)
        local i = 1;
        self:forEach(function(...)
            if i == n then
                self.abort = true
            end
            callback(...)
            i = i + 1
        end)
    end)
end

function M.count(self)
    checkIterator(self)
    local i = 0
    self:forEach(function(...)
        i = i + 1
    end)
    return i
end

function M.sum(self)
    checkIterator(self)
    local i = 0
    self:forEach(function(...)
        i = i + ...
    end)
    return i
end

function M.product(self)
    checkIterator(self)
    local i = 1
    self:forEach(function(...)
        i = i * ...
    end)
    return i
end

function M.concat(self, delimiter)
    checkIterator(self)
    local t = {}
    self:forEach(function(...)
        t[#t + 1] = ...
    end)
    return table.concat(t, delimiter)
end

function M.toArray(self, array)
    checkIterator(self)
    array = array or {}
    self:forEach(function(...)
        local value = ...
        table.insert(array, value)
    end)
    return array
end

return M