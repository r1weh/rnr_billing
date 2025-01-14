local isDead = false
function ShowBillsMenu()
	RNRFunctions.TriggerServerCallback('esx_billing:getBills', function(bills)
		if #bills > 0 then
			local elements = {}
			for k,v in ipairs(bills) do
				table.insert(elements, {
					title = v.label,
					description = 'Kamu Memiliki Tagihan Dari '..v.label..', Lakukan Pembayaran Secepatnya',
					icon = 'fa-solid fa-scroll',
					onSelect = function()
						RNRFunctions.TriggerServerCallback('esx_billing:payBill', function(resultPay)
						end, v.id)
					end,
					metadata = {
					  {label = 'Pengirim ', value = v.label},
					  {label = 'Jumlah ', value = v.amount}
					},
				})
			end
			Citizen.Wait(300)
			lib.registerContext({
				id = 'billing_list',
				title = 'Tagihan',
				options = elements
			  })
			lib.showContext('billing_list')
		else
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Tidak Ada Tagihan' })
		end
	end)
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
        return 'YM$ '..formatted
    else
        return "Nilai tidak valid"
    end
end

if Config.Framework == 'esx' then
	AddEventHandler('esx:onPlayerDeath', function() isDead = true if Config.Debug then print("Player died. isDead set to:", isDead) end end)
	AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false if Config.Debug then print("Player Spawn. isDead set to:", isDead) end  end)
elseif Config.Framework == 'qb' then
	AddEventHandler('QBCore:onPlayerDeath', function() isDead = true if Config.Debug then print("Player died. isDead set to:", isDead) end  end)
	AddEventHandler('QBCore:onPlayerSpawn', function(spawn) isDead = false if Config.Debug then print("Player Spawn. isDead set to:", isDead) end  end)
end

RegisterCommand('pay', function()
	TriggerEvent('rnr_billing:add')
end, false)

RegisterCommand('billing', function()
	TriggerEvent('rnr_billing:add')
end, false)

RegisterNetEvent('rnr_billing:add')
AddEventHandler('rnr_billing:add', function()
	lib.registerContext({
		id = 'rnr_billing',
		title = 'BILLING',
		options = {
			{
				title = 'Tagihan',
				icon = "fas fa-file-invoice",
				onSelect = function()
					ShowBillsMenu()
				end,
			},
			{
				title = 'Tambah Tagihan',
				icon = "fas fa-plus",
				onSelect = function()
					TriggerEvent('rnr_billing:add2')
				end,
			},
			{
				title = 'Check Tagihan',
				icon = "fas fa-file-invoice-dollar",
				description = 'Untuk Memeriksa Tagihan Orang Yang Ada Disekitar',
				onSelect = function()
					TriggerEvent('rnr_billing:check')
				end,
			},
		}
	})

	lib.registerContext({
		id = 'rnr_billing2',
		title = 'Billing',
		options = {
			{
				title = 'Tagihan',
				description = '',
				onSelect = function()
					ShowBillsMenu()
				end,
			},
		}
	})

	local dataTarget = lib.callback.await('rnr-billing:server:getData', false, false)
	if dataTarget.job_name == 'ambulance' or dataTarget.job_name == 'taxi' or dataTarget.job_name == 'police' or dataTarget.job_name == 'pedagang' or dataTarget.job_name == 'mechanic' then
		lib.showContext('rnr_billing')
	else
		lib.showContext('rnr_billing2')
	end
end)


AddEventHandler('rnr_billing:check', function()
	local elementsTagihan = {}
	local closestPlayerServerId = CariPlayerTerdekat()
	if closestPlayerServerId ~= -1 then
		RNRFunctions.TriggerServerCallback('rnr_billing:checkBilling:callback', function(resultCheck)
			local tagihanHitung = 0
			for no=1, #resultCheck do 
				if string.gsub(resultCheck[no].target, 'society_', "") == RNRFunctions.GetPlayerData().job.name then
					tagihanHitung = tagihanHitung + 1
				end
			end
			Citizen.Wait(500)
			if tagihanHitung == 0 then 
				TriggerEvent('mythic_notify:client:SendAlert', { type = 'inform', text = 'Dia Tidak Memiliki Tagihan Ke '..RNRFunctions.GetPlayerData().job.label})
			else
				for no=1, #resultCheck do 
					if string.gsub(resultCheck[no].target, 'society_', "") == RNRFunctions.GetPlayerData().job.name then
						table.insert(elementsTagihan, {
							title = 'TAGIHAN '..resultCheck[no].label..' SEBESAR '..FormatMataUang(resultCheck[no].amount),
							description = 'Memiliki Tagihan Ke '..resultCheck[no].label..' Bayar Sekarang Juga',
							onSelect = function()
								TriggerServerEvent('rnr-billing:tagihkembali', resultCheck[no].identifier, resultCheck[no].amount)
							end,
						})
					end
				end
				lib.registerContext({
					id = 'rnr_billingcheck',
					title = 'BILLING CHECK',
					options = elementsTagihan
				})
				Citizen.Wait(500)
				lib.showContext('rnr_billingcheck')
			end
		end, closestPlayerServerId)
	else
		TriggerEvent('mythic_notify:client:SendAlert', { type = 'inform', text = 'Tidak Ada Orang Disekitar'})
	end
end)

AddEventHandler('rnr_billing:add2', function()
	local closestPlayerServerId = CariPlayerTerdekat()
	if Config.Debug then print('Debbug : '..json.encode(closestPlayerServerId)) end
	if closestPlayerServerId ~= -1 then
		RNRFunctions.TriggerServerCallback('rnr_billing:callback', function(result)
			local alert = lib.alertDialog({
				header = 'PERIKSA KEMBALI',
				content = 'Nama Lengkap : '..result.name,
				centered = true,
				cancel = true
			})
			
			if alert == 'confirm' then
				local input = lib.inputDialog('Invoice', {
					{type = 'number', label = 'Jumlah', description = '', icon = 'dollar'},
				  })
				  
				  if input[1] ~= '' and input[1] > 0 then 
					TriggerServerEvent("rnr_billing:TambahBilling", closestPlayerServerId, input[1])
				  else
					TriggerEvent('mythic_notify:client:SendAlert', { type = 'inform', text = 'Kolom Tidak Boleh Kosong/Lebih Kecil Dari 0'})
				  end
			else

			end
		end, closestPlayerServerId)
	else
		TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Tidak Ada Orang Disekitar'})
	end
end)


function CariPlayerTerdekat()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1

    for i=1,#players do
        if players[i] ~= PlayerId() then -- Ignore the local player
            local playerCoords = GetEntityCoords(GetPlayerPed(players[i]))
            local distance = #(GetEntityCoords(PlayerPedId()) - playerCoords)
			
            if distance < 1.8 then
                return GetPlayerServerId(players[i])
            end
        end
    end
end

AddEventHandler("playerSpawned", function()
	local ped = GetPlayerPed(-1)
	if GetPedMaxHealth(ped) ~= 200 and not IsEntityDead(ped) then
		SetPedMaxHealth(ped, 200)
		SetEntityHealth(ped, GetEntityHealth(ped) + 25)
	end
end)

