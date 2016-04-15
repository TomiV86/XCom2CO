class CO_X2StrategyElement_DefaultTechs extends X2StrategyElement_DefaultTechs;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	Techs = super.CreateTemplates();

	// Command Overhaul
	Techs.AddItem(CreateTracerRoundsTechTemplate());

	return Techs;
}

static function X2DataTemplate CreateTracerRoundsTechTemplate()
{
	local X2TechTemplate Template;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'TracerRounds');
	Template.PointsToComplete = 0;
	Template.SortingTier = 3;
	Template.strImage = "img:///UILibrary_StrategyImages.ScienceIcons.IC_Elerium";

	// Requirements
	//Template.Requirements.RequiredTechs.AddItem('DummyResearch');

	return Template;
}