AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/cashregister01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    self.NextUse = 0
end

function ENT:Use(activator, caller)
    if activator:IsPlayer() and self.NextUse <= CurTime() then
        self.NextUse = CurTime() + 1
        net.Start("OpenBankTerminal")
        net.Send(activator)
    end
end
