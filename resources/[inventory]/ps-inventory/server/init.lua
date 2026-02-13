local QBCore = exports['qb-core']:GetCoreObject()

-- Load the language locales
Core.Language.SetLanguage(Config.Language).LoadLocales()

-- Determine the framework
local determined = Framework.Determine()

-- Determine framework
if not determined then
    Core.Utilities.Log({
        type = "error",
        title = "Framework.Determine",
        message = "Unable to determine inventory framework."
    })
else
    -- Return locales from language state
    lib.callback.register(Config.ServerEventPrefix .. 'RetrieveLocales', function ()
        return Core.Language.State.Locales
    end)

    -- Load the inventory items
    Core.Classes.Inventory.Load(true)

    -- Process crafting queue
    Core.Crons.Register('Crafting.Queue', 1, function ()
        Core.Classes.Crafting.ProcessQueue()
    end, false)

    -- Clear expired drops
    Core.Crons.Register('Drops.ClearExpired', Config.Drops.ExpirationTime, function ()
        Core.Classes.Drops.ClearExpired()
    end, true)

    -- Only runs if Config.Player.DatabaseSyncingThread is true
    if Config.Player.DatabaseSyncingThread then
        Core.Crons.Register('Inventory.DatabaseSyncing', Config.Player.DatabaseSyncTime, function ()
            Core.Classes.Inventory.SyncDatabase()
        end, true)
    end

    -- Starts the cron processor
    Core.Crons.StartProcessor()

    -- Resource stop event
    AddEventHandler('onServerResourceStop', function(resource)
        if resource == GetCurrentResourceName() then

            Core.Utilities.Log({
                type = "warning",
                title = "Inventory Stopped",
                message = "Syncing database for all online players"
            })

            Core.Classes.Inventory.SyncDatabase()
        end
    end)
end


------------------------------------------------------------------
-- 🔥 QBCORE COMPATIBILITY EXPORTS (FOR YOUR CORE VERSION)
------------------------------------------------------------------

exports('LoadInventory', function(source, citizenid)
    local inv = MySQL.single.await(
        'SELECT items FROM `inventories` WHERE identifier = ? LIMIT 1',
        { "player-" .. citizenid }
    )

    if not inv or not inv.items then
        return {}
    end

    local items = json.decode(inv.items or "[]")

    -- If needed: convert PS format → QB format
    return Core.Classes.Inventory.ConvertPsToQb(items)
end)

exports('SaveInventory', function(source, citizenid)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local qbItems = Player.PlayerData.items

    -- If needed: convert QB format → PS format
    local psItems = Core.Classes.Inventory.ConvertQbToPs(qbItems)

    MySQL.update.await(
        'UPDATE `inventories` SET items = ? WHERE identifier = ?',
        { json.encode(psItems), "player-" .. citizenid }
    )

    return true
end)
