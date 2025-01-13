Framework = nil
RNRFunctions = {}

Citizen.CreateThread(function()
    if Config.Framework == "esx" then
        while Framework == nil do
            Framework = exports[Config.NameResourceCore]:getSharedObject()
            Citizen.Wait(0)
        end
    elseif Config.Framework == "qb" then
        while Framework == nil do
            Framework = exports[Config.NameResourceCore]:GetCoreObject()
            Citizen.Wait(0)
        end
    end
end)

RNRFunctions.TriggerServerCallback = function(name, cb, ...)
	if Config.Framework == 'esx' then
		Framework.TriggerServerCallback(name, cb, ...)
	elseif Config.Framework == 'qb' then
		Framework.Functions.TriggerCallback(name, cb, ...)
	end
end

RNRFunctions.GetPlayerData = function(source)
    if Config.Framework == 'esx' then
        return Framework.GetPlayerData(source)
    elseif Config.Framework == 'qb' then
        return Framework.Functions.GetPlayerData(source)
    end
end

RNRFunctions.ClNotify = function(msg, type)
    if Config.Notify == 'ox' then
        exports.ox_lib:notify(msg, type)
    elseif Config.Notify == 'esx' then
        Framework.TriggerEvent('ox_admin:notify', msg, type)
    elseif Config.Notify == 'qb' then
        Framework.Functions.Notify(msg, type)
    elseif Config.Notify == 'costum' then
        print('Jika Kamu Memilih custom Silahkan isi value tersebut di bridge/client.lua dibagian Line 39!')
    end
end