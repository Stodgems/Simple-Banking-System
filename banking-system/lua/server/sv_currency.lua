local playerMeta = FindMetaTable("Player")

function playerMeta:AddMoney(amount)
    if self:getDarkRPVar("money") then
        self:addMoney(amount)
        print(self:Nick() .. " now has " .. self:getDarkRPVar("money") .. " money.")
    else
        print("Error: Could not retrieve money for " .. self:Nick())
    end
end

function playerMeta:RemoveMoney(amount)
    if self:getDarkRPVar("money") then
        if self:getDarkRPVar("money") >= amount then
            self:addMoney(-amount)
            print(self:Nick() .. " now has " .. self:getDarkRPVar("money") .. " money.")
            return true
        else
            print(self:Nick() .. " does not have enough money.")
            return false
        end
    else
        print("Error: Could not retrieve money for " .. self:Nick())
        return false
    end
end

function playerMeta:GetMoney()
    return self:getDarkRPVar("money") or 0
end
