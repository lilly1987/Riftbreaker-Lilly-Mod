local carbonium_factory = require("lua/buildings/resources/carbonium_factory.lua")

class 'smart_powerplant' ( carbonium_factory )

function smart_powerplant:__init()
	building.__init(self,self)
	self.fsm = self:CreateStateMachine()
	self.fsm:AddState( "idle", {enter="OnEnterIdle", execute="OnIdle", interval=1.0} )
	self.fsm:AddState( "working", {enter="OnEnterWorking", execute="OnWorking", interval=1.0} )
	self.fsm:ChangeState("idle")
end

function smart_powerplant:OnEnterIdle( state )
	BuildingService:DisableBuilding( self.entity )
end

function smart_powerplant:OnIdle( state )
	local fraction = PlayerService:GetResourceAmount( "energy" ) / PlayerService:GetResourceLimit( "energy" );
	if fraction <= 0.3 then
		self.fsm:ChangeState("working")
		return
	end
end

function smart_powerplant:OnEnterWorking( state )
	BuildingService:EnableBuilding( self.entity )
end

function smart_powerplant:OnWorking( state )
	local fraction = PlayerService:GetResourceAmount( "energy" ) / PlayerService:GetResourceLimit( "energy" );
	if fraction >= 0.7 then
		self.fsm:ChangeState("idle")
	end	
end

return smart_powerplant
