class Comm_StrategyListener extends UIScreenListener dependson(Comm_XComGameState_CommMod) config(GameData);;

var config int	MissionMinDuration;
var config int	MissionMaxDuration;

var() private array<X2ItemTemplate> arrProcessedAmmoTypes;
var() private bool DoInitOnce;
var() protectedwrite Comm_XComGameState_CommMod CommMod;

function bool IsInStrategy()
{
	return `HQGAME  != none && `HQPC != None && `HQPRES != none;
}

event OnInit(UIScreen Screen)
{
	local XComGameState NewGameState;
	local XComGameState BaseGameState;
	local XComGameStateContext Context;

	if(IsInStrategy())
	{
		/*
		if (!DoInitOnce)
		{
			BaseGameState = `XCOMHISTORY.GetGameStateFromHistory();
			CommMod = Comm_XComGameState_CommMod(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'Comm_XComGameState_CommMod', true));
			NewGameState = `XCOMHISTORY.CreateNewGameState(true, BaseGameState.GetContext());
			if (CommMod == none)
				CommMod = Comm_XComGameState_CommMod(NewGameState.CreateStateObject(class'Comm_XComGameState_CommMod'));
			else
				CommMod = Comm_XComGameState_CommMod(NewGameState.CreateStateObject(class'Comm_XComGameState_CommMod', CommMod.ObjectID));

			CommMod.Initialized = true;

			NewGameState.AddStateObject(CommMod);
			`GAMERULES.SubmitGameState(NewGameState);

			DoInitOnce = true;

			//CommMod = `XCOMGAME.spawn(class'XComGameState_CommMod');
		}
		*/

		ProcessInventory();
		ModifyMissionTemplates();
	}
}

static function ModifyTemplates()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2AmmoTemplate> arrAmmoTemplates;
	local X2DataTemplate Template;
	local X2AmmoTemplate AmmoTemplate;
	local int idx;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach ItemTemplateManager.IterateTemplates(Template, none)
	{
		AmmoTemplate = X2AmmoTemplate(Template);

		if (AmmoTemplate != none)
		{
			arrAmmoTemplates.AddItem(AmmoTemplate);
		}
	}

	if (arrAmmoTemplates.Length > 0)
	{
		for (idx = 0; idx < arrAmmoTemplates.Length; idx++)
		{
			AmmoTemplate = arrAmmoTemplates[idx];
		}
	}
}

static function ModifyMissionTemplates()
{
	local X2StrategyElementTemplateManager StratElementTempMgr;
	local array<X2MissionSourceTemplate> arrMissionSrcTemplates;
	local X2DataTemplate Template;
	local X2MissionSourceTemplate MissionSrcTemplate;
	local int idx;

	StratElementTempMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	idx = 0;

	foreach StratElementTempMgr.IterateTemplates(Template, none)
	{
		MissionSrcTemplate = X2MissionSourceTemplate(Template);

		if (MissionSrcTemplate != none)
		{
			MissionSrcTemplate.bDisconnectRegionOnFail = false;
			idx++;
		}
	}

	`log("COMM: Found" @ idx @ "mission source templates to modify",,'CommandOverhaul');
}

function ProcessInventory()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Item Resource;
	local int idx;
	local XComGameStateHistory History;
	local X2ItemTemplate Template;
	//local X2ItemTemplate CompareTemplate;
	local array<X2ItemTemplate> arrAmmoTemplates;
	//local X2ItemTemplateManager ItemTemplateManager;

	History = `XCOMHISTORY;

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	
	//ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	for(idx = 0; idx < XComHQ.Inventory.Length; idx++)
	{
		Resource = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.Inventory[idx].ObjectID));

		if(Resource != none)
		{
			if(Resource.GetMyTemplate().IsA('X2AmmoTemplate'))
			{
				if (!HasBeenProcessed(Resource.GetMyTemplate(), arrAmmoTemplates))
				{
					arrAmmoTemplates.AddItem(Resource.GetMyTemplate());
				}
			}
		}
	}

	foreach arrAmmoTemplates(Template)
	{
		if (!HasBeenProcessed(Template, arrProcessedAmmoTypes))
		{
			Template.CanBeBuilt = true;
			arrProcessedAmmoTypes.AddItem(Template);
		}
	}
}

static function bool HasBeenProcessed(X2ItemTemplate Comparison, array<X2ItemTemplate> TemplateList)
{
	local X2ItemTemplate Template;

	if (TemplateList.Find(Comparison) != INDEX_NONE)
		return true;

	return false;
}

DefaultProperties
{
	DoInitOnce = false;
}

static function X2DataTemplate CreateGuerrillaOp()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'CommGuerrillaOp');
	Template.PointsToComplete = 1500;
	Template.SortingTier = 1;
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_PlasmaRifle";
	Template.ResearchCompletedFn = MissionTechCompleted;

	Template.bRepeatable = true;
	//Template.ResearchCompletedFn = GiveRandomItemReward;

	// Randomized Item Rewards
	//Template.ItemRewards.AddItem('LightPoweredArmor');

	// Requirements
	//Template.Requirements.RequiredTechs.AddItem('Tech_Elerium');

	// Cost
	Resources.ItemTemplateName='Supplies';
	Resources.Quantity = 100;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'Intel';
	Resources.Quantity = 40;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function X2DataTemplate CreateSupplyRaid()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'CommSupplyRaid');
	Template.PointsToComplete = 1000;
	Template.SortingTier = 1;
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_PlasmaRifle";
	Template.ResearchCompletedFn = MissionTechCompleted;

	Template.bRepeatable = true;
	//Template.ResearchCompletedFn = GiveRandomItemReward;

	// Randomized Item Rewards
	//Template.ItemRewards.AddItem('LightPoweredArmor');

	// Requirements
	//Template.Requirements.RequiredTechs.AddItem('Tech_Elerium');

	// Cost
	Resources.ItemTemplateName='Supplies';
	Resources.Quantity = 40;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'Intel';
	Resources.Quantity = 30;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function X2DataTemplate CreateCouncilMission()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'CommCouncilMission');
	Template.PointsToComplete = 1200;
	Template.SortingTier = 1;
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_PlasmaRifle";
	Template.ResearchCompletedFn = MissionTechCompleted;

	Template.bRepeatable = true;
	//Template.ResearchCompletedFn = GiveRandomItemReward;

	// Randomized Item Rewards
	//Template.ItemRewards.AddItem('LightPoweredArmor');

	// Requirements
	//Template.Requirements.RequiredTechs.AddItem('Tech_Elerium');

	// Cost
	Resources.ItemTemplateName='Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'Intel';
	Resources.Quantity = 40;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

function MissionTechCompleted(XComGameState NewGameState, XComGameState_Tech TechState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersResistance ResistanceHQ;
	local int IntelAmount, TechID;
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;

	History = `XCOMHISTORY;

	switch (TechState.GetMyTemplateName())
	{
		case 'CommGuerrillaOp':
			StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

			MissionRewards.Length = 0;
			RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_None'));
			MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(MissionRewardState);
			MissionRewards.AddItem(MissionRewardState);

			MissionState = XComGameState_MissionSite(NewGameState.CreateStateObject(class'XComGameState_MissionSite'));
			NewGameState.AddStateObject(MissionState);
			RegionState = class'UIUtilities_Strategy'.static.GetRandomContinent(SelectedDestinationEntity.Continent).GetRandomRegionInContinent());
			MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_SupplyRaid'));
			MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
			MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);
			MissionState.PickPOI(NewGameState);
			break;
		case 'CommSupplyRaid':
			break;
		case 'CommCouncilMission':
			break;
	}

}