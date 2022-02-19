--CREDIT: @tylerneylon: https://gist.github.com/tylerneylon/81333721109155b2d244
local function deepCopy(obj)
    if type(obj) ~= "table" then return obj end
	print(10)
    local res = setmetatable({}, getmetatable(obj))
    for k, v in pairs(obj) do res[deepCopy(k)] = deepCopy(v) end
	print("res",res.playerList)
    return res
end

return deepCopy