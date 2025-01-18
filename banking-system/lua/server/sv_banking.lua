local database = include("server/sv_database.lua")

util.AddNetworkString("Banking_UpdateBalance")
util.AddNetworkString("Banking_Transaction")
util.AddNetworkString("RequestBalance")
util.AddNetworkString("SendBalance")
util.AddNetworkString("OpenBankTerminal")
util.AddNetworkString("TransactionSuccess")
util.AddNetworkString("TransactionError")

local playerAccounts = {}

local function initializePlayerAccount(ply)
    if not playerAccounts[ply:SteamID()] then
        playerAccounts[ply:SteamID()] = { balance = 0 }
        print("Creating account for player: " .. ply:SteamID())
        database.createAccount(ply:SteamID(), function()
            print("Account created for player: " .. ply:SteamID())
        end)
    end
end

local function updatePlayerBalance(ply)
    if playerAccounts[ply:SteamID()] then
        net.Start("Banking_UpdateBalance")
        net.WriteInt(playerAccounts[ply:SteamID()].balance, 32)
        net.Send(ply)
    else
        print("Error: Player account not initialized for " .. ply:SteamID())
    end
end

net.Receive("Banking_Transaction", function(len, ply)
    local action = net.ReadString()
    local amount = tonumber(net.ReadInt(32)) 
    print("Received Banking_Transaction: action=" .. action .. ", amount=" .. amount)

    initializePlayerAccount(ply)

    if action == "deposit" then
        print(ply:Nick() .. " has " .. ply:GetMoney() .. " money.")
        if ply:RemoveMoney(amount) then
            playerAccounts[ply:SteamID()].balance = playerAccounts[ply:SteamID()].balance + amount
            database.updateBalance(ply:SteamID(), playerAccounts[ply:SteamID()].balance, function()
                updatePlayerBalance(ply)
                net.Start("TransactionSuccess")
                net.WriteString("Deposit successful!")
                net.Send(ply)
            end)
        else
            net.Start("TransactionError")
            net.WriteString("Insufficient funds to deposit!")
            net.Send(ply)
        end
    elseif action == "withdraw" then
        local balance = tonumber(playerAccounts[ply:SteamID()].balance) 
        if balance >= amount then
            playerAccounts[ply:SteamID()].balance = balance - amount
            database.updateBalance(ply:SteamID(), playerAccounts[ply:SteamID()].balance, function()
                ply:AddMoney(amount)
                updatePlayerBalance(ply)
                net.Start("TransactionSuccess")
                net.WriteString("Withdrawal successful!")
                net.Send(ply)
            end)
        else
            net.Start("TransactionError")
            net.WriteString("Insufficient funds in account!")
            net.Send(ply)
        end
    end
end)

net.Receive("RequestBalance", function(len, ply)
    database.getAccountBalance(ply:SteamID(), function(balance)
        if balance then
            playerAccounts[ply:SteamID()] = { balance = tonumber(balance) }
            net.Start("SendBalance")
            net.WriteInt(balance, 32)
            net.Send(ply)
        else
            net.Start("TransactionError")
            net.WriteString("Failed to retrieve balance!")
            net.Send(ply)
        end
    end)
end)