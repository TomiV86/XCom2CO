class Comm_StrategyListener extends UIScreenListener dependson(Comm_XComGameState_CommMod);

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