local item = require("lua/items/item.lua")

class 'gravity_hole_mod' ( item )

function gravity_hole_mod:__init()
	item.__init(self,self)
end

function gravity_hole_mod:OnInit()
	self.fsm = self:CreateStateMachine()
	self.fsm:AddState( "closed", { enter="OnClosedEnter", execute="OnClosedExecute", exit="OnClosedExit" } )
	self.fsm:AddState( "opening", { enter="OnOpeningEnter", execute="OnOpeningExecute", exit="OnOpeningExit" } )
	self.fsm:AddState( "opened", { enter="OnOpenedEnter", execute="OnOpenedExecute", exit="OnOpenedExit" } )
	self.fsm:AddState( "closing", { enter="OnClosingEnter", execute="OnClosingExecute", exit="OnClosingExit" } )
	self.fsm:ChangeState( "closed" )
	self.closedTime = 0.25
	self.openingTime = 0.5
	self.openedTime = 3.0
	self.closingTime = 0.3
	
	self.initialBlast =  self.data:GetStringOrDefault("initial_blast","items/consumables/gravity_hole_initial_blast")
	self.damage =  self.data:GetStringOrDefault("damage","items/consumables/gravity_hole_damage")
end

function gravity_hole_mod:OnClosedEnter( state )
	state:SetDurationLimit( self.closedTime )
	EntityService:SpawnAndAttachEntity( "items/consumables/gravity_hole_init_sound", self.entity )

	local entity = EntityService:SpawnAndAttachEntity( self.initialBlast, self.entity )
	self:SetItemCreator(entity)

	self.closedEnt = EntityService:SpawnAndAttachEntity( "items/consumables/gravity_hole_closed", self.entity )
	self.initialPos = EntityService:GetPosition( self.entity )
	EntityService:SetScale( self.entity, 0.01, 0.01, 0.01 )
end

function gravity_hole_mod:OnClosedExecute( state )
	local currentProgress = ( state:GetDuration() / self.closedTime )
	local scale = 0.5 * currentProgress * currentProgress
	EntityService:SetScale( self.entity, scale, scale, scale )
	EntityService:SetPosition( self.entity, self.initialPos.x, self.initialPos.y + 5 * currentProgress, self.initialPos.z )
end

function gravity_hole_mod:OnClosedExit( state )
	self.fsm:ChangeState( "opening" )
	EntityService:RemoveEntity( self.closedEnt )
end

function gravity_hole_mod:SetItemCreator(entity)
	local item_creator = ItemService:GetItemCreator(self.entity )
	if item_creator ~= "" then
		ItemService:SetItemCreator( entity, item_creator );
	else
		ItemService:SetItemCreator( entity, self.entity_blueprint );
	end
end

function gravity_hole_mod:OnOpeningEnter( state )
	state:SetDurationLimit( self.openingTime )
	
	self.idleDamageEnt = EntityService:SpawnAndAttachEntity( self.damage, self.entity )
	self:SetItemCreator(self.idleDamageEnt)

	EntityService:SetTeam( self.idleDamageEnt, "player" )
end

function gravity_hole_mod:OnOpeningExecute( state )
	local currentProgress = ( state:GetDuration() / self.openingTime )
	if ( currentProgress > 0.5 ) then
		local scale = 0.5 + ( 0.7 * ( currentProgress - 0.5 ) * 2 ) + 1.0 * math.sin( 3.14 * ( currentProgress - 0.5 ) * 2 )
		EntityService:SetScale( self.entity, scale, scale, scale )
		if self.refractEnt == nil then
			EntityService:SpawnAndAttachEntity( "items/consumables/gravity_hole_open_sound", self.entity )
			self.refractEnt = EntityService:SpawnAndAttachEntity( "items/consumables/gravity_hole_refract", self.entity )
			self.vortexEnt = EntityService:SpawnAndAttachEntity( "items/consumables/gravity_hole_vortex", self.entity )
		end
	end
end

function gravity_hole_mod:OnOpeningExit( state )
	self.fsm:ChangeState( "opened" )
end

function gravity_hole_mod:OnOpenedEnter( state )
	state:SetDurationLimit( self.openedTime )
	self.idleSoundEnt = EntityService:SpawnAndAttachEntity( "items/consumables/gravity_hole_idle_sound", self.entity )
	self.idleRadiusEnt = EntityService:SpawnAndAttachEntity( "items/consumables/gravity_hole_radius", self.entity )
end

function gravity_hole_mod:OnOpenedExecute( state )
	local currentProgress = ( state:GetDuration() / self.openedTime )
	TornadoService:UpdateGravityHole( self.entity, 3.0, 0.5, 650 )
	if currentProgress > 0.95 and self.refractEnt ~= nil then 
		EntityService:RemoveEntity( self.refractEnt )
		EntityService:RemoveEntity( self.vortexEnt )
		self.refractEnt = nil;
	end
end

function gravity_hole_mod:OnOpenedExit( state )
	self.fsm:ChangeState( "closing" )
	EntityService:RemoveEntity( self.idleSoundEnt )
	EntityService:RemoveEntity( self.idleRadiusEnt )
	EntityService:RemoveEntity( self.idleDamageEnt )
	EntityService:SpawnAndAttachEntity( "items/consumables/gravity_hole_close_sound", self.entity )
end

function gravity_hole_mod:OnClosingEnter( state )
	state:SetDurationLimit( self.closingTime )
end

function gravity_hole_mod:OnClosingExecute( state )
	local currentProgress = ( state:GetDuration() / self.closingTime )
	local scale = 1.30 - ( 1.3 * ( 1 - ( ( math.cos( 3.14 * currentProgress ) + 1 ) / 2 ) ) )
	EntityService:SetScale( self.entity, scale, scale, scale )
end

function gravity_hole_mod:OnClosingExit( state )
	EntityService:RemoveEntity( self.entity )
end

return gravity_hole_mod
