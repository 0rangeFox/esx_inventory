function getCoordsFromOwner(identifier)
    local x = tonumber(string.sub(string.match(identifier, 'x[-]?%d+'), 2))
    local y = tonumber(string.sub(string.match(identifier, 'y[-]?%d+'), 2))
    local z = tonumber(string.sub(string.match(identifier, 'z[-]?%d+'), 2))
    return vector3(x, y, z)
end

function getOwnerFromCoords(coords)
    local x, y, z = table.unpack(coords)
    x = math.floor(math.round(x, 0))
    y = math.floor(math.round(y, 0))
    z = math.floor(math.round(z, 0))
    return 'x' .. x .. 'y' .. y .. 'z' .. z
end