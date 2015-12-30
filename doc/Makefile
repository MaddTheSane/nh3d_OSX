#
# This file is generated automatically.  Do not edit.
# Your changes will be lost.  See sys/unix/NewInstall.unx.
# Identify this file:
MAKEFILE_DOC=1

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
### Start Makefile.doc
###
#	NetHack Makefile.
# NetHack 3.6  Makefile.doc	$NHDT-Date: 1432512789 2015/05/25 00:13:09 $  $NHDT-Branch: master $:$NHDT-Revision: 1.14 $

# Root of source tree:
NHSROOT=..

# for Atari
# SHELL=E:/GEMINI2/MUPFEL.TTP

MAKEDEFS = ../util/makedefs

# Which version do we want to build?  (XXX These are not used anywhere.)
GUIDEBOOK = Guidebook		# regular ASCII file
#GUIDEBOOK = Guidebook.ps	# PostScript file
#GUIDEBOOK = Guidebook.dvi	# TeX device-independent file

# Some versions of col need -x to keep them from converting spaces to tabs;
# some versions of col don't do the conversion by default and don't
# recognize the option.  Sigh.
COLCMD = col -bx
#COLCMD = col -b

# The command to use to generate a PostScript file
# PSCMD = ditroff | psdit
PSCMD = groff

# Use the "cat" GUIDECMD if nroff and/or tbl and/or col are not installed
# Not appropriate for creating Guidebook.txt.
# GUIDECMD = cat Guidebook.txt
# The following works better with groff-1.18, eg on Linux
# GUIDECMD = $(GUIDE_PREFORMAT) | nroff -c -Tascii | $(COLCMD)
GUIDECMD = $(GUIDE_PREFORMAT) | nroff | $(COLCMD)

# Only generate output for the current configuration:
NHGREP = $(MAKEDEFS) --grep --input - --output -
# Generate output for all configurations:
#NHGREP = $(MAKEDEFS) --grep --input - --output - --grep-define ALLDOCS
# Fallback:
#NHGREP = cat

GUIDE_PREFORMAT = cat Guidebook.mn | $(NHGREP) | tbl tmac.n -

# the basic guidebook
Guidebook:	Guidebook.mn
	$(GUIDECMD) > Guidebook

# Fancier output for those with ditroff, psdit and a PostScript printer.
Guidebook.ps:	Guidebook.mn
	$(GUIDE_PREFORMAT) | $(PSCMD) > Guidebook.ps

# Guidebook.tex is the same as Guidebook.mn but formatted with LaTeX.
# - The invocation command for LaTeX may vary in different installations.
# - To print Guidebook.dvi you need to use a suitable dvi-driver.
# - LaTeX needs to be run twice; second pass uses Guidebook.aux made by first.
Guidebook.dvi:	Guidebook.tex
	latex Guidebook.tex
	latex Guidebook.tex


GAME	= nethack
MANDIR	= /usr/man/man6
MANEXT	= 6

# manual installation for most BSD-style systems
GAMEMANCREATE = cat nethack.6 | $(NHGREP) >
LEVMANCREATE = cat lev_comp.6 | $(NHGREP) >
DGNMANCREATE = cat dgn_comp.6 | $(NHGREP) >
RCVRMANCREATE = cat recover.6 | $(NHGREP) >
DLBMANCREATE = cat dlb.6 | $(NHGREP) >
MDMANCREATE = cat makedefs.6 | $(NHGREP) >
# manual installation for most SYSV-style systems
# GAMEMANCREATE = cat nethack.6 | $(NHGREP) | nroff -man - >
# LEVMANCREATE = cat lev_comp.6 | $(NHGREP) | nroff -man - >
# DGNMANCREATE = cat dgn_comp.6 | $(NHGREP) | nroff -man - >
# RCVRMANCREATE = cat recover.6 | $(NHGREP) | nroff -man - >
# DLBMANCREATE = cat dlb.6 | $(NHGREP) | nroff -man - >
# MDMANCREATE = cat makedefs.6 | $(NHGREP) | nroff -man - >

manpages:
	-$(GAMEMANCREATE) $(MANDIR)/$(GAME).$(MANEXT)
	-$(LEVMANCREATE) $(MANDIR)/lev_comp.$(MANEXT)
	-$(DGNMANCREATE) $(MANDIR)/dgn_comp.$(MANEXT)
	-$(RCVRMANCREATE) $(MANDIR)/recover.$(MANEXT)
	-$(DLBMANCREATE) $(MANDIR)/dlb.$(MANEXT)
	-$(MDMANCREATE) $(MANDIR)/makedefs.$(MANEXT)

# manual creation for distribution
DISTRIB = Guidebook.txt nethack.txt lev_comp.txt dgn_comp.txt recover.txt \
	dlb.txt makedefs.txt

distrib: $(DISTRIB)
	@echo "Plain text documentation is up to date."

Guidebook.txt	: Guidebook.mn tmac.n
	$(GUIDECMD) > Guidebook.txt
MAN2TXT = $(NHGREP) | nroff -man - | $(COLCMD)
nethack.txt	: nethack.6
	cat nethack.6 | $(MAN2TXT) > nethack.txt
lev_comp.txt	: lev_comp.6
	cat lev_comp.6 | $(MAN2TXT) > lev_comp.txt
dgn_comp.txt	: dgn_comp.6
	cat dgn_comp.6 | $(MAN2TXT) > dgn_comp.txt
recover.txt	: recover.6
	cat recover.6 | $(MAN2TXT) > recover.txt
dlb.txt		: dlb.6
	cat dlb.6 | $(MAN2TXT) > dlb.txt
makedefs.txt		: makedefs.6
	cat makedefs.6 | $(MAN2TXT) > makedefs.txt

clean:
	-rm -f Guidebook.aux Guidebook.log

spotless: clean
	-rm -f Guidebook Guidebook.ps Guidebook.dvi

maintainer-clean: spotless
	-rm -f $(DISTRIB)
#	-rm -f Makefile
### End Makefile.doc

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
