Config = {}

Config.NameResourceCore = 'rnr_core' --Choose a name for the resource core
Config.Framework = 'esx' -- esx | qb 
Config.Notify = 'ox' -- ox | esx | qb | costum!
Config.Debug = false

Config.webhooks = {
    ['Ambulance'] = {
        Logs = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu",
        Label = 'Ambulance'
    },
    ['Police'] = {
        Logs = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu",
        Label = 'Police'
    },
    ['Mechanic'] = {
        Logs = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu",
        Label = 'Mechanic'
    },
    ['Pedagang'] = {
        Logs = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu",
        Label = 'Pedagang'
    },
    ['State'] = {
        Logs = "https://discord.com/api/webhooks/1194068817182195784/YNCwWcW9tphLSI66iTUufwqhEoPkl0adlOexY6ZWOR4-FeDWp_HM9o22sz-sLzVfZ9nu",
        Label = 'State'
    }
}