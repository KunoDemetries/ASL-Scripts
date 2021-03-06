//Satan Loves Cake Autosplitter + Game Time by rythin

state("SATAN LOVES CAKE 1.4") {
	double igt: 		0x004B392C, 0x12C, 0x10, 0x390, 0x400;	//frame count
	double charge:		0x004B27F8, 0x2C, 0x10, 0x768, 0x430;	//	
	double walljump:	0x004B27F8, 0x2C, 0x10, 0xB40, 0x10;	//
	double bossT:		0x004B2780, 0x2C, 0x10, 0x1EC, 0x3E0;	//taiyaki
	double bossK:		0x004B2780, 0x2C, 0x10, 0x1EC, 0x3D0;	//kajkage
	double hpM:			0x004B2780, 0x2C, 0x10, 0x7A4, 0x3B0;	//max hp
	double hpC:			0x004B2780, 0x2C, 0x10, 0xB88, 0x3D0;	//current hp
	double d:			0x004B2780, 0x2C, 0x10, 0x27C, 0x380;	//1 when there's dialogue on screen, 0 otherwise
	string20 room:		0x0013DCF8, 0xA3C;
}

startup {
	//setting groups
	settings.Add("boss", true, "Bosses");
	settings.Add("ups", true, "Upgrades");
	
	//settings
	settings.Add("bT", true, "Taiyaki", "boss");
	settings.Add("bK", true, "Kajkage", "boss");
	settings.Add("uC", false, "Charge", "ups");
	settings.Add("uWJ", false, "Walljump", "ups");
	settings.Add("hp1", false, "Life Upgrade 1", "ups");
	settings.Add("hp2", false, "Life Upgrade 2", "ups");
	
	vars.igtD = 0;
	vars.dc = 0; //dialogue counter used for final split
}

start {
	if (current.igt > 1 && current.room.Contains("rm_start_0a")) {
		vars.igtD = 0;
		vars.dc = 0;
		return true;
	}
}

split {
	if (settings["bT"]) {
		if (current.bossT == 1 && old.bossT == 0) {
			return true;
		}
	}

	if (settings["bK"]) {
		if (current.bossK == 1 && old.bossK == 0) {
			return true;
		}	
	}
	
	if (settings["uC"]) {
		if (current.charge == 1 && old.charge == 0) {
			return true;
		}
	}
	
	if (settings["uWJ"]) {
		if (current.walljump == 1 && old.walljump == 0) {
			return true;
		}
	}
	
	if (settings["hp1"]) {
		if (current.hpM == 4 && old.hpM == 3) {
			return true;
		}
	}
	
	if (settings["hp2"]) {
		if (current.hpM == 5 && old.hpM == 4) {
			return true;
		}
	}

	//final split
	if (vars.dc == 2) {
		vars.dc = 0;
		return true;
	}
}
reset {
	return (current.igt == 1 && old.igt == 0);
}

update {
	if ((current.igt - 1) / 60 > 0) {
		vars.igtD = (current.igt - 1) / 60;
	}
	
	//before the credits roll, in the final room 
	//there happen 2 instances of dialogue, which we need to count
	if (current.room.Contains("rm_start_10a") && current.d == 0 && old.d == 1) {
		vars.dc++;
	}
}
	

isLoading {
	return true;
}

gameTime {
	return TimeSpan.FromSeconds(vars.igtD);
}
