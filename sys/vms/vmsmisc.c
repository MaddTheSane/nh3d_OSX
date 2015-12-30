/* NetHack 3.6	vmsmisc.c	$NHDT-Date: 1432512789 2015/05/25 00:13:09 $  $NHDT-Branch: master $:$NHDT-Revision: 1.10 $ */
/* NetHack may be freely redistributed.  See license for details. */

#include "config.h"
#undef exit
#include <ssdef.h>
#include <stsdef.h>

int debuggable = 0; /* 1 if we can debug or show a call trace */

void FDECL(vms_exit, (int));
void NDECL(vms_abort);

/* first arg should be unsigned long but <lib$routines.h> has unsigned int */
extern void VDECL(lib$signal, (unsigned, ...));

/* terminate, converting Unix-style exit code into VMS status code */
void
vms_exit(status)
int status;
{
    /* convert non-zero to failure, zero to success */
    exit(status ? (SS$_ABORT | STS$M_INHIB_MSG) : SS$_NORMAL);
    /* NOT REACHED */
}

/* put the user into the debugger; used for abort() when in wizard mode */
void
vms_abort()
{
    if (debuggable)
        lib$signal(SS$_DEBUG);

    /* we'll get here if the debugger isn't available, or if the user
       uses GO to resume execution instead of EXIT to quit */
    vms_exit(2); /* don't return to caller (2==arbitrary non-zero) */
    /* NOT REACHED */
}

/*
 * Caveat: the VERYOLD_VMS configuration hasn't been tested in many years.
 */
#ifdef VERYOLD_VMS
#include "oldcrtl.c"
#endif

/*vmsmisc.c*/
