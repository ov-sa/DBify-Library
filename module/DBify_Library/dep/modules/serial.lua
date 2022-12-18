-----------------
--[[ Imports ]]--
-----------------

local imports = {
    getElementsByType = getElementsByType,
    addEventHandler = addEventHandler,
    getPlayerSerial = getPlayerSerial,
    table = table,
    assetify = assetify
}


------------------------
--[[ Module: Serial ]]--
------------------------

local cModule = dbify.createModule({
    moduleName = "serial",
    tableName = "dbify_serials",
    structure = {
        {"serial", "VARCHAR(100) PRIMARY KEY"}
    }
})

if dbify.settings.syncNativeSerials then
    local serverPlayers = imports.getElementsByType("player")
    for i = 1, imports.table.length(serverPlayers), 1 do
        local playerSerial = imports.getPlayerSerial(serverPlayers[i])
        cModule.create(playerSerial)
    end
    imports.addEventHandler("onPlayerJoin", root, function()
        cModule.create(imports.getPlayerSerial(source))
    end)
end