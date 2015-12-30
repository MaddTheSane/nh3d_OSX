#
# This file is generated automatically.  Do not edit.
# Your changes will be lost.  See sys/unix/NewInstall.unx.
# Identify this file:
MAKEFILE_TOP=1

###
### Start hints/macosx10.10 PRE
###
# (new segment at source line 6 )
# Mac OS X (Darwin) hints file
# This is for Mac OS X 10.10 or later.  If this doesn't work for some other
# version of Mac OS X, make a new file for that OS, don't change this one.
# And let us know about it.
# Useful info: http://www.opensource.apple.com/darwinsource/index.html

# This hints file can build several different types of installations.
# Edit the next section to match the type of build you need.

# 1. Which window system(s) should be included in this binary?
WANT_WIN_TTY=1
#WANT_WIN_X11=1
#WANT_WIN_QT=1

# 1a. What is the default window system?
WANT_DEFAULT=tty
#WANT_DEFAULT=x11
#WANT_DEFAULT=qt

# 1b. If you set WANT_WIN_QT, you need to
#  A) set QTDIR either here or in the environment to point to the Qt2 or Qt3
#     library installation root.  (Qt4 will not work; Qt3 does not presently
#     compile under Leopard (MacOSX 10.5) out-of-the-box.)
#  B) set XPMLIB to point to the Xpm library
ifdef WANT_WIN_QT
QTDIR=/Developer/Qt
LIBXPM= -L/opt/X11/lib -lXpm
endif	# WANT_WIN_QT

# 2. Is this a build for a binary that will be shared among different users
#    or will it be private to you?
#    If it is shared:
#	- it will be owned by the user and group listed
#	- if the user does not exist, you MUST create it before installing
#	  NetHack
#	- if the group does not exist, it will be created.
#	  NB: if the group already exists and is being used for something
#	   besides games, you probably want to specify a new group instead
#	  NB: the group will be created locally; if your computer is centrally
#	   administered this may not be what you (or your admin) want.
#	   Consider a non-shared install (WANT_SHARE_INSTALL=0) instead.
#	- 'make install' must be run as "sudo make install"    
#WANT_SHARE_INSTALL=1
GAMEUID  = $(USER)
GAMEGRP  = games
# build to run in the source tree - primarily for development.  Build with "make all"
#WANT_SOURCE_INSTALL=1

CC=gcc

# At the moment this is just for debugging, but in the future it could be
# useful for other things.  Requires SYSCF and an ANSI compiler.
#WANT_WIN_CHAIN=1

#
# You shouldn't need to change anything below here.
#

#CFLAGS+=-W -Wimplicit -Wreturn-type -Wunused -Wformat -Wswitch -Wshadow -Wcast-qual -Wwrite-strings -DGCC_WARN
CFLAGS+=-Wall -Wextra -Wno-missing-field-initializers -Wimplicit -Wreturn-type -Wunused -Wformat -Wswitch -Wshadow -Wwrite-strings -DGCC_WARN -ansi -pedantic
# As of LLVM build 2336.1.00, this gives dozens of spurious messages, so
# leave it out by default.
#CFLAGS+=-Wunreachable-code

# XXX -g vs -O should go here, -I../include goes in the makefile
CFLAGS+=-g -I../include
# older binaries use NOCLIPPING, but that disables SIGWINCH
#CFLAGS+=-DNOCLIPPING
CFLAGS+= -DNOMAIL -DNOTPARMDECL -DHACKDIR=\"$(HACKDIR)\"
CFLAGS+= -DDEFAULT_WINDOW_SYS=\"$(WANT_DEFAULT)\" -DDLB

CFLAGS+= -DGREPPATH=\"/usr/bin/grep\"

ifdef WANT_WIN_CHAIN
CFLAGS+= -DWINCHAIN
HINTSRC=$(CHAINSRC)
HINTOBJ=$(CHAINOBJ)
endif

ifdef WANT_WIN_TTY
WINSRC = $(WINTTYSRC)
WINOBJ = $(WINTTYOBJ)
WINLIB = $(WINTTYLIB)
WINTTYLIB=-lncurses
else	# !WANT_WIN_TTY
CFLAGS += -DNOTTYGRAPHICS
endif	# !WANT_WIN_TTY

ifdef WANT_WIN_X11
WINSRC += $(WINX11SRC)
WINOBJ += $(WINX11OBJ)
WINLIB += $(WINX11LIB)
LFLAGS=-L/opt/X11/lib
VARDATND = x11tiles NetHack.ad pet_mark.xbm pilemark.xbm
POSTINSTALL+= bdftopcf win/X11/nh10.bdf > $(HACKDIR)/nh10.pcf; (cd $(HACKDIR); mkfontdir);
CFLAGS += -DX11_GRAPHICS -I/opt/X11/include
endif	# WANT_WIN_X11

ifdef WANT_WIN_QT
CFLAGS += -DQT_GRAPHICS -DNOUSER_SOUNDS
CFLAGS += -isysroot /Developer/SDKs/MacOSX10.4u.sdk -mmacosx-version-min=10.4
LINK=g++
WINSRC += $(WINQTSRC)
WINLIB += $(WINQTLIB) $(LIBXPM)
WINLIB += -framework Carbon -framework QuickTime -lz -framework OpenGL
WINLIB += -framework AGL
ifdef WANT_WIN_X11
	# prevent duplicate tile.o in WINOBJ
WINOBJ = $(sort $(WINQTOBJ) $(WINX11OBJ))
ifdef WANT_WIN_TTY
WINOBJ += $(WINTTYOBJ)
endif	# WANT_WIN_TTY
else	# !WANT_WIN_X11
WINOBJ += $(WINQTOBJ)
endif	# !WANT_WIN_X11

# XXX if /Developer/qt exists and QTDIR not set, use that
ifndef QTDIR
$(error QTDIR not defined in the environment or Makefile)
endif	# QTDIR
# XXX make sure QTDIR points to something reasonable
else	# !WANT_WIN_QT
LINK=$(CC)
endif	# !WANT_WIN_QT

ifdef WANT_SHARE_INSTALL
# if $GAMEUID is root, we install into roughly proper Mac locations, otherwise
# we install into ~/nethackdir
ifeq ($(GAMEUID),root)
PREFIX:=/Library/NetHack
SHELLDIR=/usr/local/bin
HACKDIR=$(PREFIX)/nethackdir
CHOWN=chown
CHGRP=chgrp
# We run sgid so the game has access to both HACKDIR and user preferences.
GAMEPERM = 02755
else	# ! root
PREFIX:=/Users/$(GAMEUID)
SHELLDIR=$(PREFIX)/bin
HACKDIR=$(PREFIX)/Library/NetHack/nethackdir
CHOWN=/usr/bin/true
CHGRP=/usr/bin/true
GAMEPERM = 0500
endif	# ! root
VARFILEPERM = 0664
VARDIRPERM = 0775
ROOTCHECK= [[ `id -u` == 0 ]] || ( echo "Must run install with sudo."; exit 1)
# XXX it's nice we don't write over sysconf, but we've already erased it
# make sure we have group GAMEUID and group GAMEGRP
PREINSTALL= . sys/unix/hints/macosx.sh user2 $(GAMEUID); . sys/unix/hints/macosx.sh group2 $(GAMEGRP); mkdir $(SHELLDIR); chown $(GAMEUID) $(SHELLDIR)
POSTINSTALL+= cp -n sys/unix/sysconf $(HACKDIR)/sysconf; $(CHOWN) $(GAMEUID) $(HACKDIR)/sysconf; $(CHGRP) $(GAMEGRP) $(HACKDIR)/sysconf; chmod $(VARFILEPERM) $(HACKDIR)/sysconf;
CFLAGS+=-DSYSCF -DSYSCF_FILE=\"$(HACKDIR)/sysconf\" -DSECURE
else ifdef WANT_SOURCE_INSTALL
PREFIX=$(abspath $(NHSROOT))
# suppress nethack.sh
#SHELLDIR=
HACKDIR=$(PREFIX)/playground
CHOWN=/usr/bin/true
CHGRP=/usr/bin/true
GAMEPERM = 0700
VARFILEPERM = 0600
VARDIRPERM = 0700
# We can use "make all" to build the whole thing - but it misses some things:
MOREALL=$(MAKE) install
CFLAGS+=-DSYSCF -DSYSCF_FILE=\"$(HACKDIR)/sysconf\" -DSECURE
else	# !WANT_SOURCE_INSTALL
PREFIX:=$(wildcard ~)
SHELLDIR=$(PREFIX)/bin
HACKDIR=$(PREFIX)/nethackdir
CHOWN=/usr/bin/true
CHGRP=/usr/bin/true
GAMEPERM = 0700
VARFILEPERM = 0600
VARDIRPERM = 0700
ifdef WANT_WIN_X11
# install nethack.rc as ~/.nethackrc if no ~/.nethackrc exists
PREINSTALL= cp -n win/X11/nethack.rc ~/.nethackrc
endif	# WANT_WIN_X11
POSTINSTALL+= cp -n sys/unix/sysconf $(HACKDIR)/sysconf; $(CHOWN) $(GAMEUID) $(HACKDIR)/sysconf; $(CHGRP) $(GAMEGRP) $(HACKDIR)/sysconf; chmod $(VARFILEPERM) $(HACKDIR)/sysconf;
CFLAGS+=-DSYSCF -DSYSCF_FILE=\"$(HACKDIR)/sysconf\" -DSECURE
endif	# !WANT_SOURCE_INSTALL

INSTDIR=$(HACKDIR)
VARDIR=$(HACKDIR)


# ~/Library/Preferences/NetHack Defaults
# OPTIONS=name:player,number_pad,menustyle:partial,!time,showexp
# OPTIONS=hilite_pet,toptenwin,msghistory:200,windowtype:Qt
#
# Install.Qt mentions a patch for macos - it's not there (it seems to be in the Qt binary
# package under the docs directory).

### End hints/macosx10.10 PRE

###
### Start Makefile.top
###
#	NetHack Makefile.
# NetHack 3.6  Makefile.top	$NHDT-Date: 1447844578 2015/11/18 11:02:58 $  $NHDT-Branch: master $:$NHDT-Revision: 1.32 $

# Root of source tree:
NHSROOT=.

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
#PREFIX	 = /usr
GAME     = nethack
# GAME     = nethack.prg
#GAMEUID  = games
#GAMEGRP  = bin

# Permissions - some places use setgid instead of setuid, for instance
# See also the option "SECURE" in include/config.h
#GAMEPERM = 04755
FILEPERM = 0644
# VARFILEPERM = 0644
EXEPERM  = 0755
DIRPERM  = 0755
# VARDIRPERM = 0755

# VARDIR may also appear in unixconf.h as "VAR_PLAYGROUND" else HACKDIR
#
# note that 'make install' believes in creating a nice tidy HACKDIR for
# installation, free of debris from previous NetHack versions --
# therefore there should not be anything in HACKDIR that you want to keep
# (if there is, you'll have to do the installation by hand or modify the
# instructions)
#HACKDIR  = $(PREFIX)/games/lib/$(GAME)dir
#VARDIR  = $(HACKDIR)
# Where nethack.sh in installed.  If this is not defined, the wrapper is not used.
#SHELLDIR = $(PREFIX)/games

# per discussion in Install.X11 and Install.Qt
#VARDATND = 
# VARDATND = x11tiles NetHack.ad pet_mark.xbm pilemark.xpm
# VARDATND = x11tiles NetHack.ad pet_mark.xbm pilemark.xpm rip.xpm
# for Atari/Gem
# VARDATND = nh16.img title.img GEM_RSC.RSC rip.img
# for BeOS
# VARDATND = beostiles
# for Gnome
# VARDATND = x11tiles pet_mark.xbm pilemark.xpm rip.xpm mapbg.xpm

VARDATD = bogusmon data engrave epitaph oracles options quest.dat rumors
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
#CHOWN = chown
#CHGRP = chgrp

#
# end of configuration
#

DATHELP = help hh cmdhelp history opthelp wizhelp

SPEC_LEVS = asmodeus.lev baalz.lev bigrm-*.lev castle.lev fakewiz?.lev \
	juiblex.lev knox.lev medusa-?.lev minend-?.lev minefill.lev \
	minetn-?.lev oracle.lev orcus.lev sanctum.lev soko?-?.lev \
	tower?.lev valley.lev wizard?.lev \
	astral.lev air.lev earth.lev fire.lev water.lev
QUEST_LEVS = ???-goal.lev ???-fil?.lev ???-loca.lev ???-strt.lev

DATNODLB = $(VARDATND) license
DATDLB = $(DATHELP) dungeon tribute $(SPEC_LEVS) $(QUEST_LEVS) $(VARDATD)
DAT = $(DATNODLB) $(DATDLB)

$(GAME):
	( cd src ; $(MAKE) )

all:	$(GAME) recover Guidebook $(VARDAT) dungeon spec_levs check-dlb
	true; $(MOREALL)
	@echo "Done."

# Note: many of the dependencies below are here to allow parallel make
# to generate valid output

Guidebook:
	( cd doc ; $(MAKE) Guidebook )

manpages:
	( cd doc ; $(MAKE) manpages )

data: $(GAME)
	( cd dat ; $(MAKE) data )

engrave: $(GAME)
	( cd dat ; $(MAKE) engrave )

bogusmon: $(GAME)
	( cd dat ; $(MAKE) bogusmon )

epitaph: $(GAME)
	( cd dat ; $(MAKE) epitaph )

rumors: $(GAME)
	( cd dat ; $(MAKE) rumors )

oracles: $(GAME)
	( cd dat ; $(MAKE) oracles )

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

pilemark.xbm:
	( cd dat ; $(MAKE) pilemark.xbm )

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
recover: $(GAME)
	( cd util ; $(MAKE) recover )

dofiles:
	target=`sed -n					\
		-e '/librarian/{' 			\
		-e	's/.*/dlb/p' 			\
		-e	'q' 				\
		-e '}' 					\
	  	-e '$$s/.*/nodlb/p' < dat/options` ;	\
	$(MAKE) dofiles-$${target-nodlb}
	(cd dat ; cp symbols $(INSTDIR) )
	cp src/$(GAME) $(INSTDIR)
	cp util/recover $(INSTDIR)
	-if test -n '$(SHELLDIR)'; then rm -f $(SHELLDIR)/$(GAME); fi
	if test -n '$(SHELLDIR)'; then \
		sed -e 's;/usr/games/lib/nethackdir;$(HACKDIR);' \
		-e 's;HACKDIR/nethack;HACKDIR/$(GAME);' \
		< sys/unix/nethack.sh \
		> $(SHELLDIR)/$(GAME) ; fi
# set up their permissions
	-( cd $(INSTDIR) ; $(CHOWN) $(GAMEUID) $(GAME) recover ; \
			$(CHGRP) $(GAMEGRP) $(GAME) recover )
	chmod $(GAMEPERM) $(INSTDIR)/$(GAME)
	chmod $(EXEPERM) $(INSTDIR)/recover
	-if test -n '$(SHELLDIR)'; then \
		$(CHOWN) $(GAMEUID) $(SHELLDIR)/$(GAME); fi
	if test -n '$(SHELLDIR)'; then \
		$(CHGRP) $(GAMEGRP) $(SHELLDIR)/$(GAME); \
		chmod $(EXEPERM) $(SHELLDIR)/$(GAME); fi
	-( cd $(INSTDIR) ; $(CHOWN) $(GAMEUID) symbols ; \
			$(CHGRP) $(GAMEGRP) symbols ; \
			chmod $(FILEPERM) symbols )

dofiles-dlb: check-dlb
	( cd dat ; cp nhdat $(DATNODLB) $(INSTDIR) )
# set up their permissions
	-( cd $(INSTDIR) ; $(CHOWN) $(GAMEUID) nhdat $(DATNODLB) ; \
			$(CHGRP) $(GAMEGRP) nhdat $(DATNODLB) ; \
			chmod $(FILEPERM) nhdat $(DATNODLB) )

dofiles-nodlb:
# copy over the game files
	( cd dat ; cp $(DAT) $(INSTDIR) )
# set up their permissions
	-( cd $(INSTDIR) ; $(CHOWN) $(GAMEUID) $(DAT) ; \
			$(CHGRP) $(GAMEGRP) $(DAT) ; \
			chmod $(FILEPERM) $(DAT) )

update: $(GAME) recover $(VARDAT) dungeon spec_levs
#	(don't yank the old version out from under people who're playing it)
	-mv $(INSTDIR)/$(GAME) $(INSTDIR)/$(GAME).old
#	quest.dat is also kept open and has the same problems over NFS
#	(quest.dat may be inside nhdat if dlb is in use)
	-mv $(INSTDIR)/quest.dat $(INSTDIR)/quest.dat.old
	-mv $(INSTDIR)/nhdat $(INSTDIR)/nhdat.old
# set up new versions of the game files
	( $(MAKE) dofiles )
# touch time-sensitive files
	-touch -c $(VARDIR)/bones* $(VARDIR)/?lock* $(VARDIR)/wizard*
	-touch -c $(VARDIR)/save/*
	touch $(VARDIR)/perm $(VARDIR)/record
# and a reminder
	@echo You may also want to install the man pages via the doc Makefile.

rootcheck:
	@true; $(ROOTCHECK)

install: rootcheck $(GAME) recover $(VARDAT) dungeon spec_levs
	true; $(PREINSTALL)
# set up the directories
# not all mkdirs have -p; those that don't will create a -p directory
	-if test -n '$(SHELLDIR)'; then \
		mkdir -p $(SHELLDIR); fi
	rm -rf $(INSTDIR) $(VARDIR)
	-mkdir -p $(INSTDIR) $(VARDIR) $(VARDIR)/save
	if test -d ./-p; then rmdir ./-p; fi
	-$(CHOWN) $(GAMEUID) $(INSTDIR) $(VARDIR) $(VARDIR)/save
	$(CHGRP) $(GAMEGRP) $(INSTDIR) $(VARDIR) $(VARDIR)/save
# order counts here:
	chmod $(DIRPERM) $(INSTDIR)
	chmod $(VARDIRPERM) $(VARDIR) $(VARDIR)/save
# set up the game files
	( $(MAKE) dofiles )
# set up some additional files
	touch $(VARDIR)/perm $(VARDIR)/record $(VARDIR)/logfile $(VARDIR)/xlogfile
	-( cd $(VARDIR) ; $(CHOWN) $(GAMEUID) perm record logfile xlogfile ; \
			$(CHGRP) $(GAMEGRP) perm record logfile xlogfile ; \
			chmod $(VARFILEPERM) perm record logfile xlogfile )
	true; $(POSTINSTALL)
# and a reminder
	@echo You may also want to reinstall the man pages via the doc Makefile.


# 'make clean' removes all the .o files, but leaves around all the executables
# and compiled data files
clean:
	( cd src ; $(MAKE) clean )
	( cd util ; $(MAKE) clean )
	( cd doc ; $(MAKE) clean )

# 'make spotless' returns the source tree to near-distribution condition.
# it removes .o files, executables, and compiled data files
spotless:
	( cd src ; $(MAKE) spotless )
	( cd util ; $(MAKE) spotless )
	( cd dat ; $(MAKE) spotless )
	( cd doc ; $(MAKE) spotless )
### End Makefile.top

###
### Start hints/macosx10.10 POST
###
# (new segment at source line 200 )
ifdef MAKEFILE_TOP
###
### Packaging
###
# Notes:
# 1) The Apple developer utilities must be installed in the default location.
# 2) Do a normal build before trying to package the game.
# 3) This matches the 3.4.3 Term package, but there are some things that should
#    be changed.

ifdef WANT_WIN_TTY
DEVUTIL=/Developer/Applications/Utilities
SVS=$(shell $(NHSROOT)/util/makedefs --svs)
SVSDOT=$(shell $(NHSROOT)/util/makedefs --svs .)

PKGROOT_UG	= PKGROOT/$(PREFIX)
PKGROOT_UGLN	= PKGROOT/$(HACKDIR)
PKGROOT_BIN	= PKGROOT/$(SHELLDIR)
build_tty_pkg:
ifneq (,$(WANT_WIN_X11)$(WANT_WIN_QT))
	-echo build_tty_pkg only works for a tty-only build
	exit 1
else
	rm -rf NetHack-$(SVS)-mac-Term.pkg NetHack-$(SVS)-mac-Term.dmg
	$(MAKE) build_package_root
	rm -rf RESOURCES
	mkdir RESOURCES
	#enscript --language=rtf -o - < dat/license >RESOURCES/License.rtf
	sys/unix/hints/macosx.sh descplist > RESOURCES/Description.plist
	sys/unix/hints/macosx.sh infoplist > Info.plist

	mkdir PKGROOT/Applications
	#osacompile -o NetHackQt/NetHackQt.app/nethackdir/NetHackRecover.app \
	#	 win/macosx/NetHackRecover.applescript
	#cp win/macosx/recover.pl NetHackQt/NetHackQt.app/nethackdir
	osacompile -o PKGROOT/Applications/NetHackRecover.app \
		 win/macosx/NetHackRecover.applescript
	cp win/macosx/recover.pl $(PKGROOT_UGLN)

	osacompile -o PKGROOT/Applications/NetHackTerm.app \
		 win/macosx/NetHackTerm.applescript

	# XXX integrate into Makefile.doc
	(cd doc; cat Guidebook.mn | ../util/makedefs --grep --input - --output - \
	| tbl tmac.n - | groff | pstopdf -i -o Guidebook.pdf)
	cp doc/Guidebook.pdf $(PKGROOT_UG)/doc/NetHackGuidebook.pdf

	osacompile -o PKGROOT/Applications/NetHackGuidebook.app \
		 win/macosx/NetHackGuidebook.applescript

	mkdir -p PKG
	pkgbuild --root PKGROOT --identifier org.nethack.term --scripts PKGSCRIPTS PKG/NH-Term.pkg
	productbuild --synthesize --product Info.plist --package PKG/NH-Term.pkg Distribution.xml
	productbuild --distribution Distribution.xml --resources RESOURCES --package-path PKG NetHack-$(SVS)-mac-Term.pkg
	hdiutil create -verbose -srcfolder NetHack-$(SVS)-mac-Term.pkg NetHack-$(SVS)-mac-Term.dmg

build_package_root:
	cd src/..       # make sure we are at TOP
	rm -rf PKGROOT
	mkdir -p $(PKGROOT_UG)/lib $(PKGROOT_BIN) $(PKGROOT_UG)/man/man6 $(PKGROOT_UG)/doc $(PKGROOT_UGLN)
	install -p src/nethack $(PKGROOT_BIN)
	# XXX should this be called nethackrecover?
	install -p util/recover $(PKGROOT_BIN)
	install -p doc/nethack.6 $(PKGROOT_UG)/man/man6
	install -p doc/recover.6 $(PKGROOT_UG)/man/man6
	install -p doc/Guidebook $(PKGROOT_UG)/doc
	install -p dat/nhdat $(PKGROOT_UGLN)
	sed 's/^GDBPATH/#GDBPATH/' sys/unix/sysconf | sed 's/^GREPPATH=\/bin\/grep/GREPPATH=\/usr\/bin\/grep/' | sed 's/^PANICTRACE_GDB=[12]/PANICTRACE_GDB=0/' > $(PKGROOT_UGLN)/sysconf
	cd dat; install -p $(DATNODLB) ../$(PKGROOT_UGLN)
# XXX these files should be somewhere else for good Mac form
	touch $(PKGROOT_UGLN)/perm $(PKGROOT_UGLN)/record $(PKGROOT_UGLN)/logfile $(PKGROOT_UGLN)/xlogfile
	mkdir $(PKGROOT_UGLN)/save
# XXX what about a news file?

	mkdir -p PKGSCRIPTS
	echo '#!/bin/sh'                              >  PKGSCRIPTS/postinstall
	echo $(CHOWN) -R $(GAMEUID) $(HACKDIR)        >> PKGSCRIPTS/postinstall
	echo $(CHGRP) -R $(GAMEGRP) $(HACKDIR)        >> PKGSCRIPTS/postinstall
	echo $(CHOWN) $(GAMEUID) $(SHELLDIR)/nethack  >> PKGSCRIPTS/postinstall
	echo $(CHGRP) $(GAMEGRP) $(SHELLDIR)/nethack  >> PKGSCRIPTS/postinstall
	echo $(CHOWN) $(GAMEUID) $(SHELLDIR)/recover  >> PKGSCRIPTS/postinstall
	echo $(CHGRP) $(GAMEGRP) $(SHELLDIR)/recover  >> PKGSCRIPTS/postinstall
	echo chmod $(VARDIRPERM)  $(HACKDIR)          >> PKGSCRIPTS/postinstall
	echo chmod $(VARDIRPERM)  $(HACKDIR)/save     >> PKGSCRIPTS/postinstall
	echo chmod $(FILEPERM)    $(HACKDIR)/nhdat    >> PKGSCRIPTS/postinstall
	echo chmod $(VARFILEPERM) $(HACKDIR)/perm     >> PKGSCRIPTS/postinstall
	echo chmod $(VARFILEPERM) $(HACKDIR)/record   >> PKGSCRIPTS/postinstall
	echo chmod $(VARFILEPERM) $(HACKDIR)/logfile  >> PKGSCRIPTS/postinstall
	echo chmod $(VARFILEPERM) $(HACKDIR)/xlogfile >> PKGSCRIPTS/postinstall
	echo chmod $(VARFILEPERM) $(HACKDIR)/sysconf  >> PKGSCRIPTS/postinstall
	echo chmod $(GAMEPERM)   $(SHELLDIR)/nethack  >> PKGSCRIPTS/postinstall
	echo chmod $(EXEPERM)    $(SHELLDIR)/recover  >> PKGSCRIPTS/postinstall
	chmod 0775 PKGSCRIPTS/postinstall

endif	# end of build_tty_pkg
endif	# WANT_WIN_TTY for packaging

ifdef WANT_WIN_QT
# XXX untested and incomplete (see below)
build_qt_pkg:
ifneq (,$(WANT_WIN_X11)$(WANT_WIN_TTY))
	-echo build_qt_pkg only works for a qt-only build
	exit 1
else
	$(MAKE) build_package_root
	rm -rf NetHackQt
	mkdir -p NetHackQt/NetHackQt.app/nethackdir/save
	mkdir NetHackQt/Documentation
	cp doc/Guidebook.txt doc/nethack.txt doc/recover.txt NetHackQt/Documentation

	osacompile -o NetHackQt/NetHackQt.app/nethackdir/NetHackRecover.app \
		 win/macosx/NetHackRecover.applescript
	cp win/macosx/recover.pl NetHackQt/NetHackQt.app/nethackdir

	mkdir -p NetHackQt/NetHackQt.app/Contents/Frameworks
	cp $(QTDIR)/libqt-mt.3.dylib NetHackQt/NetHackQt.app/Contents/Frameworks

	mkdir NetHackQt/NetHackQt.app/Contents/MacOS
	mv PKGROOT/nethack NetHackQt/NetHackQt.app/Contents/MacOS

	mv PKGROOT/lib/nethackdir NetHackQt/NetHackQt.app/nethackdir

# XXX still missing:
#NetHackQt/NetHackQt.app
# /Contents
#	Info.plist
#	Resources/nethack.icns
#NetHackQt/Documentation
#NetHackQtRecover.txt
#NetHack Defaults.txt
#changes.patch XXX is this still needed?  why isn't it part of the tree?
#  doesn't go here
	hdiutil create -verbose -srcfolder NetHackQt NetHack-$(SVS)-macosx-qt.dmg
endif	# end of build_qt_pkg
endif	# WANT_WIN_QT for packaging
endif	# MAKEFILE_TOP
### End hints/macosx10.10 POST
