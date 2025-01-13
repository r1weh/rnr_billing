local societies = {}
AddEventHandler("esx_society:registerSociety", function(n, label, a)
	local name, account = n, a;
    local tbl = {
        ["name"] = name,
        ["account"] = account,
    }
	local exists = false;

    for _, i in pairs(societies) do
        if i.name == name then
            exists, i = true, tbl
            break
        end
    end

    if exists == false then
		societies[#societies+1] = tbl
    end
end)

function findSociety(account)
    for _, i in pairs(societies) do
        if i["account"] == account then
            return i
        end
    end
end

function FormatMataUang(amount)
    local formattedAmount = tonumber(amount)
    if formattedAmount then
        local formatted = amount
        local k = 0
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
            if k == 0 then
                break
            end
        end
        return '$ '..formatted
    else
        return "Nilai tidak valid"
    end
end


RNRFunctions.RegisterServerCallback('klrp_billing:checkBilling:callback', function(source, cb, xTarget)
	local xTarget = RNRFunctions.GetPlayerFromId(xTarget)
	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xTarget.identifier
	}, function(result)
		cb(result)
	end)
end)

lib.callback.register('klrp-billing:server:getData', function(source, target)
    local xTarget
	if target then
		xTarget = RNRFunctions.GetPlayerFromId(target)
	else
		xTarget = RNRFunctions.GetPlayerFromId(source)
	end
	
	local dataTarget = {
		name = xTarget.name,
		job_name = xTarget.job.name,
		job_label = xTarget.job.label
	}
    return dataTarget
end)

RNRFunctions.RegisterServerCallback('klrp_billing:callback', function(source, cb, xTarget)
	local xTarget = RNRFunctions.GetPlayerFromId(xTarget)
	local dataTarget = {
		name = xTarget.name,
		job_name = xTarget.job.name,
		job_label = xTarget.job.label
	}
	cb(dataTarget)
end)


RegisterServerEvent('ym-billing:tagihkembali')
AddEventHandler('ym-billing:tagihkembali', function(idenTarget, jmlTagihan)
	local xTarget = RNRFunctions.GetPlayerFromIdentifier(idenTarget)
	local xPlayer = RNRFunctions.GetPlayerFromId(source)
	
	if xTarget and xPlayer then 
		TriggerClientEvent('mythic_notify:client:SendAlert', xTarget.source, { type = 'inform', text = xPlayer.name..' Memperingati Anda Untuk Membayar Tagihan Anda Sebesar '..FormatMataUang(jmlTagihan), length = 25000})
	end

end)
RegisterServerEvent('klrp_billing:TambahBilling')
AddEventHandler('klrp_billing:TambahBilling', function(target, jumlah)
	local source = source
	local xTarget = RNRFunctions.GetPlayerFromId(target)
	local xPlayer = RNRFunctions.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		JobName = "EMS"
	elseif xPlayer.job.name == 'police' then
		JobName = "POLISI"
	elseif xPlayer.job.name == 'pedagang' then
		JobName = "PEDAGANG"
	elseif xPlayer.job.name == 'mechanic' then
		JobName = "MEKANIK"
	elseif xPlayer.job.name == 'state' then
		JobName = "STATE"
	end
	
	MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)', {
		['@identifier'] = xTarget.identifier,
		['@sender'] = xPlayer.identifier,
		['@target_type'] = 'society',
		['@target'] = 'society_'..xPlayer.job.name,
		['@label'] = JobName,
		['@amount'] = jumlah
	}, function(rowsChanged)
		xTarget.showNotification('Anda Baru Saja Menerima INVOICE')
	end)
end)

RegisterServerEvent('ym-billing:discordWebhook')
AddEventHandler('ym-billing:discordWebhook', function(penagih, penerima, jumlah, targetSociety)
	local xPlayer = RNRFunctions.GetPlayerFromIdentifier(penerima)
	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = penagih
	}, function(resultSender)
		KirimDCBang(resultSender[1].firstname..' '..resultSender[1].lastname, xPlayer.name, jumlah, targetSociety)
	end)
end)

RegisterServerEvent('esx_billing:sendBill')
AddEventHandler('esx_billing:sendBill', function(target, sharedAccountName, label, amount)
	local src, tgt = source;
	local xPlayer, xTarget = RNRFunctions.GetPlayerFromId(src), RNRFunctions.GetPlayerFromId(target)
	amount = RNRFunctions.Round(amount)

	if amount > 0 and xTarget then

		local society = findSociety(sharedAccountName)
		if xPlayer.job.name == society.name then
			TriggerEvent('esx_addonaccount:getSharedAccount', sharedAccountName, function(account)
				if account then
					MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)', {
						['@identifier'] = xTarget.identifier,
						['@sender'] = xPlayer.identifier,
						['@target_type'] = 'society',
						['@target'] = sharedAccountName,
						['@label'] = label,
						['@amount'] = amount
					}, function(rowsChanged)
						xTarget.showNotification('Anda Baru Saja Menerima INVOICE')
					end)
				else
					MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)', {
						['@identifier'] = xTarget.identifier,
						['@sender'] = xPlayer.identifier,
						['@target_type'] = 'player',
						['@target'] = xPlayer.identifier,
						['@label'] = label,
						['@amount'] = amount
					}, function(rowsChanged)
						xTarget.showNotification('Anda Baru Saja Menerima INVOICE')
					end)
				end
			end)
		else
			print(
				string.format(
					"^2%s^7 -> [^1%s^7] ^1%s^7 has attempted to send a bill to [^5%s^7] ^5%s^7 from the ^2%s^7 via the society but, the player was not in the society job.",
					GetCurrentResourceName(), src, GetPlayerName(src), tgt, GetPlayerName(tgt), society.name
				)
			)
		end
	end
end)

RNRFunctions.RegisterServerCallback('esx_billing:getBills', function(source, cb)
	local xPlayer = RNRFunctions.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT amount, id, label FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		cb(result)
	end)
end)

RNRFunctions.RegisterServerCallback('esx_billing:getTargetBills', function(source, cb, target)
	local xPlayer = RNRFunctions.GetPlayerFromId(target)

	if xPlayer then
		MySQL.Async.fetchAll('SELECT amount, id, label FROM billing WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

RNRFunctions.RegisterServerCallback('esx_billing:payBill', function(source, cb, billId)
	local xPlayer = RNRFunctions.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT sender, target_type, target, amount FROM billing WHERE id = @id', {
		['@id'] = billId
	}, function(result)
		if result[1] then
			local amount = result[1].amount
			local xTarget = RNRFunctions.GetPlayerFromIdentifier(result[1].sender)

			if xTarget then 
				KirimDCBang(xTarget.name, xPlayer.name, amount, result[1].target)
			else
				MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
					['@identifier'] = result[1].sender
				}, function(resultSender)
					KirimDCBang(resultSender[1].firstname..' '..resultSender[1].lastname, xPlayer.name, amount, result[1].target)
				end)
			end

			if result[1].target_type == 'player' then
				if xTarget then
					if xPlayer.getMoney() >= amount then
						MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
							['@id'] = billId
						}, function(rowsChanged)
							if rowsChanged == 1 then
								xPlayer.removeMoney(amount)
								xTarget.addMoney(amount)
								TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = 'Kamu Membayar Invoice Sebesar YM$ '..RNRFunctions.GroupDigits(amount), style = { ['background-color'] = '#9AFF35', ['color'] = '#000000' }, length = 25000 })
								TriggerClientEvent('mythic_notify:client:SendAlert', xTarget.source, { type = 'inform', text = xPlayer.name..' Telah Membayar Tagihan Sebesar '..FormatMataUang(amount), style = { ['background-color'] = '#9AFF35', ['color'] = '#000000' }, length = 25000 })
							end
							cb()
						end)
					else
						MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
							['@id'] = billId
						}, function(rowsChanged)
							if rowsChanged == 1 then
								xPlayer.removeAccountMoney('bank', amount)
								xTarget.addAccountMoney('bank', amount)
								TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = 'Kamu Membayar Invoice Sebesar YM$ '..RNRFunctions.GroupDigits(amount), style = { ['background-color'] = '#9AFF35', ['color'] = '#000000' }, length = 25000 })
								TriggerClientEvent('mythic_notify:client:SendAlert', xTarget.source, { type = 'inform', text = xPlayer.name..' Telah Membayar Tagihan Sebesar '..FormatMataUang(amount), style = { ['background-color'] = '#9AFF35', ['color'] = '#000000' }, length = 25000 })
							end
							cb()
						end)
					end
				else
					xPlayer.showNotification('Pemain Tidak Berada Dikota')
				end
			else
				TriggerEvent('esx_addonaccount:getSharedAccount', result[1].target, function(account)
					if xPlayer.getMoney() >= amount then
						MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
							['@id'] = billId
						}, function(rowsChanged)
							if rowsChanged == 1 then
								xPlayer.removeMoney(amount)
								account.addMoney(amount)
								TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text ='Kamu Telah Membayar Tagihan Sebesar '..FormatMataUang(amount), style = { ['background-color'] = '#9AFF35', ['color'] = '#000000' }, length = 25000 })
								if xTarget then
									TriggerClientEvent('mythic_notify:client:SendAlert', xTarget.source, { type = 'inform', text = xPlayer.name..' Telah Membayar Tagihan Sebesar '..FormatMataUang(amount), style = { ['background-color'] = '#9AFF35', ['color'] = '#000000' }, length = 25000 })
								end
							end
							cb()
						end)
					else
						MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
							['@id'] = billId
						}, function(rowsChanged)
							if rowsChanged == 1 then
								xPlayer.removeAccountMoney('bank', amount)
								account.addMoney(amount)
								
								TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = 'Kamu Membayar Tagihan Sebesar '..RNRFunctions.GroupDigits(amount), style = { ['background-color'] = '#9AFF35', ['color'] = '#000000' }, length = 25000 })
								if xTarget then
									TriggerClientEvent('mythic_notify:client:SendAlert', xTarget.source, { type = 'inform', text = xPlayer.name..' Telah Membayar Tagihan Sebesar '..FormatMataUang(amount), style = { ['background-color'] = '#9AFF35', ['color'] = '#000000' }, length = 25000 })
								end
							end
							cb()
						end)
					end
				end)
			end
		end
	end)
end)


function KirimDCBang(penagih, penerima, jumlah, targetSociety)
	if targetSociety == "society_ambulance" then
		LinkSent = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu"
		Instansi = 'EMS'
	elseif targetSociety == "society_police" then
		LinkSent = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu"
		Instansi = 'POLISI'
	elseif targetSociety == "society_mechanic" then
		LinkSent = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu"
		Instansi = 'MEKANIK'
	elseif targetSociety == "society_pedagang" then
		LinkSent = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu"
		Instansi = 'PEDAGANG'
	elseif targetSociety == "society_state" then
		LinkSent = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu"
		Instansi = 'STATE'
	end

    local connect = {
        {
            ["color"] = 16711680,
            ["title"] = "**YUME INVOICE**",
            ["description"] = "Nama Penagih : "..penagih.."\nNama Penerima : "..penerima.."\nInstansi : "..Instansi.."\nJumlah : "..jumlah,
            ["footer"] = {
                ["text"] = os.date("%d-%B-%Y  (%H:%M:%S)"),
            },
        }
    }
    PerformHttpRequest(LinkSent, function(err, text, headers) end, 'POST', json.encode({username = "YUME INVOICE", embeds = connect}), { ['Content-Type'] = 'application/json' })
end