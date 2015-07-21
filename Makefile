#	NetHack Makefile.
#	SCCS Id: @(#)Makefile.top	3.4	1995/01/05

# newer makes predefine $(MAKE) to 'make' and do smarter processing of
# recursive make calls if $(MAKE) is used
# these makes allow $(MAKE) to be overridden by the environment if someone
# wants to (or has to) use something other than the standard make, so we do
# not want to unconditionally set $(MAKE) here
#
# unfortunately, some older makes do not predefine $(MAKE); if you have one of
# these, uncomment the following line
# (you will know that you have one if you get complaints about unable to
# execute things like 'data' and 'rumors')
# MAKE = make

# make NetHack
PREFIX	 = .
GAME     = NetHack3D
# GAME     = nethack.prg
GAMEUID  = $(USER)
GAMEGRP  = $(GROUP)

# Permissions - some places use setgid instead of setuid, for instance
# See also the option "SECURE" in include/config.h
GAMEPERM = 02755
FILEPERM = 0644
EXEPERM  = 0755
DIRPERM  = 0755

# GAMEDIR also appears in config.h as "HACKDIR".
# VARDIR may also appear in unixconf.h as "VAR_PLAYGROUND" else GAMEDIR
#
# note that 'make install' believes in creating a nice tidy GAMEDIR for
# installation, free of debris from previous NetHack versions --
# therefore there should not be anything in GAMEDIR that you want to keep
# (if there is, you'll have to do the installation by hand or modify the
# instructions)
GAMEDIR  = $(PREFIX)/NetHack3D_Folder/NetHack3D.app/Contents/Resources
BINDIR  = $(PREFIX)/NetHack3D_Folder/NetHack3D.app/Contents/MacOS
VARDIR  = $(GAMEDIR)
USOUNDDIR = $(PREFIX)/NetHack3D_Folder/nh3dSounds
DOCDIR  = $(PREFIX)/NetHack3D_Folder/Documentation
#SHELLDIR = $(PREFIX)/games
SHELLDIR =

# For MacOSX, specify Qt library to be copied from $(QTDIR)/lib/
QTLIB=

VARDAT_X11 = x11tiles NetHack.ad pet_mark.xbm
VARDAT_Qt = nhtiles.bmp rip.xpm nhsplash.xpm
VARDAT_NH3D = nh3dmodels nh3dresources nh3dtextures nh3dsounds
VARDAT_NH3D_MacOSX = $(VARDAT_NH3D) nh3dInfo.plist Englishlproj Japaneselproj nh3d.icns nh3dUserSound
#VARDAT_NH3D_GNUStep = $(VARDAT_NH3D)
VARDAT_Qt_MacOSX = $(VARDAT_Qt) Info.plist nethack.icns libqt macdoc maccnf
VARDAT_AtariGem = nh16.img title.img GEM_RSC.RSC rip.img
VARDAT_BeOS = beostiles
VARDAT_Gnome = x11tiles pet_mark.xbm rip.xpm mapbg.xpm
#
# Choose from the above for your platform.
#
VARDATND = $(VARDAT_NH3D_MacOSX)

VARDATD = data oracles options quest.dat rumors
VARDAT = $(VARDATD) $(VARDATND)

# Some versions of make use the SHELL environment variable as the shell
# for running commands.  We need this to be a Bourne shell.
# SHELL = /bin/sh
# for Atari
# SHELL=E:/GEMINI2/MUPFEL.TTP

# Commands for setting the owner and group on files during installation.
# Some systems fail with one or the other when installing over NFS or for
# other permission-related reasons.  If that happens, you may want to set the
# command to "true", which is a no-op. Note that disabling chown or chgrp
# will only work if setuid (or setgid) behavior is not desired or required.
CHOWN = chown
CHGRP = chgrp

#
# end of configuration
#

# by issei 1994/2/5, 1994/6/25
DATHELP = help hh cmdhelp history opthelp wizhelp
#DATHELP = jhelp jhh jcmdhelp jhistory jopthelp jwizhelp

SPEC_LEVS = asmodeus.lev baalz.lev bigrm-?.lev castle.lev fakewiz?.lev \
	juiblex.lev knox.lev medusa-?.lev minend-?.lev minefill.lev \
	minetn-?.lev oracle.lev orcus.lev sanctum.lev soko?-?.lev \
	tower?.lev valley.lev wizard?.lev \
	astral.lev air.lev earth.lev fire.lev water.lev
QUEST_LEVS = ???-goal.lev ???-fil?.lev ???-loca.lev ???-strt.lev

DATNODLB = $(VARDATND) license
DATDLB = $(DATHELP) dungeon $(SPEC_LEVS) $(QUEST_LEVS) $(VARDATD)
DAT = $(DATNODLB) $(DATDLB)


$(GAME):
	( cd src ; $(MAKE) )


all:	$(GAME) recover Guidebook $(VARDAT) dungeon spec_levs check-dlb
	@echo "Done."



# Note: many of the dependencies below are here to allow parallel make
# to generate valid output

Guidebook:
	( cd doc ; $(MAKE) Guidebook )

manpages:
	( cd doc ; $(MAKE) manpages )

data: $(GAME)
	( cd dat ; $(MAKE) data )

rumors: $(GAME)
	( cd dat ; $(MAKE) rumors )

oracles: $(GAME)
	( cd dat ; $(MAKE) oracles )

jrumors: $(GAME)
	( cd dat ; $(MAKE) jrumors )

joracles: $(GAME)
	( cd dat ; $(MAKE) joracles )

#	Note: options should have already been made with make, but...
options: $(GAME)
	( cd dat ; $(MAKE) options )

quest.dat: $(GAME)
	( cd dat ; $(MAKE) quest.dat )

spec_levs: dungeon
	( cd util ; $(MAKE) lev_comp )
	( cd dat ; $(MAKE) spec_levs )
	( cd dat ; $(MAKE) quest_levs )

dungeon: $(GAME)
	( cd util ; $(MAKE) dgn_comp )
	( cd dat ; $(MAKE) dungeon )

nhtiles.bmp: $(GAME)
	( cd dat ; $(MAKE) nhtiles.bmp )

x11tiles: $(GAME)
	( cd util ; $(MAKE) tile2x11 )
	( cd dat ; $(MAKE) x11tiles )

beostiles: $(GAME)
	( cd util ; $(MAKE) tile2beos )
	( cd dat ; $(MAKE) beostiles )

NetHack.ad: $(GAME)
	( cd dat ; $(MAKE) NetHack.ad )

pet_mark.xbm:
	( cd dat ; $(MAKE) pet_mark.xbm )

rip.xpm:
	( cd dat ; $(MAKE) rip.xpm )

mapbg.xpm:
	(cd dat ; $(MAKE) mapbg.xpm )

nhsplash.xpm:
	( cd dat ; $(MAKE) nhsplash.xpm )

nh16.img: $(GAME)
	( cd util ; $(MAKE) tile2img.ttp )
	( cd dat ; $(MAKE) nh16.img )

rip.img:
	( cd util ; $(MAKE) xpm2img.ttp )
	( cd dat ; $(MAKE) rip.img )
GEM_RSC.RSC:
	( cd dat ; $(MAKE) GEM_RSC.RSC )

title.img:
	( cd dat ; $(MAKE) title.img )

check-dlb: options
	@if egrep -s librarian dat/options ; then $(MAKE) dlb ; else true ; fi

dlb:
	( cd util ; $(MAKE) dlb )
	( cd dat ; ../util/dlb cf nhdat $(DATDLB) )

# recover can be used when INSURANCE is defined in include/config.h
# and the checkpoint option is true
recover: $(NH3D)
	( cd util ; $(MAKE) recover )

dofiles:
	cp src/$(GAME) $(BINDIR)
	cp util/recover $(GAMEDIR)

	target=`sed -n					\
		-e '/librarian/{' 			\
		-e	's/.*/dlb/p' 			\
		-e	'q' 				\
		-e '}' 					\
	  	-e '$$s/.*/nodlb/p' < dat/options` ;	\
	$(MAKE) dofiles-$${target-nodlb}
	-rm -f $(SHELLDIR)/$(GAME)
	test -z "$(SHELLDIR)" || sed -e 's;/usr/games/lib/nethackdir;$(GAMEDIR);' \
		-e 's;HACKDIR/nethack;HACKDIR/$(GAME);' \
		< sys/unix/nethack.sh \
		> $(SHELLDIR)/$(GAME)
# set up their permissions
	-( cd $(BINDIR) ; $(CHOWN) $(GAMEUID) $(GAME) recover ; \
			$(CHGRP) $(GAMEGRP) $(GAME) recover )
	chmod $(GAMEPERM) $(BINDIR)/$(GAME)
	chmod $(EXEPERM) $(GAMEDIR)/recover
	-test -z "$(SHELLDIR)" || $(CHOWN) $(GAMEUID) $(SHELLDIR)/$(GAME)
	-test -z "$(SHELLDIR)" || $(CHGRP) $(GAMEGRP) $(SHELLDIR)/$(GAME)
	test -z "$(SHELLDIR)" || chmod $(EXEPERM) $(SHELLDIR)/$(GAME)


dofiles-dlb: check-dlb
	( cd dat ; cp nhdat $(DATNODLB) $(GAMEDIR) )
#	( cd win/X11 ; cp JNetHack.ad $(GAMEDIR)/JNetHack )
#	( cd win/gtk ; cp GTKRC $(GAMEDIR)/gtkrc )
#	( bdftopcf win/X11/nh10.bdf > $(GAMEDIR)/nh10.pcf ; mkfontdir $(GAMEDIR))
# set up their permissions
	-( cd $(GAMEDIR) ; $(CHOWN) $(GAMEUID) nhdat $(DATNODLB) ; \
			$(CHGRP) $(GAMEGRP) nhdat $(DATNODLB) ; \
			chmod $(FILEPERM) nhdat $(DATNODLB) )

dofiles-nodlb:
# copy over the game files
	for i in $(DAT); do \
	    $(MAKE) install.$$i 2>/dev/null || cp dat/$$i $(GAMEDIR); \
	done
#	( cd win/X11 ; cp JNetHack.ad $(GAMEDIR)/JNetHack )
#	( cd win/gtk ; cp GTKRC $(GAMEDIR)/gtkrc )
#	( bdftopcf win/X11/nh10.bdf > $(GAMEDIR)/nh10.pcf ; mkfontdir $(GAMEDIR))
# set up their permissions
	-( cd $(GAMEDIR) ; $(CHOWN) $(GAMEUID) $(DAT) ; \
			$(CHGRP) $(GAMEGRP) $(DAT) ; \
			chmod $(FILEPERM) $(DAT) )
nethack.icns:
	$(MAKE) -C dat nethack.icns

install.nethack.icns:
	-mkdir -p $(BINDIR)/../Resources
	cp dat/nethack.icns $(BINDIR)/../Resources

Info.plist:
	$(MAKE) -C dat Info.plist

install.Info.plist:
	cp dat/Info.plist $(BINDIR)/..

libqt:

install.libqt:
	mkdir -p $(BINDIR)/../Frameworks
	cp $(QTDIR)/lib/$(QTLIB) $(BINDIR)/../Frameworks
	install_name_tool -change $(QTLIB) @executable_path/../Frameworks/$(QTLIB) $(BINDIR)/$(GAME)
	install_name_tool -id @executable_path/../Frameworks/$(QTLIB) $(BINDIR)/../Frameworks/$(QTLIB)

macdoc:

install.macdoc:
	-mkdir -p $(DOCDIR)
	$(MAKE) INSTALLDIR=../$(DOCDIR) -C doc install-distrib

maccnf:

install.maccnf:
	echo "# Move this file to your 'Library/Preferences' folder" \
	    >"$(DOCDIR)/NetHack Defaults.txt"
	echo "OPTIONS=name:player,number_pad,menustyle:partial,!time,showexp" \
	    >>"$(DOCDIR)/NetHack Defaults.txt"
	echo "OPTIONS=hilite_pet,toptenwin,msghistory:200,windowtype:Qt" \
	    >>"$(DOCDIR)/NetHack Defaults.txt"
#
#NetHack3D
#
nh3dmodels:

install.nh3dmodels:
	-mkdir -p $(GAMEDIR)
	cp win/nh3d/models/*.* $(GAMEDIR)

nh3dresources:

install.nh3dresources:
	-mkdir -p $(GAMEDIR)
	cp win/nh3d/Resources/*.* $(GAMEDIR)

nh3dtextures:

install.nh3dtextures:
	-mkdir -p $(GAMEDIR)
	cp win/nh3d/texture/*.* $(GAMEDIR)

nh3dInfo.plist:

install.nh3dInfo.plist:
	cp win/nh3d/Info.plist $(BINDIR)/..
	
Englishlproj:

install.Englishlproj:
	cp -r win/nh3d/en.lproj $(GAMEDIR)/ja.lproj
	chmod $(DIRPERM) $(GAMEDIR)/ja.lproj

Japaneselproj:

install.Japaneselproj:
	cp -r win/nh3d/ja.lproj $(GAMEDIR)/ja.lproj
	chmod $(DIRPERM) $(GAMEDIR)/ja.lproj

nh3d.icns:

install.nh3d.icns:
	cp win/nh3d/nh3d.icns $(GAMEDIR)

nh3dsounds:

install.nh3dsounds:
	-mkdir -p $(GAMEDIR)
	cp win/nh3d/Sound/*.* $(GAMEDIR)

nh3dUserSound:
	-mkdir -p $(USOUNDDIR)
	cp win/nh3d/nh3dSounds/*.* $(USOUNDDIR)

update: $(GAME) recover $(VARDAT) dungeon spec_levs
#	(don't yank the old version out from under people who're playing it)
	-mv $(BINDIR)/$(GAME) $(BINDIR)/$(GAME).old
#	quest.dat is also kept open and has the same problems over NFS
#	(quest.dat may be inside nhdat if dlb is in use)
	-mv $(GAMEDIR)/quest.dat $(GAMEDIR)/quest.dat.old
	-mv $(GAMEDIR)/nhdat $(GAMEDIR)/nhdat.old
# set up new versions of the game files
	( $(MAKE) dofiles )
# touch time-sensitive files
	-touch -c $(VARDIR)/bones* $(VARDIR)/?lock* $(VARDIR)/wizard*
	-touch -c $(VARDIR)/save/*
	touch $(VARDIR)/perm $(VARDIR)/record
# and a reminder
	@echo You may also want to install the man pages via the doc Makefile.

install: $(GAME) recover $(VARDAT) dungeon spec_levs
# set up the directories
# not all mkdirs have -p; those that don't will create a -p directory
	-test -z "$(SHELLDIR)" || mkdir -p $(SHELLDIR)
	-rm -rf $(GAMEDIR) $(VARDIR) $(BINDIR)
	-mkdir -p $(GAMEDIR) $(VARDIR) $(BINDIR) $(VARDIR)/save
	-rmdir ./-p
	-$(CHOWN) $(GAMEUID) $(GAMEDIR) $(VARDIR) $(VARDIR)/save
	-$(CHGRP) $(GAMEGRP) $(GAMEDIR) $(VARDIR) $(VARDIR)/save
	chmod $(DIRPERM) $(GAMEDIR) $(VARDIR) $(VARDIR)/save
# set up the game files
	( $(MAKE) dofiles )
# set up some additional files
	touch $(VARDIR)/perm $(VARDIR)/record $(VARDIR)/logfile
	-( cd $(VARDIR) ; $(CHOWN) $(GAMEUID) perm record logfile ; \
			$(CHGRP) $(GAMEGRP) perm record logfile ; \
			chmod $(FILEPERM) perm record logfile )
# and a reminder
	@echo You may also want to reinstall the man pages via the doc Makefile.


# 'make clean' removes all the .o files, but leaves around all the executables
# and compiled data files
clean:
	( cd src ; $(MAKE) clean )
	( cd util ; $(MAKE) clean )

# 'make spotless' returns the source tree to near-distribution condition.
# it removes .o files, executables, and compiled data files
spotless:
	( cd src ; $(MAKE) spotless )
	( cd util ; $(MAKE) spotless )
	( cd dat ; $(MAKE) spotless )
	( cd doc ; $(MAKE) spotless )
