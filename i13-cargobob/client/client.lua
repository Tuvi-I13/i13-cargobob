PlayerData = {}
local pedspawned = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function(Player)
    	PlayerData =  QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate')
AddEventHandler('QBCore:Client:OnGangUpdate', function(gang)
     	PlayerData.gang = gang
end)

RegisterNetEvent('QBCore:Player:SetPlayerData')
AddEventHandler('QBCore:Player:SetPlayerData', function(val)
	PlayerData = val
end)

CreateThread(function()
	while true do
		Wait(1000)
		for k, v in pairs(Config.GaragePedLocations) do
			local pos = GetEntityCoords(PlayerPedId())	
			local dist = #(pos - vector3(v.coords.x, v.coords.y, v.coords.z))
			
			if dist < 40 and not pedspawned then
				TriggerEvent('i13-cargobob:spawn:ped', v.coords)
				pedspawned = true
			end
			if dist >= 35 then
				pedspawned = false
				DeletePed(npc)
			end
		end
	end
end)

RegisterNetEvent('i13-cargobob:spawn:ped')
AddEventHandler('i13-cargobob:spawn:ped',function(coords)
	local hash = "a_c_chimp"

	RequestModel(hash)
	while not HasModelLoaded(hash) do 
		Wait(10)
	end

    	pedspawned = true
	npc = CreatePed(5, hash, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
	FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
	loadAnimDict("amb@world_human_cop_idles@male@idle_b") 
	TaskPlayAnim(npc, "amb@world_human_cop_idles@male@idle_b", "idle_e", 8.0, 1.0, -1, 17, 0, 0, 0, 0)
end)

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(5)
    end
end

RegisterNetEvent('i13-cargobob:garage')
AddEventHandler('i13-cargobob:garage', function(bs)
    local vehicle = bs.vehicle
    local coords = vector4(1495.27, 1067.59, 116.58, 141.92)
        if PlayerData.gang.name == "racing" then
            if vehicle == 'cargobob2' then		
                QBCore.Functions.SpawnVehicle(vehicle, function(veh)
                    SetVehicleNumberPlateText(veh, "FRANKU"..tostring(math.random(1000, 9999)))
                    exports['LegacyFuel']:SetFuel(veh, 100.0)
                    SetEntityHeading(veh, coords.w)
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                    SetVehicleEngineOn(veh, true, true)
                end, coords, true)
            end
        else
            QBCore.Functions.Notify('Sa ei meeldi monkele :cccc', 'error')
        end
end)

RegisterNetEvent('i13-cargobob:storecar')
AddEventHandler('i13-cargobob:storecar', function()
    QBCore.Functions.Notify('Kopter garaazi pandud')
    local car = GetVehiclePedIsIn(PlayerPedId(),true)
    NetworkFadeOutEntity(car, true,false)
    Wait(2000)
    QBCore.Functions.DeleteVehicle(car)
end)

RegisterNetEvent('qb-menu:RacingGarage', function()
    exports['qb-menu']:openMenu({
        {
            header = "| Monke Garaaz |",
            txt = ""
        },
        {
            header = "Cargobob",
            txt = "Monke",
            params = {
                event = "i13-cargobob:garage",
                args = {
                    vehicle = 'cargobob2',
                }
            }
        },
        {
            header = "• Pane Kopter Tagasi",
            txt = "Pane kopter tagasi",
            params = {
                event = "i13-cargobob:storecar",
                args = {
                    
                }
            }
        },
    })
end)

CreateThread(function()
    local models = {
        'a_c_chimp',
    }
    exports['qb-target']:AddTargetModel(models, {
        options = {
            {
                type = "client",
				event = "qb-menu:RacingGarage",
				icon = "fas fa-helicopter",
				label = "Rallikopter",
                gang = "racing",
            }
        },
        distance = 2.5,
    })
end)