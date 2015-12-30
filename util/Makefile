#
# This file is generated automatically.  Do not edit.
# Your changes will be lost.  See sys/unix/NewInstall.unx.
# Identify this file:
MAKEFILE_UTL=1

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
### Start Makefile.utl
###
#	Makefile for NetHack's utility programs.
# NetHack 3.6  Makefile.utl	$NHDT-Date: 1449386560 2015/12/06 07:22:40 $  $NHDT-Branch: NetHack-3.6.0 $:$NHDT-Revision: 1.27 $

# Root of source tree:
NHSROOT=..

# newer makes predefine $(MAKE) to 'make' and do smarter processing of
# recursive make calls if $(MAKE) is used
# these makes allow $(MAKE) to be overridden by the environment if someone
# wants to (or has to) use something other than the standard make, so we do
# not want to unconditionally set $(MAKE) here
#
# unfortunately, some older makes do not predefine $(MAKE); if you have one of
# these, uncomment the following line
# (you will know that you have one if you get complaints about unable to
# execute things like 'foo.o')
# MAKE = make

# if you are using gcc as your compiler,
#	uncomment the CC definition below if it's not in your environment
# CC = gcc
#
#	For Bull DPX/2 systems at B.O.S. 2.0 or higher use the following:
#
# CC = gcc -ansi -D_BULL_SOURCE -D_XOPEN_SOURCE -D_POSIX_SOURCE
#
#	If you are using GCC 2.2.2 or higher on a DPX/2, just use:
#
# CC = gcc -ansi
#
#	For HP/UX 10.20 with GCC:
# CC = gcc -D_POSIX_SOURCE
#
# if your make doesn't define a default SHELL properly, you may need
#    the line below (Atari users will need a bourne work-alike)
# SHELL = /bin/sh
# for Atari
# SHELL=E:/GEMINI2/MUPFEL.TTP

# flags may have to be changed as required
# flags for 286 Xenix:
# CFLAGS = -Ml2t16 -O -LARGE -I../include
# LFLAGS = -Ml -F 4000 -SEG 512

# flags for 286 Microport SysV-AT
# CFLAGS = -DDUMB -Ml -I../include
# LFLAGS = -Ml

# flags for Atari GCC (3.2.1)
# CFLAGS = -O -I../include
# LFLAGS = -s
# flags for Atari GCC (3.3)
# CFLAGS = -mshort -O2 -I../include
# LFLAGS = -mshort -s

# flags for Apollos using their native cc
# (as long as it claims to be __STDC__ but isn't)
# CFLAGS = -DAPOLLO -O -I../include

# flags for AIX 3.1 cc on IBM RS/6000 to define
# a suitable subset of standard libraries
# (note that there is more info regarding the "-qchars=signed"
# switch in file Install.unx note 8)
# CFLAGS = -D_NO_PROTO -D_XOPEN_SOURCE -O -I../include -qchars=signed
# and for AIX 3.2:
# CFLAGS = -D_NO_PROTO -D_XOPEN_SOURCE -D_ALL_SOURCE -O -I../include -qchars=signed

# flags for A/UX 2.01 using native cc or c89
# gcc predefines AUX so that's not needed there
# CFLAGS = -ZS -D_POSIX_SOURCE -O -I../include -DAUX

# flags for IRIX 4.0.x using native cc
# SGI cc 3.10 will fail to compile makedefs with -O
# CFLAGS = -I../include -D__STDC__ -woff 100,293

# flags for Linux
#   compile normally
# CFLAGS = -O2 -fomit-frame-pointer -I../include
# LFLAGS = -L/usr/X11R6/lib
#   OR compile backwards compatible a.out format
# CFLAGS = -O2 -b i486-linuxaout -fomit-frame-pointer -I../include
# LFLAGS = -b i486-linuxaout -L/usr/X11R6/lib

# flags for BeOS using the command line
# remember to uncomment flex and bison below
#   BeOS on a Mac/BeBox:
#CC = mwcc
#CFLAGS = -I../include
#   BeOS on Intel:
# the default values are fine

# flags for debugging:
# CFLAGS = -g -I../include

#CFLAGS = -O -I../include
#LFLAGS =

LIBS =

# If you are cross-compiling, you must use this:
#OBJDIR = .
# otherwise, you can save a little bit of disk space with this:
OBJDIR = ../src

# yacc/lex programs to use to generate *_comp.h, *_lex.c, and *_yacc.c.
# if, instead of yacc/lex you have bison/flex, comment/uncomment the following.
YACC     = yacc
LEX      = lex
# YACC     = bison -y
# YACC     = byacc
# LEX      = flex

# these are the names of the output files from YACC/LEX. Under MS-DOS
# and similar systems, they may differ
YTABC = y.tab.c
YTABH = y.tab.h
LEXYYC = lex.yy.c
# YTABC = y_tab.c
# YTABH = y_tab.h
# LEXYYC = lexyy.c



# ----------------------------------------
#
# Nothing below this line should have to be changed.

# timestamps for primary header files, matching src/Makefile
CONFIG_H = ../src/config.h-t
HACK_H	 = ../src/hack.h-t

# utility .c files
MAKESRC = makedefs.c
SPLEVSRC = lev_yacc.c lev_lex.c lev_main.c
DGNCOMPSRC = dgn_yacc.c dgn_lex.c dgn_main.c
RECOVSRC = recover.c
DLBSRC = dlb_main.c
UTILSRCS = $(MAKESRC) panic.c $(SPLEVSRC) $(DGNCOMPSRC) $(RECOVSRC) $(DLBSRC)

# files that define all monsters and objects
CMONOBJ = ../src/monst.c ../src/objects.c
OMONOBJ = $(OBJDIR)/monst.o $(OBJDIR)/objects.o
# files that provide access to NetHack's names
CNAMING = ../src/drawing.c ../src/decl.c $(CMONOBJ)
ONAMING = $(OBJDIR)/drawing.o $(OBJDIR)/decl.o $(OMONOBJ)
# dynamic memory allocation
CALLOC = ../src/alloc.c panic.c
OALLOC = $(OBJDIR)/alloc.o panic.o

# object files for makedefs
MAKEOBJS = makedefs.o $(OMONOBJ)

# object files for special levels compiler
SPLEVOBJS = lev_yacc.o lev_lex.o lev_main.o $(OALLOC) $(ONAMING)

# object files for dungeon compiler
DGNCOMPOBJS = dgn_yacc.o dgn_lex.o dgn_main.o $(OALLOC)

# object files for recovery utility
RECOVOBJS = recover.o

# object files for the data librarian
DLBOBJS = dlb_main.o $(OBJDIR)/dlb.o $(OALLOC)

# flags for creating distribution versions of sys/share/*_lex.c, using
# a more portable flex skeleton, which is not included in the distribution.
# hopefully keeping this out of the section to be edited will keep too
# many people from being confused by it...
# FLEXDIST = -L -S../sys/share/flexhack.skl
FLEXDIST =
#
# flags for creating distribution versions of sys/share/*_yacc.c, without
# line numbers so patches from version to version are practical
# YACCDIST = -l
YACCDIST =


#	dependencies for makedefs
#
makedefs:	$(MAKEOBJS) mdgrep.h
	$(CC) $(LFLAGS) -o makedefs $(MAKEOBJS)

makedefs.o: makedefs.c $(CONFIG_H) ../include/permonst.h \
		../include/objclass.h ../include/monsym.h \
		../include/artilist.h ../include/dungeon.h ../include/obj.h \
		../include/monst.h ../include/you.h ../include/flag.h \
		../include/dlb.h ../include/patchlevel.h ../include/qtext.h

# Don't require perl to build; that is why mdgrep.h is spelled wrong below.
mdgreph: mdgrep.pl
	perl mdgrep.pl

../include/onames.h: makedefs
	./makedefs -o
../include/pm.h: makedefs
	./makedefs -p
../src/monstr.c: makedefs
	./makedefs -m
../include/vis_tab.h: makedefs
	./makedefs -z
# makedefs -z makes both vis_tab.h and vis_tab.c, but writes the .h first
../src/vis_tab.c: ../include/vis_tab.h

lintdefs:
	@lint -axbh -I../include -DLINT $(MAKESRC) $(CMONOBJ) | sed '/_flsbuf/d'


# we defer this makedefs call to the src Makefile, since it knows all about
# the main src and include files date.h is a timestamp for
../include/date.h::
	@( cd ../src ; $(MAKE) ../include/date.h )

# support code used by several of the utility programs (but not makedefs)
panic.o:     panic.c $(CONFIG_H)


#	dependencies for lev_comp
#
lev_comp:  $(SPLEVOBJS)
	$(CC) $(LFLAGS) -o lev_comp $(SPLEVOBJS) $(LIBS)

lev_yacc.o:  lev_yacc.c $(HACK_H) ../include/sp_lev.h
lev_main.o:  lev_main.c $(HACK_H) ../include/sp_lev.h ../include/tcap.h \
		../include/date.h

# see lev_comp.l for WEIRD_LEX discussion
# egrep will return failure if it doesn't find anything, but we know there
# is one "_cplusplus" inside a comment
lev_lex.o:   lev_lex.c $(HACK_H) ../include/lev_comp.h ../include/sp_lev.h
	@echo $(CC) -c $(CFLAGS) lev_lex.c
	@$(CC) -c $(CFLAGS) -DWEIRD_LEX=`egrep -c _cplusplus lev_lex.c` lev_lex.c

# '$(YACC) -d' generates both $(YTABC) and $(YTABH) in one run
../include/lev_comp.h: lev_yacc.c

lev_yacc.c: lev_comp.y
	$(YACC) $(YACCDIST) -d lev_comp.y
	sed -e 's#"$(YTABC)"#"$@"#' -e 's#$(YTABC):#$@:#' $(YTABC) > $@ \
		&& rm $(YTABC)
	sed -e 's#"$(YTABH)"#"lev_comp.h"#' $(YTABH) > ../include/lev_comp.h \
		&& rm $(YTABH)

lev_lex.c: lev_comp.l
	$(LEX) $(FLEXDIST) lev_comp.l
	sed -e 's#"$(LEXYYC)"#"$@"#' -e 's#  *$$##' $(LEXYYC) > $@ \
		&& rm $(LEXYYC)
#	note: flex code construction using m4 macros results in some trailing
#	spaces; <space><space><star> is basic RE substitute for <space><plus>
#	and we don't bother stripping trailing tabs because that gets messy;
#	make expands <dollar><dollar> into <dollar> which is RE end-of-line.

# with all of extern.h's functions to complain about, we drown in
# 'defined but not used' without -u
lintlev:
	@lint -axhu -I../include -DLINT $(SPLEVSRC) $(CALLOC) $(CNAMING) | sed '/_flsbuf/d'


#	dependencies for dgn_comp
#
dgn_comp:  $(DGNCOMPOBJS)
	$(CC) $(LFLAGS) -o dgn_comp $(DGNCOMPOBJS) $(LIBS)

dgn_yacc.o:  dgn_yacc.c $(CONFIG_H) ../include/dgn_file.h ../include/date.h
dgn_main.o:  dgn_main.c $(CONFIG_H) ../include/dlb.h

# see dgn_comp.l for WEIRD_LEX discussion
dgn_lex.o:   dgn_lex.c $(CONFIG_H) ../include/dgn_comp.h ../include/dgn_file.h
	@echo $(CC) -c $(CFLAGS) dgn_lex.c
	@$(CC) -c $(CFLAGS) -DWEIRD_LEX=`egrep -c _cplusplus dgn_lex.c` dgn_lex.c

# '$(YACC) -d' generates both $(YTABC) and $(YTABH) in one run
../include/dgn_comp.h: dgn_yacc.c

dgn_yacc.c: dgn_comp.y
	$(YACC) $(YACCDIST) -d dgn_comp.y
	sed -e 's#"$(YTABC)"#"$@"#' -e 's#$(YTABC):#$@:#' $(YTABC) > $@ \
		&& rm $(YTABC)
	sed -e 's#"$(YTABH)"#"dgn_comp.h"#' $(YTABH) > ../include/dgn_comp.h \
		&& rm $(YTABH)

dgn_lex.c: dgn_comp.l
	$(LEX) $(FLEXDIST) dgn_comp.l
	sed -e 's#"$(LEXYYC)"#"$@"#' -e 's#  *$$##' $(LEXYYC) > $@ \
		&& rm $(LEXYYC)
#	note: <space><space><star> is basic RE substitute for <space><plus>

# with all of extern.h's functions to complain about, we drown in
# 'defined but not used' without -u
lintdgn:
	@lint -axhu -I../include -DLINT $(DGNCOMPSRC) $(CALLOC) | sed '/_flsbuf/d'


#	dependencies for recover
#
recover: $(RECOVOBJS)
	$(CC) $(LFLAGS) -o recover $(RECOVOBJS) $(LIBS)

recover.o: recover.c $(CONFIG_H) ../include/date.h


#	dependencies for dlb
#
dlb:	$(DLBOBJS)
	$(CC) $(LFLAGS) -o dlb $(DLBOBJS) $(LIBS)

dlb_main.o: dlb_main.c $(CONFIG_H) ../include/dlb.h ../include/date.h
	$(CC) $(CFLAGS) -c dlb_main.c



#	dependencies for tile utilities
#
TEXT_IO = tiletext.o tiletxt.o $(ONAMING)
GIFREADERS = gifread.o $(OALLOC)
PPMWRITERS = ppmwrite.o $(OALLOC)

tileutils: tilemap gif2txt txt2ppm tile2x11

gif2txt: $(GIFREADERS) $(TEXT_IO)
	$(CC) $(LFLAGS) -o gif2txt $(GIFREADERS) $(TEXT_IO) $(LIBS)
txt2ppm: $(PPMWRITERS) $(TEXT_IO)
	$(CC) $(LFLAGS) -o txt2ppm $(PPMWRITERS) $(TEXT_IO) $(LIBS)

tile2x11: tile2x11.o $(TEXT_IO)
	$(CC) $(LFLAGS) -o tile2x11 tile2x11.o $(TEXT_IO) $(LIBS)

tile2img.ttp: tile2img.o bitmfile.o $(TEXT_IO)
	$(CC) $(LFLAGS) -o tile2img.ttp tile2img.o bitmfile.o $(TEXT_IO) $(LIBS)

tile2bmp: tile2bmp.o $(TEXT_IO)
	$(CC) $(LFLAGS) -o tile2bmp tile2bmp.o $(TEXT_IO)

xpm2img.ttp: xpm2img.o bitmfile.o
	$(CC) $(LFLAGS) -o xpm2img.ttp xpm2img.o bitmfile.o $(LIBS)

tile2beos: tile2beos.o $(TEXT_IO)
	$(CC) $(LFLAGS) -o tile2beos tile2beos.o $(TEXT_IO) -lbe

#--compiling and linking in one step leaves extra debugging files (in their
#  own subdirectories!) on OSX; compile and link separately to suppress
#  that without mucking about with extra OS-specific CFLAGS and/or LFLAGS
#tilemap: ../win/share/tilemap.c $(HACK_H)
#	$(CC) $(CFLAGS) $(LFLAGS) -o tilemap ../win/share/tilemap.c $(LIBS)
tilemap: tilemap.o
	$(CC) $(LFLAGS) -o tilemap tilemap.o $(LIBS)
../src/tile.c: tilemap
	./tilemap

../include/tile.h: ../win/share/tile.h
	cp ../win/share/tile.h ../include/tile.h
tiletext.o: ../win/share/tiletext.c $(CONFIG_H) ../include/tile.h
	$(CC) $(CFLAGS) -c ../win/share/tiletext.c
tiletxt.c: ./Makefile
	echo '/* alternate compilation for tilemap.c to create tiletxt.o' > tiletxt.c
	echo '   that does not rely on "cc -c -o tiletxt.o tilemap.c"'	 >> tiletxt.c
	echo '   since many pre-POSIX compilers did not support that */' >> tiletxt.c
	echo '#define TILETEXT'			 >> tiletxt.c
	echo '#include "../win/share/tilemap.c"' >> tiletxt.c
	echo '/*tiletxt.c*/'			 >> tiletxt.c
tiletxt.o: tiletxt.c ../win/share/tilemap.c $(HACK_H)
	$(CC) $(CFLAGS) -c tiletxt.c
tilemap.o: ../win/share/tilemap.c $(HACK_H)
	$(CC) $(CFLAGS) -c ../win/share/tilemap.c

gifread.o: ../win/share/gifread.c $(CONFIG_H) ../include/tile.h
	$(CC) $(CFLAGS) -c ../win/share/gifread.c
ppmwrite.o: ../win/share/ppmwrite.c $(CONFIG_H) ../include/tile.h
	$(CC) $(CFLAGS) -c ../win/share/ppmwrite.c

tile2bmp.o: ../win/share/tile2bmp.c $(HACK_H) ../include/tile.h
	$(CC) $(CFLAGS) -c ../win/share/tile2bmp.c

tile2x11.o: ../win/X11/tile2x11.c $(HACK_H) ../include/tile.h \
						../include/tile2x11.h
	$(CC) $(CFLAGS) -c ../win/X11/tile2x11.c

tile2img.o: ../win/gem/tile2img.c $(HACK_H) ../include/tile.h \
						../include/bitmfile.h
	$(CC) $(CFLAGS) -c ../win/gem/tile2img.c
xpm2img.o: ../win/gem/xpm2img.c $(HACK_H) ../include/bitmfile.h
	$(CC) $(CFLAGS) -c ../win/gem/xpm2img.c
bitmfile.o: ../win/gem/bitmfile.c ../include/bitmfile.h
	$(CC) $(CFLAGS) -c ../win/gem/bitmfile.c

tile2beos.o: ../win/BeOS/tile2beos.cpp $(HACK_H) ../include/tile.h
	$(CXX) $(CFLAGS) -c ../win/BeOS/tile2beos.cpp

tileedit: tileedit.cpp $(TEXT_IO)
	$(QTDIR)/bin/moc -o tileedit.moc tileedit.h
	$(CC) -o tileedit -I../include -I$(QTDIR)/include -L$(QTDIR)/lib \
		tileedit.cpp $(TEXT_IO) -lqt

# using dependencies like
#	../src/foo::
#		@( cd ../src ; $(MAKE) foo )
# would always force foo to be up-to-date according to the src Makefile
# when it's needed here.  unfortunately, some makes believe this syntax
# means foo always changes, instead of foo should always be checked.
# therefore, approximate via config.h dependencies, and hope that anybody
# changing anything other than basic configuration also knows when not
# to improvise things not in the instructions, like 'make makedefs' here
# in util...

# make sure object files from src are available when needed
#
$(OBJDIR)/alloc.o: ../src/alloc.c $(CONFIG_H)
	$(CC) $(CFLAGS) -c ../src/alloc.c -o $@
$(OBJDIR)/drawing.o: ../src/drawing.c $(CONFIG_H)
	$(CC) $(CFLAGS) -c ../src/drawing.c -o $@
$(OBJDIR)/decl.o: ../src/decl.c $(CONFIG_H)
	$(CC) $(CFLAGS) -c ../src/decl.c -o $@
$(OBJDIR)/monst.o: ../src/monst.c $(CONFIG_H)
	$(CC) $(CFLAGS) -c ../src/monst.c -o $@
$(OBJDIR)/objects.o: ../src/objects.c $(CONFIG_H)
	$(CC) $(CFLAGS) -c ../src/objects.c -o $@
$(OBJDIR)/dlb.o: ../src/dlb.c $(HACK_H) ../include/dlb.h
	$(CC) $(CFLAGS) -c ../src/dlb.c -o $@

# make sure hack.h dependencies get transitive information
$(HACK_H): $(CONFIG_H)
	@( cd ../src ; $(MAKE) $(HACK_H) )
$(CONFIG_H): ../include/config.h
	@( cd ../src ; $(MAKE) $(CONFIG_H) )

# 'make dist' => put generated lex and yacc sources into place for distribution
SYSSHARE=../sys/share/
$(SYSSHARE)lev_lex.c: lev_lex.c
	cp lev_lex.c $@
$(SYSSHARE)lev_yacc.c: lev_yacc.c
	cp lev_yacc.c $@
$(SYSSHARE)lev_comp.h: ../include/lev_comp.h
	cp ../include/lev_comp.h $@
$(SYSSHARE)dgn_lex.c: dgn_lex.c
	cp dgn_lex.c $@
$(SYSSHARE)dgn_yacc.c: dgn_yacc.c
	cp dgn_yacc.c $@
$(SYSSHARE)dgn_comp.h: ../include/dgn_comp.h
	cp ../include/dgn_comp.h $@

dist:	$(SYSSHARE)lev_lex.c $(SYSSHARE)lev_yacc.c $(SYSSHARE)lev_comp.h \
	$(SYSSHARE)dgn_lex.c $(SYSSHARE)dgn_yacc.c $(SYSSHARE)dgn_comp.h
	@echo 'pre-generated lex and yacc sources are in place in sys/share'

tags: $(UTILSRCS)
	@ctags -tw $(UTILSRCS)

clean:
	-rm -f *.o

spotless: clean
	-rm -f lev_lex.c lev_yacc.c dgn_lex.c dgn_yacc.c
	-rm -f ../include/lev_comp.h ../include/dgn_comp.h
	-rm -f ../include/tile.h tiletxt.c
	-rm -f makedefs lev_comp dgn_comp recover dlb
	-rm -f gif2txt txt2ppm tile2x11 tile2img.ttp xpm2img.ttp \
		tilemap tileedit
### End Makefile.utl

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
