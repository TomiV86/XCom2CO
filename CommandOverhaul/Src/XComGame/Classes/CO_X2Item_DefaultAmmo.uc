class CO_X2Item_DefaultAmmo extends X2Item_DefaultAmmo;

static function X2AmmoTemplate CreateTracerRounds()
{
	local X2AmmoTemplate Template;
	local ArtifactCost Resources;
	local WeaponDamageValue DamageValue;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'TracerRounds');
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Tracer_Rounds";
	Template.Abilities.AddItem('TracerRounds');
	DamageValue.Damage = default.TRACER_DMGMOD;
	Template.AddAmmoDamageModifier(none, DamageValue);
	Template.CanBeBuilt = true;
	Template.TradingPostValue = 30;
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.RewardDecks.AddItem('ExperimentalAmmoRewards');

	Template.SetUIStatMarkup(class'XLocalizedData'.default.AimLabel, eStat_Offense, class'X2Effect_TracerRounds'.default.AimMod);

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('TracerRounds');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 90;
	Template.Cost.ResourceCosts.AddItem(Resources);
	Resources.ItemTemplateName = 'EleriumCore';
	Resources.Quantity = 1;
	Template.Cost.ResourceCosts.AddItem(Resources);
	Resources.ItemTemplateName = 'EleriumDust';
	Resources.Quantity = 15;
	Template.Cost.ResourceCosts.AddItem(Resources);
		
	//FX Reference
	Template.GameArchetype = "Ammo_Tracer.PJ_Tracer";
	
	return Template;
}