local db

local function connectToDatabase()
    db = sql.Query("CREATE TABLE IF NOT EXISTS bank_accounts (player_id TEXT PRIMARY KEY, balance INTEGER)")
    if db == false then
        print("Failed to create table: " .. sql.LastError())
    else
        print("Connected to the SQLite database.")
    end
end

local function queryDatabase(query, callback)
    local result = sql.Query(query)
    if result == false then
        print("Query failed: " .. sql.LastError())
    else
        if callback then
            callback(result)
        end
    end
end

local function createAccount(playerID, callback)
    local query = string.format("INSERT INTO bank_accounts (player_id, balance) VALUES ('%s', 0)", playerID)
    queryDatabase(query, function(result)
        print("Account created for player ID: " .. playerID)
        if callback then callback(result) end
    end)
end

local function updateBalance(playerID, balance, callback)
    local query = string.format("UPDATE bank_accounts SET balance = %d WHERE player_id = '%s'", balance, playerID)
    queryDatabase(query, function(result)
        print("Balance updated for player ID: " .. playerID)
        if callback then callback(result) end
    end)
end

local function getAccountBalance(playerID, callback)
    local query = string.format("SELECT balance FROM bank_accounts WHERE player_id = '%s'", playerID)
    queryDatabase(query, function(result)
        if result and result[1] then
            callback(result[1].balance)
        else
            callback(nil)
        end
    end)
end

connectToDatabase()

return {
    createAccount = createAccount,
    updateBalance = updateBalance,
    getAccountBalance = getAccountBalance
}