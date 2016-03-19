/* NetHack 3.6	pline.c	$NHDT-Date: 1456528597 2016/02/26 23:16:37 $  $NHDT-Branch: NetHack-3.6.0 $:$NHDT-Revision: 1.49 $ */
/* Copyright (c) Stichting Mathematisch Centrum, Amsterdam, 1985. */
/* NetHack may be freely redistributed.  See license for details. */

#define NEED_VARARGS /* Uses ... */ /* comment line for pre-compiled headers \
                                       */
#include "hack.h"

static boolean no_repeat = FALSE;
static char prevmsg[BUFSZ];

static char *You_buf(int);
#if defined(MSGHANDLER) && (defined(POSIX_TYPES) || defined(__GNUC__))
static void execplinehandler(const char *);
#endif

/*VARARGS1*/
/* Note that these declarations rely on knowledge of the internals
 * of the variable argument handling stuff in "tradstdc.h"
 */

static void vpline(const char *, va_list);

void pline
(const char *line, ...) {
    va_list the_args;
    va_start(the_args, line);
    vpline(line, the_args);
    va_end(the_args);
}

static void
vpline(const char *line, va_list the_args)
{       /* start of vpline() or of nested block in USE_OLDARG's pline() */
    char pbuf[3 * BUFSZ];
    int ln;
    xchar msgtyp;
    /* Do NOT use VA_START and VA_END in here... see above */

    if (!line || !*line)
        return;
#ifdef HANGUPHANDLING
    if (program_state.done_hup)
        return;
#endif
    if (program_state.wizkit_wishing)
        return;

    if (index(line, '%')) {
        Vsprintf(pbuf, line, the_args);
        line = pbuf;
    }
    if ((ln = (int) strlen(line)) > BUFSZ - 1) {
        if (line != pbuf)                          /* no '%' was present */
            (void) strncpy(pbuf, line, BUFSZ - 1); /* caveat: unterminated */
        /* truncate, preserving the final 3 characters:
           "___ extremely long text" -> "___ extremely l...ext"
           (this may be suboptimal if overflow is less than 3) */
        (void) strncpy(pbuf + BUFSZ - 1 - 6, "...", 3);
        /* avoid strncpy; buffers could overlap if excess is small */
        pbuf[BUFSZ - 1 - 3] = line[ln - 3];
        pbuf[BUFSZ - 1 - 2] = line[ln - 2];
        pbuf[BUFSZ - 1 - 1] = line[ln - 1];
        pbuf[BUFSZ - 1] = '\0';
        line = pbuf;
    }
    if (!iflags.window_inited) {
        raw_print(line);
        iflags.last_msg = PLNMSG_UNKNOWN;
        return;
    }

    msgtyp = msgtype_type(line, no_repeat);
    if (msgtyp == MSGTYP_NOSHOW
        || (msgtyp == MSGTYP_NOREP && !strcmp(line, prevmsg)))
        return;
    if (vision_full_recalc)
        vision_recalc(0);
    if (u.ux)
        flush_screen(1); /* %% */

    putstr(WIN_MESSAGE, 0, line);

#if defined(MSGHANDLER) && (defined(POSIX_TYPES) || defined(__GNUC__))
    execplinehandler(line);
#endif

    /* this gets cleared after every pline message */
    iflags.last_msg = PLNMSG_UNKNOWN;
    strncpy(prevmsg, line, BUFSZ), prevmsg[BUFSZ - 1] = '\0';
    if (msgtyp == MSGTYP_STOP)
        display_nhwindow(WIN_MESSAGE, TRUE); /* --more-- */

}

/*VARARGS1*/
void Norep(const char *line, ...)
{
    va_list the_args;
    va_start(the_args, line);
    no_repeat = TRUE;
    vpline(line, the_args);
    no_repeat = FALSE;
    va_end(the_args);
    return;
}

/* work buffer for You(), &c and verbalize() */
static char *you_buf = 0;
static int you_buf_siz = 0;

static char *
You_buf(int siz)
{
    if (siz > you_buf_siz) {
        if (you_buf)
            free((genericptr_t) you_buf);
        you_buf_siz = siz + 10;
        you_buf = (char *) alloc((unsigned) you_buf_siz);
    }
    return you_buf;
}

void
free_youbuf()
{
    if (you_buf)
        free((genericptr_t) you_buf), you_buf = (char *) 0;
    you_buf_siz = 0;
}

/* `prefix' must be a string literal, not a pointer */
#define YouPrefix(pointer, prefix, text) \
    Strcpy((pointer = You_buf((int) (strlen(text) + sizeof prefix))), prefix)

#define YouMessage(pointer, prefix, text) \
    strcat((YouPrefix(pointer, prefix, text), pointer), text)

/*VARARGS1*/
void You(const char *line, ...)
{
    va_list the_args;
    char *tmp;
    va_start(the_args, line);
    vpline(YouMessage(tmp, "You ", line), the_args);
    va_end(the_args);
}

/*VARARGS1*/
void Your(const char *line, ...)
{
    va_list the_args;
    char *tmp;
    va_start(the_args, line);
    vpline(YouMessage(tmp, "Your ", line), the_args);
    va_end(the_args);
}

/*VARARGS1*/
void You_feel(const char *line, ...)
{
    va_list the_args;
    char *tmp;
    va_start(the_args, line);
    if (Unaware)
        YouPrefix(tmp, "You dream that you feel ", line);
    else
        YouPrefix(tmp, "You feel ", line);
    vpline(strcat(tmp, line), the_args);
    va_end(the_args);
}

/*VARARGS1*/
void You_cant(const char *line, ...)
{
    va_list the_args;
    char *tmp;
    va_start(the_args, line);
    vpline(YouMessage(tmp, "You can't ", line), the_args);
    va_end(the_args);
}

/*VARARGS1*/
void pline_The(const char *line, ...)
{
    va_list the_args;
    char *tmp;
    va_start(the_args, line);
    vpline(YouMessage(tmp, "The ", line), the_args);
    va_end(the_args);
}

/*VARARGS1*/
void There(const char *line, ...)
{
    va_list the_args;
    char *tmp;
    va_start(the_args, line);
    vpline(YouMessage(tmp, "There ", line), the_args);
    va_end(the_args);
}

/*VARARGS1*/
void You_hear(const char *line, ...)
{
    va_list the_args;
    char *tmp;

    if (Deaf || !flags.acoustics)
        return;
    va_start(the_args, line);
    if (Underwater)
        YouPrefix(tmp, "You barely hear ", line);
    else if (Unaware)
        YouPrefix(tmp, "You dream that you hear ", line);
    else
        YouPrefix(tmp, "You hear ", line);
    vpline(strcat(tmp, line), the_args);
    va_end(the_args);
}

/*VARARGS1*/
void You_see(const char *line, ...)
{
    va_list the_args;
    char *tmp;

    va_start(the_args, line);
    if (Unaware)
        YouPrefix(tmp, "You dream that you see ", line);
    else if (Blind) /* caller should have caught this... */
        YouPrefix(tmp, "You sense ", line);
    else
        YouPrefix(tmp, "You see ", line);
    vpline(strcat(tmp, line), the_args);
    va_end(the_args);
}

/* Print a message inside double-quotes.
 * The caller is responsible for checking deafness.
 * Gods can speak directly to you in spite of deafness.
 */
/*VARARGS1*/
void verbalize(const char *line, ...)
{
    va_list the_args;
    char *tmp;

    va_start(the_args, line);
    tmp = You_buf((int) strlen(line) + sizeof "\"\"");
    Strcpy(tmp, "\"");
    Strcat(tmp, line);
    Strcat(tmp, "\"");
    vpline(tmp, the_args);
    va_end(the_args);
}

/*VARARGS1*/
/* Note that these declarations rely on knowledge of the internals
 * of the variable argument handling stuff in "tradstdc.h"
 */

static void vraw_printf(const char *, va_list);

void raw_printf(const char *line, ...)
{
    va_list the_args;
    va_start(the_args, line);
    vraw_printf(line, the_args);
    va_end(the_args);
}

static void
vraw_printf(const char *line, va_list the_args)
{
    char pbuf[3 * BUFSZ];
    int ln;
    /* Do NOT use VA_START and VA_END in here... see above */

    if (index(line, '%')) {
        Vsprintf(pbuf, line, the_args);
        line = pbuf;
    }
    if ((ln = (int) strlen(line)) > BUFSZ - 1) {
        if (line != pbuf)
            line = strncpy(pbuf, line, BUFSZ - 1);
        /* unlike pline, we don't futz around to keep last few chars */
        pbuf[BUFSZ - 1] = '\0'; /* terminate strncpy or truncate vsprintf */
    }
    raw_print(line);
}

/*VARARGS1*/
void impossible(const char *s, ...)
{
    va_list the_args;
    char pbuf[2 * BUFSZ];
    va_start(the_args, s);
    if (program_state.in_impossible)
        panic("impossible called impossible");

    program_state.in_impossible = 1;
    Vsprintf(pbuf, s, the_args);
    pbuf[BUFSZ - 1] = '\0'; /* sanity */
    paniclog("impossible", pbuf);
    pline("%s", pbuf);
    pline("Program in disorder - perhaps you'd better #quit.");
    program_state.in_impossible = 0;
    va_end(the_args);
}

const char *
align_str(aligntyp alignment)
{
    switch ((int) alignment) {
    case A_CHAOTIC:
        return "chaotic";
    case A_NEUTRAL:
        return "neutral";
    case A_LAWFUL:
        return "lawful";
    case A_NONE:
        return "unaligned";
    }
    return "unknown";
}

void
mstatusline(register struct monst *mtmp)
{
    aligntyp alignment = mon_aligntyp(mtmp);
    char info[BUFSZ], monnambuf[BUFSZ];

    info[0] = 0;
    if (mtmp->mtame) {
        Strcat(info, ", tame");
        if (wizard) {
            Sprintf(eos(info), " (%d", mtmp->mtame);
            if (!mtmp->isminion)
                Sprintf(eos(info), "; hungry %ld; apport %d",
                        EDOG(mtmp)->hungrytime, EDOG(mtmp)->apport);
            Strcat(info, ")");
        }
    } else if (mtmp->mpeaceful)
        Strcat(info, ", peaceful");

    if (mtmp->data == &mons[PM_LONG_WORM]) {
        int segndx, nsegs = count_wsegs(mtmp);

        /* the worm code internals don't consider the head of be one of
           the worm's segments, but we count it as such when presenting
           worm feedback to the player */
        if (!nsegs) {
            Strcat(info, ", single segment");
        } else {
            ++nsegs; /* include head in the segment count */
            segndx = wseg_at(mtmp, bhitpos.x, bhitpos.y);
            Sprintf(eos(info), ", %d%s of %d segments",
                    segndx, ordin(segndx), nsegs);
        }
    }
    if (mtmp->cham >= LOW_PM && mtmp->data != &mons[mtmp->cham])
        /* don't reveal the innate form (chameleon, vampire, &c),
           just expose the fact that this current form isn't it */
        Strcat(info, ", shapechanger");
    /* pets eating mimic corpses mimic while eating, so this comes first */
    if (mtmp->meating)
        Strcat(info, ", eating");
    /* a stethoscope exposes mimic before getting here so this
       won't be relevant for it, but wand of probing doesn't */
    if (mtmp->mundetected || mtmp->m_ap_type)
        mhidden_description(mtmp, TRUE, eos(info));
    if (mtmp->mcan)
        Strcat(info, ", cancelled");
    if (mtmp->mconf)
        Strcat(info, ", confused");
    if (mtmp->mblinded || !mtmp->mcansee)
        Strcat(info, ", blind");
    if (mtmp->mstun)
        Strcat(info, ", stunned");
    if (mtmp->msleeping)
        Strcat(info, ", asleep");
#if 0 /* unfortunately mfrozen covers temporary sleep and being busy \
         (donning armor, for instance) as well as paralysis */
	else if (mtmp->mfrozen)	  Strcat(info, ", paralyzed");
#else
    else if (mtmp->mfrozen || !mtmp->mcanmove)
        Strcat(info, ", can't move");
#endif
    /* [arbitrary reason why it isn't moving] */
    else if (mtmp->mstrategy & STRAT_WAITMASK)
        Strcat(info, ", meditating");
    if (mtmp->mflee)
        Strcat(info, ", scared");
    if (mtmp->mtrapped)
        Strcat(info, ", trapped");
    if (mtmp->mspeed)
        Strcat(info, mtmp->mspeed == MFAST ? ", fast" : mtmp->mspeed == MSLOW
                                                            ? ", slow"
                                                            : ", ???? speed");
    if (mtmp->minvis)
        Strcat(info, ", invisible");
    if (mtmp == u.ustuck)
        Strcat(info, sticks(youmonst.data)
                         ? ", held by you"
                         : !u.uswallow ? ", holding you"
                                       : attacktype_fordmg(u.ustuck->data,
                                                           AT_ENGL, AD_DGST)
                                             ? ", digesting you"
                                             : is_animal(u.ustuck->data)
                                                   ? ", swallowing you"
                                                   : ", engulfing you");
    if (mtmp == u.usteed)
        Strcat(info, ", carrying you");

    /* avoid "Status of the invisible newt ..., invisible" */
    /* and unlike a normal mon_nam, use "saddled" even if it has a name */
    Strcpy(monnambuf, x_monnam(mtmp, ARTICLE_THE, (char *) 0,
                               (SUPPRESS_IT | SUPPRESS_INVISIBLE), FALSE));

    pline("Status of %s (%s):  Level %d  HP %d(%d)  AC %d%s.", monnambuf,
          align_str(alignment), mtmp->m_lev, mtmp->mhp, mtmp->mhpmax,
          find_mac(mtmp), info);
}

void
ustatusline()
{
    char info[BUFSZ];

    info[0] = '\0';
    if (Sick) {
        Strcat(info, ", dying from");
        if (u.usick_type & SICK_VOMITABLE)
            Strcat(info, " food poisoning");
        if (u.usick_type & SICK_NONVOMITABLE) {
            if (u.usick_type & SICK_VOMITABLE)
                Strcat(info, " and");
            Strcat(info, " illness");
        }
    }
    if (Stoned)
        Strcat(info, ", solidifying");
    if (Slimed)
        Strcat(info, ", becoming slimy");
    if (Strangled)
        Strcat(info, ", being strangled");
    if (Vomiting)
        Strcat(info, ", nauseated"); /* !"nauseous" */
    if (Confusion)
        Strcat(info, ", confused");
    if (Blind) {
        Strcat(info, ", blind");
        if (u.ucreamed) {
            if ((long) u.ucreamed < Blinded || Blindfolded
                || !haseyes(youmonst.data))
                Strcat(info, ", cover");
            Strcat(info, "ed by sticky goop");
        } /* note: "goop" == "glop"; variation is intentional */
    }
    if (Stunned)
        Strcat(info, ", stunned");
    if (!u.usteed && Wounded_legs) {
        const char *what = body_part(LEG);
        if ((Wounded_legs & BOTH_SIDES) == BOTH_SIDES)
            what = makeplural(what);
        Sprintf(eos(info), ", injured %s", what);
    }
    if (Glib)
        Sprintf(eos(info), ", slippery %s", makeplural(body_part(HAND)));
    if (u.utrap)
        Strcat(info, ", trapped");
    if (Fast)
        Strcat(info, Very_fast ? ", very fast" : ", fast");
    if (u.uundetected)
        Strcat(info, ", concealed");
    if (Invis)
        Strcat(info, ", invisible");
    if (u.ustuck) {
        if (sticks(youmonst.data))
            Strcat(info, ", holding ");
        else
            Strcat(info, ", held by ");
        Strcat(info, mon_nam(u.ustuck));
    }

    pline("Status of %s (%s%s):  Level %d  HP %d(%d)  AC %d%s.", plname,
          (u.ualign.record >= 20)
              ? "piously "
              : (u.ualign.record > 13)
                    ? "devoutly "
                    : (u.ualign.record > 8)
                          ? "fervently "
                          : (u.ualign.record > 3)
                                ? "stridently "
                                : (u.ualign.record == 3)
                                      ? ""
                                      : (u.ualign.record >= 1)
                                            ? "haltingly "
                                            : (u.ualign.record == 0)
                                                  ? "nominally "
                                                  : "insufficiently ",
          align_str(u.ualign.type),
          Upolyd ? mons[u.umonnum].mlevel : u.ulevel, Upolyd ? u.mh : u.uhp,
          Upolyd ? u.mhmax : u.uhpmax, u.uac, info);
}

void
self_invis_message()
{
    pline("%s %s.",
          Hallucination ? "Far out, man!  You" : "Gee!  All of a sudden, you",
          See_invisible ? "can see right through yourself"
                        : "can't see yourself");
}

void
pudding_merge_message(struct obj *otmp, struct obj *otmp2)
{
    boolean visible =
        cansee(otmp->ox, otmp->oy) || cansee(otmp2->ox, otmp2->oy);
    boolean onfloor = otmp->where == OBJ_FLOOR || otmp2->where == OBJ_FLOOR;
    boolean inpack = carried(otmp) || carried(otmp2);

    /* the player will know something happened inside his own inventory */
    if ((!Blind && visible) || inpack) {
        if (Hallucination) {
            if (onfloor) {
                You_see("parts of the floor melting!");
            } else if (inpack) {
                Your("pack reaches out and grabs something!");
            }
            /* even though we can see where they should be,
             * they'll be out of our view (minvent or container)
             * so don't actually show anything */
        } else if (onfloor || inpack) {
            pline("The %s coalesce%s.", makeplural(obj_typename(otmp->otyp)),
                  inpack ? " inside your pack" : "");
        }
    } else {
        You_hear("a faint sloshing sound.");
    }
}

#if defined(MSGHANDLER) && (defined(POSIX_TYPES) || defined(__GNUC__))
static boolean use_pline_handler = TRUE;
static void
execplinehandler(line)
const char *line;
{
    int f;
    const char *args[3];
    char *env;

    if (!use_pline_handler)
        return;

    if (!(env = nh_getenv("NETHACK_MSGHANDLER"))) {
        use_pline_handler = FALSE;
        return;
    }

    f = fork();
    if (f == 0) { /* child */
        args[0] = env;
        args[1] = line;
        args[2] = NULL;
        (void) setgid(getgid());
        (void) setuid(getuid());
        (void) execv(args[0], (char *const *) args);
        perror((char *) 0);
        (void) fprintf(stderr, "Exec to message handler %s failed.\n",
                       env);
        terminate(EXIT_FAILURE);
    } else if (f == -1) {
        perror((char *) 0);
        use_pline_handler = FALSE;
        pline("Fork to message handler failed.");
    }
}
#endif /* defined(POSIX_TYPES) || defined(__GNUC__) */

/*pline.c*/
