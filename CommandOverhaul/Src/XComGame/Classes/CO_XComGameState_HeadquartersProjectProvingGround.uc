class CO_XComGameState_HeadquartersProjectProvingGround extends XComGameState_HeadquartersProjectProvingGround;

function OnProjectCompleted()
{
	local bool NeedNewGameState;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Tech Tech;
	local XComGameStateHistory History;
	local name TechName;

	History = `XCOMHISTORY;
	NeedNewGameState = false;

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	Tech = XComGameState_Tech(History.GetGameStateForObjectID(ProjectFocus.ObjectID));
	TechName = Tech.GetMyTemplateName();

	class'Helpers'.static.OutputMsg("CommmandOverhaul: Project" @TechName@ "finished");

	if (XComHQ.TechIsResearched(ProjectFocus))
	{
		switch (TechName)
		{
			case 'TracerRounds':
				XComHQ.TechsResearched.AddItem(ProjectFocus);
				NeedNewGameState = true;
				class'Helpers'.static.OutputMsg("CommmandOverhaul: Tracer rounds tech added to HQ");
				break;
			default:
				break;
		}
	}

	if (NeedNewGameState)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CommandOverhaul: Ammo Project Completed");
		NewGameState.AddStateObject(XComHQ);
	}

	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}