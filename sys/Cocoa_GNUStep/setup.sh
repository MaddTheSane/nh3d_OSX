#!/bin/sh
# Copy files to their correct locations.
#
# If arguments are given, try symbolic link first.  This is not the default
# so that most people will have the distribution versions stay around so
# subsequent patches can be applied.  People who pay enough attention to
# know there's a non-default behavior are assumed to pay enough attention
# to keep distribution versions if they modify things.

# Were we started from the top level?  Cope.
if [ -f sys/Cocoa_GNUStep/Makefile.top ]; then cd sys/Cocoa_GNUStep; fi

if [ $# -gt 0 ] ; then
#	First, try to make a symbolic link.
#
	ln -s Makefile.top Makefile >/dev/null 2>&1
	if [ $? -eq 0 ] ; then

		echo "Lucky you!  Symbolic links."
		rm -f Makefile

		umask 0
		ln -s sys/Cocoa_GNUStep/Makefile.top ../../Makefile
		ln -s ../sys/Cocoa_GNUStep/Makefile.dat ../../dat/Makefile
		ln -s ../sys/Cocoa_GNUStep/Makefile.doc ../../doc/Makefile
		ln -s ../sys/Cocoa_GNUStep/Makefile.src ../../src/Makefile
		ln -s ../sys/Cocoa_GNUStep/Makefile.utl ../../util/Makefile
		exit 0
	fi
fi

#
#	Otherwise...

echo "Copying Makefiles."

cp Makefile.top ../../Makefile
cp Makefile.dat ../../dat/Makefile
cp Makefile.doc ../../doc/Makefile
cp Makefile.src ../../src/Makefile
cp Makefile.utl ../../util/Makefile
