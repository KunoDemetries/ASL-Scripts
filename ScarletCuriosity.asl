//Load Remover for Touhou: Scarlet Curiosity by rythin

state("Kokishin", "1.31 JP") {
	int gameLoading: 0x05A5464;	//1 in gameplay, 257 in loads
}

init {
	if (modules.First().ModuleMemorySize == 7761920) {
		version = "1.31 JP";
	}
	
	//if (modules.First().ModuleMemorySize == 9460301) {	steam version currently not supported as i dont own it lol
	//	version = "Steam";
	//}
}

isLoading {
	return (current.gameLoading != 1);
} 
