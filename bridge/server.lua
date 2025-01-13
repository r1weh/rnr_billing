Framework = nil
RNRFunctions = {}

if Config.Framework == 'esx' then
    Framework = exports[Config.NameResourceCore]:getSharedObject()
elseif Config.Framework == 'qb' then
    Framework = exports[Config.NameResourceCore]:GetCoreObject()
end

RNRFunctions.RegisterServerCallback = function(name, cb, ...)
	if Config.Framework == 'esx' then
		Framework.RegisterServerCallback(name, cb, ...)
	elseif Config.Framework == 'qb' then
		Framework.Functions.CreateCallback(name, cb, ...)
	end
end

RNRFunctions.GetPlayerFromId = function(source)
	if Config.Framework == 'esx' then
		return Framework.GetPlayerFromId(source)
	elseif Config.Framework == 'qb' then
		return Framework.Functions.GetPlayer(source)
	end
end

RNRFunctions.Notify = function(source, msg, info)
	if Config.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', source, msg)
    elseif Config.Framework == 'qb' then
        TriggerClientEvent('QBCore:Notify', source, msg, info)
	end
end

RNRFunctions.GetPlayerFromIdentifier = function(identifier)
    if Config.Framework == 'esx' then
        return Framework.GetPlayerFromIdentifier(identifier)
    elseif Config.Framework == 'qb' then
        return RNRFunctions.GetPlayerByIdentifier(identifier)
    end
end

RNRFunctions.GetPlayerByIdentifier = function(identifier)
    for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData.license == identifier then
            return Player
        end
    end
    return nil
end

RNRFunctions.Round = function(amount, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(amount * mult + 0.5) / mult
end

RNRFunctions.GroupDigits = function(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end