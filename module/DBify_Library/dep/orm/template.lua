-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tostring = tostring,
    loadstring = loadstring,
    dbExec = dbExec,
    table = table,
    string = string
}


-----------------------
--[[ ORM: Template ]]--
-----------------------

local templateKeys = {
    ["TINYINT"] = "number",
    ["SMALLINT"] = "number",
    ["MEDIUMINT"] = "number",
    ["INT"] = "number",
    ["BIGINT"] = "number",
    ["VARCHAR"] = "string",
    ["CHAR"] = "string",
    ["BINARY"] = "string",
    ["VARBINARY"] = "string",
    ["TINYBLOB"] = "string",
    ["TINYTEXT"] = "string",
    ["BLOB"] = "string",
    ["TEXT"] = "string",
    ["MEDIUMBLOB"] = "string",
    ["MEDIUMTEXT"] = "string",
    ["LONGBLOB"] = "string",
    ["LONGTEXT"] = "string"
}

local template = [[
    local imports = {
        type = type,
        dbExec = dbExec,
        table = table,
        assetify = assetify
    }

    return {
        connection = {
            table = "<tableName>",
            key = "<keyName>"
        },

        fetchAll = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].fetchAll(table: keyColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local keyColumns = dbify.mysql.util.fetchArg(_, cArgs)
                            resolve(dbify.mysql.table.fetchContents(dbify.module["<moduleName>"].connection.table, keyColumns), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
        
        create = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].create(<keyType>: <keyName>)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer = dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= "<keyType>") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].connection.key})
                            if isExisting then return resolve(not isExisting, cArgs) end
                            resolve(imports.dbExec(dbify.mysql.connection.instance, "INSERT INTO `??` (`??`) VALUES(?)", dbify.module["<moduleName>"].connection.table, dbify.module["<moduleName>"].connection.key, identifer), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        delete = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].delete(<keyType>: <keyName>)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer = dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= "<keyType>") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].connection.key})
                            if not isExisting then return resolve(isExisting, cArgs) end
                            resolve(imports.dbExec(dbify.mysql.connection.instance, "DELETE FROM `??` WHERE `??`=?", dbify.module["<moduleName>"].connection.table, dbify.module["<moduleName>"].connection.key, identifer), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        setData = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].setData(<keyType>: <keyName>, table: dataColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= "<keyType>") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].connection.key})
                            if not isExisting then return resolve(isExisting, cArgs) end
                            resolve(dbify.mysql.data.set(dbify.module["<moduleName>"].connection.table, dataColumns, { {dbify.module["<moduleName>"].connection.key, identifer} }), cArgs)                        
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        getData = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].getData(<keyType>: <keyName>, table: dataColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= "<keyType>") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            resolve(dbify.mysql.data.get(dbify.module["<moduleName>"].connection.table, dataColumns, { {dbify.module["<moduleName>"].connection.key, identifer} }, true), cArgs)                        
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end
    }
]]

dbify.module = {}
dbify.createModule = function(config)
    if not config or (imports.type(config) ~= "table") then return false end
    config.moduleName = (config.moduleName and (imports.type(config.moduleName) == "string") and config.moduleName) or false
    config.tableName = (config.tableName and (imports.type(config.tableName) == "string") and config.tableName) or false
    config.structure = (config.structure and (imports.type(config.structure) == "table") and (#config.structure > 0) and config.structure) or false
    if not config.moduleName or not config.tableName or not config.structure then return false end
    local structure, redundantColumns = {}, {}
    for i = 1, #config.structure, 1 do
        local j = config.structure[i]
        j[1] = imports.tostring(j[1])
        if not redundantColumns[(j[1])] then
            redundantColumns[(j[1])] = true
            j[2] = imports.string.upper(imports.tostring(j[2]))
            local matchedIndex = (imports.string.find(j[2], ",") or (#j[2] + 1)) - 1
            j[2] = imports.string.sub(j[2], 0, matchedIndex)
            if imports.string.find(j[2], "PRIMARY KEY") or imports.string.find(j[2], "PRIMARY_KEY") then
                if structure.keyName then return false end
                for k, v in imports.pairs(templateKeys) do
                    if imports.string.find(j[2], k) then
                        structure.keyName, structure.keyType = j[1], v
                        structure.isAutoIncrement = ((imports.string.find(j[2], "AUTO INCREMENT") or imports.string.find(j[2], "AUTO_INCREMENT")) and true) or false
                        break
                    end
                end
                if not structure.keyName then return false end
            end
            imports.table.insert(structure, j)
        end
    end
    config.structure = structure
    if not config.structure.keyName or not config.structure.keyType or (#config.structure <= 0) then return false end
    local cTemplate = template
    local queryString, queryArguments = "CREATE TABLE IF NOT EXISTS `??` (", {config.tableName, config.structure.keyName}
    cTemplate = imports.string.gsub(cTemplate, "<moduleName>", config.moduleName)
    cTemplate = imports.string.gsub(cTemplate, "<tableName>", config.tableName)
    cTemplate = imports.string.gsub(cTemplate, "<keyName>", config.structure.keyName)
    cTemplate = imports.string.gsub(cTemplate, "<keyType>", config.structure.keyType)
    for i = 1, #config.structure, 1 do
        local j = config.structure[i]
        queryString = queryString.."`??` "..j[2]..(((i < #config.structure) and ", ") or "")
        imports.table.insert(queryArguments, j[1])
    end
    queryString = queryString..")"
    if not imports.dbExec(dbify.mysql.connection.instance, queryString, imports.table.unpack(queryArguments)) then return false end
    dbify.module[(config.moduleName)] = imports.loadstring(cTemplate)()
    return config
end