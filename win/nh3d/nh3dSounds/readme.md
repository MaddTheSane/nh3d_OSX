#Additional Sounds for NetHack 3D
##For More Sounds

Additional sound samples can be found 
[here](http://git.klever.net/view/cgit/patchwork/opie.git/tree/sounds/nethack?id=dfac71239116c4804081d925e9cf3021680b1e2c). They are not included because I do not know they copyright of all the samples (some sound like they were taken from Monty Python).

##Format
###Sound Messages
Entries begin with `SOUND=MESG`. Each part is seperated with either one or more tabs and/or spaces. The next part is the message that, when displayed, plays the related sound. As spaces are the separators, using asterisks (`*`) in place of spaces is advised. Asterisks are used for wildcard arguments. The next part is the file name. The sound format needs to be playable by AVFoundation (CoreAudio extensions might work). Also, the file name must not contain spaces. The last part is the volume, where 100 means full volume.

###Effect Messages
These must begin with `EFFECT=MESG`. Each part is seperated with either one or more tabs and/or spaces. The next part is the message that, when displayed, has the effect run. As spaces are the separators, using asterisks (`*`) in place of spaces is advised. Asterisks are used for wildcard arguments. The next part is an integer of the effect to use. There are currently only two:

1. Camera Vibration
2. Splash(Only in three front directions)
