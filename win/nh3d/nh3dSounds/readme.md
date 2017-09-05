# Additional Sounds for NetHack 3D
## For More Sounds

Additional sound samples can be found 
[here](http://git.klever.net/view/cgit/patchwork/opie.git/tree/sounds/nethack?id=dfac71239116c4804081d925e9cf3021680b1e2c). They are not included because I do not know they copyright of all the samples (some sound like they were taken from Monty Python).

## Format
### Sound Messages
In order to use sounds, you must first set the location via `SOUNDDIR=` first. This can be set in between  `SOUND=MESG` declarations if you want to use sounds that are in different directories.

Entries begin with `SOUND=MESG`. Each part is seperated with either one or more tabs and/or spaces. The next part is the regular expression that, when matched with the displayed text, plays the related sound. It is encapsulated by quotation marks (`"`). The next part is the file name. It is encapsulated by quotation marks (`"`) . The sound format needs to be playable by AVFoundation (CoreAudio extensions might work). The last part is the volume, where 100 means full volume.

### Effect Messages
These must begin with `EFFECT=MESG`. Each part is seperated with either one or more tabs and/or spaces. The next part is the regular expression that, when matched with the displayed text, has the effect run. It is encapsulated by quotation marks (`"`) . The next part is an integer of the effect to use. There are currently only two:

1. Camera Vibration
2. Splash (Only in three front directions)
