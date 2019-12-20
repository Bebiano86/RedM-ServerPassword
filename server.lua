
--- CONFIG ---
password = "senha" -- Defina aqui a senha do servidor
kickMessage = "senha inválida" -- A mensagem de expulsar de senha inválida. Padrão: senha inválida
timeRanOutMsg = "You ran out of time to enter the password" --Ainda não está ativo! Não se preocupe com isso
timeoutMessage = "Senha inválida. Aguarde alguns segundos antes de tentar se conectar novamente." -- é exibido se o usuário tentar tentar muitas vezes, isso os bloqueia do servidor por x segundos
invalidPasswordTimeout = 5 * 60 -- Aguarde um tempo até que o jogador possa se associar novamente. Alterar o primeiro valor Não o '* 60'. Padrão: 5 minutos

---------------------------------------------------------------------------------------------------------------
local Timeouts = {}

function Timeout(source)
    Timeouts[GetPlayerIdentifier(source, 1)] = os.time() + invalidPasswordTimeout
end

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00", "00", "00", "00:00:00"
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours, mins, secs, hours .. ":" .. mins .. ":" .. secs
    end
end

function TimesToSexy(m,s)
    local r = ""
    if m ~= "00" then
        r = r .. m .. "m"
    end
    if r ~= "" then r = r .. " " end
    r = r .. s .. "s"
    return r
end

function GetSexyTime(seconds)
    local _,m,s = SecondsToClock(seconds)
    return TimesToSexy(m,s)
end

---------------------------------------------------------------------------------------------------------------
AddEventHandler("playerConnecting", function(name, setMessage, deferrals)
    local source = source
    local timeout = Timeouts[GetPlayerIdentifier(source, 1)]
    if timeout then
        if timeout > os.time() then
			local sexytime = GetSexyTime(timeout - os.time())
            deferrals.defer()
            deferrals.update((timeoutMessage):format(sexytime))
            Wait(500)
            deferrals.done((timeoutMessage):format(sexytime))
        end
    end
end)

RegisterServerEvent("Fax:ServerPassword:Initialize")
AddEventHandler("Fax:ServerPassword:Initialize", function()
    local source = source
    if not IsPlayerAceAllowed(source, "Bypass") then
        TriggerClientEvent("Fax:ServerPassword:ShowPasswordPrompt", source)
    else
        TriggerClientEvent("Fax:ServerPassword:PassedPassword", source, true)
    end
end)

RegisterServerEvent('Fax:ServerPassword:CheckPassword')
AddEventHandler('Fax:ServerPassword:CheckPassword', function(Newpassword, attempts)
    local clPassword = Newpassword
    local s = source

    if clPassword == password then
        TriggerClientEvent("Fax:ServerPassword:PassedPassword", s)
    elseif password ~= clPassword then
        if attempts <= 0 then
            Timeout(s)
            DropPlayer(s, kickMessage)
        else
            TriggerClientEvent("Fax:ServerPassword:ShowPasswordPrompt", s)
        end
    else
        Timeout(s)
        DropPlayer(s, kickMessage)
    end
end)
