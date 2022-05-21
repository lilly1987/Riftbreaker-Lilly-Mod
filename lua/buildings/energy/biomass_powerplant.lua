local carbonium_factory = require("lua/buildings/resources/carbonium_factory.lua")
local BioPower = {
	animal_biomass_powerplant = 200,
	animal_biomass_powerplant_lvl_2 = 300,
	animal_biomass_powerplant_lvl_3 = 400,
	plant_biomass_powerplant = 100,
	plant_biomass_powerplant_lvl_2 = 150,
	plant_biomass_powerplant_lvl_3 = 200,
}


class 'biomass_powerplant' ( carbonium_factory )

function biomass_powerplant:__init()
	building.__init(self,self)
	self.max = -1.0
	self.segment_size = 0.0
	self.output = 0.0
	self.prev = 0.0
	self.fsm = self:CreateStateMachine()
	self.fsm:AddState( "idle", {enter="OnEnterIdle", execute="OnIdle", interval=1.0} )
	self.fsm:AddState( "working", {enter="OnEnterWorking", execute="OnWorking", interval=1.0} )
	self.fsm:ChangeState("idle")
end

function biomass_powerplant:CheckBounds(energy)
	local output = self.output
	local min_target = 1.5 * output
	local max_candidate = math.max(min_target, energy)
	local delta = energy - self.prev
	self.prev = energy

	if (self.max - energy) > (3 * self.segment_size)  -- Broken lower bound 
	then
		self.segment_size = (0.45 * output) + (0.033333 * max_candidate)
		self.max = max_candidate + self.segment_size - math.random(0.0, output)	-- (add segment offset)
	elseif
		  delta == 0 and energy > min_target -- possibly at max energy
	or 	(max_candidate - self.max) > (2 * self.segment_size) -- broken upper bound 
	then
		self.segment_size = (0.45 * output) + (0.033333 * max_candidate)
		self.max = max_candidate - math.random(0.0, output)	-- (dont add segment offset)
	end
end

function biomass_powerplant:OnEnterIdle( state )
	BuildingService:DisableBuilding( self.entity )
	self.output = BioPower[BuildingService:GetBuildingName( self.entity )]
end

function biomass_powerplant:OnIdle( state )
	local energy = BuildingService:GetEnergyAmount( self.entity )
	local segment_size = self.segment_size	

	if energy < segment_size then
		self.fsm:ChangeState("working")
		return
	end

	local deficit = self.max - energy
	self:CheckBounds(energy)
	if deficit > (2 * segment_size) then
		self.fsm:ChangeState("working")
	end
end

function biomass_powerplant:OnEnterWorking( state )
	BuildingService:EnableBuilding( self.entity )
end

function biomass_powerplant:OnWorking( state )
	local energy = BuildingService:GetEnergyAmount( self.entity )
	local deficit = self.max - energy
	self:CheckBounds(energy)
	
	if deficit < self.segment_size then
		self.fsm:ChangeState("idle")
	end	
end

return biomass_powerplant
