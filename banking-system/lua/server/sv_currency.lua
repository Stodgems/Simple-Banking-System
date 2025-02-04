local playerMeta = FindMetaTable("Player")

function playerMeta:AddMoney(amount)
    if self:getDarkRPVar("money") then
        self:addMoney(amount)
    else
        print("Error: Could not retrieve money for " .. self:Nick())
    end
end

function playerMeta:RemoveMoney(amount)
    if self:getDarkRPVar("money") then
        if self:getDarkRPVar("money") >= amount then
            self:addMoney(-amount)
            return true
        else
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
