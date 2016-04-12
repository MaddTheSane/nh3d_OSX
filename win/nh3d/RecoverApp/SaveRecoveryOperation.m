//
//  SaveRecoveryOperation.m
//  NetHackCocoa
//
//  Created by C.W. Betts on 12/10/15.
//  Copyright © 2015 Dirk Zimmermann. All rights reserved.
//

#include "C99Bool.h"
#import "SaveRecoveryOperation.h"

/*
 *  Utility for reconstructing NetHack save file from a set of individual
 *  level files.  Requires that the `checkpoint' option be enabled at the
 *  time NetHack creates those level files.
 */
#include "config.h"
#include <fcntl.h>
#include <limits.h>
#include <stdbool.h>
#include <stdio.h>

NSString * const NHRecoveryErrorDomain = @"net.hack.cocoa.recover.error";

@interface SaveRecoveryOperation ()
- (void)setLevelFileName:(int)lev;
- (int)openLevelFile:(int)lev;
- (int)createSaveFile;
@end

#define set_levelfile_name(first) [self setLevelFileName: first ]
#define open_levelfile(first) [self openLevelFile: first ]
#define create_savefile() [self createSaveFile] 
static BOOL copy_bytes(int ifd, int ofd);

#define Fprintf	(void)fprintf
#define Close	(void)close

#ifdef UNIX
#define SAVESIZE	(PL_NSIZ + 13)	/* save/99999player.e */
#else
# ifdef VMS
#define SAVESIZE	(PL_NSIZ + 22)	/* [.save]<uid>player.e;1 */
# else
#  ifdef WIN32
#define SAVESIZE	(PL_NSIZ + 40)  /* username-player.NetHack-saved-game */
#  else
#define SAVESIZE	FILENAME	/* from macconf.h or pcconf.h */
#  endif
# endif
#endif


@implementation SaveRecoveryOperation
{
@private
	char savename[SAVESIZE];
	char lock[PATH_MAX];
	NSURL *baseURL;
}

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if ([NSError respondsToSelector:@selector(setUserInfoValueProviderForDomain:provider:)]) {
			[NSError setUserInfoValueProviderForDomain:NHRecoveryErrorDomain provider:^id _Nullable(NSError * _Nonnull err, NSString * _Nonnull userInfoKey) {
				
				if ([userInfoKey isEqualToString:NSLocalizedFailureReasonErrorKey]) {
					if (err.code == NHRecoveryErrorHostBundleNotFound) {
						return @"The recovery app wasn't in NetHack's resource directory.";
					}
				}
				
				if ([userInfoKey isEqualToString:NSLocalizedDescriptionKey]) {
					switch (err.code) {
						case NHRecoveryErrorHostBundleNotFound:
							return @"The parent NetHack application could not be found";
							break;
							
						case NHRecoveryErrorFileCopy:
							return @"Error copying data";
							break;
							
						default:
							break;
					}
				}
				return nil;
			}];
		}
	});
}

- (instancetype)init
{
	return nil;
}

- (instancetype)initWithSaveFileURL:(NSURL*)saveURL
{
	if (self = [super init]) {
		baseURL = saveURL;
		
		if ([self respondsToSelector:@selector(setName:)]) {
			self.name = saveURL.lastPathComponent;
		}
	}
	return self;
}

- (void)main
{
	int gfd, lfd, sfd;
	int lev, savelev, hpid, pltmpsiz;
	xchar levc;
	struct version_info version_data;
	struct savefile_info sfi;
	char plbuf[PL_NSIZ];
	const char *basename = [baseURL fileSystemRepresentation];
	NSString *errStr;
	
	/* level 0 file contains:
	 *	pid of creating process (ignored here)
	 *	level number for current level of save file
	 *	name of save file nethack would have created
	 *	and game state
	 */
	(void) strcpy(lock, basename);
	gfd = open_levelfile(0);
	if (gfd < 0) {
		errStr = [[NSString alloc] initWithFormat:@"Cannot open level 0 for %s.", basename];
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorCannotOpenLevel0 userInfo:@{NSLocalizedDescriptionKey: errStr}];
		return;
	}
	if (read(gfd, (genericptr_t) &hpid, sizeof hpid) != sizeof hpid) {
		errStr = [[NSString alloc] initWithFormat:@"Checkpoint data incompletely "
				  "written or subsequently clobbered;\n"
				  "recovery for \"%s\" impossible.", basename];
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorIncompleteCheckpointData userInfo:@{NSLocalizedDescriptionKey: errStr}];

		Close(gfd);
		return;
	}
	if (read(gfd, (genericptr_t) &savelev, sizeof(savelev))
		!= sizeof(savelev)) {
		errStr = [[NSString alloc] initWithFormat:@"Checkpointing was not in effect for %s -- recovery impossible.",
				basename];
		Close(gfd);
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorCheckpointNotInEffect userInfo:@{NSLocalizedDescriptionKey: errStr}];
		return;
	}
	if ((read(gfd, (genericptr_t) savename, sizeof savename)
		 != sizeof savename)
		|| (read(gfd, (genericptr_t) &version_data, sizeof version_data)
			!= sizeof version_data)
		|| (read(gfd, (genericptr_t) &sfi, sizeof sfi) != sizeof sfi)
		|| (read(gfd, (genericptr_t) &pltmpsiz, sizeof pltmpsiz)
			!= sizeof pltmpsiz) || (pltmpsiz > PL_NSIZ)
		|| (read(gfd, (genericptr_t) &plbuf, pltmpsiz) != pltmpsiz)) {
			errStr = [[NSString alloc] initWithFormat:@"Error reading %s -- can't recover.", lock];
			Close(gfd);
			_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorReading userInfo:@{NSLocalizedDescriptionKey: errStr}];
			return;
		}
	
	/* save file should contain:
	 *	version info
	 *	savefile info
	 *	player name
	 *	current level (including pets)
	 *	(non-level-based) game state
	 *	other levels
	 */
	sfd = create_savefile();
	if (sfd < 0) {
		errStr = [[NSString alloc] initWithFormat:@"Cannot create savefile %s.", savename];
		Close(gfd);
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorCannotCreateSave userInfo:@{NSLocalizedDescriptionKey: errStr}];
		return;
	}
	
	lfd = open_levelfile(savelev);
	if (lfd < 0) {
		errStr = [[NSString alloc] initWithFormat:@"Cannot open level of save for %s.", basename];
		Close(gfd);
		Close(sfd);
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorCannotOpenLevel userInfo:@{NSLocalizedDescriptionKey: errStr}];
		return;
	}
	
	if (write(sfd, (genericptr_t) &version_data, sizeof version_data)
		!= sizeof version_data) {
		errStr = [[NSString alloc] initWithFormat:@"Error writing %s; recovery failed.", savename];
		Close(gfd);
		Close(sfd);
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorWriting userInfo:@{NSLocalizedDescriptionKey: errStr}];
		return;
	}
	
	if (write(sfd, (genericptr_t) &sfi, sizeof sfi) != sizeof sfi) {
		errStr = [[NSString alloc] initWithFormat:@"Error writing %s; recovery failed (savefile_info).", savename];
		Close(gfd);
		Close(sfd);
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorWriting userInfo:@{NSLocalizedDescriptionKey: errStr}];
		return;
	}
	
	if (write(sfd, (genericptr_t) &pltmpsiz, sizeof pltmpsiz)
		!= sizeof pltmpsiz) {
		errStr = [[NSString alloc] initWithFormat:@"Error writing %s; recovery failed (player name size).", savename];
		Close(gfd);
		Close(sfd);
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorWriting userInfo:@{NSLocalizedDescriptionKey: errStr}];
		return;
	}
	
	if (write(sfd, (genericptr_t) &plbuf, pltmpsiz) != pltmpsiz) {
		errStr = [[NSString alloc] initWithFormat:@"Error writing %s; recovery failed (player name).", savename];
		Close(gfd);
		Close(sfd);
		_error = [[NSError alloc] initWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorWriting userInfo:@{NSLocalizedDescriptionKey: errStr}];
		return;
	}
	
	if (!copy_bytes(lfd, sfd)) {
		Close(gfd);
		Close(sfd);
		Close(lfd);
		(void) unlink(lock);
		_error = [NSError errorWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorFileCopy userInfo:nil];
		return;
	}
	Close(lfd);
	(void) unlink(lock);
	
	if (!copy_bytes(gfd, sfd)) {
		Close(gfd);
		Close(sfd);
		(void) unlink(lock);
		_error = [NSError errorWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorFileCopy userInfo:nil];
		return;
	}
	Close(gfd);
	set_levelfile_name(0);
	(void) unlink(lock);
	
	for (lev = 1; lev < 256; lev++) {
		/* level numbers are kept in xchars in save.c, so the
		 * maximum level number (for the endlevel) must be < 256
		 */
		if (lev != savelev) {
			lfd = open_levelfile(lev);
			if (lfd >= 0) {
				/* any or all of these may not exist */
				levc = (xchar) lev;
				write(sfd, (genericptr_t) &levc, sizeof(levc));
				if (!copy_bytes(lfd, sfd)) {
					Close(lfd);
					(void) unlink(lock);
					_error = [NSError errorWithDomain:NHRecoveryErrorDomain code:NHRecoveryErrorFileCopy userInfo:nil];
					return;
				}
				Close(lfd);
				(void) unlink(lock);
			}
		}
	}
	
	Close(sfd);
	
	_success = YES;
}

- (void)setLevelFileName:(int)lev
{
	char *tf;
	
	tf = strrchr(lock, '.');
	if (!tf)
		tf = lock + strlen(lock);
	(void) sprintf(tf, ".%d", lev);
}

- (int)openLevelFile:(int)lev
{
	int fd;
	
	set_levelfile_name(lev);
	fd = open(lock, O_RDONLY, 0);
	return fd;
}

- (int)createSaveFile
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *saveNameNSStr = [fm stringWithFileSystemRepresentation:savename length:strlen(savename)];
	int fd;
	NSURL *saveURL = [baseURL URLByDeletingLastPathComponent];
	saveURL = [saveURL URLByAppendingPathComponent:saveNameNSStr];
	fd = creat([saveURL fileSystemRepresentation], FCMASK);
	return fd;
}

@end

BOOL copy_bytes(int ifd, int ofd)
{
	char buf[BUFSIZ];
	ssize_t nfrom, nto;
	
	do {
		nfrom = read(ifd, buf, BUFSIZ);
		nto = write(ofd, buf, nfrom);
		if (nto != nfrom) {
			Fprintf(stderr, "file copy failed!\n");
			return false;
		}
	} while (nfrom == BUFSIZ);
	return true;
}
