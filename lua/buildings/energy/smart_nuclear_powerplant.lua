local building = require("lua/buildings/building.lua")

class 'smart_nuclear_powerplant' ( building )

function smart_nuclear_powerplant:__init()
	building.__init(self,self)
	self.fsm = self:CreateStateMachine()
	self.fsm:AddState( "idle", {enter="OnEnterIdle", execute="OnIdle", interval=1.0} )
	self.fsm:AddState( "working", {enter="OnEnterWorking", execute="OnWorking", interval=1.0} )
	self.fsm:ChangeState("idle")
end

function smart_nuclear_powerplant:OnEnterIdle( state )
	BuildingService:DisableBuilding( self.entity )
end

function smart_nuclear_powerplant:OnIdle( state )
	local fraction = PlayerService:GetResourceAmount( "energy" ) / PlayerService:GetResourceLimit( "energy" );
	if fraction <= 0.3 then
		self.fsm:ChangeState("working")
		return
	end
end

function smart_nuclear_powerplant:OnEnterWorking( state )
	BuildingService:EnableBuilding( self.entity )
end

function smart_nuclear_powerplant:OnWorking( state )
	local fraction = PlayerService:GetResourceAmount( "energy" ) / PlayerService:GetResourceLimit( "energy" );
	if fraction >= 0.7 then
		self.fsm:ChangeState("idle")
	end	
end

return smart_nuclear_powerplant
