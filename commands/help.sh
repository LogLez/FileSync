#! /bin/bash

echo "List of commands:

 - help : shows all commands and its description
 - init : Init the synchronization between 2 directories ./sync init '<Directory A>' '<Directory B>'
 - start : Start the synchronization between 2 directories. If it's the first time, the init will be created ./sync start '<Directory A>' '<Directory B>'
 - remove : Remove the synchronization between 2 directories from the file will be created ./sync remove '<Directory A>' '<Directory B>'
 - infos : Get informations from the diary wtih specified options ./sync infos [ -options ] 
 	Options :
 		-s --> specified the source/dest directory
 		-t --> specified the source/dest directory
 		-b --> specified the start date in TimeUnix
 		-e --> specified the end date in TimeUnix

 		command to read the current date : date +%s
 	Examples:
 		./sync.sh infos -s A --> Get all synchronizations with A directory inclued.
 		./sync.sh infos -s A -t B -s 1704196218 --> Get all synchronizations with A and B directories inclued and with a lastEdit equals or newer than 1704196218
 		./sync.sh infos -s A -t B -s 1704196218 -e 1704196250 --> Get all synchronizations with A and B directories inclued and with a lastEdit equals or newer than 1704196218 and equals or lower than 1704196250
 		./sync.sh infos -s A -t B -s 1704196218 -e 1704196250 --> Get all synchronizations with A and B directories inclued and with a lastEdit equals or newer than 1704196218 and equals or lower than 1704196250

"