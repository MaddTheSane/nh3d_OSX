/* original parser id follows */
/* yysccsid[] = "@(#)yaccpar	1.9 (Berkeley) 02/21/93" */
/* nhsccsid[] = \"@(#)yaccpar   1.9.0-nh2 (NetHack) 11/22/2018\"; */
/* (use YYMAJOR/YYMINOR for ifdefs dependent on parser version) */

#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9
#define YYSUBMINOR "0-nh2"
#define YYPATCH 20160324

#define YYEMPTY        (-1)
#define yyclearin      (yychar = YYEMPTY)
#define yyerrok        (yyerrflag = 0)
#define YYRECOVERING() (yyerrflag != 0)
#define YYENOMEM       (-2)
#define YYEOF          0
#define YYPREFIX "yy"

#define YYPURE 0

#line 2 "util/lev_comp.y"
/* NetHack 3.6  lev_comp.y	$NHDT-Date: 1543371691 2018/11/28 02:21:31 $  $NHDT-Branch: NetHack-3.6.2-beta01 $:$NHDT-Revision: 1.22 $ */
/*      Copyright (c) 1989 by Jean-Christophe Collet */
/* NetHack may be freely redistributed.  See license for details. */

/*
 * This file contains the Level Compiler code
 * It may handle special mazes & special room-levels
 */

/* In case we're using bison in AIX.  This definition must be
 * placed before any other C-language construct in the file
 * excluding comments and preprocessor directives (thanks IBM
 * for this wonderful feature...).
 *
 * Note: some cpps barf on this 'undefined control' (#pragma).
 * Addition of the leading space seems to prevent barfage for now,
 * and AIX will still see the directive.
 */
#ifdef _AIX
 #pragma alloca         /* keep leading space! */
#endif

#define SPEC_LEV    /* for USE_OLDARGS (sp_lev.h) */
#include "hack.h"
#include "sp_lev.h"

#define ERR             (-1)
/* many types of things are put in chars for transference to NetHack.
 * since some systems will use signed chars, limit everybody to the
 * same number for portability.
 */
#define MAX_OF_TYPE     128

#define MAX_NESTED_IFS   20
#define MAX_SWITCH_CASES 20

#define New(type) \
        (type *) memset((genericptr_t) alloc(sizeof (type)), 0, sizeof (type))
#define NewTab(type, size)      (type **) alloc(sizeof (type *) * size)
#define Free(ptr)               free((genericptr_t) ptr)

extern void lc_error(const char *, ...);
extern void lc_warning(const char *, ...);
extern void yyerror(const char *);
extern void yywarning(const char *);
extern int yylex(void);
int yyparse(void);

extern int get_floor_type(char);
extern int get_room_type(char *);
extern int get_trap_type(char *);
extern int get_monster_id(char *,char);
extern int get_object_id(char *,char);
extern boolean check_monster_char(char);
extern boolean check_object_char(char);
extern char what_map_char(char);
extern void scan_map(char *, sp_lev *);
extern void add_opcode(sp_lev *, int, genericptr_t);
extern genericptr_t get_last_opcode_data1(sp_lev *, int);
extern genericptr_t get_last_opcode_data2(sp_lev *, int,int);
extern boolean check_subrooms(sp_lev *);
extern boolean write_level_file(char *,sp_lev *);
extern struct opvar *set_opvar_int(struct opvar *, long);
extern void add_opvars(sp_lev *, const char *, ...);
extern void start_level_def(sp_lev * *, char *);

extern struct lc_funcdefs *funcdef_new(long,char *);
extern void funcdef_free_all(struct lc_funcdefs *);
extern struct lc_funcdefs *funcdef_defined(struct lc_funcdefs *,char *, int);
extern char *funcdef_paramtypes(struct lc_funcdefs *);
extern char *decode_parm_str(char *);

extern struct lc_vardefs *vardef_new(long,char *);
extern void vardef_free_all(struct lc_vardefs *);
extern struct lc_vardefs *vardef_defined(struct lc_vardefs *,char *, int);

extern void break_stmt_start(void);
extern void break_stmt_end(sp_lev *);
extern void break_stmt_new(sp_lev *, long);

extern void splev_add_from(sp_lev *, sp_lev *);

extern void check_vardef_type(struct lc_vardefs *, char *, long);
extern void vardef_used(struct lc_vardefs *, char *);
extern struct lc_vardefs *add_vardef_type(struct lc_vardefs *, char *, long);

extern int reverse_jmp_opcode(int);

struct coord {
    long x;
    long y;
};

struct forloopdef {
    char *varname;
    long jmp_point;
};
static struct forloopdef forloop_list[MAX_NESTED_IFS];
static short n_forloops = 0;


sp_lev *splev = NULL;

static struct opvar *if_list[MAX_NESTED_IFS];

static short n_if_list = 0;

unsigned int max_x_map, max_y_map;
int obj_containment = 0;

int in_container_obj = 0;

/* integer value is possibly an inconstant value (eg. dice notation
   or a variable) */
int is_inconstant_number = 0;

int in_switch_statement = 0;
static struct opvar *switch_check_jump = NULL;
static struct opvar *switch_default_case = NULL;
static struct opvar *switch_case_list[MAX_SWITCH_CASES];
static long switch_case_value[MAX_SWITCH_CASES];
int n_switch_case_list = 0;

int allow_break_statements = 0;
struct lc_breakdef *break_list = NULL;

extern struct lc_vardefs *vardefs; /* variable definitions */


struct lc_vardefs *function_tmp_var_defs = NULL;
extern struct lc_funcdefs *function_definitions;
struct lc_funcdefs *curr_function = NULL;
struct lc_funcdefs_parm * curr_function_param = NULL;
int in_function_definition = 0;
sp_lev *function_splev_backup = NULL;

extern int fatal_error;
extern int got_errors;
extern int line_number;
extern const char *fname;

extern char curr_token[512];

#line 150 "util/lev_comp.y"
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union
{
    long    i;
    char    *map;
    struct {
        long room;
        long wall;
        long door;
    } corpos;
    struct {
        long area;
        long x1;
        long y1;
        long x2;
        long y2;
    } lregn;
    struct {
        long x;
        long y;
    } crd;
    struct {
        long ter;
        long lit;
    } terr;
    struct {
        long height;
        long width;
    } sze;
    struct {
        long die;
        long num;
    } dice;
    struct {
        long cfunc;
        char *varstr;
    } meth;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
#line 215 ""

/* compatibility with bison */
#ifdef YYPARSE_PARAM
/* compatibility with FreeBSD */
# ifdef YYPARSE_PARAM_TYPE
#  define YYPARSE_DECL() yyparse(YYPARSE_PARAM_TYPE YYPARSE_PARAM)
# else
#  define YYPARSE_DECL() yyparse(void *YYPARSE_PARAM)
# endif
#else
# define YYPARSE_DECL() yyparse(void)
#endif

/* Parameters sent to lex. */
#ifdef YYLEX_PARAM
# define YYLEX_DECL() yylex(void *YYLEX_PARAM)
# define YYLEX yylex(YYLEX_PARAM)
#else
# define YYLEX_DECL() yylex(void)
# define YYLEX yylex()
#endif

/* Parameters sent to yyerror. */
#ifndef YYERROR_DECL
#define YYERROR_DECL() yyerror(const char *s)
#endif
#ifndef YYERROR_CALL
#define YYERROR_CALL(msg) yyerror(msg)
#endif

extern int YYPARSE_DECL();
#define YYNHXFLAG 1
#define YYSTACKSIZE 500
#define YYMAXDEPTH 500

#define CHAR 257
#define INTEGER 258
#define BOOLEAN 259
#define PERCENT 260
#define SPERCENT 261
#define MINUS_INTEGER 262
#define PLUS_INTEGER 263
#define MAZE_GRID_ID 264
#define SOLID_FILL_ID 265
#define MINES_ID 266
#define ROGUELEV_ID 267
#define MESSAGE_ID 268
#define MAZE_ID 269
#define LEVEL_ID 270
#define LEV_INIT_ID 271
#define GEOMETRY_ID 272
#define NOMAP_ID 273
#define OBJECT_ID 274
#define COBJECT_ID 275
#define MONSTER_ID 276
#define TRAP_ID 277
#define DOOR_ID 278
#define DRAWBRIDGE_ID 279
#define object_ID 280
#define monster_ID 281
#define terrain_ID 282
#define MAZEWALK_ID 283
#define WALLIFY_ID 284
#define REGION_ID 285
#define FILLING 286
#define IRREGULAR 287
#define JOINED 288
#define ALTAR_ID 289
#define LADDER_ID 290
#define STAIR_ID 291
#define NON_DIGGABLE_ID 292
#define NON_PASSWALL_ID 293
#define ROOM_ID 294
#define PORTAL_ID 295
#define TELEPRT_ID 296
#define BRANCH_ID 297
#define LEV 298
#define MINERALIZE_ID 299
#define CORRIDOR_ID 300
#define GOLD_ID 301
#define ENGRAVING_ID 302
#define FOUNTAIN_ID 303
#define POOL_ID 304
#define SINK_ID 305
#define NONE 306
#define RAND_CORRIDOR_ID 307
#define DOOR_STATE 308
#define LIGHT_STATE 309
#define CURSE_TYPE 310
#define ENGRAVING_TYPE 311
#define DIRECTION 312
#define RANDOM_TYPE 313
#define RANDOM_TYPE_BRACKET 314
#define A_REGISTER 315
#define ALIGNMENT 316
#define LEFT_OR_RIGHT 317
#define CENTER 318
#define TOP_OR_BOT 319
#define ALTAR_TYPE 320
#define UP_OR_DOWN 321
#define SUBROOM_ID 322
#define NAME_ID 323
#define FLAGS_ID 324
#define FLAG_TYPE 325
#define MON_ATTITUDE 326
#define MON_ALERTNESS 327
#define MON_APPEARANCE 328
#define ROOMDOOR_ID 329
#define IF_ID 330
#define ELSE_ID 331
#define TERRAIN_ID 332
#define HORIZ_OR_VERT 333
#define REPLACE_TERRAIN_ID 334
#define EXIT_ID 335
#define SHUFFLE_ID 336
#define QUANTITY_ID 337
#define BURIED_ID 338
#define LOOP_ID 339
#define FOR_ID 340
#define TO_ID 341
#define SWITCH_ID 342
#define CASE_ID 343
#define BREAK_ID 344
#define DEFAULT_ID 345
#define ERODED_ID 346
#define TRAPPED_STATE 347
#define RECHARGED_ID 348
#define INVIS_ID 349
#define GREASED_ID 350
#define FEMALE_ID 351
#define CANCELLED_ID 352
#define REVIVED_ID 353
#define AVENGE_ID 354
#define FLEEING_ID 355
#define BLINDED_ID 356
#define PARALYZED_ID 357
#define STUNNED_ID 358
#define CONFUSED_ID 359
#define SEENTRAPS_ID 360
#define ALL_ID 361
#define MONTYPE_ID 362
#define GRAVE_ID 363
#define ERODEPROOF_ID 364
#define FUNCTION_ID 365
#define MSG_OUTPUT_TYPE 366
#define COMPARE_TYPE 367
#define UNKNOWN_TYPE 368
#define rect_ID 369
#define fillrect_ID 370
#define line_ID 371
#define randline_ID 372
#define grow_ID 373
#define selection_ID 374
#define flood_ID 375
#define rndcoord_ID 376
#define circle_ID 377
#define ellipse_ID 378
#define filter_ID 379
#define complement_ID 380
#define gradient_ID 381
#define GRADIENT_TYPE 382
#define LIMITED 383
#define HUMIDITY_TYPE 384
#define STRING 385
#define MAP_ID 386
#define NQSTRING 387
#define VARSTRING 388
#define CFUNC 389
#define CFUNC_INT 390
#define CFUNC_STR 391
#define CFUNC_COORD 392
#define CFUNC_REGION 393
#define VARSTRING_INT 394
#define VARSTRING_INT_ARRAY 395
#define VARSTRING_STRING 396
#define VARSTRING_STRING_ARRAY 397
#define VARSTRING_VAR 398
#define VARSTRING_VAR_ARRAY 399
#define VARSTRING_COORD 400
#define VARSTRING_COORD_ARRAY 401
#define VARSTRING_REGION 402
#define VARSTRING_REGION_ARRAY 403
#define VARSTRING_MAPCHAR 404
#define VARSTRING_MAPCHAR_ARRAY 405
#define VARSTRING_MONST 406
#define VARSTRING_MONST_ARRAY 407
#define VARSTRING_OBJ 408
#define VARSTRING_OBJ_ARRAY 409
#define VARSTRING_SEL 410
#define VARSTRING_SEL_ARRAY 411
#define METHOD_INT 412
#define METHOD_INT_ARRAY 413
#define METHOD_STRING 414
#define METHOD_STRING_ARRAY 415
#define METHOD_VAR 416
#define METHOD_VAR_ARRAY 417
#define METHOD_COORD 418
#define METHOD_COORD_ARRAY 419
#define METHOD_REGION 420
#define METHOD_REGION_ARRAY 421
#define METHOD_MAPCHAR 422
#define METHOD_MAPCHAR_ARRAY 423
#define METHOD_MONST 424
#define METHOD_MONST_ARRAY 425
#define METHOD_OBJ 426
#define METHOD_OBJ_ARRAY 427
#define METHOD_SEL 428
#define METHOD_SEL_ARRAY 429
#define DICE 430
#define YYERRCODE 256
typedef short YYINT;
 YYINT yylhs[] = {                           -1,
    0,    0,   73,   73,   74,   57,   57,   56,   56,   76,
   76,   76,   76,   55,   55,   54,   54,   46,   46,   14,
   14,   75,   75,   26,   26,   22,   22,   23,   78,   78,
   78,   78,   78,   78,   78,   78,   78,   78,   78,   78,
   78,   78,   78,   78,   78,   78,   78,   78,   78,   78,
   78,   78,   78,   78,   78,   78,   78,   78,   78,   78,
   78,   78,   78,   78,   78,   78,   78,   78,   78,   78,
   78,   78,   59,   59,   59,   59,   59,   59,   59,   59,
   59,   58,   58,   58,   58,   58,   58,   58,   58,   58,
   60,   60,   60,   61,   61,   85,   84,   84,   84,   84,
   84,   84,   84,   84,   84,   84,   84,   84,   84,   84,
   84,   38,   38,   44,   44,   43,   43,   42,   42,   41,
   41,   39,   39,   40,   40,  129,  130,  100,  101,   98,
   45,   45,   31,   31,   31,  131,  133,   93,  134,  134,
  136,  135,  137,  135,   99,  138,  138,  139,  140,   94,
  141,   95,  142,   97,  144,   96,  143,  145,  143,   79,
  110,  110,  110,   83,   83,   65,  146,  147,  113,  148,
  112,   10,   10,   68,   68,   69,   69,   70,   70,   71,
   71,   87,   87,   15,   15,   13,   13,   16,   16,   11,
   11,  103,  103,  103,    1,    1,    2,    2,  105,  150,
  105,  149,   20,   20,   21,   21,   21,   21,   21,   21,
   21,   21,   21,   21,   21,   21,   21,   21,   21,   21,
   35,   35,   35,  106,  152,  106,  151,   18,   18,   19,
   19,   19,   19,   19,   19,   19,   19,   19,   19,   19,
   19,   19,   19,   19,  120,   88,  104,  104,  121,  121,
  102,  117,  118,  109,  119,   82,   17,   17,   91,  114,
  108,   72,   72,  116,  115,   86,  107,  154,  111,   24,
   24,   80,   81,   81,   81,   92,   89,   90,   90,    3,
    3,    4,    4,   29,   29,   28,   28,   27,   27,   27,
    5,    5,    6,    6,    7,    7,    7,   12,   12,   12,
    8,    8,    9,  155,  155,  155,  132,   77,   77,   77,
   77,   32,   32,   32,   30,   30,  127,  127,  127,   33,
  124,  124,  124,   34,   34,  125,  125,  125,   36,   36,
   36,   36,  126,  126,  126,   37,   37,   37,   37,  123,
  123,  122,  122,  122,  122,  122,  122,  122,  122,  122,
  122,  122,   50,   50,  157,  158,  158,  128,  128,   64,
   64,   63,   63,   62,   62,   49,   49,   49,   49,   49,
   49,   49,   49,   49,   49,   49,   49,   49,   49,   49,
   49,   49,   49,   49,   48,   48,  156,   47,   47,   47,
  153,  153,  153,  153,   51,   51,   52,   52,   53,   53,
   25,   25,   67,   67,   66,
};
 YYINT yylen[] = {                            2,
    0,    1,    1,    2,    3,    3,    5,    1,    1,    5,
    5,    3,   16,    0,    2,    0,    2,    0,    2,    1,
    1,    0,    3,    3,    1,    0,    2,    3,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    3,    3,    5,    3,    5,
    5,    5,    3,    3,    5,    5,    5,    7,    7,    7,
    5,    1,    3,    1,    3,    1,    3,    1,    3,    1,
    3,    1,    3,    1,    3,    0,    0,    8,    4,    1,
    0,    1,    1,    5,    3,    0,    0,    9,    0,    2,
    0,    5,    0,    4,    1,    2,    1,    6,    0,    3,
    0,    6,    0,    4,    0,    4,    1,    0,    4,    3,
    1,    3,    3,    5,    5,    7,    4,    0,   10,    0,
   12,    0,    2,    5,    1,    5,    1,    5,    1,    5,
    1,    9,    5,    1,    1,    1,    1,    1,    3,    1,
    1,    1,    7,    5,    1,    1,    1,    1,    3,    0,
    5,    4,    0,    3,    1,    1,    1,    1,    2,    1,
    1,    1,    1,    1,    3,    3,    3,    1,    1,    3,
    1,    1,    3,    3,    0,    5,    2,    0,    3,    1,
    3,    1,    3,    3,    1,    1,    3,    1,    1,    1,
    3,    1,    1,    1,    5,    7,    5,    8,    1,    3,
    5,    5,    7,    7,    6,    5,    0,    2,    3,    3,
    3,    1,    5,    9,    5,    3,    3,    0,   10,    0,
    1,    7,    5,    5,    3,    5,    7,    9,    1,    1,
    1,    1,    1,    0,    2,    1,    3,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    3,
    1,    1,    4,    1,    1,    4,    1,    1,    4,    1,
    4,    5,    1,    3,    1,    3,    1,    1,    4,    9,
    1,    1,    4,    1,    5,    1,    1,    4,    1,    1,
    5,    1,    1,    1,    4,    1,    1,    5,    1,    1,
    3,    1,    1,    3,    1,    4,    3,    3,    3,    3,
    3,    3,    1,    1,    3,    1,    3,    0,    1,    1,
    1,    1,    3,    0,    1,    1,    2,    2,    4,    6,
    4,    6,    6,    6,    6,    2,    6,    8,    8,   10,
   14,    2,    1,    3,    1,    3,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,   10,    9,
};
 YYINT yydefred[] = {                         0,
    0,    0,    0,    0,    2,    0,    0,    0,    0,    0,
    4,    0,    6,    0,  133,    0,    0,    0,  192,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  130,    0,    0,    0,  136,  145,    0,    0,    0,    0,
   93,   82,   73,   83,   74,   84,   75,   85,   76,   86,
   77,   87,   78,   88,   79,   89,   80,   90,   81,    5,
    0,   92,   91,    0,   30,    0,   29,   31,   32,   33,
   34,   35,   36,   37,   38,   39,   40,   41,   42,   43,
   44,   45,   46,   47,   48,   49,   50,   51,   52,   53,
   54,   55,   56,   57,   58,   59,   60,   61,   62,   63,
   64,   65,   66,   67,   68,   69,   70,   71,   72,  149,
    0,    0,   23,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  155,    0,    0,    0,    0,   94,
   95,    0,    0,    0,    0,  342,    0,  345,    0,  387,
    0,  343,    0,  153,    0,   27,    0,    9,    8,    7,
    0,  304,  305,    0,    0,  340,    0,    0,    0,   12,
  313,    0,  195,  196,    0,    0,  310,    0,    0,  308,
    0,  337,  339,    0,  336,  334,    0,  333,  228,  224,
  225,  330,  332,    0,  329,  327,    0,  326,    0,    0,
  281,  280,    0,  291,  292,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  383,  250,    0,  366,    0,  318,    0,  317,    0,    0,
    0,    0,    0,  403,    0,    0,  266,  267,  283,  282,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,  259,  261,  260,  390,  388,  389,  163,  162,
    0,  184,  185,    0,    0,    0,    0,   96,    0,    0,
    0,    0,  126,    0,    0,    0,    0,  135,    0,    0,
    0,    0,    0,    0,    0,  362,    0,    0,    0,  396,
  398,  395,  397,  399,  400,    0,    0,    0,    0,    0,
    0,  103,    0,    0,  104,    0,  150,   24,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  367,  368,    0,    0,    0,  376,    0,
    0,    0,  382,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  132,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  156,    0,    0,  151,    0,    0,    0,    0,  344,  352,
    0,    0,    0,    0,  349,  350,  351,  129,    0,  154,
    0,    0,  120,  118,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  341,   11,  262,    0,   10,
    0,    0,  314,    0,    0,    0,  198,  197,    0,  173,
  194,    0,    0,    0,  226,    0,    0,  203,  201,  245,
  183,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  324,    0,    0,  322,    0,  321,    0,    0,    0,  384,
  386,    0,    0,  293,  294,    0,  297,    0,  295,    0,
  296,  251,    0,    0,    0,  252,    0,  175,    0,    0,
    0,    0,    0,  256,    0,    0,  165,  164,  276,  401,
  402,    0,  177,    0,    0,    0,    0,    0,  265,    0,
    0,  147,    0,    0,  137,  274,    0,    0,    0,  356,
    0,  346,  134,  363,   98,    0,    0,  105,    0,  111,
    0,  106,    0,  107,    0,  102,    0,  101,    0,  100,
   28,  306,    0,    0,  316,  309,    0,  311,    0,    0,
  335,  393,  391,  392,  239,  236,  230,    0,    0,  235,
    0,  240,    0,  242,  243,    0,  238,  229,  244,  232,
  394,    0,  328,    0,    0,    0,  369,    0,    0,    0,
  371,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  319,    0,    0,    0,    0,    0,    0,  167,    0,    0,
    0,    0,    0,  255,    0,    0,    0,    0,    0,    0,
    0,    0,  152,  146,    0,    0,    0,  127,    0,    0,
    0,    0,  121,  119,  112,    0,  114,    0,  116,    0,
    0,    0,  312,  193,  338,    0,    0,    0,    0,    0,
  331,    0,  246,    0,    0,  189,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  302,  301,
  272,    0,    0,  253,    0,  179,    0,    0,  254,  258,
    0,    0,    0,    0,  181,    0,    0,  187,    0,  186,
  159,    0,    0,  353,  354,  355,    0,  357,    0,  110,
    0,  109,    0,  108,    0,    0,    0,  234,  237,  241,
  231,    0,  298,  206,  207,    0,  211,  210,  212,  213,
  214,    0,    0,    0,  218,  219,    0,  299,  208,  204,
    0,    0,  248,    0,  372,    0,  377,    0,  373,    0,
  323,  374,  375,    0,    0,    0,  268,  303,    0,    0,
    0,    0,    0,    0,  190,  191,    0,    0,    0,  168,
    0,    0,    0,    0,    0,    0,  128,  113,  115,  117,
  263,    0,    0,    0,    0,    0,    0,    0,   19,    0,
    0,  325,    0,    0,  288,  289,  290,    0,  285,    0,
    0,    0,  174,    0,    0,  278,  166,  176,    0,    0,
  182,  264,    0,  143,  138,  140,    0,  300,  215,  216,
  217,  222,    0,  220,  378,    0,  379,    0,    0,    0,
  271,  269,    0,    0,    0,  170,    0,  169,  141,    0,
    0,    0,    0,    0,    0,  320,  287,    0,  405,  178,
    0,  180,    0,  144,    0,  223,  380,   15,    0,  404,
  171,  142,    0,    0,    0,    0,   20,   21,    0,    0,
    0,   13,   17,  381,
};
 YYINT yydgoto[] = {                          3,
  209,  449,  233,  271,  236,  486,  490,  671,  491,  351,
  757,  729,  689,  859,  294,  467,  614,  354,  578,  584,
  730,   80,  337,  822,  512,  133,  788,  789,  747,  345,
   81,  210,  258,  476,  814,  228,  218,  636,  425,  426,
  427,  428,  640,  638,  387,  733,  290,  375,  253,  696,
  329,  330,  331,  861,  835,  190,    4,   82,   83,   84,
  172,  314,  315,  316,  280,  264,  265,  500,  515,  678,
  687,  440,    5,    6,   10,   85,  254,   86,   87,   88,
   89,   90,   91,   92,   93,   94,   95,   96,   97,   98,
   99,  100,  101,  102,  103,  104,  105,  106,  107,  108,
  109,  110,  111,  112,  113,  114,  115,  116,  117,  118,
  119,  120,  121,  122,  123,  124,  125,  126,  127,  128,
  129,  277,  318,  478,  229,  219,  259,  529,  408,  697,
  173,  278,  626,  765,  766,  843,  830,  524,  130,  187,
  521,  319,  401,  295,  517,  272,  800,  841,  230,  359,
  220,  355,  580,  790,  196,  182,  530,  531,
};
 YYINT yysindex[] = {                        68,
   17,   31,    0, -217,    0,   68, -257, -226,  112, 5680,
    0,  136,    0, -136,    0,  170,  185,  201,    0,  225,
  229,  238,  244,  248,  251,  255,  266,  272,  275,  283,
  304,  309,  346,  366,  378,  380,  382,  383,  396,  397,
  398,  400,  401,  404,  405,  413,  415,  -46,  417,  420,
    0,  426,  108,  489,    0,    0,  428,  101,  -35,  449,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  432,    0,    0,  430,    0, 5680,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
 -190,  450,    0, -234,   62,  -13,   41,   41,   40, -252,
 -121,  109,  109, 1644,  -34,  109,  109,   92,  -34,  -34,
 -249,  -20,  -20,  -20,  -35,  458,  -35,  109, 1644, 1644,
 1644, -160, -249, -174,    0, 1644,  -34,  288,  -35,    0,
    0,  439,  414,  109,  467,    0,  -22,    0,  421,    0,
   -9,    0,  -14,    0,  163,    0,  385,    0,    0,    0,
 -136,    0,    0,  423,  465,    0,  471,  473,  475,    0,
    0,  137,    0,    0,  490,  271,    0,  441,  496,    0,
  503,    0,    0,  276,    0,    0,  452,    0,    0,    0,
    0,    0,    0,  292,    0,    0,  470,    0,  512,    0,
    0,    0,  518,    0,    0,  523,  524,  526,  -34,  -34,
  109,  109,  540,  109,  542,  544,  545, 1644,  548, 5537,
    0,    0,  533,    0,  331,    0,  500,    0,  555,  558,
  559,  564,  347,    0,  571,  582,    0,    0,    0,    0,
  367,  584,  379,  592,  594,  595,  141,  596,  402,  597,
  588,  611,    0,    0,    0,    0,    0,    0,    0,    0,
  617,    0,    0,  628,  385,  638,  640,    0,  593,  -35,
  -35,  644,    0,  649,  159,  -35,  -35,    0,  -35,  -35,
  -35,  -35,  -35,  651,  650,    0,  141,  465, 5680,    0,
    0,    0,    0,    0,    0,  642,   -1,    4,  643,  647,
  653,    0,  141,  465,    0, 5680,    0,    0,  -35, -234,
  445,   14,  455,  654,  614, 1644,  678,  -35,   38,  476,
  338,  682,  -35,  688,  385,  690,  -35,  109,  385,  109,
 1644,  424,  431,    0,    0,  694,  696, 1298,    0,  109,
  109, 5435,    0,  360,  704, 1644,  702,  -35, -165,  -83,
  429,  491,  703,  -20,  433,    0,  707,  -24,  708,  -20,
  -20,  -20,  -35,  709,   10,  109,  -91,  -19, -121,    0,
    0,    9,    9,    0,   45,  655, -254,  560,    0,    0,
   75,  148,   79,   79,    0,    0,    0,    0,  -14,    0,
 1644,  711,    0,    0,   16,   25,   27,   29,  141,  465,
   22,  -10,  -28,  631,  427,    0,    0,    0,  501,    0,
  715,  137,    0,  719,  505,  459,    0,    0,  503,    0,
    0,  381,  499,    2,    0,  403,  508,    0,    0,    0,
    0,  721,  723,  109,  109,  662,  743,  748,  746,  749,
    0,  750, 5448,    0,  701,    0,  751,  752,  753,    0,
    0,  554,  536,    0,    0,  754,    0,  726,    0,  774,
    0,    0,  775,  579,  785,    0, -165,    0,  581,  796,
  583,  798,  800,    0,  802,  535,    0,    0,    0,    0,
    0,  804,    0,  591,  806,  807,  521,  598,    0,  810,
  385,    0,  811,  -35,    0,    0,  465,  801,  815,    0,
  814,    0,    0,    0,    0,  604,  -35,    0, -234,    0,
  -21,    0,  824,    0,   57,    0,   98,    0,   23,    0,
    0,    0,  825,  621,    0,    0,  827,    0,  493,  839,
    0,    0,    0,    0,    0,    0,    0,  823,  826,    0,
  828,    0,  830,    0,    0,  832,    0,    0,    0,    0,
    0,  841,    0,  848, -121,  641,    0,  857,  590, 1644,
    0,  -35,  -35, 1644,  859,  -35, 1644, 1644,  864,  861,
    0, -249,  648, -148,  652,  135,  586,    0,  867,   -5,
  868,  528,  587,    0,  -35,  870, -234,  871,    6,   72,
  385,    9,    0,    0,  141,  793,    1,    0,  560,  166,
  141,  465,    0,    0,    0,   32,    0,   33,    0,   35,
 -165,  873,    0,    0,    0, -234,  -35,  -35,  -35,   40,
    0, 5526,    0,  876,  -35,    0,  880,  174,  686,  881,
 -165,  569,  882,  883,  -35,  685,  900,  852,    0,    0,
    0,  902,  691,    0,  693,    0,  110,  908,    0,    0,
  928, -184,  465,  716,    0,  717,  900,    0,  929,    0,
    0,  932,   90,    0,    0,    0,  385,    0,   57,    0,
   98,    0,   23,    0,  936,  722,  465,    0,    0,    0,
    0,   56,    0,    0,    0, -234,    0,    0,    0,    0,
    0,  920,  921,  924,    0,    0,  925,    0,    0,    0,
  465,  727,    0,  141,    0,  699,    0,  -35,    0,  945,
    0,    0,    0,  481,  943,   59,    0,    0,  744,  957,
  965,  963,    6,  -35,    0,    0,  967,  977,  982,    0,
 -184,  767,  -50,  971,  905,   90,    0,    0,    0,    0,
    0,  987,  724,  465,  -35,  -35,  -35, -261,    0,  991,
  576,    0,  -35,  777,    0,    0,    0,  989,    0,  385,
  992,  780,    0,   38,  900,    0,    0,    0,  781,  385,
    0,    0,  983,    0,    0,    0,  784,    0,    0,    0,
    0,    0,  916,    0,    0,  758,    0,   93, 1004,   59,
    0,    0,  788, 1006, 1007,    0, 1010,    0,    0, 5680,
 1009, -261, 1016,  675, 1020,    0,    0, 1025,    0,    0,
  385,    0, 5680,    0, -165,    0,    0,    0, 1023,    0,
    0,    0, 1024,  109, -149, 1026,    0,    0,  876,  109,
 1028,    0,    0,    0,
};
 YYINT yyrindex[] = {                      1071,
    0,    0,    0, 5225,    0, 1072,    0,    0,    0,   53,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0, 2985,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0, 3174,    0,    0,
    0,    0,    0,    0, 3331,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  182,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0, 5382,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, 1032,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0, 3520,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  689,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0, 1947,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, 1098,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  136,    0,    0,    0,    0,    0,  720,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0, 3677,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0, 1033,    0,  241,  247,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, 3866, 4023,    0,  951,    0,    0,    0,    0,
    0,    0,    0,  984,    0,    0,    0,    0,    0,    0,
    0,    0,    0, 2136,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0, 2293,
    0,    0,    0,    0,    0,    0,    0, 1037,    0,    0,
    0,    0,  374,  531,    0,    0,    0,    0,    0,    0,
    0,  553,    0,    0,    0,    0,    0,    0,   42,   49,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  689,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, 4212,    0,    0, 1035,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, 4369,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0, 4558,    0,    0,    0,
 1039,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0, 2482,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  958,    0,    0,    0,    0,    0,
   50,   52,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0, 4715,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0, 2639,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, 4904,    0,    0,    0,  959,    0,    0,    0,
    0,    0,  961,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0, 1255,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
 1444,    0,    0,  909,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  961,    0,    0,    0,    0,
    0,    0,    0, 1601,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0, 2828,    0, 5061,
    0,    0,    0,    0,  959,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, 1790,    0,    0,    0,    0,  128,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  -69,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,  -69,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0, 1043,    0,    0, 4715,    0,
    0,    0,    0,    0,
};
 YYINT yygindex[] = {                         0,
  410,  294,    0,  487, -329, -480,    0,    0,  438,  645,
  330,    0,    0,    0,    0, -474,    0,    0,    0,    0,
    0,  -86, -287,    0,    0,  901,    0,  273, -629,  657,
 1047, -296, -297, -509,  264, -504, -494,    0,    0,    0,
    0,    0,    0,    0,    0,  242, -384, -137,  849,    0,
    0,    0,    0,    0,    0,    0,    0, 1046,  934, -371,
    0,    0,    0,  684,  710,    0,  -48,    0,    0,    0,
  351,    0, 1100,    0,    0,    0, -133,  790,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  -58, -130, -355, -375,  679,  -84,    0,    0,    0,
    0, -167,    0,  345,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  949,    0,    0,    0,    0,
  975,    0,    0,    0,  792,  680,  504,    0,
};
#define YYTABLESIZE 6091
 YYINT yytable[] = {                        186,
  181,  299,  211,  195,  177,  255,  252,  400,  237,  238,
  507,  518,  260,  261,  266,  499,  608,  177,  206,  273,
  514,  283,  284,  285,  282,  177,  206,  313,  296,  224,
  424,  423,  311,  309,  677,  310,  528,  312,  177,  639,
  302,  206,  637,  327,   59,  686,  519,  520,  518,  279,
  635,  332,   26,  439,  334,   26,  548,  760,  526,  537,
  231,  214,  518,  269,  267,  268,  188,  455,  539,  516,
  541,  459,  543,  755,    7,  699,  701,  550,  703,  224,
  214,  313,  297,  308,  292,  122,  311,  309,    8,  310,
  523,  312,  124,  123,  549,  125,  214,  286,  281,  812,
  335,  287,  288,  274,  275,  276,    9,  366,  367,  857,
  369,  313,  547,  773,  656,  313,  311,  309,  305,  310,
  311,  312,  189,  813,  317,  312,  333,   12,  756,  313,
  192,  263,  232,  406,  311,  270,  834,  224,  293,  312,
  538,  193,  194,  484,  545,  690,  603,  485,  206,  540,
  192,  542,  289,  544,  364,  365,  700,  702,   13,  704,
  705,  193,  194,  858,  669,  826,  122,  532,   14,   14,
  348,  670,  348,  124,  123,  643,  125,  313,  673,  131,
  740,   26,  311,  309,  313,  310,  234,  312,  132,  311,
  309,  235,  310,  770,  312,  313,  769,  430,  169,  410,
  311,  309,  327,  310,  768,  312,  643,  286,  444,  666,
  313,  287,  288,   15,  737,  311,  309,  736,  310,  510,
  312,  511,  176,  461,  458,  505,  460,  134,  471,  487,
  468,  488,  489,  623,  477,  176,  469,  470,  481,  304,
  533,  405,  135,  176,  633,  634,  222,  411,  412,  434,
  413,  414,  415,  416,  417,  653,  422,  528,  136,  562,
  304,  176,  509,  563,  564,  471,  692,  286,  305,  429,
  438,  287,  288,   26,  711,   26,  527,  262,  212,  471,
  435,  360,  137,  535,  360,  328,  138,  361,  498,  446,
  361,  201,  202,  513,  453,  139,  222,  212,  457,  201,
  202,  140,  223,  203,  204,  141,   26,  676,  142,  565,
  566,  567,  143,  212,  201,  202,  201,  202,  685,  483,
  579,   26,   26,  144,  568,  197,  198,  199,  200,  145,
  587,  588,  146,  691,  213,  495,    1,    2,  569,  570,
  147,  502,  503,  504,  785,  786,  787,  571,  572,  573,
  574,  575,  223,  213,  222,  447,  448,  307,  178,  179,
  317,  148,  205,  576,  853,  577,  149,  256,  257,  213,
  192,  178,  179,  347,  225,  474,  475,  205,  803,  178,
  179,  193,  194,  466,  688,  522,  207,  208,  192,  262,
  694,  695,  178,  179,  180,  226,  227,  178,  179,  193,
  194,  207,  208,  150,  201,  202,  215,  180,  632,  767,
  223,  347,  474,  475,  347,  180,  347,  347,  347,  347,
  176,  201,  202,  151,  225,  215,  203,  204,  180,  216,
  217,  180,  763,  180,  764,  152,  320,  153,  321,  154,
  155,  215,  322,  323,  324,  226,  227,  681,  216,  217,
   26,   26,  657,  156,  157,  158,  660,  159,  160,  663,
  664,  161,  162,  313,  347,  625,  347,  205,  311,  309,
  163,  310,  164,  312,  166,  201,  202,  167,  631,  708,
  709,  710,  225,  168,  205,  174,  683,  175,  183,  184,
  185,  207,  208,  191,  325,  313,  347,  279,  347,  300,
  311,  309,  821,  310,  301,  312,  303,  336,  207,  208,
  340,  306,  828,  339,  341,  707,  342,  313,  343,  552,
  344,  731,  311,  309,   26,  783,   26,  312,  347,  346,
  348,  348,  352,  658,  659,  313,  326,  662,  205,  349,
  311,  309,  353,  310,  313,  312,  350,  192,  356,  311,
  309,  558,  310,  851,  312,  358,  178,  179,  193,  194,
  357,  360,  207,  208,  256,  257,  361,  362,  348,  363,
  376,  348,  313,  348,  348,  348,  348,  311,  309,  368,
  310,  370,  312,  371,  372,  774,  796,  374,  377,  342,
  378,  561,  180,  342,  342,  342,  734,  342,  379,  342,
  583,  380,  381,  382,  383,  313,  744,  809,  810,  811,
  311,  309,  313,  310,  384,  312,  817,  311,  309,  816,
  310,  348,  312,  348,  313,  385,  386,  388,  601,  311,
  309,  396,  310,  347,  312,  390,  389,  391,  392,  393,
  395,  347,  347,  347,  347,  347,  347,  347,  347,  347,
  347,  347,  347,  348,  397,  348,  347,  347,  347,  394,
  398,  741,  347,  347,  347,  347,  347,  347,  347,  347,
  347,  399,  347,  347,  347,  347,  347,  347,  347,  781,
  347,  402,   63,  403,   65,  404,   67,  407,   69,  409,
   71,  418,   73,  419,   75,  347,   77,  442,   79,  421,
  431,  437,  347,  347,  432,  347,  443,  347,  347,  347,
  433,  441,  347,  347,  347,  347,  347,  347,  347,  307,
  856,  445,  313,  451,  818,  452,  863,  311,  309,  738,
  310,  454,  312,  456,  450,  462,  347,  464,  347,  465,
  347,  479,  463,  844,  480,  482,  494,  525,  493,  492,
  497,  501,  506,  496,  536,  551,  852,  553,  554,  556,
  347,  347,  557,  307,  585,  560,  586,  347,  347,  347,
  347,  347,  347,  347,  347,  347,  347,  347,  347,  347,
  347,  347,  347,  347,  347,  589,  590,  582,  591,  592,
  348,  596,  593,  594,  597,  598,  599,  602,  348,  348,
  348,  348,  348,  348,  348,  348,  348,  348,  348,  348,
  307,  600,  307,  348,  348,  348,  603,  604,  605,  348,
  348,  348,  348,  348,  348,  348,  348,  348,  607,  348,
  348,  348,  348,  348,  348,  348,  606,  348,  609,  610,
  611,  612,  307,  613,  307,  615,  616,  617,  618,  619,
  620,  621,  348,  622,  595,  628,  624,  629,  627,  348,
  348,  630,  348,  255,  348,  348,  348,  643,  641,  348,
  348,  348,  348,  348,  348,  348,  170,  642,  644,  645,
  646,  651,   62,  647,   64,  648,   66,  649,   68,  650,
   70,  652,   72,  348,   74,  348,   76,  348,   78,  654,
  655,  466,  661,  665,  666,  668,  674,  680,  370,  672,
  675,  673,  679,  682,  684,  693,  706,  348,  348,  732,
  735,  739,  742,  743,  348,  348,  348,  348,  348,  348,
  348,  348,  348,  348,  348,  348,  348,  348,  348,  348,
  348,  348,  745,  746,  748,  749,  370,   61,  750,  370,
  751,  753,  370,   62,   63,   64,   65,   66,   67,   68,
   69,   70,   71,   72,   73,   74,   75,   76,   77,   78,
   79,  754,  761,  758,  759,  762,  771,  775,  776,  307,
  772,  777,  778,  779,  780,  782,  784,  307,  307,  307,
  307,  307,  307,  307,  307,  307,  307,  307,  307,  370,
  792,  791,  307,  307,  307,  793,  794,  797,  307,  307,
  307,  307,  307,  307,  307,  307,  307,  798,  307,  307,
  307,  307,  307,  307,  307,  799,  307,  802,  804,  805,
  807,  815,  820,  370,  819,  823,  808,  824,  827,  832,
  829,  307,  831,  833,  836,  838,  839,  840,  307,  307,
  842,  307,  845,  307,  307,  307,  847,  848,  307,  307,
  849,  307,  307,  307,  307,  850,  854,  855,  864,  860,
    1,    3,  364,  365,  172,   26,  315,  358,  188,  359,
  148,  284,  307,   16,  307,  139,  752,  825,  667,  728,
  801,  338,  837,  559,  165,  846,  373,  385,  555,  171,
  862,  298,  534,  795,  508,   11,  307,  307,  420,  546,
  806,  291,  221,  307,  307,  307,  307,  307,  307,  307,
  307,  307,  307,  307,  307,  307,  307,  307,  307,  307,
  307,  436,  698,  581,    0,    0,    0,    0,  385,    0,
    0,  385,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  370,    0,
    0,    0,    0,    0,    0,    0,  370,  370,  370,  370,
  370,  370,  370,  370,  370,  370,  370,  370,  385,    0,
    0,  370,  370,  370,    0,    0,    0,  370,  370,  370,
  370,  370,  370,  370,  370,  370,    0,  370,  370,  370,
  370,  370,  370,  370,    0,  370,    0,    0,    0,    0,
    0,    0,  385,    0,    0,    0,    0,    0,    0,    0,
  370,    0,    0,    0,    0,    0,    0,  370,  370,    0,
  370,    0,  370,  370,  370,    0,    0,  370,  370,    0,
  370,  370,  370,  370,  233,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  370,    0,  370,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  370,  370,    0,  233,    0,
    0,    0,  370,  370,  370,  370,  370,  370,  370,  370,
  370,  370,  370,  370,  370,  370,  370,  370,  370,  370,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  250,    0,    0,
    0,    0,    0,    0,    0,  233,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  385,    0,    0,
    0,    0,    0,    0,    0,  385,  385,  385,  385,  385,
  385,  385,  385,  385,  385,  385,  385,  233,    0,  233,
  385,  385,  385,    0,    0,    0,  385,  385,  385,  385,
  385,  385,  385,  385,  385,    0,  385,  385,  385,  385,
  385,  385,  385,    0,  385,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  385,
    0,    0,    0,    0,    0,    0,  385,  385,    0,  385,
    0,  385,  385,  385,    0,    0,  385,  385,    0,  385,
  385,  385,  385,  205,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  385,    0,  385,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  385,  385,    0,  205,    0,    0,
    0,  385,  385,  385,  385,  385,  385,  385,  385,  385,
  385,  385,  385,  385,  385,  385,  385,  385,  385,    0,
    0,    0,    0,    0,  233,    0,    0,    0,    0,    0,
    0,    0,  233,  233,  233,  233,  233,  233,  233,  233,
  233,  233,  233,  233,  205,    0,    0,  233,  233,  233,
    0,    0,    0,  233,  233,  233,  233,  233,  233,  233,
  233,  233,    0,  233,  233,  233,  233,  233,  233,  233,
    0,  233,    0,    0,    0,    0,  205,    0,  205,    0,
    0,    0,    0,    0,    0,    0,  233,    0,    0,    0,
    0,    0,    0,  233,  233,    0,  233,    0,  233,  233,
  233,    0,    0,  233,  233,    0,  233,  233,  233,  233,
  209,    0,    0,    0,    0,    0,    0,    0,    0,  466,
  201,  202,    0,    0,    0,    0,    0,  233,    0,  233,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  233,  233,    0,  209,    0,    0,    0,  233,  233,
  233,  233,  233,  233,  233,  233,  233,  233,  233,  233,
  233,  233,  233,  233,  233,  233,  239,  240,  241,  242,
  243,    0,  244,  205,  245,  246,  247,  248,  249,    0,
    0,    0,    0,  250,    0,    0,    0,    0,    0,    0,
    0,  209,    0,    0,    0,    0,    0,  207,  208,    0,
    0,    0,    0,  205,    0,    0,    0,  251,    0,    0,
    0,  205,  205,  205,  205,  205,  205,  205,  205,  205,
  205,  205,  205,  209,    0,  209,  205,  205,  205,    0,
    0,    0,  205,  205,  205,  205,  205,  205,  205,  205,
  205,    0,  205,  205,  205,  205,  205,  205,  205,    0,
  205,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  205,    0,    0,    0,    0,
    0,    0,  205,  205,    0,  205,    0,  205,  205,  205,
    0,    0,  205,  205,    0,  205,  205,  205,  205,  221,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  205,    0,  205,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  205,  205,    0,  221,    0,    0,    0,  205,  205,  205,
  205,  205,  205,  205,  205,  205,  205,  205,  205,  205,
  205,  205,  205,  205,  205,    0,    0,    0,    0,    0,
  209,    0,    0,    0,    0,    0,    0,    0,  209,  209,
  209,  209,  209,  209,  209,  209,  209,  209,  209,  209,
  221,    0,    0,  209,  209,  209,    0,    0,    0,  209,
  209,  209,  209,  209,  209,  209,  209,  209,    0,  209,
  209,  209,  209,  209,  209,  209,    0,  209,    0,    0,
    0,    0,  221,    0,  221,    0,    0,    0,    0,    0,
    0,    0,  209,    0,    0,    0,    0,    0,    0,  209,
  209,    0,  209,    0,  209,  209,  209,    0,    0,  209,
  209,    0,  209,  209,  209,  209,  199,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  201,  202,    0,    0,
    0,    0,    0,  209,    0,  209,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  209,  209,    0,
    0,    0,    0,    0,  209,  209,  209,  209,  209,  209,
  209,  209,  209,  209,  209,  209,  209,  209,  209,  209,
  209,  209,  239,  240,  241,  242,  243,    0,  244,  205,
  245,  246,  247,  248,  249,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  199,    0,    0,
    0,    0,    0,  207,  208,    0,    0,    0,    0,  221,
    0,    0,    0,  251,    0,    0,    0,  221,  221,  221,
  221,  221,  221,  221,  221,  221,  221,  221,  221,  200,
    0,  199,  221,  221,  221,    0,    0,    0,  221,  221,
  221,  221,  221,  221,  221,  221,  221,    0,  221,  221,
  221,  221,  221,  221,  221,    0,  221,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  221,    0,    0,    0,    0,    0,    0,  221,  221,
    0,  221,    0,  221,  221,  221,    0,    0,  221,  221,
    0,  221,  221,  221,  221,  227,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,  221,    0,  221,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  221,  221,    0,    0,
    0,    0,    0,  221,  221,  221,  221,  221,  221,  221,
  221,  221,  221,  221,  221,  221,  221,  221,  221,  221,
  221,    0,    0,    0,    0,    0,  199,    0,    0,    0,
    0,    0,    0,    0,  199,  199,  199,  199,  199,  199,
  199,  199,  199,  199,  199,  199,  227,    0,    0,  199,
  199,  199,    0,    0,    0,  199,  199,  199,  199,  199,
  199,  199,  199,  199,    0,  199,  199,  199,  199,  199,
  199,  199,    0,  199,    0,    0,    0,    0,  227,    0,
  227,    0,    0,    0,    0,    0,    0,    0,  199,    0,
    0,    0,    0,    0,    0,  199,  199,    0,  199,    0,
  199,  199,  199,    0,    0,  199,  199,    0,  199,  199,
  199,  199,  157,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  199,
    0,  199,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  199,  199,    0,    0,    0,    0,    0,
  199,  199,  199,  199,  199,  199,  199,  199,  199,  199,
  199,  199,  199,  199,  199,  199,  199,  199,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  157,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  227,    0,    0,    0,    0,
    0,    0,    0,  227,  227,  227,  227,  227,  227,  227,
  227,  227,  227,  227,  227,    0,    0,  157,  227,  227,
  227,    0,    0,    0,  227,  227,  227,  227,  227,  227,
  227,  227,  227,    0,  227,  227,  227,  227,  227,  227,
  227,    0,  227,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  227,    0,    0,
    0,    0,    0,    0,  227,  227,    0,  227,    0,  227,
  227,  227,    0,    0,  227,  227,    0,  227,  227,  227,
  227,  202,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  227,    0,
  227,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,  227,  227,    0,    0,    0,    0,    0,  227,
  227,  227,  227,  227,  227,  227,  227,  227,  227,  227,
  227,  227,  227,  227,  227,  227,  227,    0,    0,    0,
    0,    0,  157,    0,    0,    0,    0,    0,    0,    0,
  157,  157,  157,  157,  157,  157,  157,  157,  157,  157,
  157,  157,  202,    0,    0,  157,  157,  157,    0,    0,
    0,  157,  157,  157,  157,  157,  157,  157,  157,  157,
    0,  157,  157,  157,  157,  157,  157,  157,    0,  157,
    0,    0,    0,    0,  202,    0,  202,    0,    0,    0,
    0,    0,    0,    0,  157,    0,    0,    0,    0,    0,
    0,  157,  157,  158,  157,    0,  157,  157,  157,    0,
    0,  157,  157,    0,  157,  157,  157,  157,  284,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  157,    0,  157,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  157,
  157,    0,    0,    0,    0,    0,  157,  157,  157,  157,
  157,  157,  157,  157,  157,  157,  157,  157,  157,  157,
  157,  157,  157,  157,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  284,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  202,    0,    0,    0,    0,    0,    0,    0,  202,
  202,  202,  202,  202,  202,  202,  202,  202,  202,  202,
  202,  284,    0,  284,  202,  202,  202,    0,    0,    0,
  202,  202,  202,  202,  202,  202,  202,  202,  202,    0,
  202,  202,  202,  202,  202,  202,  202,    0,  202,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  202,    0,    0,    0,    0,    0,    0,
  202,  202,    0,  202,    0,  202,  202,  202,    0,    0,
  202,  202,    0,  202,  202,  202,  202,  286,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  202,    0,  202,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  202,  202,
    0,    0,    0,    0,    0,  202,  202,  202,  202,  202,
  202,  202,  202,  202,  202,  202,  202,  202,  202,  202,
  202,  202,  202,    0,    0,    0,    0,    0,  284,    0,
    0,    0,    0,    0,    0,    0,  284,  284,  284,  284,
  284,  284,  284,  284,  284,  284,  284,  284,  286,    0,
    0,  284,  284,  284,    0,    0,    0,  284,  284,  284,
  284,  284,  284,  284,  284,  284,    0,  284,  284,  284,
  284,  284,  284,  284,    0,  284,    0,    0,    0,    0,
  286,    0,  286,    0,    0,    0,    0,    0,    0,    0,
  284,    0,    0,    0,    0,    0,    0,  284,  284,    0,
  284,    0,  284,  284,  284,    0,    0,  284,  284,    0,
  284,  284,  284,  284,  249,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  284,    0,  284,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  284,  284,    0,    0,    0,
    0,    0,  284,  284,  284,  284,  284,  284,  284,  284,
  284,  284,  284,  284,  284,  284,  284,  284,  284,  284,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  249,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  286,    0,    0,
    0,    0,    0,    0,    0,  286,  286,  286,  286,  286,
  286,  286,  286,  286,  286,  286,  286,    0,    0,  249,
  286,  286,  286,    0,    0,    0,  286,  286,  286,  286,
  286,  286,  286,  286,  286,    0,  286,  286,  286,  286,
  286,  286,  286,    0,  286,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  286,
    0,    0,    0,    0,    0,    0,  286,  286,    0,  286,
    0,  286,  286,  286,    0,    0,  286,  286,    0,  286,
  286,  286,  286,  279,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  286,    0,  286,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  286,  286,    0,    0,    0,    0,
    0,  286,  286,  286,  286,  286,  286,  286,  286,  286,
  286,  286,  286,  286,  286,  286,  286,  286,  286,    0,
    0,    0,    0,    0,  249,    0,    0,    0,    0,    0,
    0,    0,  249,  249,  249,  249,  249,  249,  249,  249,
  249,  249,  249,  249,  279,    0,    0,  249,  249,  249,
    0,    0,    0,  249,  249,  249,  249,  249,  249,  249,
  249,  249,    0,  249,  249,  249,  249,  249,  249,  249,
    0,  249,    0,    0,    0,    0,    0,    0,  279,    0,
    0,    0,    0,    0,    0,    0,  249,    0,    0,    0,
    0,    0,    0,  249,  249,    0,  249,    0,  249,  249,
  249,    0,    0,  249,  249,    0,  249,  249,  249,  249,
  161,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  249,    0,  249,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  249,  249,    0,    0,    0,    0,    0,  249,  249,
  249,  249,  249,  249,  249,  249,  249,  249,  249,  249,
  249,  249,  249,  249,  249,  249,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  161,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  279,    0,    0,    0,    0,    0,    0,
    0,  279,  279,  279,  279,  279,  279,  279,  279,  279,
  279,  279,  279,    0,    0,  161,  279,  279,  279,    0,
    0,    0,  279,  279,  279,  279,  279,  279,  279,  279,
  279,    0,  279,  279,  279,  279,  279,  279,  279,    0,
  279,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  279,    0,    0,    0,    0,
    0,    0,  279,  279,    0,  279,    0,  279,  279,  279,
    0,    0,  279,  279,    0,  279,  279,  279,  279,  160,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  279,    0,  279,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  279,  279,    0,    0,    0,    0,    0,  279,  279,  279,
  279,  279,  279,  279,  279,  279,  279,  279,  279,  279,
  279,  279,  279,  279,  279,    0,    0,    0,    0,    0,
  161,    0,    0,    0,    0,    0,    0,    0,  161,  161,
  161,  161,  161,  161,  161,  161,  161,  161,  161,  161,
  160,    0,    0,  161,  161,  161,    0,    0,    0,  161,
  161,  161,  161,  161,  161,  161,  161,  161,    0,  161,
  161,  161,  161,  161,  161,  161,    0,  161,    0,    0,
    0,    0,    0,    0,  160,    0,    0,    0,    0,    0,
    0,    0,  161,    0,    0,    0,    0,    0,    0,  161,
  161,    0,  161,    0,  161,  161,  161,    0,    0,  161,
  161,    0,  161,  161,  161,  161,  275,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  161,    0,  161,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  161,  161,    0,
    0,    0,    0,    0,  161,  161,  161,  161,  161,  161,
  161,  161,  161,  161,  161,  161,  161,  161,  161,  161,
  161,  161,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  275,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  160,
    0,    0,    0,    0,    0,    0,    0,  160,  160,  160,
  160,  160,  160,  160,  160,  160,  160,  160,  160,    0,
    0,  275,  160,  160,  160,    0,    0,    0,  160,  160,
  160,  160,  160,  160,  160,  160,  160,    0,  160,  160,
  160,  160,  160,  160,  160,    0,  160,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  160,    0,    0,    0,    0,    0,    0,  160,  160,
    0,  160,    0,  160,  160,  160,    0,    0,  160,  160,
    0,  160,  160,  160,  160,   97,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,  160,    0,  160,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  160,  160,    0,    0,
    0,    0,    0,  160,  160,  160,  160,  160,  160,  160,
  160,  160,  160,  160,  160,  160,  160,  160,  160,  160,
  160,    0,    0,    0,    0,    0,  275,    0,    0,    0,
    0,    0,    0,    0,  275,  275,  275,  275,  275,  275,
  275,  275,  275,  275,  275,  275,   97,    0,    0,  275,
  275,  275,    0,    0,    0,  275,  275,  275,  275,  275,
  275,  275,  275,  275,    0,  275,  275,  275,  275,  275,
  275,  275,    0,  275,    0,    0,    0,    0,    0,    0,
   97,    0,    0,    0,    0,    0,    0,    0,  275,    0,
    0,    0,    0,    0,    0,  275,  275,    0,  275,    0,
  275,  275,  275,    0,    0,  275,  275,    0,  275,  275,
  275,  275,   99,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  275,
    0,  275,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  275,  275,    0,    0,    0,    0,    0,
  275,  275,  275,  275,  275,  275,  275,  275,  275,  275,
  275,  275,  275,  275,  275,  275,  275,  275,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   99,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,   97,    0,    0,    0,    0,
    0,    0,    0,   97,   97,   97,   97,   97,   97,   97,
   97,   97,   97,   97,   97,    0,    0,   99,   97,   97,
   97,    0,    0,    0,   97,   97,   97,   97,   97,   97,
   97,   97,   97,    0,   97,   97,   97,   97,   97,   97,
   97,    0,   97,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   97,    0,    0,
    0,    0,    0,    0,   97,   97,    0,   97,    0,   97,
   97,   97,    0,    0,   97,   97,    0,   97,   97,   97,
   97,  247,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   97,    0,
   97,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   97,   97,    0,    0,    0,    0,    0,   97,
   97,   97,   97,   97,   97,   97,   97,   97,   97,   97,
   97,   97,   97,   97,   97,   97,   97,    0,    0,    0,
    0,    0,   99,    0,    0,    0,    0,    0,    0,    0,
   99,   99,   99,   99,   99,   99,   99,   99,   99,   99,
   99,   99,  247,    0,    0,   99,   99,   99,    0,    0,
    0,   99,   99,   99,   99,   99,   99,   99,   99,   99,
    0,   99,   99,   99,   99,   99,   99,   99,    0,   99,
    0,    0,    0,    0,    0,    0,  247,    0,    0,    0,
    0,    0,    0,    0,   99,    0,    0,    0,    0,    0,
    0,   99,   99,    0,   99,    0,   99,   99,   99,    0,
    0,   99,   99,    0,   99,   99,   99,   99,  257,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,   99,    0,   99,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,   99,
   99,    0,    0,    0,    0,    0,   99,   99,   99,   99,
   99,   99,   99,   99,   99,   99,   99,   99,   99,   99,
   99,   99,   99,   99,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  257,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  247,    0,    0,    0,    0,    0,    0,    0,  247,
  247,  247,  247,  247,  247,  247,  247,  247,  247,  247,
  247,    0,    0,  257,  247,  247,  247,    0,    0,    0,
  247,  247,  247,  247,  247,  247,  247,  247,  247,    0,
  247,  247,  247,  247,  247,  247,  247,    0,  247,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  247,    0,    0,    0,    0,    0,    0,
  247,  247,    0,  247,    0,  247,  247,  247,    0,    0,
  247,  247,    0,  247,  247,  247,  247,  273,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  247,    0,  247,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  247,  247,
    0,    0,    0,    0,    0,  247,  247,  247,  247,  247,
  247,  247,  247,  247,  247,  247,  247,  247,  247,  247,
  247,  247,  247,    0,    0,    0,    0,    0,  257,    0,
    0,    0,    0,    0,    0,    0,  257,  257,  257,  257,
  257,  257,  257,  257,  257,  257,  257,  257,  273,    0,
    0,  257,  257,  257,    0,    0,    0,  257,  257,  257,
  257,  257,  257,  257,  257,  257,    0,  257,  257,  257,
  257,  257,  257,  257,    0,  257,    0,    0,    0,    0,
    0,    0,  273,    0,    0,    0,    0,    0,    0,    0,
  257,    0,    0,    0,    0,    0,    0,  257,  257,    0,
  257,    0,  257,  257,  257,    0,    0,  257,  257,    0,
  257,  257,  257,  257,   18,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  257,    0,  257,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  257,  257,    0,    0,    0,
    0,    0,  257,  257,  257,  257,  257,  257,  257,  257,
  257,  257,  257,  257,  257,  257,  257,  257,  257,  257,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,   18,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  273,    0,    0,
    0,    0,    0,    0,    0,  273,  273,  273,  273,  273,
  273,  273,  273,  273,  273,  273,  273,    0,    0,   18,
  273,  273,  273,    0,    0,    0,  273,  273,  273,  273,
  273,  273,  273,  273,  273,    0,  273,  273,  273,  273,
  273,  273,  273,    0,  273,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  273,
    0,    0,    0,    0,    0,    0,  273,  273,    0,  273,
    0,  273,  273,  273,    0,    0,  273,  273,    0,  273,
  273,  273,  273,  277,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  273,    0,  273,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  273,  273,    0,    0,    0,    0,
    0,  273,  273,  273,  273,  273,  273,  273,  273,  273,
  273,  273,  273,  273,  273,  273,  273,  273,  273,    0,
    0,    0,    0,    0,   18,    0,    0,    0,    0,    0,
    0,    0,   18,   18,   18,   18,   18,   18,   18,   18,
   18,   18,   18,   18,  277,    0,    0,   18,   18,   18,
    0,    0,    0,   18,   18,   18,   18,   18,   18,   18,
   18,   18,    0,   18,   18,   18,   18,   18,   18,   18,
    0,   18,    0,    0,    0,    0,    0,    0,  277,    0,
    0,    0,    0,    0,    0,    0,   18,    0,    0,    0,
    0,    0,    0,   18,   18,    0,   18,    0,   18,   18,
   18,    0,    0,   18,   18,    0,   18,   18,   18,   18,
  270,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   18,    0,   18,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   18,   18,    0,    0,    0,    0,    0,   18,   18,
   18,   18,   18,   18,   18,   18,   18,   18,   18,   18,
   18,   18,   18,   18,   18,   18,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  270,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  277,    0,    0,    0,    0,    0,    0,
    0,  277,  277,  277,  277,  277,  277,  277,  277,  277,
  277,  277,  277,    0,    0,  270,  277,  277,  277,    0,
    0,    0,  277,  277,  277,  277,  277,  277,  277,  277,
  277,    0,  277,  277,  277,  277,  277,  277,  277,    0,
  277,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   22,  277,    0,    0,    0,    0,
    0,    0,  277,  277,    0,  277,    0,  277,  277,  277,
    0,    0,  277,  277,    0,  277,  277,  277,  277,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  277,    0,  277,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  277,  277,    0,    0,    0,    0,    0,  277,  277,  277,
  277,  277,  277,  277,  277,  277,  277,  277,  277,  277,
  277,  277,  277,  277,  277,   22,    0,    0,    0,    0,
  270,    0,    0,    0,    0,    0,    0,    0,  270,  270,
  270,  270,  270,  270,  270,  270,  270,  270,  270,  270,
    0,    0,    0,  270,  270,  270,    0,    0,    0,  270,
  270,  270,  270,  270,  270,  270,  270,  270,    0,  270,
  270,  270,  270,  270,  270,  270,    0,  270,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   25,  270,    0,    0,    0,    0,    0,    0,  270,
  270,    0,  270,    0,  270,  270,  270,    0,    0,  270,
  270,    0,  270,  270,  270,  270,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  270,    0,  270,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  270,  270,    0,
    0,    0,    0,    0,  270,  270,  270,  270,  270,  270,
  270,  270,  270,  270,  270,  270,  270,  270,  270,  270,
  270,  270,   25,    0,  473,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   22,    0,    0,  250,    0,    0,
    0,    0,   22,   22,   22,   22,   22,   22,   22,   22,
   22,   22,   22,   22,    0,    0,    0,   22,   22,   22,
    0,    0,    0,   22,   22,   22,   22,   22,   22,   22,
   22,   22,    0,   22,   22,   22,   22,   22,   22,   22,
    0,   22,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   22,    0,    0,    0,
    0,    0,    0,   22,   22,    0,   22,    0,   22,   22,
   22,    0,    0,   22,   22,    0,   22,    0,   22,    0,
    0,    0,    0,    0,    0,    0,  250,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   22,    0,   22,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   22,   22,    0,    0,    0,    0,    0,   22,   22,
   22,   22,   22,   22,   22,   22,   22,   22,   22,   22,
   22,   22,   22,   22,   22,   22,    0,    0,    0,    0,
    0,   25,    0,    0,    0,    0,    0,    0,    0,   25,
   25,   25,   25,   25,   25,   25,   25,   25,   25,   25,
   25,    0,    0,    0,   25,   25,   25,    0,    0,    0,
   25,   25,   25,   25,   25,   25,   25,   25,   25,    0,
   25,   25,   25,   25,   25,   25,   25,    0,   25,    0,
    0,  471,    0,    0,    0,  472,    0,    0,    0,    0,
    0,    0,    0,   25,  595,  347,    0,    0,    0,    0,
   25,   25,    0,   25,    0,   25,   25,   25,    0,    0,
   25,   25,    0,   25,    0,   25,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   25,    0,   25,  201,  202,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  201,  202,    0,    0,    0,    0,    0,    0,   25,   25,
   59,    0,    0,    0,    0,   25,   25,   25,   25,   25,
   25,   25,   25,   25,   25,   25,   25,   25,   25,   25,
   25,   25,   25,    0,  347,    0,    0,    0,    0,    0,
    0,    0,    0,  239,  240,  241,  242,  243,    0,  244,
  205,  245,  246,  247,  248,  249,  239,  240,  241,  242,
  243,    0,  244,  205,  245,  246,  247,  248,  249,    0,
    0,    0,    0,    0,  207,  208,    0,    0,  474,  475,
  712,  713,    0,    0,  251,    0,    0,  207,  208,  201,
  202,  714,  715,  716,    0,    0,    0,  251,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  717,    0,  718,  719,  720,  721,
  722,  723,  724,  725,  726,  727,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  239,  240,  241,  242,  243,
  192,  244,  205,  245,  246,  247,  248,  249,    0,    0,
    0,  193,  194,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  207,  208,    0,   15,
    0,    0,    0,    0,    0,    0,  251,   16,    0,    0,
   17,   18,   19,   20,   21,   22,   23,   24,   25,    0,
    0,    0,   26,   27,   28,    0,    0,    0,   29,   30,
   31,   32,   33,   34,   35,   36,   37,    0,   38,   39,
   40,   41,   42,   43,   44,    0,   45,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   46,    0,    0,    0,    0,    0,    0,   47,   48,
    0,   49,    0,   50,   51,   52,    0,    0,   53,   54,
    0,   55,    0,   56,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   57,    0,   58,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   60,   61,    0,    0,
    0,    0,    0,   62,   63,   64,   65,   66,   67,   68,
   69,   70,   71,   72,   73,   74,   75,   76,   77,   78,
   79,
};
 YYINT yycheck[] = {                         86,
   59,  169,  136,  134,   40,   40,  144,  295,  142,  143,
  395,   40,  146,  147,  148,   40,  497,   40,   40,   40,
   40,  159,  160,  161,  158,   40,   40,   37,  166,   40,
  328,  328,   42,   43,   40,   45,  408,   47,   40,  549,
  174,   40,  547,   40,   91,   40,  402,  403,   40,   40,
  545,  185,    0,   40,  185,  125,  432,  687,  313,   44,
  313,   40,   40,  313,  149,  150,  257,  355,   44,  399,
   44,  359,   44,  258,   58,   44,   44,  433,   44,   40,
   40,   37,  167,   93,  259,   44,   42,   43,   58,   45,
   46,   47,   44,   44,  123,   44,   40,  258,  157,  361,
  185,  262,  263,  152,  153,  154,  324,  241,  242,  259,
  244,   37,  123,   58,  589,   37,   42,   43,  177,   45,
   42,   47,  313,  385,  183,   47,  185,  385,  313,   37,
  385,   40,  385,  301,   42,  385,   44,   40,  313,   47,
  125,  396,  397,  309,  123,  620,   91,  313,   40,  125,
  385,  125,  313,  125,  239,  240,  125,  125,  385,  125,
  641,  396,  397,  313,  313,  795,  125,   93,   41,   58,
   43,  320,   45,  125,  125,   41,  125,   37,   44,   44,
  661,    0,   42,   43,   37,   45,  308,   47,  325,   42,
   43,  313,   45,  703,   47,   37,  701,  328,   91,   41,
   42,   43,   40,   45,  699,   47,   41,  258,  346,   44,
   37,  262,  263,  260,   41,   42,   43,   44,   45,  311,
   47,  313,  258,  361,  358,  393,  360,   58,  257,  313,
  368,  315,  316,  521,  372,  258,  370,  371,  376,  262,
   93,  300,   58,  258,  541,  543,  257,  306,  307,  336,
  309,  310,  311,  312,  313,  585,  258,  629,   58,  258,
  262,  258,  396,  262,  263,  257,  622,  258,  327,  328,
  257,  262,  263,  343,  650,  345,  407,  298,  257,  257,
  339,   41,   58,  421,   44,  123,   58,   41,  313,  348,
   44,  313,  314,  313,  353,   58,  257,  257,  357,  313,
  314,   58,  313,  317,  318,   58,  125,  313,   58,  308,
  309,  310,   58,  257,  313,  314,  313,  314,  313,  378,
  454,  269,  270,   58,  323,  264,  265,  266,  267,   58,
  464,  465,   58,  621,  313,  384,  269,  270,  337,  338,
   58,  390,  391,  392,  286,  287,  288,  346,  347,  348,
  349,  350,  313,  313,  257,  318,  319,  367,  394,  395,
  419,   58,  376,  362,  845,  364,   58,  402,  403,  313,
  385,  394,  395,    0,  385,  404,  405,  376,  763,  394,
  395,  396,  397,  312,  313,  341,  400,  401,  385,  298,
  390,  391,  394,  395,  430,  406,  407,  394,  395,  396,
  397,  400,  401,   58,  313,  314,  385,  430,  539,  697,
  313,   38,  404,  405,   41,  430,   43,   44,   45,   46,
  258,  313,  314,   58,  385,  385,  317,  318,  430,  408,
  409,  430,  343,  430,  345,   58,  274,   58,  276,   58,
   58,  385,  280,  281,  282,  406,  407,  615,  408,  409,
  269,  270,  590,   58,   58,   58,  594,   58,   58,  597,
  598,   58,   58,   37,   91,  524,   93,  376,   42,   43,
   58,   45,   58,   47,   58,  313,  314,   58,  537,  647,
  648,  649,  385,   58,  376,   58,  617,  387,   40,   58,
   61,  400,  401,   44,  332,   37,  123,   40,  125,   61,
   42,   43,  790,   45,   91,   47,   40,  123,  400,  401,
   46,   91,  800,   91,   44,  646,   44,   37,   44,   93,
  384,  652,   42,   43,  343,   45,  345,   47,  258,   40,
    0,   91,  257,  592,  593,   37,  374,  596,  376,   44,
   42,   43,   91,   45,   37,   47,   44,  385,  257,   42,
   43,   93,   45,  841,   47,   44,  394,  395,  396,  397,
   91,   44,  400,  401,  402,  403,   44,   44,   38,   44,
   38,   41,   37,   43,   44,   45,   46,   42,   43,   40,
   45,   40,   47,   40,   40,  716,  754,   40,  258,   37,
   91,   93,  430,   41,   42,   43,  655,   45,   44,   47,
   93,   44,   44,   40,  258,   37,  665,  775,  776,  777,
   42,   43,   37,   45,   44,   47,   41,   42,   43,   44,
   45,   91,   47,   93,   37,   44,  260,   44,   93,   42,
   43,   44,   45,  260,   47,   44,  258,   44,   44,   44,
   44,  268,  269,  270,  271,  272,  273,  274,  275,  276,
  277,  278,  279,  123,   44,  125,  283,  284,  285,  258,
   44,   93,  289,  290,  291,  292,  293,  294,  295,  296,
  297,   44,  299,  300,  301,  302,  303,  304,  305,  738,
  307,   44,  395,   44,  397,   93,  399,   44,  401,   41,
  403,   41,  405,   44,  407,  322,  409,   44,  411,   58,
   58,  257,  329,  330,   58,  332,   93,  334,  335,  336,
   58,  257,  339,  340,  341,  342,  343,  344,  345,    0,
  854,   44,   37,  386,  783,   44,  860,   42,   43,   44,
   45,   44,   47,   44,  259,  312,  363,   44,  365,   44,
  367,  382,  312,  830,   41,   44,   44,   93,  258,  321,
   44,   44,   44,  321,   44,  125,  843,  257,   44,   41,
  387,  388,  258,   44,   44,  385,   44,  394,  395,  396,
  397,  398,  399,  400,  401,  402,  403,  404,  405,  406,
  407,  408,  409,  410,  411,  124,   44,  385,   41,   44,
  260,   91,   44,   44,   44,   44,   44,   44,  268,  269,
  270,  271,  272,  273,  274,  275,  276,  277,  278,  279,
   91,  258,   93,  283,  284,  285,   91,   44,   44,  289,
  290,  291,  292,  293,  294,  295,  296,  297,   44,  299,
  300,  301,  302,  303,  304,  305,  258,  307,  258,   44,
  258,   44,  123,   44,  125,   44,  312,   44,  258,   44,
   44,  331,  322,   44,  257,   41,   46,   44,   58,  329,
  330,  258,  332,   40,  334,  335,  336,   41,   44,  339,
  340,  341,  342,  343,  344,  345,  388,  257,  386,   41,
   58,   41,  394,   58,  396,   58,  398,   58,  400,   58,
  402,   44,  404,  363,  406,  365,  408,  367,  410,  259,
   44,  312,   44,   40,   44,  258,  321,  321,    0,  258,
   44,   44,  385,   44,   44,  123,   44,  387,  388,   44,
   41,   41,   41,   41,  394,  395,  396,  397,  398,  399,
  400,  401,  402,  403,  404,  405,  406,  407,  408,  409,
  410,  411,  258,   44,   93,   44,   38,  388,  258,   41,
  258,   44,   44,  394,  395,  396,  397,  398,  399,  400,
  401,  402,  403,  404,  405,  406,  407,  408,  409,  410,
  411,   44,   44,  258,  258,   44,   41,   58,   58,  260,
  259,   58,   58,  257,  286,   41,   44,  268,  269,  270,
  271,  272,  273,  274,  275,  276,  277,  278,  279,   91,
   44,  258,  283,  284,  285,   41,   44,   41,  289,  290,
  291,  292,  293,  294,  295,  296,  297,   41,  299,  300,
  301,  302,  303,  304,  305,   44,  307,  261,   58,  125,
   44,   41,   44,  125,  258,   44,  313,  258,  258,  124,
   58,  322,  259,  286,   41,  258,   41,   41,  329,  330,
   41,  332,   44,  334,  335,  336,   41,  383,  339,  340,
   41,  342,  343,  344,  345,   41,   44,   44,   41,   44,
    0,    0,   41,   41,  386,  125,   93,   41,   44,   41,
  123,  123,  363,   41,  365,  125,  677,  794,  602,  652,
  761,  191,  820,  449,   48,  832,  248,    0,  442,   54,
  859,  168,  419,  753,  395,    6,  387,  388,  319,  431,
  766,  163,  138,  394,  395,  396,  397,  398,  399,  400,
  401,  402,  403,  404,  405,  406,  407,  408,  409,  410,
  411,  340,  629,  454,   -1,   -1,   -1,   -1,   41,   -1,
   -1,   44,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  260,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  268,  269,  270,  271,
  272,  273,  274,  275,  276,  277,  278,  279,   91,   -1,
   -1,  283,  284,  285,   -1,   -1,   -1,  289,  290,  291,
  292,  293,  294,  295,  296,  297,   -1,  299,  300,  301,
  302,  303,  304,  305,   -1,  307,   -1,   -1,   -1,   -1,
   -1,   -1,  125,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,   -1,
  332,   -1,  334,  335,  336,   -1,   -1,  339,  340,   -1,
  342,  343,  344,  345,    0,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,   44,   -1,
   -1,   -1,  394,  395,  396,  397,  398,  399,  400,  401,
  402,  403,  404,  405,  406,  407,  408,  409,  410,  411,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   40,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   91,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  260,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  268,  269,  270,  271,  272,
  273,  274,  275,  276,  277,  278,  279,  123,   -1,  125,
  283,  284,  285,   -1,   -1,   -1,  289,  290,  291,  292,
  293,  294,  295,  296,  297,   -1,  299,  300,  301,  302,
  303,  304,  305,   -1,  307,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  322,
   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,   -1,  332,
   -1,  334,  335,  336,   -1,   -1,  339,  340,   -1,  342,
  343,  344,  345,    0,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  387,  388,   -1,   44,   -1,   -1,
   -1,  394,  395,  396,  397,  398,  399,  400,  401,  402,
  403,  404,  405,  406,  407,  408,  409,  410,  411,   -1,
   -1,   -1,   -1,   -1,  260,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  268,  269,  270,  271,  272,  273,  274,  275,
  276,  277,  278,  279,   91,   -1,   -1,  283,  284,  285,
   -1,   -1,   -1,  289,  290,  291,  292,  293,  294,  295,
  296,  297,   -1,  299,  300,  301,  302,  303,  304,  305,
   -1,  307,   -1,   -1,   -1,   -1,  123,   -1,  125,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  322,   -1,   -1,   -1,
   -1,   -1,   -1,  329,  330,   -1,  332,   -1,  334,  335,
  336,   -1,   -1,  339,  340,   -1,  342,  343,  344,  345,
    0,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  312,
  313,  314,   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  387,  388,   -1,   44,   -1,   -1,   -1,  394,  395,
  396,  397,  398,  399,  400,  401,  402,  403,  404,  405,
  406,  407,  408,  409,  410,  411,  369,  370,  371,  372,
  373,   -1,  375,  376,  377,  378,  379,  380,  381,   -1,
   -1,   -1,   -1,   40,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   91,   -1,   -1,   -1,   -1,   -1,  400,  401,   -1,
   -1,   -1,   -1,  260,   -1,   -1,   -1,  410,   -1,   -1,
   -1,  268,  269,  270,  271,  272,  273,  274,  275,  276,
  277,  278,  279,  123,   -1,  125,  283,  284,  285,   -1,
   -1,   -1,  289,  290,  291,  292,  293,  294,  295,  296,
  297,   -1,  299,  300,  301,  302,  303,  304,  305,   -1,
  307,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  322,   -1,   -1,   -1,   -1,
   -1,   -1,  329,  330,   -1,  332,   -1,  334,  335,  336,
   -1,   -1,  339,  340,   -1,  342,  343,  344,  345,    0,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  387,  388,   -1,   44,   -1,   -1,   -1,  394,  395,  396,
  397,  398,  399,  400,  401,  402,  403,  404,  405,  406,
  407,  408,  409,  410,  411,   -1,   -1,   -1,   -1,   -1,
  260,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  268,  269,
  270,  271,  272,  273,  274,  275,  276,  277,  278,  279,
   91,   -1,   -1,  283,  284,  285,   -1,   -1,   -1,  289,
  290,  291,  292,  293,  294,  295,  296,  297,   -1,  299,
  300,  301,  302,  303,  304,  305,   -1,  307,   -1,   -1,
   -1,   -1,  123,   -1,  125,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,
  330,   -1,  332,   -1,  334,  335,  336,   -1,   -1,  339,
  340,   -1,  342,  343,  344,  345,    0,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  313,  314,   -1,   -1,
   -1,   -1,   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,
   -1,   -1,   -1,   -1,  394,  395,  396,  397,  398,  399,
  400,  401,  402,  403,  404,  405,  406,  407,  408,  409,
  410,  411,  369,  370,  371,  372,  373,   -1,  375,  376,
  377,  378,  379,  380,  381,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   91,   -1,   -1,
   -1,   -1,   -1,  400,  401,   -1,   -1,   -1,   -1,  260,
   -1,   -1,   -1,  410,   -1,   -1,   -1,  268,  269,  270,
  271,  272,  273,  274,  275,  276,  277,  278,  279,  123,
   -1,  125,  283,  284,  285,   -1,   -1,   -1,  289,  290,
  291,  292,  293,  294,  295,  296,  297,   -1,  299,  300,
  301,  302,  303,  304,  305,   -1,  307,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,
   -1,  332,   -1,  334,  335,  336,   -1,   -1,  339,  340,
   -1,  342,  343,  344,  345,    0,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,   -1,
   -1,   -1,   -1,  394,  395,  396,  397,  398,  399,  400,
  401,  402,  403,  404,  405,  406,  407,  408,  409,  410,
  411,   -1,   -1,   -1,   -1,   -1,  260,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  268,  269,  270,  271,  272,  273,
  274,  275,  276,  277,  278,  279,   91,   -1,   -1,  283,
  284,  285,   -1,   -1,   -1,  289,  290,  291,  292,  293,
  294,  295,  296,  297,   -1,  299,  300,  301,  302,  303,
  304,  305,   -1,  307,   -1,   -1,   -1,   -1,  123,   -1,
  125,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  322,   -1,
   -1,   -1,   -1,   -1,   -1,  329,  330,   -1,  332,   -1,
  334,  335,  336,   -1,   -1,  339,  340,   -1,  342,  343,
  344,  345,    0,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  363,
   -1,  365,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  387,  388,   -1,   -1,   -1,   -1,   -1,
  394,  395,  396,  397,  398,  399,  400,  401,  402,  403,
  404,  405,  406,  407,  408,  409,  410,  411,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   91,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  260,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  268,  269,  270,  271,  272,  273,  274,
  275,  276,  277,  278,  279,   -1,   -1,  125,  283,  284,
  285,   -1,   -1,   -1,  289,  290,  291,  292,  293,  294,
  295,  296,  297,   -1,  299,  300,  301,  302,  303,  304,
  305,   -1,  307,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  322,   -1,   -1,
   -1,   -1,   -1,   -1,  329,  330,   -1,  332,   -1,  334,
  335,  336,   -1,   -1,  339,  340,   -1,  342,  343,  344,
  345,    0,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  363,   -1,
  365,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  387,  388,   -1,   -1,   -1,   -1,   -1,  394,
  395,  396,  397,  398,  399,  400,  401,  402,  403,  404,
  405,  406,  407,  408,  409,  410,  411,   -1,   -1,   -1,
   -1,   -1,  260,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  268,  269,  270,  271,  272,  273,  274,  275,  276,  277,
  278,  279,   91,   -1,   -1,  283,  284,  285,   -1,   -1,
   -1,  289,  290,  291,  292,  293,  294,  295,  296,  297,
   -1,  299,  300,  301,  302,  303,  304,  305,   -1,  307,
   -1,   -1,   -1,   -1,  123,   -1,  125,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  322,   -1,   -1,   -1,   -1,   -1,
   -1,  329,  330,  331,  332,   -1,  334,  335,  336,   -1,
   -1,  339,  340,   -1,  342,  343,  344,  345,    0,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  387,
  388,   -1,   -1,   -1,   -1,   -1,  394,  395,  396,  397,
  398,  399,  400,  401,  402,  403,  404,  405,  406,  407,
  408,  409,  410,  411,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   91,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  260,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  268,
  269,  270,  271,  272,  273,  274,  275,  276,  277,  278,
  279,  123,   -1,  125,  283,  284,  285,   -1,   -1,   -1,
  289,  290,  291,  292,  293,  294,  295,  296,  297,   -1,
  299,  300,  301,  302,  303,  304,  305,   -1,  307,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  322,   -1,   -1,   -1,   -1,   -1,   -1,
  329,  330,   -1,  332,   -1,  334,  335,  336,   -1,   -1,
  339,  340,   -1,  342,  343,  344,  345,    0,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  363,   -1,  365,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,
   -1,   -1,   -1,   -1,   -1,  394,  395,  396,  397,  398,
  399,  400,  401,  402,  403,  404,  405,  406,  407,  408,
  409,  410,  411,   -1,   -1,   -1,   -1,   -1,  260,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  268,  269,  270,  271,
  272,  273,  274,  275,  276,  277,  278,  279,   91,   -1,
   -1,  283,  284,  285,   -1,   -1,   -1,  289,  290,  291,
  292,  293,  294,  295,  296,  297,   -1,  299,  300,  301,
  302,  303,  304,  305,   -1,  307,   -1,   -1,   -1,   -1,
  123,   -1,  125,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,   -1,
  332,   -1,  334,  335,  336,   -1,   -1,  339,  340,   -1,
  342,  343,  344,  345,    0,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,   -1,   -1,
   -1,   -1,  394,  395,  396,  397,  398,  399,  400,  401,
  402,  403,  404,  405,  406,  407,  408,  409,  410,  411,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   91,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  260,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  268,  269,  270,  271,  272,
  273,  274,  275,  276,  277,  278,  279,   -1,   -1,  125,
  283,  284,  285,   -1,   -1,   -1,  289,  290,  291,  292,
  293,  294,  295,  296,  297,   -1,  299,  300,  301,  302,
  303,  304,  305,   -1,  307,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  322,
   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,   -1,  332,
   -1,  334,  335,  336,   -1,   -1,  339,  340,   -1,  342,
  343,  344,  345,    0,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  387,  388,   -1,   -1,   -1,   -1,
   -1,  394,  395,  396,  397,  398,  399,  400,  401,  402,
  403,  404,  405,  406,  407,  408,  409,  410,  411,   -1,
   -1,   -1,   -1,   -1,  260,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  268,  269,  270,  271,  272,  273,  274,  275,
  276,  277,  278,  279,   91,   -1,   -1,  283,  284,  285,
   -1,   -1,   -1,  289,  290,  291,  292,  293,  294,  295,
  296,  297,   -1,  299,  300,  301,  302,  303,  304,  305,
   -1,  307,   -1,   -1,   -1,   -1,   -1,   -1,  125,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  322,   -1,   -1,   -1,
   -1,   -1,   -1,  329,  330,   -1,  332,   -1,  334,  335,
  336,   -1,   -1,  339,  340,   -1,  342,  343,  344,  345,
    0,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  387,  388,   -1,   -1,   -1,   -1,   -1,  394,  395,
  396,  397,  398,  399,  400,  401,  402,  403,  404,  405,
  406,  407,  408,  409,  410,  411,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   91,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  260,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  268,  269,  270,  271,  272,  273,  274,  275,  276,
  277,  278,  279,   -1,   -1,  125,  283,  284,  285,   -1,
   -1,   -1,  289,  290,  291,  292,  293,  294,  295,  296,
  297,   -1,  299,  300,  301,  302,  303,  304,  305,   -1,
  307,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  322,   -1,   -1,   -1,   -1,
   -1,   -1,  329,  330,   -1,  332,   -1,  334,  335,  336,
   -1,   -1,  339,  340,   -1,  342,  343,  344,  345,    0,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  387,  388,   -1,   -1,   -1,   -1,   -1,  394,  395,  396,
  397,  398,  399,  400,  401,  402,  403,  404,  405,  406,
  407,  408,  409,  410,  411,   -1,   -1,   -1,   -1,   -1,
  260,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  268,  269,
  270,  271,  272,  273,  274,  275,  276,  277,  278,  279,
   91,   -1,   -1,  283,  284,  285,   -1,   -1,   -1,  289,
  290,  291,  292,  293,  294,  295,  296,  297,   -1,  299,
  300,  301,  302,  303,  304,  305,   -1,  307,   -1,   -1,
   -1,   -1,   -1,   -1,  125,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,
  330,   -1,  332,   -1,  334,  335,  336,   -1,   -1,  339,
  340,   -1,  342,  343,  344,  345,    0,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,
   -1,   -1,   -1,   -1,  394,  395,  396,  397,  398,  399,
  400,  401,  402,  403,  404,  405,  406,  407,  408,  409,
  410,  411,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   91,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  260,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  268,  269,  270,
  271,  272,  273,  274,  275,  276,  277,  278,  279,   -1,
   -1,  125,  283,  284,  285,   -1,   -1,   -1,  289,  290,
  291,  292,  293,  294,  295,  296,  297,   -1,  299,  300,
  301,  302,  303,  304,  305,   -1,  307,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,
   -1,  332,   -1,  334,  335,  336,   -1,   -1,  339,  340,
   -1,  342,  343,  344,  345,    0,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,   -1,
   -1,   -1,   -1,  394,  395,  396,  397,  398,  399,  400,
  401,  402,  403,  404,  405,  406,  407,  408,  409,  410,
  411,   -1,   -1,   -1,   -1,   -1,  260,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  268,  269,  270,  271,  272,  273,
  274,  275,  276,  277,  278,  279,   91,   -1,   -1,  283,
  284,  285,   -1,   -1,   -1,  289,  290,  291,  292,  293,
  294,  295,  296,  297,   -1,  299,  300,  301,  302,  303,
  304,  305,   -1,  307,   -1,   -1,   -1,   -1,   -1,   -1,
  125,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  322,   -1,
   -1,   -1,   -1,   -1,   -1,  329,  330,   -1,  332,   -1,
  334,  335,  336,   -1,   -1,  339,  340,   -1,  342,  343,
  344,  345,    0,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  363,
   -1,  365,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  387,  388,   -1,   -1,   -1,   -1,   -1,
  394,  395,  396,  397,  398,  399,  400,  401,  402,  403,
  404,  405,  406,  407,  408,  409,  410,  411,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   91,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  260,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  268,  269,  270,  271,  272,  273,  274,
  275,  276,  277,  278,  279,   -1,   -1,  125,  283,  284,
  285,   -1,   -1,   -1,  289,  290,  291,  292,  293,  294,
  295,  296,  297,   -1,  299,  300,  301,  302,  303,  304,
  305,   -1,  307,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  322,   -1,   -1,
   -1,   -1,   -1,   -1,  329,  330,   -1,  332,   -1,  334,
  335,  336,   -1,   -1,  339,  340,   -1,  342,  343,  344,
  345,    0,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  363,   -1,
  365,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  387,  388,   -1,   -1,   -1,   -1,   -1,  394,
  395,  396,  397,  398,  399,  400,  401,  402,  403,  404,
  405,  406,  407,  408,  409,  410,  411,   -1,   -1,   -1,
   -1,   -1,  260,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  268,  269,  270,  271,  272,  273,  274,  275,  276,  277,
  278,  279,   91,   -1,   -1,  283,  284,  285,   -1,   -1,
   -1,  289,  290,  291,  292,  293,  294,  295,  296,  297,
   -1,  299,  300,  301,  302,  303,  304,  305,   -1,  307,
   -1,   -1,   -1,   -1,   -1,   -1,  125,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  322,   -1,   -1,   -1,   -1,   -1,
   -1,  329,  330,   -1,  332,   -1,  334,  335,  336,   -1,
   -1,  339,  340,   -1,  342,  343,  344,  345,    0,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  387,
  388,   -1,   -1,   -1,   -1,   -1,  394,  395,  396,  397,
  398,  399,  400,  401,  402,  403,  404,  405,  406,  407,
  408,  409,  410,  411,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   91,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  260,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  268,
  269,  270,  271,  272,  273,  274,  275,  276,  277,  278,
  279,   -1,   -1,  125,  283,  284,  285,   -1,   -1,   -1,
  289,  290,  291,  292,  293,  294,  295,  296,  297,   -1,
  299,  300,  301,  302,  303,  304,  305,   -1,  307,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  322,   -1,   -1,   -1,   -1,   -1,   -1,
  329,  330,   -1,  332,   -1,  334,  335,  336,   -1,   -1,
  339,  340,   -1,  342,  343,  344,  345,    0,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  363,   -1,  365,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,
   -1,   -1,   -1,   -1,   -1,  394,  395,  396,  397,  398,
  399,  400,  401,  402,  403,  404,  405,  406,  407,  408,
  409,  410,  411,   -1,   -1,   -1,   -1,   -1,  260,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  268,  269,  270,  271,
  272,  273,  274,  275,  276,  277,  278,  279,   91,   -1,
   -1,  283,  284,  285,   -1,   -1,   -1,  289,  290,  291,
  292,  293,  294,  295,  296,  297,   -1,  299,  300,  301,
  302,  303,  304,  305,   -1,  307,   -1,   -1,   -1,   -1,
   -1,   -1,  125,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,   -1,
  332,   -1,  334,  335,  336,   -1,   -1,  339,  340,   -1,
  342,  343,  344,  345,    0,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,   -1,   -1,
   -1,   -1,  394,  395,  396,  397,  398,  399,  400,  401,
  402,  403,  404,  405,  406,  407,  408,  409,  410,  411,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   91,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  260,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  268,  269,  270,  271,  272,
  273,  274,  275,  276,  277,  278,  279,   -1,   -1,  125,
  283,  284,  285,   -1,   -1,   -1,  289,  290,  291,  292,
  293,  294,  295,  296,  297,   -1,  299,  300,  301,  302,
  303,  304,  305,   -1,  307,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  322,
   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,   -1,  332,
   -1,  334,  335,  336,   -1,   -1,  339,  340,   -1,  342,
  343,  344,  345,    0,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  387,  388,   -1,   -1,   -1,   -1,
   -1,  394,  395,  396,  397,  398,  399,  400,  401,  402,
  403,  404,  405,  406,  407,  408,  409,  410,  411,   -1,
   -1,   -1,   -1,   -1,  260,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  268,  269,  270,  271,  272,  273,  274,  275,
  276,  277,  278,  279,   91,   -1,   -1,  283,  284,  285,
   -1,   -1,   -1,  289,  290,  291,  292,  293,  294,  295,
  296,  297,   -1,  299,  300,  301,  302,  303,  304,  305,
   -1,  307,   -1,   -1,   -1,   -1,   -1,   -1,  125,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  322,   -1,   -1,   -1,
   -1,   -1,   -1,  329,  330,   -1,  332,   -1,  334,  335,
  336,   -1,   -1,  339,  340,   -1,  342,  343,  344,  345,
    0,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  387,  388,   -1,   -1,   -1,   -1,   -1,  394,  395,
  396,  397,  398,  399,  400,  401,  402,  403,  404,  405,
  406,  407,  408,  409,  410,  411,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   91,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  260,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  268,  269,  270,  271,  272,  273,  274,  275,  276,
  277,  278,  279,   -1,   -1,  125,  283,  284,  285,   -1,
   -1,   -1,  289,  290,  291,  292,  293,  294,  295,  296,
  297,   -1,  299,  300,  301,  302,  303,  304,  305,   -1,
  307,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,    0,  322,   -1,   -1,   -1,   -1,
   -1,   -1,  329,  330,   -1,  332,   -1,  334,  335,  336,
   -1,   -1,  339,  340,   -1,  342,  343,  344,  345,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  387,  388,   -1,   -1,   -1,   -1,   -1,  394,  395,  396,
  397,  398,  399,  400,  401,  402,  403,  404,  405,  406,
  407,  408,  409,  410,  411,   91,   -1,   -1,   -1,   -1,
  260,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  268,  269,
  270,  271,  272,  273,  274,  275,  276,  277,  278,  279,
   -1,   -1,   -1,  283,  284,  285,   -1,   -1,   -1,  289,
  290,  291,  292,  293,  294,  295,  296,  297,   -1,  299,
  300,  301,  302,  303,  304,  305,   -1,  307,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,    0,  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,
  330,   -1,  332,   -1,  334,  335,  336,   -1,   -1,  339,
  340,   -1,  342,  343,  344,  345,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,
   -1,   -1,   -1,   -1,  394,  395,  396,  397,  398,  399,
  400,  401,  402,  403,  404,  405,  406,  407,  408,  409,
  410,  411,   91,   -1,   40,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  260,   -1,   -1,   40,   -1,   -1,
   -1,   -1,  268,  269,  270,  271,  272,  273,  274,  275,
  276,  277,  278,  279,   -1,   -1,   -1,  283,  284,  285,
   -1,   -1,   -1,  289,  290,  291,  292,  293,  294,  295,
  296,  297,   -1,  299,  300,  301,  302,  303,  304,  305,
   -1,  307,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  322,   -1,   -1,   -1,
   -1,   -1,   -1,  329,  330,   -1,  332,   -1,  334,  335,
  336,   -1,   -1,  339,  340,   -1,  342,   -1,  344,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   40,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  363,   -1,  365,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  387,  388,   -1,   -1,   -1,   -1,   -1,  394,  395,
  396,  397,  398,  399,  400,  401,  402,  403,  404,  405,
  406,  407,  408,  409,  410,  411,   -1,   -1,   -1,   -1,
   -1,  260,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  268,
  269,  270,  271,  272,  273,  274,  275,  276,  277,  278,
  279,   -1,   -1,   -1,  283,  284,  285,   -1,   -1,   -1,
  289,  290,  291,  292,  293,  294,  295,  296,  297,   -1,
  299,  300,  301,  302,  303,  304,  305,   -1,  307,   -1,
   -1,  257,   -1,   -1,   -1,  261,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  322,  257,  258,   -1,   -1,   -1,   -1,
  329,  330,   -1,  332,   -1,  334,  335,  336,   -1,   -1,
  339,  340,   -1,  342,   -1,  344,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  363,   -1,  365,  313,  314,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
  313,  314,   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,
   91,   -1,   -1,   -1,   -1,  394,  395,  396,  397,  398,
  399,  400,  401,  402,  403,  404,  405,  406,  407,  408,
  409,  410,  411,   -1,  258,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  369,  370,  371,  372,  373,   -1,  375,
  376,  377,  378,  379,  380,  381,  369,  370,  371,  372,
  373,   -1,  375,  376,  377,  378,  379,  380,  381,   -1,
   -1,   -1,   -1,   -1,  400,  401,   -1,   -1,  404,  405,
  315,  316,   -1,   -1,  410,   -1,   -1,  400,  401,  313,
  314,  326,  327,  328,   -1,   -1,   -1,  410,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,  349,   -1,  351,  352,  353,  354,
  355,  356,  357,  358,  359,  360,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,  369,  370,  371,  372,  373,
  385,  375,  376,  377,  378,  379,  380,  381,   -1,   -1,
   -1,  396,  397,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  400,  401,   -1,  260,
   -1,   -1,   -1,   -1,   -1,   -1,  410,  268,   -1,   -1,
  271,  272,  273,  274,  275,  276,  277,  278,  279,   -1,
   -1,   -1,  283,  284,  285,   -1,   -1,   -1,  289,  290,
  291,  292,  293,  294,  295,  296,  297,   -1,  299,  300,
  301,  302,  303,  304,  305,   -1,  307,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  322,   -1,   -1,   -1,   -1,   -1,   -1,  329,  330,
   -1,  332,   -1,  334,  335,  336,   -1,   -1,  339,  340,
   -1,  342,   -1,  344,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  363,   -1,  365,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  387,  388,   -1,   -1,
   -1,   -1,   -1,  394,  395,  396,  397,  398,  399,  400,
  401,  402,  403,  404,  405,  406,  407,  408,  409,  410,
  411,
};
#define YYFINAL 3
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 430
#define YYUNDFTOKEN 591
#define YYTRANSLATE(a) ((a) > YYMAXTOKEN ? YYUNDFTOKEN : (a))
#if YYDEBUG
 char * yyname[] = {

"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,"'%'","'&'",0,"'('","')'","'*'","'+'","','","'-'","'.'","'/'",0,0,0,0,0,0,
0,0,0,0,"':'",0,0,"'='",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,"'['",0,"']'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"'{'",
"'|'","'}'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"CHAR","INTEGER","BOOLEAN","PERCENT",
"SPERCENT","MINUS_INTEGER","PLUS_INTEGER","MAZE_GRID_ID","SOLID_FILL_ID",
"MINES_ID","ROGUELEV_ID","MESSAGE_ID","MAZE_ID","LEVEL_ID","LEV_INIT_ID",
"GEOMETRY_ID","NOMAP_ID","OBJECT_ID","COBJECT_ID","MONSTER_ID","TRAP_ID",
"DOOR_ID","DRAWBRIDGE_ID","object_ID","monster_ID","terrain_ID","MAZEWALK_ID",
"WALLIFY_ID","REGION_ID","FILLING","IRREGULAR","JOINED","ALTAR_ID","LADDER_ID",
"STAIR_ID","NON_DIGGABLE_ID","NON_PASSWALL_ID","ROOM_ID","PORTAL_ID",
"TELEPRT_ID","BRANCH_ID","LEV","MINERALIZE_ID","CORRIDOR_ID","GOLD_ID",
"ENGRAVING_ID","FOUNTAIN_ID","POOL_ID","SINK_ID","NONE","RAND_CORRIDOR_ID",
"DOOR_STATE","LIGHT_STATE","CURSE_TYPE","ENGRAVING_TYPE","DIRECTION",
"RANDOM_TYPE","RANDOM_TYPE_BRACKET","A_REGISTER","ALIGNMENT","LEFT_OR_RIGHT",
"CENTER","TOP_OR_BOT","ALTAR_TYPE","UP_OR_DOWN","SUBROOM_ID","NAME_ID",
"FLAGS_ID","FLAG_TYPE","MON_ATTITUDE","MON_ALERTNESS","MON_APPEARANCE",
"ROOMDOOR_ID","IF_ID","ELSE_ID","TERRAIN_ID","HORIZ_OR_VERT",
"REPLACE_TERRAIN_ID","EXIT_ID","SHUFFLE_ID","QUANTITY_ID","BURIED_ID","LOOP_ID",
"FOR_ID","TO_ID","SWITCH_ID","CASE_ID","BREAK_ID","DEFAULT_ID","ERODED_ID",
"TRAPPED_STATE","RECHARGED_ID","INVIS_ID","GREASED_ID","FEMALE_ID",
"CANCELLED_ID","REVIVED_ID","AVENGE_ID","FLEEING_ID","BLINDED_ID",
"PARALYZED_ID","STUNNED_ID","CONFUSED_ID","SEENTRAPS_ID","ALL_ID","MONTYPE_ID",
"GRAVE_ID","ERODEPROOF_ID","FUNCTION_ID","MSG_OUTPUT_TYPE","COMPARE_TYPE",
"UNKNOWN_TYPE","rect_ID","fillrect_ID","line_ID","randline_ID","grow_ID",
"selection_ID","flood_ID","rndcoord_ID","circle_ID","ellipse_ID","filter_ID",
"complement_ID","gradient_ID","GRADIENT_TYPE","LIMITED","HUMIDITY_TYPE",
"STRING","MAP_ID","NQSTRING","VARSTRING","CFUNC","CFUNC_INT","CFUNC_STR",
"CFUNC_COORD","CFUNC_REGION","VARSTRING_INT","VARSTRING_INT_ARRAY",
"VARSTRING_STRING","VARSTRING_STRING_ARRAY","VARSTRING_VAR",
"VARSTRING_VAR_ARRAY","VARSTRING_COORD","VARSTRING_COORD_ARRAY",
"VARSTRING_REGION","VARSTRING_REGION_ARRAY","VARSTRING_MAPCHAR",
"VARSTRING_MAPCHAR_ARRAY","VARSTRING_MONST","VARSTRING_MONST_ARRAY",
"VARSTRING_OBJ","VARSTRING_OBJ_ARRAY","VARSTRING_SEL","VARSTRING_SEL_ARRAY",
"METHOD_INT","METHOD_INT_ARRAY","METHOD_STRING","METHOD_STRING_ARRAY",
"METHOD_VAR","METHOD_VAR_ARRAY","METHOD_COORD","METHOD_COORD_ARRAY",
"METHOD_REGION","METHOD_REGION_ARRAY","METHOD_MAPCHAR","METHOD_MAPCHAR_ARRAY",
"METHOD_MONST","METHOD_MONST_ARRAY","METHOD_OBJ","METHOD_OBJ_ARRAY",
"METHOD_SEL","METHOD_SEL_ARRAY","DICE",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"illegal-symbol",
};
 char * yyrule[] = {
"$accept : file",
"file :",
"file : levels",
"levels : level",
"levels : level levels",
"level : level_def flags levstatements",
"level_def : LEVEL_ID ':' STRING",
"level_def : MAZE_ID ':' STRING ',' mazefiller",
"mazefiller : RANDOM_TYPE",
"mazefiller : CHAR",
"lev_init : LEV_INIT_ID ':' SOLID_FILL_ID ',' terrain_type",
"lev_init : LEV_INIT_ID ':' MAZE_GRID_ID ',' CHAR",
"lev_init : LEV_INIT_ID ':' ROGUELEV_ID",
"lev_init : LEV_INIT_ID ':' MINES_ID ',' CHAR ',' CHAR ',' BOOLEAN ',' BOOLEAN ',' light_state ',' walled opt_fillchar",
"opt_limited :",
"opt_limited : ',' LIMITED",
"opt_coord_or_var :",
"opt_coord_or_var : ',' coord_or_var",
"opt_fillchar :",
"opt_fillchar : ',' CHAR",
"walled : BOOLEAN",
"walled : RANDOM_TYPE",
"flags :",
"flags : FLAGS_ID ':' flag_list",
"flag_list : FLAG_TYPE ',' flag_list",
"flag_list : FLAG_TYPE",
"levstatements :",
"levstatements : levstatement levstatements",
"stmt_block : '{' levstatements '}'",
"levstatement : message",
"levstatement : lev_init",
"levstatement : altar_detail",
"levstatement : grave_detail",
"levstatement : branch_region",
"levstatement : corridor",
"levstatement : variable_define",
"levstatement : shuffle_detail",
"levstatement : diggable_detail",
"levstatement : door_detail",
"levstatement : drawbridge_detail",
"levstatement : engraving_detail",
"levstatement : mineralize",
"levstatement : fountain_detail",
"levstatement : gold_detail",
"levstatement : switchstatement",
"levstatement : forstatement",
"levstatement : loopstatement",
"levstatement : ifstatement",
"levstatement : chancestatement",
"levstatement : exitstatement",
"levstatement : breakstatement",
"levstatement : function_define",
"levstatement : function_call",
"levstatement : ladder_detail",
"levstatement : map_definition",
"levstatement : mazewalk_detail",
"levstatement : monster_detail",
"levstatement : object_detail",
"levstatement : passwall_detail",
"levstatement : pool_detail",
"levstatement : portal_region",
"levstatement : random_corridors",
"levstatement : region_detail",
"levstatement : room_def",
"levstatement : subroom_def",
"levstatement : sink_detail",
"levstatement : terrain_detail",
"levstatement : replace_terrain_detail",
"levstatement : stair_detail",
"levstatement : stair_region",
"levstatement : teleprt_region",
"levstatement : trap_detail",
"levstatement : wallify_detail",
"any_var_array : VARSTRING_INT_ARRAY",
"any_var_array : VARSTRING_STRING_ARRAY",
"any_var_array : VARSTRING_VAR_ARRAY",
"any_var_array : VARSTRING_COORD_ARRAY",
"any_var_array : VARSTRING_REGION_ARRAY",
"any_var_array : VARSTRING_MAPCHAR_ARRAY",
"any_var_array : VARSTRING_MONST_ARRAY",
"any_var_array : VARSTRING_OBJ_ARRAY",
"any_var_array : VARSTRING_SEL_ARRAY",
"any_var : VARSTRING_INT",
"any_var : VARSTRING_STRING",
"any_var : VARSTRING_VAR",
"any_var : VARSTRING_COORD",
"any_var : VARSTRING_REGION",
"any_var : VARSTRING_MAPCHAR",
"any_var : VARSTRING_MONST",
"any_var : VARSTRING_OBJ",
"any_var : VARSTRING_SEL",
"any_var_or_arr : any_var_array",
"any_var_or_arr : any_var",
"any_var_or_arr : VARSTRING",
"any_var_or_unk : VARSTRING",
"any_var_or_unk : any_var",
"shuffle_detail : SHUFFLE_ID ':' any_var_array",
"variable_define : any_var_or_arr '=' math_expr_var",
"variable_define : any_var_or_arr '=' selection_ID ':' ter_selection",
"variable_define : any_var_or_arr '=' string_expr",
"variable_define : any_var_or_arr '=' terrainid ':' mapchar_or_var",
"variable_define : any_var_or_arr '=' monsterid ':' monster_or_var",
"variable_define : any_var_or_arr '=' objectid ':' object_or_var",
"variable_define : any_var_or_arr '=' coord_or_var",
"variable_define : any_var_or_arr '=' region_or_var",
"variable_define : any_var_or_arr '=' '{' integer_list '}'",
"variable_define : any_var_or_arr '=' '{' encodecoord_list '}'",
"variable_define : any_var_or_arr '=' '{' encoderegion_list '}'",
"variable_define : any_var_or_arr '=' terrainid ':' '{' mapchar_list '}'",
"variable_define : any_var_or_arr '=' monsterid ':' '{' encodemonster_list '}'",
"variable_define : any_var_or_arr '=' objectid ':' '{' encodeobj_list '}'",
"variable_define : any_var_or_arr '=' '{' string_list '}'",
"encodeobj_list : encodeobj",
"encodeobj_list : encodeobj_list ',' encodeobj",
"encodemonster_list : encodemonster",
"encodemonster_list : encodemonster_list ',' encodemonster",
"mapchar_list : mapchar",
"mapchar_list : mapchar_list ',' mapchar",
"encoderegion_list : encoderegion",
"encoderegion_list : encoderegion_list ',' encoderegion",
"encodecoord_list : encodecoord",
"encodecoord_list : encodecoord_list ',' encodecoord",
"integer_list : math_expr_var",
"integer_list : integer_list ',' math_expr_var",
"string_list : string_expr",
"string_list : string_list ',' string_expr",
"$$1 :",
"$$2 :",
"function_define : FUNCTION_ID NQSTRING '(' $$1 func_params_list ')' $$2 stmt_block",
"function_call : NQSTRING '(' func_call_params_list ')'",
"exitstatement : EXIT_ID",
"opt_percent :",
"opt_percent : PERCENT",
"comparestmt : PERCENT",
"comparestmt : '[' math_expr_var COMPARE_TYPE math_expr_var ']'",
"comparestmt : '[' math_expr_var ']'",
"$$3 :",
"$$4 :",
"switchstatement : SWITCH_ID $$3 '[' integer_or_var ']' $$4 '{' switchcases '}'",
"switchcases :",
"switchcases : switchcase switchcases",
"$$5 :",
"switchcase : CASE_ID all_integers ':' $$5 levstatements",
"$$6 :",
"switchcase : DEFAULT_ID ':' $$6 levstatements",
"breakstatement : BREAK_ID",
"for_to_span : '.' '.'",
"for_to_span : TO_ID",
"forstmt_start : FOR_ID any_var_or_unk '=' math_expr_var for_to_span math_expr_var",
"$$7 :",
"forstatement : forstmt_start $$7 stmt_block",
"$$8 :",
"loopstatement : LOOP_ID '[' integer_or_var ']' $$8 stmt_block",
"$$9 :",
"chancestatement : comparestmt ':' $$9 levstatement",
"$$10 :",
"ifstatement : IF_ID comparestmt $$10 if_ending",
"if_ending : stmt_block",
"$$11 :",
"if_ending : stmt_block $$11 ELSE_ID stmt_block",
"message : MESSAGE_ID ':' string_expr",
"random_corridors : RAND_CORRIDOR_ID",
"random_corridors : RAND_CORRIDOR_ID ':' all_integers",
"random_corridors : RAND_CORRIDOR_ID ':' RANDOM_TYPE",
"corridor : CORRIDOR_ID ':' corr_spec ',' corr_spec",
"corridor : CORRIDOR_ID ':' corr_spec ',' all_integers",
"corr_spec : '(' INTEGER ',' DIRECTION ',' door_pos ')'",
"room_begin : room_type opt_percent ',' light_state",
"$$12 :",
"subroom_def : SUBROOM_ID ':' room_begin ',' subroom_pos ',' room_size optroomregionflags $$12 stmt_block",
"$$13 :",
"room_def : ROOM_ID ':' room_begin ',' room_pos ',' room_align ',' room_size optroomregionflags $$13 stmt_block",
"roomfill :",
"roomfill : ',' BOOLEAN",
"room_pos : '(' INTEGER ',' INTEGER ')'",
"room_pos : RANDOM_TYPE",
"subroom_pos : '(' INTEGER ',' INTEGER ')'",
"subroom_pos : RANDOM_TYPE",
"room_align : '(' h_justif ',' v_justif ')'",
"room_align : RANDOM_TYPE",
"room_size : '(' INTEGER ',' INTEGER ')'",
"room_size : RANDOM_TYPE",
"door_detail : ROOMDOOR_ID ':' secret ',' door_state ',' door_wall ',' door_pos",
"door_detail : DOOR_ID ':' door_state ',' ter_selection",
"secret : BOOLEAN",
"secret : RANDOM_TYPE",
"door_wall : dir_list",
"door_wall : RANDOM_TYPE",
"dir_list : DIRECTION",
"dir_list : DIRECTION '|' dir_list",
"door_pos : INTEGER",
"door_pos : RANDOM_TYPE",
"map_definition : NOMAP_ID",
"map_definition : GEOMETRY_ID ':' h_justif ',' v_justif roomfill MAP_ID",
"map_definition : GEOMETRY_ID ':' coord_or_var roomfill MAP_ID",
"h_justif : LEFT_OR_RIGHT",
"h_justif : CENTER",
"v_justif : TOP_OR_BOT",
"v_justif : CENTER",
"monster_detail : MONSTER_ID ':' monster_desc",
"$$14 :",
"monster_detail : MONSTER_ID ':' monster_desc $$14 stmt_block",
"monster_desc : monster_or_var ',' coord_or_var monster_infos",
"monster_infos :",
"monster_infos : monster_infos ',' monster_info",
"monster_info : string_expr",
"monster_info : MON_ATTITUDE",
"monster_info : MON_ALERTNESS",
"monster_info : alignment_prfx",
"monster_info : MON_APPEARANCE string_expr",
"monster_info : FEMALE_ID",
"monster_info : INVIS_ID",
"monster_info : CANCELLED_ID",
"monster_info : REVIVED_ID",
"monster_info : AVENGE_ID",
"monster_info : FLEEING_ID ':' integer_or_var",
"monster_info : BLINDED_ID ':' integer_or_var",
"monster_info : PARALYZED_ID ':' integer_or_var",
"monster_info : STUNNED_ID",
"monster_info : CONFUSED_ID",
"monster_info : SEENTRAPS_ID ':' seen_trap_mask",
"seen_trap_mask : STRING",
"seen_trap_mask : ALL_ID",
"seen_trap_mask : STRING '|' seen_trap_mask",
"object_detail : OBJECT_ID ':' object_desc",
"$$15 :",
"object_detail : COBJECT_ID ':' object_desc $$15 stmt_block",
"object_desc : object_or_var object_infos",
"object_infos :",
"object_infos : object_infos ',' object_info",
"object_info : CURSE_TYPE",
"object_info : MONTYPE_ID ':' monster_or_var",
"object_info : all_ints_push",
"object_info : NAME_ID ':' string_expr",
"object_info : QUANTITY_ID ':' integer_or_var",
"object_info : BURIED_ID",
"object_info : LIGHT_STATE",
"object_info : ERODED_ID ':' integer_or_var",
"object_info : ERODEPROOF_ID",
"object_info : DOOR_STATE",
"object_info : TRAPPED_STATE",
"object_info : RECHARGED_ID ':' integer_or_var",
"object_info : INVIS_ID",
"object_info : GREASED_ID",
"object_info : coord_or_var",
"trap_detail : TRAP_ID ':' trap_name ',' coord_or_var",
"drawbridge_detail : DRAWBRIDGE_ID ':' coord_or_var ',' DIRECTION ',' door_state",
"mazewalk_detail : MAZEWALK_ID ':' coord_or_var ',' DIRECTION",
"mazewalk_detail : MAZEWALK_ID ':' coord_or_var ',' DIRECTION ',' BOOLEAN opt_fillchar",
"wallify_detail : WALLIFY_ID",
"wallify_detail : WALLIFY_ID ':' ter_selection",
"ladder_detail : LADDER_ID ':' coord_or_var ',' UP_OR_DOWN",
"stair_detail : STAIR_ID ':' coord_or_var ',' UP_OR_DOWN",
"stair_region : STAIR_ID ':' lev_region ',' lev_region ',' UP_OR_DOWN",
"portal_region : PORTAL_ID ':' lev_region ',' lev_region ',' STRING",
"teleprt_region : TELEPRT_ID ':' lev_region ',' lev_region teleprt_detail",
"branch_region : BRANCH_ID ':' lev_region ',' lev_region",
"teleprt_detail :",
"teleprt_detail : ',' UP_OR_DOWN",
"fountain_detail : FOUNTAIN_ID ':' ter_selection",
"sink_detail : SINK_ID ':' ter_selection",
"pool_detail : POOL_ID ':' ter_selection",
"terrain_type : CHAR",
"terrain_type : '(' CHAR ',' light_state ')'",
"replace_terrain_detail : REPLACE_TERRAIN_ID ':' region_or_var ',' mapchar_or_var ',' mapchar_or_var ',' SPERCENT",
"terrain_detail : TERRAIN_ID ':' ter_selection ',' mapchar_or_var",
"diggable_detail : NON_DIGGABLE_ID ':' region_or_var",
"passwall_detail : NON_PASSWALL_ID ':' region_or_var",
"$$16 :",
"region_detail : REGION_ID ':' region_or_var ',' light_state ',' room_type optroomregionflags $$16 region_detail_end",
"region_detail_end :",
"region_detail_end : stmt_block",
"altar_detail : ALTAR_ID ':' coord_or_var ',' alignment ',' altar_type",
"grave_detail : GRAVE_ID ':' coord_or_var ',' string_expr",
"grave_detail : GRAVE_ID ':' coord_or_var ',' RANDOM_TYPE",
"grave_detail : GRAVE_ID ':' coord_or_var",
"gold_detail : GOLD_ID ':' math_expr_var ',' coord_or_var",
"engraving_detail : ENGRAVING_ID ':' coord_or_var ',' engraving_type ',' string_expr",
"mineralize : MINERALIZE_ID ':' integer_or_var ',' integer_or_var ',' integer_or_var ',' integer_or_var",
"mineralize : MINERALIZE_ID",
"trap_name : STRING",
"trap_name : RANDOM_TYPE",
"room_type : STRING",
"room_type : RANDOM_TYPE",
"optroomregionflags :",
"optroomregionflags : ',' roomregionflags",
"roomregionflags : roomregionflag",
"roomregionflags : roomregionflag ',' roomregionflags",
"roomregionflag : FILLING",
"roomregionflag : IRREGULAR",
"roomregionflag : JOINED",
"door_state : DOOR_STATE",
"door_state : RANDOM_TYPE",
"light_state : LIGHT_STATE",
"light_state : RANDOM_TYPE",
"alignment : ALIGNMENT",
"alignment : a_register",
"alignment : RANDOM_TYPE",
"alignment_prfx : ALIGNMENT",
"alignment_prfx : a_register",
"alignment_prfx : A_REGISTER ':' RANDOM_TYPE",
"altar_type : ALTAR_TYPE",
"altar_type : RANDOM_TYPE",
"a_register : A_REGISTER '[' INTEGER ']'",
"string_or_var : STRING",
"string_or_var : VARSTRING_STRING",
"string_or_var : VARSTRING_STRING_ARRAY '[' math_expr_var ']'",
"integer_or_var : math_expr_var",
"coord_or_var : encodecoord",
"coord_or_var : rndcoord_ID '(' ter_selection ')'",
"coord_or_var : VARSTRING_COORD",
"coord_or_var : VARSTRING_COORD_ARRAY '[' math_expr_var ']'",
"encodecoord : '(' INTEGER ',' INTEGER ')'",
"encodecoord : RANDOM_TYPE",
"encodecoord : RANDOM_TYPE_BRACKET humidity_flags ']'",
"humidity_flags : HUMIDITY_TYPE",
"humidity_flags : HUMIDITY_TYPE ',' humidity_flags",
"region_or_var : encoderegion",
"region_or_var : VARSTRING_REGION",
"region_or_var : VARSTRING_REGION_ARRAY '[' math_expr_var ']'",
"encoderegion : '(' INTEGER ',' INTEGER ',' INTEGER ',' INTEGER ')'",
"mapchar_or_var : mapchar",
"mapchar_or_var : VARSTRING_MAPCHAR",
"mapchar_or_var : VARSTRING_MAPCHAR_ARRAY '[' math_expr_var ']'",
"mapchar : CHAR",
"mapchar : '(' CHAR ',' light_state ')'",
"monster_or_var : encodemonster",
"monster_or_var : VARSTRING_MONST",
"monster_or_var : VARSTRING_MONST_ARRAY '[' math_expr_var ']'",
"encodemonster : STRING",
"encodemonster : CHAR",
"encodemonster : '(' CHAR ',' STRING ')'",
"encodemonster : RANDOM_TYPE",
"object_or_var : encodeobj",
"object_or_var : VARSTRING_OBJ",
"object_or_var : VARSTRING_OBJ_ARRAY '[' math_expr_var ']'",
"encodeobj : STRING",
"encodeobj : CHAR",
"encodeobj : '(' CHAR ',' STRING ')'",
"encodeobj : RANDOM_TYPE",
"string_expr : string_or_var",
"string_expr : string_expr '.' string_or_var",
"math_expr_var : INTEGER",
"math_expr_var : dice",
"math_expr_var : '(' MINUS_INTEGER ')'",
"math_expr_var : VARSTRING_INT",
"math_expr_var : VARSTRING_INT_ARRAY '[' math_expr_var ']'",
"math_expr_var : math_expr_var '+' math_expr_var",
"math_expr_var : math_expr_var '-' math_expr_var",
"math_expr_var : math_expr_var '*' math_expr_var",
"math_expr_var : math_expr_var '/' math_expr_var",
"math_expr_var : math_expr_var '%' math_expr_var",
"math_expr_var : '(' math_expr_var ')'",
"func_param_type : CFUNC_INT",
"func_param_type : CFUNC_STR",
"func_param_part : any_var_or_arr ':' func_param_type",
"func_param_list : func_param_part",
"func_param_list : func_param_list ',' func_param_part",
"func_params_list :",
"func_params_list : func_param_list",
"func_call_param_part : math_expr_var",
"func_call_param_part : string_expr",
"func_call_param_list : func_call_param_part",
"func_call_param_list : func_call_param_list ',' func_call_param_part",
"func_call_params_list :",
"func_call_params_list : func_call_param_list",
"ter_selection_x : coord_or_var",
"ter_selection_x : rect_ID region_or_var",
"ter_selection_x : fillrect_ID region_or_var",
"ter_selection_x : line_ID coord_or_var ',' coord_or_var",
"ter_selection_x : randline_ID coord_or_var ',' coord_or_var ',' math_expr_var",
"ter_selection_x : grow_ID '(' ter_selection ')'",
"ter_selection_x : grow_ID '(' dir_list ',' ter_selection ')'",
"ter_selection_x : filter_ID '(' SPERCENT ',' ter_selection ')'",
"ter_selection_x : filter_ID '(' ter_selection ',' ter_selection ')'",
"ter_selection_x : filter_ID '(' mapchar_or_var ',' ter_selection ')'",
"ter_selection_x : flood_ID coord_or_var",
"ter_selection_x : circle_ID '(' coord_or_var ',' math_expr_var ')'",
"ter_selection_x : circle_ID '(' coord_or_var ',' math_expr_var ',' FILLING ')'",
"ter_selection_x : ellipse_ID '(' coord_or_var ',' math_expr_var ',' math_expr_var ')'",
"ter_selection_x : ellipse_ID '(' coord_or_var ',' math_expr_var ',' math_expr_var ',' FILLING ')'",
"ter_selection_x : gradient_ID '(' GRADIENT_TYPE ',' '(' math_expr_var '-' math_expr_var opt_limited ')' ',' coord_or_var opt_coord_or_var ')'",
"ter_selection_x : complement_ID ter_selection_x",
"ter_selection_x : VARSTRING_SEL",
"ter_selection_x : '(' ter_selection ')'",
"ter_selection : ter_selection_x",
"ter_selection : ter_selection_x '&' ter_selection",
"dice : DICE",
"all_integers : MINUS_INTEGER",
"all_integers : PLUS_INTEGER",
"all_integers : INTEGER",
"all_ints_push : MINUS_INTEGER",
"all_ints_push : PLUS_INTEGER",
"all_ints_push : INTEGER",
"all_ints_push : dice",
"objectid : object_ID",
"objectid : OBJECT_ID",
"monsterid : monster_ID",
"monsterid : MONSTER_ID",
"terrainid : terrain_ID",
"terrainid : TERRAIN_ID",
"engraving_type : ENGRAVING_TYPE",
"engraving_type : RANDOM_TYPE",
"lev_region : region",
"lev_region : LEV '(' INTEGER ',' INTEGER ',' INTEGER ',' INTEGER ')'",
"region : '(' INTEGER ',' INTEGER ',' INTEGER ',' INTEGER ')'",

};
#endif

int      yydebug;
int      yynerrs;

int      yyerrflag;
int      yychar;
YYSTYPE  yyval;
YYSTYPE  yylval;

/* define the initial stack-sizes */
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH  YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH  10000
#endif
#endif

#define YYINITSTACKSIZE 200

typedef struct {
    unsigned stacksize;
    YYINT    *s_base;
    YYINT    *s_mark;
    YYINT    *s_last;
    YYSTYPE  *l_base;
    YYSTYPE  *l_mark;
} YYSTACKDATA;
/* variables for the parser stack */
static YYSTACKDATA yystack;
#line 2720 "util/lev_comp.y"

/*lev_comp.y*/
#line 2545 ""

#if YYDEBUG
#include <stdio.h>		/* needed for printf */
#endif

#if YYNHXFLAG
extern char *getenv();
#define CONST
#else
#include <stdlib.h>	/* needed for malloc, etc */
#include <string.h>	/* needed for memset */
#define CONST const
#endif

/* allocate initial stack or double stack size, up to YYMAXDEPTH */
static int yygrowstack(YYSTACKDATA *data)
{
    int i;
    unsigned newsize;
    YYINT *newss;
    YYSTYPE *newvs;

    if ((newsize = data->stacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return YYENOMEM;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;

    i = (int) (data->s_mark - data->s_base);
    newss = (YYINT *)realloc(data->s_base, newsize * sizeof(*newss));
    if (newss == 0)
        return YYENOMEM;

    data->s_base = newss;
    data->s_mark = newss + i;

    newvs = (YYSTYPE *)realloc(data->l_base, newsize * sizeof(*newvs));
    if (newvs == 0)
        return YYENOMEM;

    data->l_base = newvs;
    data->l_mark = newvs + i;

    data->stacksize = newsize;
    data->s_last = data->s_base + newsize - 1;
    return 0;
}

#if YYPURE || defined(YY_NO_LEAKS)
static void yyfreestack(YYSTACKDATA *data)
{
    free(data->s_base);
    free(data->l_base);
    memset(data, 0, sizeof(*data));
}
#else
#define yyfreestack(data) /* nothing */
#endif

#define YYABORT  goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR  goto yyerrlab

int
YYPARSE_DECL()
{
    int yym, yyn, yystate;
#if YYDEBUG
    CONST char *yys;

    if ((yys = getenv("YYDEBUG")) != 0)
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yynerrs = 0;
    yyerrflag = 0;
    yychar = YYEMPTY;
    yystate = 0;

#if YYPURE
    memset(&yystack, 0, sizeof(yystack));
#endif

    if (yystack.s_base == NULL && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
    yystack.s_mark = yystack.s_base;
    yystack.l_mark = yystack.l_base;
    yystate = 0;
    *yystack.s_mark = 0;

yyloop:
    if ((yyn = yydefred[yystate]) != 0) goto yyreduce;
    if (yychar < 0)
    {
        if ((yychar = YYLEX) < 0) yychar = YYEOF;
#if YYDEBUG
        if (yydebug)
        {
            yys = yyname[YYTRANSLATE(yychar)];
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) != 0 && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
#endif
        if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
        {
            goto yyoverflow;
        }
        yystate = yytable[yyn];
        *++yystack.s_mark = yytable[yyn];
        *++yystack.l_mark = yylval;
        yychar = YYEMPTY;
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if ((yyn = yyrindex[yystate]) != 0 && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag) goto yyinrecovery;

    YYERROR_CALL("syntax error");

    goto yyerrlab;

yyerrlab:
    ++yynerrs;

yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if ((yyn = yysindex[*yystack.s_mark]) != 0 && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yystack.s_mark, yytable[yyn]);
#endif
                if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
                {
                    goto yyoverflow;
                }
                yystate = yytable[yyn];
                *++yystack.s_mark = yytable[yyn];
                *++yystack.l_mark = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yystack.s_mark);
#endif
                if (yystack.s_mark <= yystack.s_base) goto yyabort;
                --yystack.s_mark;
                --yystack.l_mark;
            }
        }
    }
    else
    {
        if (yychar == YYEOF) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            yys = yyname[YYTRANSLATE(yychar)];
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = YYEMPTY;
        goto yyloop;
    }

yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    if (yym)
        yyval = yystack.l_mark[1-yym];
    else
        memset(&yyval, 0, sizeof yyval);
    switch (yyn)
    {
case 5:
#line 290 "util/lev_comp.y"
	{
			if (fatal_error > 0) {
				(void) fprintf(stderr,
              "%s: %d errors detected for level \"%s\". No output created!\n",
					       fname, fatal_error, yystack.l_mark[-2].map);
				fatal_error = 0;
				got_errors++;
			} else if (!got_errors) {
				if (!write_level_file(yystack.l_mark[-2].map, splev)) {
                                    lc_error("Can't write output file for '%s'!",
                                             yystack.l_mark[-2].map);
				    exit(EXIT_FAILURE);
				}
			}
			Free(yystack.l_mark[-2].map);
			Free(splev);
			splev = NULL;
			vardef_free_all(vardefs);
			vardefs = NULL;
		  }
break;
case 6:
#line 313 "util/lev_comp.y"
	{
		      start_level_def(&splev, yystack.l_mark[0].map);
		      yyval.map = yystack.l_mark[0].map;
		  }
break;
case 7:
#line 318 "util/lev_comp.y"
	{
		      start_level_def(&splev, yystack.l_mark[-2].map);
		      if (yystack.l_mark[0].i == -1) {
			  add_opvars(splev, "iiiiiiiio",
				     VA_PASS9(LVLINIT_MAZEGRID, HWALL, 0,0,
					      0,0,0,0, SPO_INITLEVEL));
		      } else {
			  int bg = (int) what_map_char((char) yystack.l_mark[0].i);

			  add_opvars(splev, "iiiiiiiio",
				     VA_PASS9(LVLINIT_SOLIDFILL, bg, 0,0,
					      0,0,0,0, SPO_INITLEVEL));
		      }
		      add_opvars(splev, "io",
				 VA_PASS2(MAZELEVEL, SPO_LEVEL_FLAGS));
		      max_x_map = COLNO-1;
		      max_y_map = ROWNO;
		      yyval.map = yystack.l_mark[-2].map;
		  }
break;
case 8:
#line 340 "util/lev_comp.y"
	{
		      yyval.i = -1;
		  }
break;
case 9:
#line 344 "util/lev_comp.y"
	{
		      yyval.i = what_map_char((char) yystack.l_mark[0].i);
		  }
break;
case 10:
#line 350 "util/lev_comp.y"
	{
		      int filling = (int) yystack.l_mark[0].terr.ter;

		      if (filling == INVALID_TYPE || filling >= MAX_TYPE)
			  lc_error("INIT_MAP: Invalid fill char type.");
		      add_opvars(splev, "iiiiiiiio",
				 VA_PASS9(LVLINIT_SOLIDFILL, filling,
                                          0, (int) yystack.l_mark[0].terr.lit,
                                          0,0,0,0, SPO_INITLEVEL));
		      max_x_map = COLNO-1;
		      max_y_map = ROWNO;
		  }
break;
case 11:
#line 363 "util/lev_comp.y"
	{
		      int filling = (int) what_map_char((char) yystack.l_mark[0].i);

		      if (filling == INVALID_TYPE || filling >= MAX_TYPE)
			  lc_error("INIT_MAP: Invalid fill char type.");
                      add_opvars(splev, "iiiiiiiio",
				 VA_PASS9(LVLINIT_MAZEGRID, filling, 0,0,
					  0,0,0,0, SPO_INITLEVEL));
		      max_x_map = COLNO-1;
		      max_y_map = ROWNO;
		  }
break;
case 12:
#line 375 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiiiiiio",
				 VA_PASS9(LVLINIT_ROGUE,0,0,0,
					  0,0,0,0, SPO_INITLEVEL));
		  }
break;
case 13:
#line 381 "util/lev_comp.y"
	{
                      int fg = (int) what_map_char((char) yystack.l_mark[-11].i),
                          bg = (int) what_map_char((char) yystack.l_mark[-9].i);
                      int smoothed = (int) yystack.l_mark[-7].i,
                          joined = (int) yystack.l_mark[-5].i,
                          lit = (int) yystack.l_mark[-3].i,
                          walled = (int) yystack.l_mark[-1].i,
                          filling = (int) yystack.l_mark[0].i;

		      if (fg == INVALID_TYPE || fg >= MAX_TYPE)
			  lc_error("INIT_MAP: Invalid foreground type.");
		      if (bg == INVALID_TYPE || bg >= MAX_TYPE)
			  lc_error("INIT_MAP: Invalid background type.");
		      if (joined && fg != CORR && fg != ROOM)
			  lc_error("INIT_MAP: Invalid foreground type for joined map.");

		      if (filling == INVALID_TYPE)
			  lc_error("INIT_MAP: Invalid fill char type.");

		      add_opvars(splev, "iiiiiiiio",
				 VA_PASS9(LVLINIT_MINES, filling, walled, lit,
					  joined, smoothed, bg, fg,
					  SPO_INITLEVEL));
			max_x_map = COLNO-1;
			max_y_map = ROWNO;
		  }
break;
case 14:
#line 410 "util/lev_comp.y"
	{
		      yyval.i = 0;
		  }
break;
case 15:
#line 414 "util/lev_comp.y"
	{
		      yyval.i = yystack.l_mark[0].i;
		  }
break;
case 16:
#line 420 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_COPY));
		      yyval.i = 0;
		  }
break;
case 17:
#line 425 "util/lev_comp.y"
	{
		      yyval.i = 1;
		  }
break;
case 18:
#line 431 "util/lev_comp.y"
	{
		      yyval.i = -1;
		  }
break;
case 19:
#line 435 "util/lev_comp.y"
	{
		      yyval.i = what_map_char((char) yystack.l_mark[0].i);
		  }
break;
case 22:
#line 446 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(0, SPO_LEVEL_FLAGS));
		  }
break;
case 23:
#line 450 "util/lev_comp.y"
	{
		      add_opvars(splev, "io",
                                 VA_PASS2((int) yystack.l_mark[0].i, SPO_LEVEL_FLAGS));
		  }
break;
case 24:
#line 457 "util/lev_comp.y"
	{
		      yyval.i = (yystack.l_mark[-2].i | yystack.l_mark[0].i);
		  }
break;
case 25:
#line 461 "util/lev_comp.y"
	{
		      yyval.i = yystack.l_mark[0].i;
		  }
break;
case 26:
#line 467 "util/lev_comp.y"
	{
		      yyval.i = 0;
		  }
break;
case 27:
#line 471 "util/lev_comp.y"
	{
		      yyval.i = 1 + yystack.l_mark[0].i;
		  }
break;
case 28:
#line 477 "util/lev_comp.y"
	{
		      yyval.i = yystack.l_mark[-1].i;
		  }
break;
case 96:
#line 560 "util/lev_comp.y"
	{
		      struct lc_vardefs *vd;

		      if ((vd = vardef_defined(vardefs, yystack.l_mark[0].map, 1))) {
			  if (!(vd->var_type & SPOVAR_ARRAY))
			      lc_error("Trying to shuffle non-array variable '%s'",
                                       yystack.l_mark[0].map);
		      } else
                          lc_error("Trying to shuffle undefined variable '%s'",
                                   yystack.l_mark[0].map);
		      add_opvars(splev, "so", VA_PASS2(yystack.l_mark[0].map, SPO_SHUFFLE_ARRAY));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 97:
#line 576 "util/lev_comp.y"
	{
		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-2].map, SPOVAR_INT);
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-2].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-2].map);
		  }
break;
case 98:
#line 582 "util/lev_comp.y"
	{
		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map, SPOVAR_SEL);
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-4].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 99:
#line 588 "util/lev_comp.y"
	{
		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-2].map, SPOVAR_STRING);
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-2].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-2].map);
		  }
break;
case 100:
#line 594 "util/lev_comp.y"
	{
		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map, SPOVAR_MAPCHAR);
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-4].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 101:
#line 600 "util/lev_comp.y"
	{
		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map, SPOVAR_MONST);
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-4].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 102:
#line 606 "util/lev_comp.y"
	{
		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map, SPOVAR_OBJ);
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-4].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 103:
#line 612 "util/lev_comp.y"
	{
		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-2].map, SPOVAR_COORD);
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-2].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-2].map);
		  }
break;
case 104:
#line 618 "util/lev_comp.y"
	{
		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-2].map, SPOVAR_REGION);
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-2].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-2].map);
		  }
break;
case 105:
#line 624 "util/lev_comp.y"
	{
		      int n_items = (int) yystack.l_mark[-1].i;

		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map,
                                                SPOVAR_INT | SPOVAR_ARRAY);
		      add_opvars(splev, "iso",
				 VA_PASS3(n_items, yystack.l_mark[-4].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 106:
#line 634 "util/lev_comp.y"
	{
		      int n_items = (int) yystack.l_mark[-1].i;

		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map,
                                                SPOVAR_COORD | SPOVAR_ARRAY);
		      add_opvars(splev, "iso",
				 VA_PASS3(n_items, yystack.l_mark[-4].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 107:
#line 644 "util/lev_comp.y"
	{
                      int n_items = (int) yystack.l_mark[-1].i;

		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map,
                                                SPOVAR_REGION | SPOVAR_ARRAY);
		      add_opvars(splev, "iso",
				 VA_PASS3(n_items, yystack.l_mark[-4].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 108:
#line 654 "util/lev_comp.y"
	{
                      int n_items = (int) yystack.l_mark[-1].i;

		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-6].map,
                                                SPOVAR_MAPCHAR | SPOVAR_ARRAY);
		      add_opvars(splev, "iso",
				 VA_PASS3(n_items, yystack.l_mark[-6].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-6].map);
		  }
break;
case 109:
#line 664 "util/lev_comp.y"
	{
		      int n_items = (int) yystack.l_mark[-1].i;

		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-6].map,
                                                SPOVAR_MONST | SPOVAR_ARRAY);
		      add_opvars(splev, "iso",
				 VA_PASS3(n_items, yystack.l_mark[-6].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-6].map);
		  }
break;
case 110:
#line 674 "util/lev_comp.y"
	{
                      int n_items = (int) yystack.l_mark[-1].i;

		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-6].map,
                                                SPOVAR_OBJ | SPOVAR_ARRAY);
		      add_opvars(splev, "iso",
				 VA_PASS3(n_items, yystack.l_mark[-6].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-6].map);
		  }
break;
case 111:
#line 684 "util/lev_comp.y"
	{
                      int n_items = (int) yystack.l_mark[-1].i;

		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map,
                                                SPOVAR_STRING | SPOVAR_ARRAY);
		      add_opvars(splev, "iso",
				 VA_PASS3(n_items, yystack.l_mark[-4].map, SPO_VAR_INIT));
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 112:
#line 696 "util/lev_comp.y"
	{
		      add_opvars(splev, "O", VA_PASS1(yystack.l_mark[0].i));
		      yyval.i = 1;
		  }
break;
case 113:
#line 701 "util/lev_comp.y"
	{
		      add_opvars(splev, "O", VA_PASS1(yystack.l_mark[0].i));
		      yyval.i = 1 + yystack.l_mark[-2].i;
		  }
break;
case 114:
#line 708 "util/lev_comp.y"
	{
		      add_opvars(splev, "M", VA_PASS1(yystack.l_mark[0].i));
		      yyval.i = 1;
		  }
break;
case 115:
#line 713 "util/lev_comp.y"
	{
		      add_opvars(splev, "M", VA_PASS1(yystack.l_mark[0].i));
		      yyval.i = 1 + yystack.l_mark[-2].i;
		  }
break;
case 116:
#line 720 "util/lev_comp.y"
	{
		      add_opvars(splev, "m", VA_PASS1(yystack.l_mark[0].i));
		      yyval.i = 1;
		  }
break;
case 117:
#line 725 "util/lev_comp.y"
	{
		      add_opvars(splev, "m", VA_PASS1(yystack.l_mark[0].i));
		      yyval.i = 1 + yystack.l_mark[-2].i;
		  }
break;
case 118:
#line 732 "util/lev_comp.y"
	{
		      yyval.i = 1;
		  }
break;
case 119:
#line 736 "util/lev_comp.y"
	{
		      yyval.i = 1 + yystack.l_mark[-2].i;
		  }
break;
case 120:
#line 742 "util/lev_comp.y"
	{
		      add_opvars(splev, "c", VA_PASS1(yystack.l_mark[0].i));
		      yyval.i = 1;
		  }
break;
case 121:
#line 747 "util/lev_comp.y"
	{
		      add_opvars(splev, "c", VA_PASS1(yystack.l_mark[0].i));
		      yyval.i = 1 + yystack.l_mark[-2].i;
		  }
break;
case 122:
#line 754 "util/lev_comp.y"
	{
		      yyval.i = 1;
		  }
break;
case 123:
#line 758 "util/lev_comp.y"
	{
		      yyval.i = 1 + yystack.l_mark[-2].i;
		  }
break;
case 124:
#line 764 "util/lev_comp.y"
	{
		      yyval.i = 1;
		  }
break;
case 125:
#line 768 "util/lev_comp.y"
	{
		      yyval.i = 1 + yystack.l_mark[-2].i;
		  }
break;
case 126:
#line 774 "util/lev_comp.y"
	{
		      struct lc_funcdefs *funcdef;

		      if (in_function_definition)
			  lc_error("Recursively defined functions not allowed (function %s).", yystack.l_mark[-1].map);

		      in_function_definition++;

		      if (funcdef_defined(function_definitions, yystack.l_mark[-1].map, 1))
			  lc_error("Function '%s' already defined once.", yystack.l_mark[-1].map);

		      funcdef = funcdef_new(-1, yystack.l_mark[-1].map);
		      funcdef->next = function_definitions;
		      function_definitions = funcdef;
		      function_splev_backup = splev;
		      splev = &(funcdef->code);
		      Free(yystack.l_mark[-1].map);
		      curr_function = funcdef;
		      function_tmp_var_defs = vardefs;
		      vardefs = NULL;
		  }
break;
case 127:
#line 796 "util/lev_comp.y"
	{
		      /* nothing */
		  }
break;
case 128:
#line 800 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(0, SPO_RETURN));
		      splev = function_splev_backup;
		      in_function_definition--;
		      curr_function = NULL;
		      vardef_free_all(vardefs);
		      vardefs = function_tmp_var_defs;
		  }
break;
case 129:
#line 811 "util/lev_comp.y"
	{
		      struct lc_funcdefs *tmpfunc;

		      tmpfunc = funcdef_defined(function_definitions, yystack.l_mark[-3].map, 1);
		      if (tmpfunc) {
			  int l;
			  int nparams = (int) strlen(yystack.l_mark[-1].map);
			  char *fparamstr = funcdef_paramtypes(tmpfunc);

			  if (strcmp(yystack.l_mark[-1].map, fparamstr)) {
			      char *tmps = strdup(decode_parm_str(fparamstr));

			      lc_error("Function '%s' requires params '%s', got '%s' instead.",
                                       yystack.l_mark[-3].map, tmps, decode_parm_str(yystack.l_mark[-1].map));
			      Free(tmps);
			  }
			  Free(fparamstr);
			  Free(yystack.l_mark[-1].map);
			  if (!(tmpfunc->n_called)) {
			      /* we haven't called the function yet, so insert it in the code */
			      struct opvar *jmp = New(struct opvar);

			      set_opvar_int(jmp, splev->n_opcodes+1);
			      add_opcode(splev, SPO_PUSH, jmp);
                              /* we must jump past it first, then CALL it, due to RETURN. */
			      add_opcode(splev, SPO_JMP, NULL);

			      tmpfunc->addr = splev->n_opcodes;

			      { /* init function parameter variables */
				  struct lc_funcdefs_parm *tfp = tmpfunc->params;
				  while (tfp) {
				      add_opvars(splev, "iso",
						 VA_PASS3(0, tfp->name,
							  SPO_VAR_INIT));
				      tfp = tfp->next;
				  }
			      }

			      splev_add_from(splev, &(tmpfunc->code));
			      set_opvar_int(jmp,
                                            splev->n_opcodes - jmp->vardata.l);
			  }
			  l = (int) (tmpfunc->addr - splev->n_opcodes - 2);
			  add_opvars(splev, "iio",
				     VA_PASS3(nparams, l, SPO_CALL));
			  tmpfunc->n_called++;
		      } else {
			  lc_error("Function '%s' not defined.", yystack.l_mark[-3].map);
		      }
		      Free(yystack.l_mark[-3].map);
		  }
break;
case 130:
#line 866 "util/lev_comp.y"
	{
		      add_opcode(splev, SPO_EXIT, NULL);
		  }
break;
case 131:
#line 872 "util/lev_comp.y"
	{
		      yyval.i = 100;
		  }
break;
case 132:
#line 876 "util/lev_comp.y"
	{
		      yyval.i = yystack.l_mark[0].i;
		  }
break;
case 133:
#line 882 "util/lev_comp.y"
	{
		      /* val > rn2(100) */
		      add_opvars(splev, "iio",
				 VA_PASS3((int) yystack.l_mark[0].i, 100, SPO_RN2));
		      yyval.i = SPO_JG;
                  }
break;
case 134:
#line 889 "util/lev_comp.y"
	{
		      yyval.i = yystack.l_mark[-2].i;
                  }
break;
case 135:
#line 893 "util/lev_comp.y"
	{
		      /* boolean, explicit foo != 0 */
		      add_opvars(splev, "i", VA_PASS1(0));
		      yyval.i = SPO_JNE;
                  }
break;
case 136:
#line 901 "util/lev_comp.y"
	{
		      is_inconstant_number = 0;
		  }
break;
case 137:
#line 905 "util/lev_comp.y"
	{
		      struct opvar *chkjmp;

		      if (in_switch_statement > 0)
			  lc_error("Cannot nest switch-statements.");

		      in_switch_statement++;

		      n_switch_case_list = 0;
		      switch_default_case = NULL;

		      if (!is_inconstant_number)
			  add_opvars(splev, "o", VA_PASS1(SPO_RN2));
		      is_inconstant_number = 0;

		      chkjmp = New(struct opvar);
		      set_opvar_int(chkjmp, splev->n_opcodes+1);
		      switch_check_jump = chkjmp;
		      add_opcode(splev, SPO_PUSH, chkjmp);
		      add_opcode(splev, SPO_JMP, NULL);
		      break_stmt_start();
		  }
break;
case 138:
#line 928 "util/lev_comp.y"
	{
		      struct opvar *endjump = New(struct opvar);
		      int i;

		      set_opvar_int(endjump, splev->n_opcodes+1);

		      add_opcode(splev, SPO_PUSH, endjump);
		      add_opcode(splev, SPO_JMP, NULL);

		      set_opvar_int(switch_check_jump,
			     splev->n_opcodes - switch_check_jump->vardata.l);

		      for (i = 0; i < n_switch_case_list; i++) {
			  add_opvars(splev, "oio",
				     VA_PASS3(SPO_COPY,
					      switch_case_value[i], SPO_CMP));
			  set_opvar_int(switch_case_list[i],
			 switch_case_list[i]->vardata.l - splev->n_opcodes-1);
			  add_opcode(splev, SPO_PUSH, switch_case_list[i]);
			  add_opcode(splev, SPO_JE, NULL);
		      }

		      if (switch_default_case) {
			  set_opvar_int(switch_default_case,
			 switch_default_case->vardata.l - splev->n_opcodes-1);
			  add_opcode(splev, SPO_PUSH, switch_default_case);
			  add_opcode(splev, SPO_JMP, NULL);
		      }

		      set_opvar_int(endjump, splev->n_opcodes - endjump->vardata.l);

		      break_stmt_end(splev);

		      add_opcode(splev, SPO_POP, NULL); /* get rid of the value in stack */
		      in_switch_statement--;


		  }
break;
case 141:
#line 973 "util/lev_comp.y"
	{
		      if (n_switch_case_list < MAX_SWITCH_CASES) {
			  struct opvar *tmppush = New(struct opvar);

			  set_opvar_int(tmppush, splev->n_opcodes);
			  switch_case_value[n_switch_case_list] = yystack.l_mark[-1].i;
			  switch_case_list[n_switch_case_list++] = tmppush;
		      } else lc_error("Too many cases in a switch.");
		  }
break;
case 142:
#line 983 "util/lev_comp.y"
	{
		  }
break;
case 143:
#line 986 "util/lev_comp.y"
	{
		      struct opvar *tmppush = New(struct opvar);

		      if (switch_default_case)
			  lc_error("Switch default case already used.");

		      set_opvar_int(tmppush, splev->n_opcodes);
		      switch_default_case = tmppush;
		  }
break;
case 144:
#line 996 "util/lev_comp.y"
	{
		  }
break;
case 145:
#line 1001 "util/lev_comp.y"
	{
		      if (!allow_break_statements)
			  lc_error("Cannot use BREAK outside a statement block.");
		      else {
			  break_stmt_new(splev, splev->n_opcodes);
		      }
		  }
break;
case 148:
#line 1015 "util/lev_comp.y"
	{
		      char buf[256], buf2[256];

		      if (n_forloops >= MAX_NESTED_IFS) {
			  lc_error("FOR: Too deeply nested loops.");
			  n_forloops = MAX_NESTED_IFS - 1;
		      }

		      /* first, define a variable for the for-loop end value */
		      Sprintf(buf, "%s end", yystack.l_mark[-4].map);
		      /* the value of which is already in stack (the 2nd math_expr) */
		      add_opvars(splev, "iso", VA_PASS3(0, buf, SPO_VAR_INIT));

		      vardefs = add_vardef_type(vardefs, yystack.l_mark[-4].map, SPOVAR_INT);
		      /* define the for-loop variable. value is in stack (1st math_expr) */
		      add_opvars(splev, "iso", VA_PASS3(0, yystack.l_mark[-4].map, SPO_VAR_INIT));

		      /* calculate value for the loop "step" variable */
		      Sprintf(buf2, "%s step", yystack.l_mark[-4].map);
		      /* end - start */
		      add_opvars(splev, "vvo",
				 VA_PASS3(buf, yystack.l_mark[-4].map, SPO_MATH_SUB));
		      /* sign of that */
		      add_opvars(splev, "o", VA_PASS1(SPO_MATH_SIGN));
		      /* save the sign into the step var */
		      add_opvars(splev, "iso",
				 VA_PASS3(0, buf2, SPO_VAR_INIT));

		      forloop_list[n_forloops].varname = strdup(yystack.l_mark[-4].map);
		      forloop_list[n_forloops].jmp_point = splev->n_opcodes;

		      n_forloops++;
		      Free(yystack.l_mark[-4].map);
		  }
break;
case 149:
#line 1052 "util/lev_comp.y"
	{
		      /* nothing */
		      break_stmt_start();
		  }
break;
case 150:
#line 1057 "util/lev_comp.y"
	{
                      int l;
		      char buf[256], buf2[256];

		      n_forloops--;
		      Sprintf(buf, "%s step", forloop_list[n_forloops].varname);
		      Sprintf(buf2, "%s end", forloop_list[n_forloops].varname);
		      /* compare for-loop var to end value */
		      add_opvars(splev, "vvo",
				 VA_PASS3(forloop_list[n_forloops].varname,
					  buf2, SPO_CMP));
		      /* var + step */
		      add_opvars(splev, "vvo",
				VA_PASS3(buf, forloop_list[n_forloops].varname,
					 SPO_MATH_ADD));
		      /* for-loop var = (for-loop var + step) */
		      add_opvars(splev, "iso",
				 VA_PASS3(0, forloop_list[n_forloops].varname,
					  SPO_VAR_INIT));
		      /* jump back if compared values were not equal */
                      l = (int) (forloop_list[n_forloops].jmp_point
                                 - splev->n_opcodes - 1);
		      add_opvars(splev, "io", VA_PASS2(l, SPO_JNE));
		      Free(forloop_list[n_forloops].varname);
		      break_stmt_end(splev);
		  }
break;
case 151:
#line 1086 "util/lev_comp.y"
	{
		      struct opvar *tmppush = New(struct opvar);

		      if (n_if_list >= MAX_NESTED_IFS) {
			  lc_error("LOOP: Too deeply nested conditionals.");
			  n_if_list = MAX_NESTED_IFS - 1;
		      }
		      set_opvar_int(tmppush, splev->n_opcodes);
		      if_list[n_if_list++] = tmppush;

		      add_opvars(splev, "o", VA_PASS1(SPO_DEC));
		      break_stmt_start();
		  }
break;
case 152:
#line 1100 "util/lev_comp.y"
	{
		      struct opvar *tmppush;

		      add_opvars(splev, "oio", VA_PASS3(SPO_COPY, 0, SPO_CMP));

		      tmppush = (struct opvar *) if_list[--n_if_list];
		      set_opvar_int(tmppush,
                                    tmppush->vardata.l - splev->n_opcodes-1);
		      add_opcode(splev, SPO_PUSH, tmppush);
		      add_opcode(splev, SPO_JG, NULL);
		      add_opcode(splev, SPO_POP, NULL); /* discard count */
		      break_stmt_end(splev);
		  }
break;
case 153:
#line 1116 "util/lev_comp.y"
	{
		      struct opvar *tmppush2 = New(struct opvar);

		      if (n_if_list >= MAX_NESTED_IFS) {
			  lc_error("IF: Too deeply nested conditionals.");
			  n_if_list = MAX_NESTED_IFS - 1;
		      }

		      add_opcode(splev, SPO_CMP, NULL);

		      set_opvar_int(tmppush2, splev->n_opcodes+1);

		      if_list[n_if_list++] = tmppush2;

		      add_opcode(splev, SPO_PUSH, tmppush2);

		      add_opcode(splev, reverse_jmp_opcode( yystack.l_mark[-1].i ), NULL);

		  }
break;
case 154:
#line 1136 "util/lev_comp.y"
	{
		      if (n_if_list > 0) {
			  struct opvar *tmppush;

			  tmppush = (struct opvar *) if_list[--n_if_list];
			  set_opvar_int(tmppush,
                                        splev->n_opcodes - tmppush->vardata.l);
		      } else lc_error("IF: Huh?!  No start address?");
		  }
break;
case 155:
#line 1148 "util/lev_comp.y"
	{
		      struct opvar *tmppush2 = New(struct opvar);

		      if (n_if_list >= MAX_NESTED_IFS) {
			  lc_error("IF: Too deeply nested conditionals.");
			  n_if_list = MAX_NESTED_IFS - 1;
		      }

		      add_opcode(splev, SPO_CMP, NULL);

		      set_opvar_int(tmppush2, splev->n_opcodes+1);

		      if_list[n_if_list++] = tmppush2;

		      add_opcode(splev, SPO_PUSH, tmppush2);

		      add_opcode(splev, reverse_jmp_opcode( yystack.l_mark[0].i ), NULL);

		  }
break;
case 156:
#line 1168 "util/lev_comp.y"
	{
		     /* do nothing */
		  }
break;
case 157:
#line 1174 "util/lev_comp.y"
	{
		      if (n_if_list > 0) {
			  struct opvar *tmppush;

			  tmppush = (struct opvar *) if_list[--n_if_list];
			  set_opvar_int(tmppush,
                                        splev->n_opcodes - tmppush->vardata.l);
		      } else lc_error("IF: Huh?!  No start address?");
		  }
break;
case 158:
#line 1184 "util/lev_comp.y"
	{
		      if (n_if_list > 0) {
			  struct opvar *tmppush = New(struct opvar);
			  struct opvar *tmppush2;

			  set_opvar_int(tmppush, splev->n_opcodes+1);
			  add_opcode(splev, SPO_PUSH, tmppush);

			  add_opcode(splev, SPO_JMP, NULL);

			  tmppush2 = (struct opvar *) if_list[--n_if_list];

			  set_opvar_int(tmppush2,
                                      splev->n_opcodes - tmppush2->vardata.l);
			  if_list[n_if_list++] = tmppush;
		      } else lc_error("IF: Huh?!  No else-part address?");
		  }
break;
case 159:
#line 1202 "util/lev_comp.y"
	{
		      if (n_if_list > 0) {
			  struct opvar *tmppush;
			  tmppush = (struct opvar *) if_list[--n_if_list];
			  set_opvar_int(tmppush, splev->n_opcodes - tmppush->vardata.l);
		      } else lc_error("IF: Huh?! No end address?");
		  }
break;
case 160:
#line 1212 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_MESSAGE));
		  }
break;
case 161:
#line 1218 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiiiio",
			      VA_PASS7(-1,  0, -1, -1, -1, -1, SPO_CORRIDOR));
		  }
break;
case 162:
#line 1223 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiiiio",
			      VA_PASS7(-1, yystack.l_mark[0].i, -1, -1, -1, -1, SPO_CORRIDOR));
		  }
break;
case 163:
#line 1228 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiiiio",
			      VA_PASS7(-1, -1, -1, -1, -1, -1, SPO_CORRIDOR));
		  }
break;
case 164:
#line 1235 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiiiio",
				 VA_PASS7(yystack.l_mark[-2].corpos.room, yystack.l_mark[-2].corpos.door, yystack.l_mark[-2].corpos.wall,
					  yystack.l_mark[0].corpos.room, yystack.l_mark[0].corpos.door, yystack.l_mark[0].corpos.wall,
					  SPO_CORRIDOR));
		  }
break;
case 165:
#line 1242 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiiiio",
				 VA_PASS7(yystack.l_mark[-2].corpos.room, yystack.l_mark[-2].corpos.door, yystack.l_mark[-2].corpos.wall,
					  -1, -1, (long)yystack.l_mark[0].i,
					  SPO_CORRIDOR));
		  }
break;
case 166:
#line 1251 "util/lev_comp.y"
	{
			yyval.corpos.room = yystack.l_mark[-5].i;
			yyval.corpos.wall = yystack.l_mark[-3].i;
			yyval.corpos.door = yystack.l_mark[-1].i;
		  }
break;
case 167:
#line 1259 "util/lev_comp.y"
	{
		      if ((yystack.l_mark[-2].i < 100) && (yystack.l_mark[-3].i == OROOM))
			  lc_error("Only typed rooms can have a chance.");
		      else {
			  add_opvars(splev, "iii",
				     VA_PASS3((long)yystack.l_mark[-3].i, (long)yystack.l_mark[-2].i, (long)yystack.l_mark[0].i));
		      }
                  }
break;
case 168:
#line 1270 "util/lev_comp.y"
	{
		      long rflags = yystack.l_mark[0].i;

		      if (rflags == -1) rflags = (1 << 0);
		      add_opvars(splev, "iiiiiiio",
				 VA_PASS8(rflags, ERR, ERR,
					  yystack.l_mark[-3].crd.x, yystack.l_mark[-3].crd.y, yystack.l_mark[-1].sze.width, yystack.l_mark[-1].sze.height,
					  SPO_SUBROOM));
		      break_stmt_start();
		  }
break;
case 169:
#line 1281 "util/lev_comp.y"
	{
		      break_stmt_end(splev);
		      add_opcode(splev, SPO_ENDROOM, NULL);
		  }
break;
case 170:
#line 1288 "util/lev_comp.y"
	{
		      long rflags = yystack.l_mark[-2].i;

		      if (rflags == -1) rflags = (1 << 0);
		      add_opvars(splev, "iiiiiiio",
				 VA_PASS8(rflags,
					  yystack.l_mark[-3].crd.x, yystack.l_mark[-3].crd.y, yystack.l_mark[-5].crd.x, yystack.l_mark[-5].crd.y,
					  yystack.l_mark[-1].sze.width, yystack.l_mark[-1].sze.height, SPO_ROOM));
		      break_stmt_start();
		  }
break;
case 171:
#line 1299 "util/lev_comp.y"
	{
		      break_stmt_end(splev);
		      add_opcode(splev, SPO_ENDROOM, NULL);
		  }
break;
case 172:
#line 1306 "util/lev_comp.y"
	{
			yyval.i = 1;
		  }
break;
case 173:
#line 1310 "util/lev_comp.y"
	{
			yyval.i = yystack.l_mark[0].i;
		  }
break;
case 174:
#line 1316 "util/lev_comp.y"
	{
			if ( yystack.l_mark[-3].i < 1 || yystack.l_mark[-3].i > 5 ||
			    yystack.l_mark[-1].i < 1 || yystack.l_mark[-1].i > 5 ) {
			    lc_error("Room positions should be between 1-5: (%li,%li)!", yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			} else {
			    yyval.crd.x = yystack.l_mark[-3].i;
			    yyval.crd.y = yystack.l_mark[-1].i;
			}
		  }
break;
case 175:
#line 1326 "util/lev_comp.y"
	{
			yyval.crd.x = yyval.crd.y = ERR;
		  }
break;
case 176:
#line 1332 "util/lev_comp.y"
	{
			if ( yystack.l_mark[-3].i < 0 || yystack.l_mark[-1].i < 0) {
			    lc_error("Invalid subroom position (%li,%li)!", yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			} else {
			    yyval.crd.x = yystack.l_mark[-3].i;
			    yyval.crd.y = yystack.l_mark[-1].i;
			}
		  }
break;
case 177:
#line 1341 "util/lev_comp.y"
	{
			yyval.crd.x = yyval.crd.y = ERR;
		  }
break;
case 178:
#line 1347 "util/lev_comp.y"
	{
		      yyval.crd.x = yystack.l_mark[-3].i;
		      yyval.crd.y = yystack.l_mark[-1].i;
		  }
break;
case 179:
#line 1352 "util/lev_comp.y"
	{
		      yyval.crd.x = yyval.crd.y = ERR;
		  }
break;
case 180:
#line 1358 "util/lev_comp.y"
	{
			yyval.sze.width = yystack.l_mark[-3].i;
			yyval.sze.height = yystack.l_mark[-1].i;
		  }
break;
case 181:
#line 1363 "util/lev_comp.y"
	{
			yyval.sze.height = yyval.sze.width = ERR;
		  }
break;
case 182:
#line 1369 "util/lev_comp.y"
	{
			/* ERR means random here */
			if (yystack.l_mark[-2].i == ERR && yystack.l_mark[0].i != ERR) {
			    lc_error("If the door wall is random, so must be its pos!");
			} else {
			    add_opvars(splev, "iiiio",
				       VA_PASS5((long)yystack.l_mark[0].i, (long)yystack.l_mark[-4].i, (long)yystack.l_mark[-6].i,
						(long)yystack.l_mark[-2].i, SPO_ROOM_DOOR));
			}
		  }
break;
case 183:
#line 1380 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2((long)yystack.l_mark[-2].i, SPO_DOOR));
		  }
break;
case 188:
#line 1394 "util/lev_comp.y"
	{
		      yyval.i = yystack.l_mark[0].i;
		  }
break;
case 189:
#line 1398 "util/lev_comp.y"
	{
		      yyval.i = (yystack.l_mark[-2].i | yystack.l_mark[0].i);
		  }
break;
case 192:
#line 1408 "util/lev_comp.y"
	{
		      add_opvars(splev, "ciisiio",
				 VA_PASS7(0, 0, 1, (char *) 0, 0, 0, SPO_MAP));
		      max_x_map = COLNO-1;
		      max_y_map = ROWNO;
		  }
break;
case 193:
#line 1415 "util/lev_comp.y"
	{
		      add_opvars(splev, "cii",
				 VA_PASS3(SP_COORD_PACK((yystack.l_mark[-4].i), (yystack.l_mark[-2].i)),
					  1, (int) yystack.l_mark[-1].i));
		      scan_map(yystack.l_mark[0].map, splev);
		      Free(yystack.l_mark[0].map);
		  }
break;
case 194:
#line 1423 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(2, (int) yystack.l_mark[-1].i));
		      scan_map(yystack.l_mark[0].map, splev);
		      Free(yystack.l_mark[0].map);
		  }
break;
case 199:
#line 1439 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(0, SPO_MONSTER));
		  }
break;
case 200:
#line 1443 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(1, SPO_MONSTER));
		      in_container_obj++;
		      break_stmt_start();
		  }
break;
case 201:
#line 1449 "util/lev_comp.y"
	{
		     break_stmt_end(splev);
		     in_container_obj--;
		     add_opvars(splev, "o", VA_PASS1(SPO_END_MONINVENT));
		 }
break;
case 202:
#line 1457 "util/lev_comp.y"
	{
		      /* nothing */
		  }
break;
case 203:
#line 1463 "util/lev_comp.y"
	{
		      struct opvar *stopit = New(struct opvar);

		      set_opvar_int(stopit, SP_M_V_END);
		      add_opcode(splev, SPO_PUSH, stopit);
		      yyval.i = 0x0000;
		  }
break;
case 204:
#line 1471 "util/lev_comp.y"
	{
		      if (( yystack.l_mark[-2].i & yystack.l_mark[0].i ))
			  lc_error("MONSTER extra info defined twice.");
		      yyval.i = ( yystack.l_mark[-2].i | yystack.l_mark[0].i );
		  }
break;
case 205:
#line 1479 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_M_V_NAME));
		      yyval.i = 0x0001;
		  }
break;
case 206:
#line 1484 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii",
				 VA_PASS2((int) yystack.l_mark[0].i, SP_M_V_PEACEFUL));
		      yyval.i = 0x0002;
		  }
break;
case 207:
#line 1490 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii",
				 VA_PASS2((int) yystack.l_mark[0].i, SP_M_V_ASLEEP));
		      yyval.i = 0x0004;
		  }
break;
case 208:
#line 1496 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii",
				 VA_PASS2((int) yystack.l_mark[0].i, SP_M_V_ALIGN));
		      yyval.i = 0x0008;
		  }
break;
case 209:
#line 1502 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii",
				 VA_PASS2((int) yystack.l_mark[-1].i, SP_M_V_APPEAR));
		      yyval.i = 0x0010;
		  }
break;
case 210:
#line 1508 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_M_V_FEMALE));
		      yyval.i = 0x0020;
		  }
break;
case 211:
#line 1513 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_M_V_INVIS));
		      yyval.i = 0x0040;
		  }
break;
case 212:
#line 1518 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_M_V_CANCELLED));
		      yyval.i = 0x0080;
		  }
break;
case 213:
#line 1523 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_M_V_REVIVED));
		      yyval.i = 0x0100;
		  }
break;
case 214:
#line 1528 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_M_V_AVENGE));
		      yyval.i = 0x0200;
		  }
break;
case 215:
#line 1533 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_M_V_FLEEING));
		      yyval.i = 0x0400;
		  }
break;
case 216:
#line 1538 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_M_V_BLINDED));
		      yyval.i = 0x0800;
		  }
break;
case 217:
#line 1543 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_M_V_PARALYZED));
		      yyval.i = 0x1000;
		  }
break;
case 218:
#line 1548 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_M_V_STUNNED));
		      yyval.i = 0x2000;
		  }
break;
case 219:
#line 1553 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_M_V_CONFUSED));
		      yyval.i = 0x4000;
		  }
break;
case 220:
#line 1558 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii",
				 VA_PASS2((int) yystack.l_mark[0].i, SP_M_V_SEENTRAPS));
		      yyval.i = 0x8000;
		  }
break;
case 221:
#line 1566 "util/lev_comp.y"
	{
		      int token = get_trap_type(yystack.l_mark[0].map);

		      if (token == ERR || token == 0)
			  lc_error("Unknown trap type '%s'!", yystack.l_mark[0].map);
                      Free(yystack.l_mark[0].map);
		      yyval.i = (1L << (token - 1));
		  }
break;
case 222:
#line 1575 "util/lev_comp.y"
	{
		      yyval.i = (long) ~0;
		  }
break;
case 223:
#line 1579 "util/lev_comp.y"
	{
		      int token = get_trap_type(yystack.l_mark[-2].map);
		      if (token == ERR || token == 0)
			  lc_error("Unknown trap type '%s'!", yystack.l_mark[-2].map);

		      if ((1L << (token - 1)) & yystack.l_mark[0].i)
			  lc_error("Monster seen_traps, trap '%s' listed twice.", yystack.l_mark[-2].map);
                      Free(yystack.l_mark[-2].map);
		      yyval.i = ((1L << (token - 1)) | yystack.l_mark[0].i);
		  }
break;
case 224:
#line 1592 "util/lev_comp.y"
	{
		      int cnt = 0;

		      if (in_container_obj)
                          cnt |= SP_OBJ_CONTENT;
		      add_opvars(splev, "io", VA_PASS2(cnt, SPO_OBJECT));
		  }
break;
case 225:
#line 1600 "util/lev_comp.y"
	{
		      int cnt = SP_OBJ_CONTAINER;

		      if (in_container_obj)
                          cnt |= SP_OBJ_CONTENT;
		      add_opvars(splev, "io", VA_PASS2(cnt, SPO_OBJECT));
		      in_container_obj++;
		      break_stmt_start();
		  }
break;
case 226:
#line 1610 "util/lev_comp.y"
	{
		     break_stmt_end(splev);
		     in_container_obj--;
		     add_opcode(splev, SPO_POP_CONTAINER, NULL);
		 }
break;
case 227:
#line 1618 "util/lev_comp.y"
	{
		      if (( yystack.l_mark[0].i & 0x4000) && in_container_obj)
                          lc_error("Object cannot have a coord when contained.");
		      else if (!( yystack.l_mark[0].i & 0x4000) && !in_container_obj)
                          lc_error("Object needs a coord when not contained.");
		  }
break;
case 228:
#line 1627 "util/lev_comp.y"
	{
		      struct opvar *stopit = New(struct opvar);
		      set_opvar_int(stopit, SP_O_V_END);
		      add_opcode(splev, SPO_PUSH, stopit);
		      yyval.i = 0x00;
		  }
break;
case 229:
#line 1634 "util/lev_comp.y"
	{
		      if (( yystack.l_mark[-2].i & yystack.l_mark[0].i ))
			  lc_error("OBJECT extra info '%s' defined twice.", curr_token);
		      yyval.i = ( yystack.l_mark[-2].i | yystack.l_mark[0].i );
		  }
break;
case 230:
#line 1642 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii",
				 VA_PASS2((int) yystack.l_mark[0].i, SP_O_V_CURSE));
		      yyval.i = 0x0001;
		  }
break;
case 231:
#line 1648 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_O_V_CORPSENM));
		      yyval.i = 0x0002;
		  }
break;
case 232:
#line 1653 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_O_V_SPE));
		      yyval.i = 0x0004;
		  }
break;
case 233:
#line 1658 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_O_V_NAME));
		      yyval.i = 0x0008;
		  }
break;
case 234:
#line 1663 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_O_V_QUAN));
		      yyval.i = 0x0010;
		  }
break;
case 235:
#line 1668 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_O_V_BURIED));
		      yyval.i = 0x0020;
		  }
break;
case 236:
#line 1673 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2((int) yystack.l_mark[0].i, SP_O_V_LIT));
		      yyval.i = 0x0040;
		  }
break;
case 237:
#line 1678 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_O_V_ERODED));
		      yyval.i = 0x0080;
		  }
break;
case 238:
#line 1683 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(-1, SP_O_V_ERODED));
		      yyval.i = 0x0080;
		  }
break;
case 239:
#line 1688 "util/lev_comp.y"
	{
		      if (yystack.l_mark[0].i == D_LOCKED) {
			  add_opvars(splev, "ii", VA_PASS2(1, SP_O_V_LOCKED));
			  yyval.i = 0x0100;
		      } else if (yystack.l_mark[0].i == D_BROKEN) {
			  add_opvars(splev, "ii", VA_PASS2(1, SP_O_V_BROKEN));
			  yyval.i = 0x0200;
		      } else
			  lc_error("DOOR state can only be locked or broken.");
		  }
break;
case 240:
#line 1699 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii",
                                 VA_PASS2((int) yystack.l_mark[0].i, SP_O_V_TRAPPED));
		      yyval.i = 0x0400;
		  }
break;
case 241:
#line 1705 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_O_V_RECHARGED));
		      yyval.i = 0x0800;
		  }
break;
case 242:
#line 1710 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_O_V_INVIS));
		      yyval.i = 0x1000;
		  }
break;
case 243:
#line 1715 "util/lev_comp.y"
	{
		      add_opvars(splev, "ii", VA_PASS2(1, SP_O_V_GREASED));
		      yyval.i = 0x2000;
		  }
break;
case 244:
#line 1720 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(SP_O_V_COORD));
		      yyval.i = 0x4000;
		  }
break;
case 245:
#line 1727 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2((int) yystack.l_mark[-2].i, SPO_TRAP));
		  }
break;
case 246:
#line 1733 "util/lev_comp.y"
	{
		       long dir, state = 0;

		       /* convert dir from a DIRECTION to a DB_DIR */
		       dir = yystack.l_mark[-2].i;
		       switch (dir) {
		       case W_NORTH: dir = DB_NORTH; break;
		       case W_SOUTH: dir = DB_SOUTH; break;
		       case W_EAST:  dir = DB_EAST;  break;
		       case W_WEST:  dir = DB_WEST;  break;
		       default:
			   lc_error("Invalid drawbridge direction.");
			   break;
		       }

		       if ( yystack.l_mark[0].i == D_ISOPEN )
			   state = 1;
		       else if ( yystack.l_mark[0].i == D_CLOSED )
			   state = 0;
		       else if ( yystack.l_mark[0].i == -1 )
			   state = -1;
		       else
			   lc_error("A drawbridge can only be open, closed or random!");
		       add_opvars(splev, "iio",
				  VA_PASS3(state, dir, SPO_DRAWBRIDGE));
		   }
break;
case 247:
#line 1762 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiio",
				 VA_PASS4((int) yystack.l_mark[0].i, 1, 0, SPO_MAZEWALK));
		  }
break;
case 248:
#line 1767 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiio",
				 VA_PASS4((int) yystack.l_mark[-3].i, (int) yystack.l_mark[-1].i,
					  (int) yystack.l_mark[0].i, SPO_MAZEWALK));
		  }
break;
case 249:
#line 1775 "util/lev_comp.y"
	{
		      add_opvars(splev, "rio",
				 VA_PASS3(SP_REGION_PACK(-1,-1,-1,-1),
					  0, SPO_WALLIFY));
		  }
break;
case 250:
#line 1781 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(1, SPO_WALLIFY));
		  }
break;
case 251:
#line 1787 "util/lev_comp.y"
	{
		      add_opvars(splev, "io",
				 VA_PASS2((int) yystack.l_mark[0].i, SPO_LADDER));
		  }
break;
case 252:
#line 1794 "util/lev_comp.y"
	{
		      add_opvars(splev, "io",
				 VA_PASS2((int) yystack.l_mark[0].i, SPO_STAIR));
		  }
break;
case 253:
#line 1801 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiii iiiii iiso",
				 VA_PASS14(yystack.l_mark[-4].lregn.x1, yystack.l_mark[-4].lregn.y1, yystack.l_mark[-4].lregn.x2, yystack.l_mark[-4].lregn.y2, yystack.l_mark[-4].lregn.area,
					   yystack.l_mark[-2].lregn.x1, yystack.l_mark[-2].lregn.y1, yystack.l_mark[-2].lregn.x2, yystack.l_mark[-2].lregn.y2, yystack.l_mark[-2].lregn.area,
				     (long) ((yystack.l_mark[0].i) ? LR_UPSTAIR : LR_DOWNSTAIR),
					   0, (char *) 0, SPO_LEVREGION));
		  }
break;
case 254:
#line 1811 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiii iiiii iiso",
				 VA_PASS14(yystack.l_mark[-4].lregn.x1, yystack.l_mark[-4].lregn.y1, yystack.l_mark[-4].lregn.x2, yystack.l_mark[-4].lregn.y2, yystack.l_mark[-4].lregn.area,
					   yystack.l_mark[-2].lregn.x1, yystack.l_mark[-2].lregn.y1, yystack.l_mark[-2].lregn.x2, yystack.l_mark[-2].lregn.y2, yystack.l_mark[-2].lregn.area,
					   LR_PORTAL, 0, yystack.l_mark[0].map, SPO_LEVREGION));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 255:
#line 1821 "util/lev_comp.y"
	{
		      long rtyp = 0;
		      switch(yystack.l_mark[0].i) {
		      case -1: rtyp = LR_TELE; break;
		      case  0: rtyp = LR_DOWNTELE; break;
		      case  1: rtyp = LR_UPTELE; break;
		      }
		      add_opvars(splev, "iiiii iiiii iiso",
				 VA_PASS14(yystack.l_mark[-3].lregn.x1, yystack.l_mark[-3].lregn.y1, yystack.l_mark[-3].lregn.x2, yystack.l_mark[-3].lregn.y2, yystack.l_mark[-3].lregn.area,
					   yystack.l_mark[-1].lregn.x1, yystack.l_mark[-1].lregn.y1, yystack.l_mark[-1].lregn.x2, yystack.l_mark[-1].lregn.y2, yystack.l_mark[-1].lregn.area,
					   rtyp, 0, (char *)0, SPO_LEVREGION));
		  }
break;
case 256:
#line 1836 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiii iiiii iiso",
				 VA_PASS14(yystack.l_mark[-2].lregn.x1, yystack.l_mark[-2].lregn.y1, yystack.l_mark[-2].lregn.x2, yystack.l_mark[-2].lregn.y2, yystack.l_mark[-2].lregn.area,
					   yystack.l_mark[0].lregn.x1, yystack.l_mark[0].lregn.y1, yystack.l_mark[0].lregn.x2, yystack.l_mark[0].lregn.y2, yystack.l_mark[0].lregn.area,
					   (long) LR_BRANCH, 0,
					   (char *) 0, SPO_LEVREGION));
		  }
break;
case 257:
#line 1846 "util/lev_comp.y"
	{
			yyval.i = -1;
		  }
break;
case 258:
#line 1850 "util/lev_comp.y"
	{
			yyval.i = yystack.l_mark[0].i;
		  }
break;
case 259:
#line 1856 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_FOUNTAIN));
		  }
break;
case 260:
#line 1862 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SINK));
		  }
break;
case 261:
#line 1868 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_POOL));
		  }
break;
case 262:
#line 1874 "util/lev_comp.y"
	{
		      yyval.terr.lit = -2;
		      yyval.terr.ter = what_map_char((char) yystack.l_mark[0].i);
		  }
break;
case 263:
#line 1879 "util/lev_comp.y"
	{
		      yyval.terr.lit = yystack.l_mark[-1].i;
		      yyval.terr.ter = what_map_char((char) yystack.l_mark[-3].i);
		  }
break;
case 264:
#line 1886 "util/lev_comp.y"
	{
		      add_opvars(splev, "io",
				 VA_PASS2(yystack.l_mark[0].i, SPO_REPLACETERRAIN));
		  }
break;
case 265:
#line 1893 "util/lev_comp.y"
	{
		     add_opvars(splev, "o", VA_PASS1(SPO_TERRAIN));
		 }
break;
case 266:
#line 1899 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_NON_DIGGABLE));
		  }
break;
case 267:
#line 1905 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_NON_PASSWALL));
		  }
break;
case 268:
#line 1911 "util/lev_comp.y"
	{
		      long irr;
		      long rt = yystack.l_mark[-1].i;
		      long rflags = yystack.l_mark[0].i;

		      if (rflags == -1) rflags = (1 << 0);
		      if (!(rflags & 1)) rt += MAXRTYPE+1;
		      irr = ((rflags & 2) != 0);
		      add_opvars(splev, "iiio",
				 VA_PASS4((long)yystack.l_mark[-3].i, rt, rflags, SPO_REGION));
		      yyval.i = (irr || (rflags & 1) || rt != OROOM);
		      break_stmt_start();
		  }
break;
case 269:
#line 1925 "util/lev_comp.y"
	{
		      break_stmt_end(splev);
		      if ( yystack.l_mark[-1].i ) {
			  add_opcode(splev, SPO_ENDROOM, NULL);
		      } else if ( yystack.l_mark[0].i )
			  lc_error("Cannot use lev statements in non-permanent REGION");
		  }
break;
case 270:
#line 1935 "util/lev_comp.y"
	{
		      yyval.i = 0;
		  }
break;
case 271:
#line 1939 "util/lev_comp.y"
	{
		      yyval.i = yystack.l_mark[0].i;
		  }
break;
case 272:
#line 1945 "util/lev_comp.y"
	{
		      add_opvars(splev, "iio",
				 VA_PASS3((long)yystack.l_mark[0].i, (long)yystack.l_mark[-2].i, SPO_ALTAR));
		  }
break;
case 273:
#line 1952 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(2, SPO_GRAVE));
		  }
break;
case 274:
#line 1956 "util/lev_comp.y"
	{
		      add_opvars(splev, "sio",
				 VA_PASS3((char *)0, 1, SPO_GRAVE));
		  }
break;
case 275:
#line 1961 "util/lev_comp.y"
	{
		      add_opvars(splev, "sio",
				 VA_PASS3((char *)0, 0, SPO_GRAVE));
		  }
break;
case 276:
#line 1968 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_GOLD));
		  }
break;
case 277:
#line 1974 "util/lev_comp.y"
	{
		      add_opvars(splev, "io",
				 VA_PASS2((long)yystack.l_mark[-2].i, SPO_ENGRAVING));
		  }
break;
case 278:
#line 1981 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_MINERALIZE));
		  }
break;
case 279:
#line 1985 "util/lev_comp.y"
	{
		      add_opvars(splev, "iiiio",
				 VA_PASS5(-1L, -1L, -1L, -1L, SPO_MINERALIZE));
		  }
break;
case 280:
#line 1992 "util/lev_comp.y"
	{
			int token = get_trap_type(yystack.l_mark[0].map);
			if (token == ERR)
			    lc_error("Unknown trap type '%s'!", yystack.l_mark[0].map);
			yyval.i = token;
			Free(yystack.l_mark[0].map);
		  }
break;
case 282:
#line 2003 "util/lev_comp.y"
	{
			int token = get_room_type(yystack.l_mark[0].map);
			if (token == ERR) {
			    lc_warning("Unknown room type \"%s\"!  Making ordinary room...", yystack.l_mark[0].map);
				yyval.i = OROOM;
			} else
				yyval.i = token;
			Free(yystack.l_mark[0].map);
		  }
break;
case 284:
#line 2016 "util/lev_comp.y"
	{
			yyval.i = -1;
		  }
break;
case 285:
#line 2020 "util/lev_comp.y"
	{
			yyval.i = yystack.l_mark[0].i;
		  }
break;
case 286:
#line 2026 "util/lev_comp.y"
	{
			yyval.i = yystack.l_mark[0].i;
		  }
break;
case 287:
#line 2030 "util/lev_comp.y"
	{
			yyval.i = yystack.l_mark[-2].i | yystack.l_mark[0].i;
		  }
break;
case 288:
#line 2037 "util/lev_comp.y"
	{
		      yyval.i = (yystack.l_mark[0].i << 0);
		  }
break;
case 289:
#line 2041 "util/lev_comp.y"
	{
		      yyval.i = (yystack.l_mark[0].i << 1);
		  }
break;
case 290:
#line 2045 "util/lev_comp.y"
	{
		      yyval.i = (yystack.l_mark[0].i << 2);
		  }
break;
case 297:
#line 2061 "util/lev_comp.y"
	{
			yyval.i = - MAX_REGISTERS - 1;
		  }
break;
case 300:
#line 2069 "util/lev_comp.y"
	{
			yyval.i = - MAX_REGISTERS - 1;
		  }
break;
case 303:
#line 2079 "util/lev_comp.y"
	{
			if ( yystack.l_mark[-1].i >= 3 )
				lc_error("Register Index overflow!");
			else
				yyval.i = - yystack.l_mark[-1].i - 1;
		  }
break;
case 304:
#line 2088 "util/lev_comp.y"
	{
		      add_opvars(splev, "s", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 305:
#line 2093 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[0].map, SPOVAR_STRING);
		      vardef_used(vardefs, yystack.l_mark[0].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 306:
#line 2100 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[-3].map,
                                        SPOVAR_STRING | SPOVAR_ARRAY);
		      vardef_used(vardefs, yystack.l_mark[-3].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[-3].map));
		      Free(yystack.l_mark[-3].map);
		  }
break;
case 307:
#line 2111 "util/lev_comp.y"
	{
		      /* nothing */
		  }
break;
case 308:
#line 2117 "util/lev_comp.y"
	{
		      add_opvars(splev, "c", VA_PASS1(yystack.l_mark[0].i));
		  }
break;
case 309:
#line 2121 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_RNDCOORD));
		  }
break;
case 310:
#line 2125 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[0].map, SPOVAR_COORD);
		      vardef_used(vardefs, yystack.l_mark[0].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 311:
#line 2132 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[-3].map,
                                        SPOVAR_COORD | SPOVAR_ARRAY);
		      vardef_used(vardefs, yystack.l_mark[-3].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[-3].map));
		      Free(yystack.l_mark[-3].map);
		  }
break;
case 312:
#line 2142 "util/lev_comp.y"
	{
		      if (yystack.l_mark[-3].i < 0 || yystack.l_mark[-1].i < 0 || yystack.l_mark[-3].i >= COLNO || yystack.l_mark[-1].i >= ROWNO)
                          lc_error("Coordinates (%li,%li) out of map range!",
                                   yystack.l_mark[-3].i, yystack.l_mark[-1].i);
		      yyval.i = SP_COORD_PACK(yystack.l_mark[-3].i, yystack.l_mark[-1].i);
		  }
break;
case 313:
#line 2149 "util/lev_comp.y"
	{
		      yyval.i = SP_COORD_PACK_RANDOM(0);
		  }
break;
case 314:
#line 2153 "util/lev_comp.y"
	{
		      yyval.i = SP_COORD_PACK_RANDOM(yystack.l_mark[-1].i);
		  }
break;
case 315:
#line 2159 "util/lev_comp.y"
	{
		      yyval.i = yystack.l_mark[0].i;
		  }
break;
case 316:
#line 2163 "util/lev_comp.y"
	{
		      if ((yystack.l_mark[-2].i & yystack.l_mark[0].i))
			  lc_warning("Humidity flag used twice.");
		      yyval.i = (yystack.l_mark[-2].i | yystack.l_mark[0].i);
		  }
break;
case 317:
#line 2171 "util/lev_comp.y"
	{
		      /* nothing */
		  }
break;
case 318:
#line 2175 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[0].map, SPOVAR_REGION);
		      vardef_used(vardefs, yystack.l_mark[0].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 319:
#line 2182 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[-3].map,
                                        SPOVAR_REGION | SPOVAR_ARRAY);
		      vardef_used(vardefs, yystack.l_mark[-3].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[-3].map));
		      Free(yystack.l_mark[-3].map);
		  }
break;
case 320:
#line 2192 "util/lev_comp.y"
	{
		      long r = SP_REGION_PACK(yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);

		      if (yystack.l_mark[-7].i > yystack.l_mark[-3].i || yystack.l_mark[-5].i > yystack.l_mark[-1].i)
			  lc_error("Region start > end: (%ld,%ld,%ld,%ld)!",
                                   yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);

		      add_opvars(splev, "r", VA_PASS1(r));
		      yyval.i = r;
		  }
break;
case 321:
#line 2205 "util/lev_comp.y"
	{
		      add_opvars(splev, "m", VA_PASS1(yystack.l_mark[0].i));
		  }
break;
case 322:
#line 2209 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[0].map, SPOVAR_MAPCHAR);
		      vardef_used(vardefs, yystack.l_mark[0].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 323:
#line 2216 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[-3].map,
                                        SPOVAR_MAPCHAR | SPOVAR_ARRAY);
		      vardef_used(vardefs, yystack.l_mark[-3].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[-3].map));
		      Free(yystack.l_mark[-3].map);
		  }
break;
case 324:
#line 2226 "util/lev_comp.y"
	{
		      if (what_map_char((char) yystack.l_mark[0].i) != INVALID_TYPE)
			  yyval.i = SP_MAPCHAR_PACK(what_map_char((char) yystack.l_mark[0].i), -2);
		      else {
			  lc_error("Unknown map char type '%c'!", yystack.l_mark[0].i);
			  yyval.i = SP_MAPCHAR_PACK(STONE, -2);
		      }
		  }
break;
case 325:
#line 2235 "util/lev_comp.y"
	{
		      if (what_map_char((char) yystack.l_mark[-3].i) != INVALID_TYPE)
			  yyval.i = SP_MAPCHAR_PACK(what_map_char((char) yystack.l_mark[-3].i), yystack.l_mark[-1].i);
		      else {
			  lc_error("Unknown map char type '%c'!", yystack.l_mark[-3].i);
			  yyval.i = SP_MAPCHAR_PACK(STONE, yystack.l_mark[-1].i);
		      }
		  }
break;
case 326:
#line 2246 "util/lev_comp.y"
	{
		      add_opvars(splev, "M", VA_PASS1(yystack.l_mark[0].i));
		  }
break;
case 327:
#line 2250 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[0].map, SPOVAR_MONST);
		      vardef_used(vardefs, yystack.l_mark[0].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 328:
#line 2257 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[-3].map,
                                        SPOVAR_MONST | SPOVAR_ARRAY);
		      vardef_used(vardefs, yystack.l_mark[-3].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[-3].map));
		      Free(yystack.l_mark[-3].map);
		  }
break;
case 329:
#line 2267 "util/lev_comp.y"
	{
                      long m = get_monster_id(yystack.l_mark[0].map, (char)0);
                      if (m == ERR) {
                          lc_error("Unknown monster \"%s\"!", yystack.l_mark[0].map);
                          yyval.i = -1;
                      } else
                          yyval.i = SP_MONST_PACK(m,
                                         def_monsyms[(int) mons[m].mlet].sym);
                      Free(yystack.l_mark[0].map);
                  }
break;
case 330:
#line 2278 "util/lev_comp.y"
	{
                        if (check_monster_char((char) yystack.l_mark[0].i))
                            yyval.i = SP_MONST_PACK(-1, yystack.l_mark[0].i);
                        else {
                            lc_error("Unknown monster class '%c'!", yystack.l_mark[0].i);
                            yyval.i = -1;
                        }
                  }
break;
case 331:
#line 2287 "util/lev_comp.y"
	{
                      long m = get_monster_id(yystack.l_mark[-1].map, (char) yystack.l_mark[-3].i);
                      if (m == ERR) {
                          lc_error("Unknown monster ('%c', \"%s\")!", yystack.l_mark[-3].i, yystack.l_mark[-1].map);
                          yyval.i = -1;
                      } else
                          yyval.i = SP_MONST_PACK(m, yystack.l_mark[-3].i);
                      Free(yystack.l_mark[-1].map);
                  }
break;
case 332:
#line 2297 "util/lev_comp.y"
	{
                      yyval.i = -1;
                  }
break;
case 333:
#line 2303 "util/lev_comp.y"
	{
		      add_opvars(splev, "O", VA_PASS1(yystack.l_mark[0].i));
		  }
break;
case 334:
#line 2307 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[0].map, SPOVAR_OBJ);
		      vardef_used(vardefs, yystack.l_mark[0].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 335:
#line 2314 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[-3].map,
                                        SPOVAR_OBJ | SPOVAR_ARRAY);
		      vardef_used(vardefs, yystack.l_mark[-3].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[-3].map));
		      Free(yystack.l_mark[-3].map);
		  }
break;
case 336:
#line 2324 "util/lev_comp.y"
	{
		      long m = get_object_id(yystack.l_mark[0].map, (char)0);
		      if (m == ERR) {
			  lc_error("Unknown object \"%s\"!", yystack.l_mark[0].map);
			  yyval.i = -1;
		      } else
                          /* obj class != 0 to force generation of a specific item */
                          yyval.i = SP_OBJ_PACK(m, 1);
                      Free(yystack.l_mark[0].map);
		  }
break;
case 337:
#line 2335 "util/lev_comp.y"
	{
			if (check_object_char((char) yystack.l_mark[0].i))
			    yyval.i = SP_OBJ_PACK(-1, yystack.l_mark[0].i);
			else {
			    lc_error("Unknown object class '%c'!", yystack.l_mark[0].i);
			    yyval.i = -1;
			}
		  }
break;
case 338:
#line 2344 "util/lev_comp.y"
	{
		      long m = get_object_id(yystack.l_mark[-1].map, (char) yystack.l_mark[-3].i);
		      if (m == ERR) {
			  lc_error("Unknown object ('%c', \"%s\")!", yystack.l_mark[-3].i, yystack.l_mark[-1].map);
			  yyval.i = -1;
		      } else
			  yyval.i = SP_OBJ_PACK(m, yystack.l_mark[-3].i);
                      Free(yystack.l_mark[-1].map);
		  }
break;
case 339:
#line 2354 "util/lev_comp.y"
	{
		      yyval.i = -1;
		  }
break;
case 340:
#line 2360 "util/lev_comp.y"
	{ }
break;
case 341:
#line 2362 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_MATH_ADD));
		  }
break;
case 342:
#line 2368 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(yystack.l_mark[0].i));
		  }
break;
case 343:
#line 2372 "util/lev_comp.y"
	{
		      is_inconstant_number = 1;
		  }
break;
case 344:
#line 2376 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(yystack.l_mark[-1].i));
		  }
break;
case 345:
#line 2380 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[0].map, SPOVAR_INT);
		      vardef_used(vardefs, yystack.l_mark[0].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		      is_inconstant_number = 1;
		  }
break;
case 346:
#line 2388 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[-3].map,
					SPOVAR_INT | SPOVAR_ARRAY);
		      vardef_used(vardefs, yystack.l_mark[-3].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[-3].map));
		      Free(yystack.l_mark[-3].map);
		      is_inconstant_number = 1;
		  }
break;
case 347:
#line 2397 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_MATH_ADD));
		  }
break;
case 348:
#line 2401 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_MATH_SUB));
		  }
break;
case 349:
#line 2405 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_MATH_MUL));
		  }
break;
case 350:
#line 2409 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_MATH_DIV));
		  }
break;
case 351:
#line 2413 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_MATH_MOD));
		  }
break;
case 352:
#line 2416 "util/lev_comp.y"
	{ }
break;
case 353:
#line 2420 "util/lev_comp.y"
	{
		      if (!strcmp("int", yystack.l_mark[0].map) || !strcmp("integer", yystack.l_mark[0].map)) {
			  yyval.i = (int)'i';
		      } else
			  lc_error("Unknown function parameter type '%s'", yystack.l_mark[0].map);
		  }
break;
case 354:
#line 2427 "util/lev_comp.y"
	{
		      if (!strcmp("str", yystack.l_mark[0].map) || !strcmp("string", yystack.l_mark[0].map)) {
			  yyval.i = (int)'s';
		      } else
			  lc_error("Unknown function parameter type '%s'", yystack.l_mark[0].map);
		  }
break;
case 355:
#line 2436 "util/lev_comp.y"
	{
		      struct lc_funcdefs_parm *tmp = New(struct lc_funcdefs_parm);

		      if (!curr_function) {
			  lc_error("Function parameters outside function definition.");
		      } else if (!tmp) {
			  lc_error("Could not alloc function params.");
		      } else {
			  long vt = SPOVAR_NULL;

			  tmp->name = strdup(yystack.l_mark[-2].map);
			  tmp->parmtype = (char) yystack.l_mark[0].i;
			  tmp->next = curr_function->params;
			  curr_function->params = tmp;
			  curr_function->n_params++;
			  switch (tmp->parmtype) {
			  case 'i':
                              vt = SPOVAR_INT;
                              break;
			  case 's':
                              vt = SPOVAR_STRING;
                              break;
			  default:
                              lc_error("Unknown func param conversion.");
                              break;
			  }
			  vardefs = add_vardef_type( vardefs, yystack.l_mark[-2].map, vt);
		      }
		      Free(yystack.l_mark[-2].map);
		  }
break;
case 360:
#line 2477 "util/lev_comp.y"
	{
			      yyval.i = (int)'i';
			  }
break;
case 361:
#line 2481 "util/lev_comp.y"
	{
			      yyval.i = (int)'s';
			  }
break;
case 362:
#line 2488 "util/lev_comp.y"
	{
			      char tmpbuf[2];
			      tmpbuf[0] = (char) yystack.l_mark[0].i;
			      tmpbuf[1] = '\0';
			      yyval.map = strdup(tmpbuf);
			  }
break;
case 363:
#line 2495 "util/lev_comp.y"
	{
			      long len = strlen( yystack.l_mark[-2].map );
			      char *tmp = (char *) alloc(len + 2);
			      sprintf(tmp, "%c%s", (char) yystack.l_mark[0].i, yystack.l_mark[-2].map );
			      Free( yystack.l_mark[-2].map );
			      yyval.map = tmp;
			  }
break;
case 364:
#line 2505 "util/lev_comp.y"
	{
			      yyval.map = strdup("");
			  }
break;
case 365:
#line 2509 "util/lev_comp.y"
	{
			      char *tmp = strdup( yystack.l_mark[0].map );
			      Free( yystack.l_mark[0].map );
			      yyval.map = tmp;
			  }
break;
case 366:
#line 2517 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_POINT));
		  }
break;
case 367:
#line 2521 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_RECT));
		  }
break;
case 368:
#line 2525 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_FILLRECT));
		  }
break;
case 369:
#line 2529 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_LINE));
		  }
break;
case 370:
#line 2533 "util/lev_comp.y"
	{
		      /* randline (x1,y1),(x2,y2), roughness */
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_RNDLINE));
		  }
break;
case 371:
#line 2538 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(W_ANY, SPO_SEL_GROW));
		  }
break;
case 372:
#line 2542 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(yystack.l_mark[-3].i, SPO_SEL_GROW));
		  }
break;
case 373:
#line 2546 "util/lev_comp.y"
	{
		      add_opvars(splev, "iio",
			     VA_PASS3(yystack.l_mark[-3].i, SPOFILTER_PERCENT, SPO_SEL_FILTER));
		  }
break;
case 374:
#line 2551 "util/lev_comp.y"
	{
		      add_opvars(splev, "io",
			       VA_PASS2(SPOFILTER_SELECTION, SPO_SEL_FILTER));
		  }
break;
case 375:
#line 2556 "util/lev_comp.y"
	{
		      add_opvars(splev, "io",
				 VA_PASS2(SPOFILTER_MAPCHAR, SPO_SEL_FILTER));
		  }
break;
case 376:
#line 2561 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_FLOOD));
		  }
break;
case 377:
#line 2565 "util/lev_comp.y"
	{
		      add_opvars(splev, "oio",
				 VA_PASS3(SPO_COPY, 1, SPO_SEL_ELLIPSE));
		  }
break;
case 378:
#line 2570 "util/lev_comp.y"
	{
		      add_opvars(splev, "oio",
				 VA_PASS3(SPO_COPY, yystack.l_mark[-1].i, SPO_SEL_ELLIPSE));
		  }
break;
case 379:
#line 2575 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(1, SPO_SEL_ELLIPSE));
		  }
break;
case 380:
#line 2579 "util/lev_comp.y"
	{
		      add_opvars(splev, "io", VA_PASS2(yystack.l_mark[-1].i, SPO_SEL_ELLIPSE));
		  }
break;
case 381:
#line 2583 "util/lev_comp.y"
	{
		      add_opvars(splev, "iio",
				 VA_PASS3(yystack.l_mark[-5].i, yystack.l_mark[-11].i, SPO_SEL_GRADIENT));
		  }
break;
case 382:
#line 2588 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_COMPLEMENT));
		  }
break;
case 383:
#line 2592 "util/lev_comp.y"
	{
		      check_vardef_type(vardefs, yystack.l_mark[0].map, SPOVAR_SEL);
		      vardef_used(vardefs, yystack.l_mark[0].map);
		      add_opvars(splev, "v", VA_PASS1(yystack.l_mark[0].map));
		      Free(yystack.l_mark[0].map);
		  }
break;
case 384:
#line 2599 "util/lev_comp.y"
	{
		      /* nothing */
		  }
break;
case 385:
#line 2605 "util/lev_comp.y"
	{
		      /* nothing */
		  }
break;
case 386:
#line 2609 "util/lev_comp.y"
	{
		      add_opvars(splev, "o", VA_PASS1(SPO_SEL_ADD));
		  }
break;
case 387:
#line 2615 "util/lev_comp.y"
	{
		      add_opvars(splev, "iio",
				 VA_PASS3(yystack.l_mark[0].dice.num, yystack.l_mark[0].dice.die, SPO_DICE));
		  }
break;
case 391:
#line 2627 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(yystack.l_mark[0].i));
		  }
break;
case 392:
#line 2631 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(yystack.l_mark[0].i));
		  }
break;
case 393:
#line 2635 "util/lev_comp.y"
	{
		      add_opvars(splev, "i", VA_PASS1(yystack.l_mark[0].i));
		  }
break;
case 394:
#line 2639 "util/lev_comp.y"
	{
		      /* nothing */
		  }
break;
case 403:
#line 2661 "util/lev_comp.y"
	{
			yyval.lregn = yystack.l_mark[0].lregn;
		  }
break;
case 404:
#line 2665 "util/lev_comp.y"
	{
			if (yystack.l_mark[-7].i <= 0 || yystack.l_mark[-7].i >= COLNO)
			    lc_error(
                          "Region (%ld,%ld,%ld,%ld) out of level range (x1)!",
                                     yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			else if (yystack.l_mark[-5].i < 0 || yystack.l_mark[-5].i >= ROWNO)
			    lc_error(
                          "Region (%ld,%ld,%ld,%ld) out of level range (y1)!",
                                     yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			else if (yystack.l_mark[-3].i <= 0 || yystack.l_mark[-3].i >= COLNO)
			    lc_error(
                          "Region (%ld,%ld,%ld,%ld) out of level range (x2)!",
                                     yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			else if (yystack.l_mark[-1].i < 0 || yystack.l_mark[-1].i >= ROWNO)
			    lc_error(
                          "Region (%ld,%ld,%ld,%ld) out of level range (y2)!",
                                     yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			yyval.lregn.x1 = yystack.l_mark[-7].i;
			yyval.lregn.y1 = yystack.l_mark[-5].i;
			yyval.lregn.x2 = yystack.l_mark[-3].i;
			yyval.lregn.y2 = yystack.l_mark[-1].i;
			yyval.lregn.area = 1;
		  }
break;
case 405:
#line 2691 "util/lev_comp.y"
	{
/* This series of if statements is a hack for MSC 5.1.  It seems that its
   tiny little brain cannot compile if these are all one big if statement. */
			if (yystack.l_mark[-7].i < 0 || yystack.l_mark[-7].i > (int) max_x_map)
			    lc_error(
                            "Region (%ld,%ld,%ld,%ld) out of map range (x1)!",
                                     yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			else if (yystack.l_mark[-5].i < 0 || yystack.l_mark[-5].i > (int) max_y_map)
			    lc_error(
                            "Region (%ld,%ld,%ld,%ld) out of map range (y1)!",
                                     yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			else if (yystack.l_mark[-3].i < 0 || yystack.l_mark[-3].i > (int) max_x_map)
			    lc_error(
                            "Region (%ld,%ld,%ld,%ld) out of map range (x2)!",
                                     yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			else if (yystack.l_mark[-1].i < 0 || yystack.l_mark[-1].i > (int) max_y_map)
			    lc_error(
                            "Region (%ld,%ld,%ld,%ld) out of map range (y2)!",
                                     yystack.l_mark[-7].i, yystack.l_mark[-5].i, yystack.l_mark[-3].i, yystack.l_mark[-1].i);
			yyval.lregn.area = 0;
			yyval.lregn.x1 = yystack.l_mark[-7].i;
			yyval.lregn.y1 = yystack.l_mark[-5].i;
			yyval.lregn.x2 = yystack.l_mark[-3].i;
			yyval.lregn.y2 = yystack.l_mark[-1].i;
		  }
break;
#line 5369 ""
    }
    yystack.s_mark -= yym;
    yystate = *yystack.s_mark;
    yystack.l_mark -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
#endif
        yystate = YYFINAL;
        *++yystack.s_mark = YYFINAL;
        *++yystack.l_mark = yyval;
        if (yychar < 0)
        {
            if ((yychar = YYLEX) < 0) yychar = YYEOF;
#if YYDEBUG
            if (yydebug)
            {
                yys = yyname[YYTRANSLATE(yychar)];
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == YYEOF) goto yyaccept;
        goto yyloop;
    }
    if ((yyn = yygindex[yym]) != 0 && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yystack.s_mark, yystate);
#endif
    if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
    {
        goto yyoverflow;
    }
    *++yystack.s_mark = (YYINT) yystate;
    *++yystack.l_mark = yyval;
    goto yyloop;

yyoverflow:
    YYERROR_CALL("yacc stack overflow");

yyabort:
    yyfreestack(&yystack);
    return (1);

yyaccept:
    yyfreestack(&yystack);
    return (0);
}
