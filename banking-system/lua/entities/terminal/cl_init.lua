include("shared.lua")

local frame

net.Receive("OpenBankTerminal", function()
    frame = vgui.Create("DFrame")
    frame:SetTitle("Bank Terminal")
    frame:SetSize(300, 200)
    frame:Center()
    frame:MakePopup()

    local balanceLabel = vgui.Create("DLabel", frame)
    balanceLabel:SetPos(10, 30)
    balanceLabel:SetText("Balance: Loading...")
    balanceLabel:SizeToContents()

    local depositButton = vgui.Create("DButton", frame)
    depositButton:SetPos(10, 60)
    depositButton:SetSize(280, 30)
    depositButton:SetText("Deposit")
    depositButton.DoClick = function()
        Derma_StringRequest("Deposit", "Enter amount to deposit:", "", function(amount)
            amount = tonumber(amount)
            if amount then
                net.Start("Banking_Transaction")
                net.WriteString("deposit")
                net.WriteInt(amount, 32)
                net.SendToServer()
            end
        end)
    end

    local withdrawButton = vgui.Create("DButton", frame)
    withdrawButton:SetPos(10, 100)
    withdrawButton:SetSize(280, 30)
    withdrawButton:SetText("Withdraw")
    withdrawButton.DoClick = function()
        Derma_StringRequest("Withdraw", "Enter amount to withdraw:", "", function(amount)
            amount = tonumber(amount)
            if amount then
                net.Start("Banking_Transaction")
                net.WriteString("withdraw")
                net.WriteInt(amount, 32)
                net.SendToServer()
            end
        end)
    end

    net.Start("RequestBalance")
    net.SendToServer()

    net.Receive("SendBalance", function()
        local balance = net.ReadInt(32)
        balanceLabel:SetText("Balance: " .. balance)
        balanceLabel:SizeToContents()
    end)
end)

net.Receive("TransactionSuccess", function()
    local message = net.ReadString()
    chat.AddText(Color(0, 255, 0), message)
    if frame and frame:IsValid() then
        frame:Close()
    end
end)

net.Receive("TransactionError", function()
    local message = net.ReadString()
    chat.AddText(Color(255, 0, 0), message)
end)
