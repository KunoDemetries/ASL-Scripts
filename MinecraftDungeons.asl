//Minecraft Dungeons Autosplitter + Load Remover by rythin, with help from KunoDemetries

state("Dungeons-Win64-Shipping", "Launcher, build 4142545") {

	//increases by 1 every frame, up to 255 then back to 0, counting pauses during loads or lag
	byte what:		0x3B1C7B8;
	
	//0 during loading AND end-of-mission chest animations
	byte lc:	0x3F5D26A;
	
	//seed given to the level when its loaded, 0 in menu and tutorial, 1 in lobby
	int seed:		0x03FA1B98, 0xD80, 0x440, 0x50;
	
	//1 when in a cutscene, 0 otherwise
	int cs:		0x03FA1AF8, 0x8;
}

state("Dungeons", "Windows Store, build 4142545") {
	byte what:		0x3F1A789;
	byte lc:		0x3F5F325;
	int seed:		0x03CED8A8, 0x20, 0xD80, 0x4E8;
	int cs:			0x03FA3BB8, 0x8;
}

startup {	
	vars.h = 0;			//used for isLoading logic
	vars.inTut = 0;		//used for dumb shit fuck you
	vars.dispS = 1;		//used for seed display
	vars.L = 0;			//for some split logic dependant on loads

	refreshRate = 30;
	
	settings.Add("seedD", false, "Display the current level's seed");
	settings.Add("levelS", true, "Split upon completing a level");
	settings.Add("IL", false, "Enable IL-Mode");
	
	vars.SetTextComponent = (Action<string, string>)((id, text) =>
	{
		var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
		var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
		if (textSetting == null)
		{
		var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
		var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
		timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));

		textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
		textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
		}

		if (textSetting != null)
		textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
	});
}

init {
	if (modules.First().ModuleMemorySize == 93192192) {
		version = "Launcher, build 4142545";
	}
	
	else if (modules.First().ModuleMemorySize == 93487104) {
		version = "Windows Store, build 4142545";
	}
	
	else {
		version = "Version Currently Not Supported";
	}
}


start {
	if (settings["IL"] == false) {
		if (current.seed == 0 && current.cs == 1 && old.cs == 0) {
			return true;
		}
	}
	
	if (settings["IL"] == true) {
		if (current.seed > 1 || current.seed == 0 ) {
			if (current.cs == 0 && old.cs == 1 || current.cs == 0 && vars.L == 0) {
				return true;
			}
		}
	}
}

split {
	/*
	//tutorial split
	if (settings["introS"]) {
		if (current.seed == 0 && current.lc != 0 && current.cs == 1 && old.cs == 0) {
			vars.inTut = 0;
			return true;
		}
	}
	*/
	
	//mission splits (also final split)
	
	if (settings["levelS"] || settings["IL"]) {
		if (old.cs == 0 && current.cs == 1 && vars.L == 0) {
			return true;
		}
	}
	
}

reset {
	if (settings["IL"]) {
		if (current.seed == 1) {
			return true;
		}
	}	
}

update {
	
	if (current.seed == 0 && vars.L == 0) {
		vars.inTut = 1;
	}
	
	else {
		vars.inTut = 0;
	}
	
	int seedV = current.seed;
	
	switch (seedV) {
		
		case 1:
		vars.dispS = "Camp";
		break;
		
		case 0:
		if (vars.inTut == 1) {
			vars.dispS = "Tutorial";
		}
		break;
		
		default:
		vars.dispS = current.seed;
		break;
	}
	
	if (settings["seedD"]) {
		vars.SetTextComponent("Seed:", (vars.dispS).ToString());
	}
	
	//logic for determining when the game is loading
	//this needs to be in update so that the variable updates even when the timer isnt running
	if (current.lc == 0) {					//only run this logic during loads (and chest anims but shh)
		Thread.Sleep(50);					//specifically on win store version the value flickers mid-load, so have 50ms of leeway
		if (current.lc == 0) {				//check again just to be sure
			if (old.what == current.what) {		//when the value stops updating
				vars.h = current.what;			//set h to that value	
				Thread.Sleep(10);				//wait 10ms
				if (vars.h == current.what) {	//if the value is still the same
					vars.L = 1;
				}
		
				else if (current.what == vars.h + 1) {	//sometimes the value can advance 1 during loads
					vars.L = 1;
				}
		
				else {
					vars.L = 0;
				}
			}
		
			else {
				vars.L = 0;
			}
		}
		
		else {
				vars.L = 0;
		}
	}
	
	else {
		vars.L = 0;
	}
}

isLoading {
	return (vars.L == 1);
}
