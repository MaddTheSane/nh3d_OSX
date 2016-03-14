/* NetHack 3.6	tradstdc.h	$NHDT-Date: 1448210011 2015/11/22 16:33:31 $  $NHDT-Branch: master $:$NHDT-Revision: 1.27 $ */
/* Copyright (c) Stichting Mathematisch Centrum, Amsterdam, 1985. */
/* NetHack may be freely redistributed.  See license for details. */

#ifndef TRADSTDC_H
#define TRADSTDC_H

#if defined(DUMB) && !defined(NOVOID)
#define NOVOID
#endif

#ifdef NOVOID
#define void int
#endif

/*
 * Borland C provides enough ANSI C compatibility in its Borland C++
 * mode to warrant this.  But it does not set __STDC__ unless it compiles
 * in its ANSI keywords only mode, which prevents use of <dos.h> and
 * far pointer use.
 */
#if (defined(__STDC__) || defined(__TURBOC__)) && !defined(NOTSTDC)
#define NHSTDC
#endif

#include <stdarg.h>
#define USE_VARARGS
#define USE_STDARG

/*
 * Used for definitions of functions which take no arguments to force
 * an explicit match with the NDECL prototype.  Needed in some cases
 * (MS Visual C 2005) for functions called through pointers.
 */
#define VOID_ARGS void

/* generic pointer, always a macro; genericptr_t is usually a typedef */
#define genericptr void *

#if (defined(ULTRIX_PROTO) && !defined(__GNUC__)) || defined(OS2_CSET2)
/* Cover for Ultrix on a DECstation with 2.0 compiler, which coredumps on
 *   typedef void * genericptr_t;
 *   extern void a(void(*)(int, genericptr_t));
 * Using the #define is OK for other compiler versions too.
 */
/* And IBM CSet/2.  The redeclaration of free hoses the compile. */
#define genericptr_t genericptr
#endif

/*
 * Suppress `const' if necessary and not handled elsewhere.
 * Don't use `#if defined(xxx) && !defined(const)'
 * because some compilers choke on `defined(const)'.
 * This has been observed with Lattice, MPW, and High C.
 */
#if (defined(ULTRIX_PROTO) && !defined(NHSTDC)) || defined(apollo)
/* the system header files don't use `const' properly */
#ifndef const
#define const
#endif
#endif

#ifndef genericptr_t
typedef genericptr genericptr_t; /* (void *) or (char *) */
#endif

#if defined(MICRO) || defined(WIN32)
/* We actually want to know which systems have an ANSI run-time library
 * to know which support the %p format for printing pointers.
 * Due to the presence of things like gcc, NHSTDC is not a good test.
 * So we assume microcomputers have all converted to ANSI and bigger
 * computers which may have older libraries give reasonable results with
 * casting pointers to unsigned long int (fmt_ptr() in alloc.c).
 */
#define HAS_PTR_FMT
#endif

/*
 * According to ANSI, prototypes for old-style declarations must widen the
 * arguments to int.  However, the MSDOS compilers accept shorter arguments
 * (char, short, etc.) in prototypes and do typechecking with them.  Therefore
 * this mess to allow the better typechecking while also allowing some
 * prototypes for the ANSI compilers so people quit trying to fix the
 * prototypes to match the standard and thus lose the typechecking.
 */
#if defined(MSDOS) && !defined(__GO32__)
#define UNWIDENED_PROTOTYPES
#endif
#if defined(AMIGA) && !defined(AZTEC_50)
#define UNWIDENED_PROTOTYPES
#endif
#if defined(macintosh) && (defined(__SC__) || defined(__MRC__))
#define WIDENED_PROTOTYPES
#endif
#if defined(__MWERKS__) && defined(__BEOS__)
#define UNWIDENED_PROTOTYPES
#endif
#if defined(WIN32)
#define UNWIDENED_PROTOTYPES
#endif

#if defined(ULTRIX_PROTO) && defined(ULTRIX_CC20)
#define UNWIDENED_PROTOTYPES
#endif
#if defined(apollo)
#define UNWIDENED_PROTOTYPES
#endif

#ifndef UNWIDENED_PROTOTYPES
#if defined(NHSTDC) || defined(ULTRIX_PROTO) || defined(THINK_C)
#ifndef WIDENED_PROTOTYPES
#define WIDENED_PROTOTYPES
#endif
#endif
#endif

/* These are used for arguments within FDECL/VDECL prototype declarations.
 */
#define ALIGNTYP_P aligntyp

/* OBJ_P and MONST_P should _only_ be used for declaring function pointers.
 */
#if defined(ULTRIX_PROTO) && !defined(__STDC__)
/* The ultrix 2.0 and 2.1 compilers (on Ultrix 4.0 and 4.2 respectively) can't
 * handle "struct obj *" constructs in prototypes.  Their bugs are different,
 * but both seem to work if we put "void*" in the prototype instead.  This
 * gives us minimal prototype checking but avoids the compiler bugs.
 */
#define OBJ_P void *
#define MONST_P void *
#else
#define OBJ_P struct obj *
#define MONST_P struct monst *
#endif

#if 0
/* The problem below is still the case through 4.0.5F, but the suggested
 * compiler flags in the Makefiles suppress the nasty messages, so we don't
 * need to be quite so drastic.
 */
#if defined(__sgi) && !defined(__GNUC__)
/*
 * As of IRIX 4.0.1, /bin/cc claims to be an ANSI compiler, but it thinks
 * it's impossible for a prototype to match an old-style definition with
 * unwidened argument types.  Thus, we have to turn off all NetHack
 * prototypes, and avoid declaring several system functions, since the system
 * include files have prototypes and the compiler also complains that
 * prototyped and unprototyped declarations don't match.
 */
#undef NDECL
#undef FDECL
#undef VDECL
#define f(void) f()
#define FDECL(f, p) f()
#define VDECL(f, p) f()
#undef VOID_ARGS
#define VOID_ARGS /*empty*/
#endif
#endif

/* MetaWare High-C defaults to unsigned chars */
/* AIX 3.2 needs this also */
#if defined(__HC__) || defined(_AIX32)
#undef signed
#endif

/*
 * Allow gcc2 to check parameters of printf-like calls with -Wformat;
 * append this to a prototype declaration (see pline() in extern.h).
 */
#ifdef __GNUC__
#if __GNUC__ >= 2
#define PRINTF_F(f, v) __attribute__((format(printf, f, v)))
#endif
#if __GNUC__ >= 3
#define UNUSED __attribute__((unused))
#define NORETURN __attribute__((noreturn))
#endif
#endif

#ifndef PRINTF_F
#define PRINTF_F(f, v)
#endif
#ifndef UNUSED
#define UNUSED
#endif
#ifndef NORETURN
#define NORETURN
#endif

#endif /* TRADSTDC_H */
