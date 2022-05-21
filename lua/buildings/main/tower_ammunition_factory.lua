local building = require("lua/buildings/building.lua")

local ammoTypes = { "ammo_tower_liquid", "ammo_tower_explosive", "ammo_tower_low_caliber" }
local function TowerAmmoIsFull()
	for i = 1, #ammoTypes, 1 do 
		if (PlayerService:IsResourceUnlocked(ammoTypes[i])) then
			if ((PlayerService:GetResourceAmount(ammoTypes[i])/PlayerService:GetResourceLimit(ammoTypes[i])) < 0.99) then
				return false
			end
		end
	end
	return true
end

class 'tower_ammunition_factory' ( building )

function tower_ammunition_factory:__init()
	building.__init(self,self)
	self.fsm = self:CreateStateMachine()
	self.interval = 1
	self.fsm:AddState( "idle", {enter="OnEnterIdle", execute="OnUpdate", interval=self.interval} )
	self.fsm:AddState( "working", {enter="OnEnterWorking", execute="OnUpdate", interval=self.interval} )
	self.fsm:ChangeState("working")
	self.activation_state = "on"
end

function tower_ammunition_factory:OnEnterIdle()
	BuildingService:DisableBuilding( self.entity )
end

function tower_ammunition_factory:OnEnterWorking()
	BuildingService:EnableBuilding( self.entity )
end

function tower_ammunition_factory:OnUpdate(state)
	if TowerAmmoIsFull() then
		if (self.activation_state == "on") then
			self.fsm:ChangeState("idle")
		end
	else
		if (self.activation_state == "off") then
			self.fsm:ChangeState("working")
		end
	end
end

function tower_ammunition_factory:OnActivate()
		self.activation_state = "on"
	end
	
	function tower_ammunition_factory:OnDeactivate()
		self.activation_state = "off"
end

return tower_ammunition_factory
