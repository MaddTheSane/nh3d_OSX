/* NetHack 3.6	mail.c	$NHDT-Date: 1436754892 2015/07/13 02:34:52 $  $NHDT-Branch: master $:$NHDT-Revision: 1.20 $ */
/* Copyright (c) Stichting Mathematisch Centrum, Amsterdam, 1985. */
/* NetHack may be freely redistributed.  See license for details. */

#import <Cocoa/Cocoa.h>
#import "Mail-AppleScript.h"
#include "hack.h"

#ifdef MAIL
#include "mail.h"

extern struct mail_info *NH3DCheckMail();

struct mail_info *NH3DCheckMail()
{
	return NULL;
}


#endif
