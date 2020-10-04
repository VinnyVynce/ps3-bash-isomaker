#!/bin/bash

gameDirectory="../1fichier/PS3 ISO"
makeps3isoDirectory="src/makeps3iso"
irdpatcherDirectory="ps3_ird_patcher"

if [ ! -f $makeps3isoDirectory/makeps3iso ]; then
	echo "makeps3iso tool not found. Exiting."
	exit 1
fi

if [ ! -f $irdpatcherDirectory/ps3_ird_patcher.exe ]; then
	echo "ps3_ird_patcher tool not found. Exiting."
	exit 1
fi

if ! command -v mono &> /dev/null
then
    echo "mono could not be found"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

directories=$(ls -d "$gameDirectory"/*/)
echo "$directories" | while read directory; do
	game="$(echo "$directory"| sed 's/.$//' | grep -Po '[^/]+$' | perl -pe 's/(B(L|C)(E|U|J)S\d\d\d\d\d)//g' | perl -pe 's/\[.*.\]//g' | sed -e 's/[[:space:]]*$//')"
	gameID="$(echo "$directory" | grep -Po 'B(L|C)(E|U|J)S\d\d\d\d\d')"
	iso="$(find "./$directory" -maxdepth 1 -name '*.iso')"
	ird="$(find "./$directory" -maxdepth 1 -name '*.ird')"
	
	printf "Directory: $directory\n"
	printf "Game: $game\n"
	
	if [ -z "$gameID" ]; then
		printf "GameID: Unknown\n"
	else
		printf "GameID: $gameID\n"
	fi
	
	if [ -z "$ird" ]; then
		printf "${RED}IRD: Not found. Skipping.${NC}\n"
	else
		if [ -z "$iso" ]; then
			printf "${RED}ISO: Not found. Proceeding.${NC}\n"
			$makeps3isoDirectory/makeps3iso "$directory" "$directory$game.iso"
		else
			printf "${BLUE}ISO: Already there. Skipping.${NC}\n"
		fi
		
		printf "${BLUE}IRD: Found.\n${NC}"
		if [ ! -f "$directory""ird_patched" ]; then
			printf "Patching the IRD on the ISO.${NC}\n"
			mono $irdpatcherDirectory/ps3_ird_patcher.exe "$directory$game.iso" "$ird"
			touch "$directory""ird_patched"
		else
			printf "${GREEN}Game is already patched. Skipping.${NC}\n"
		fi
	fi
	echo " "
done
