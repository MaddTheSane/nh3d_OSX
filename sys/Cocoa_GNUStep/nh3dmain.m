//
//  main.m
//  NetHack3D
//
//  Created by Haruumi Yoshino on 05/07/20.
//  Copyright Haruumi Yoshino. 2005.
//

#import <Cocoa/Cocoa.h>


int main(int argc, char *argv[])
{
	
/*	long uiVer;
	
	Gestalt( gestaltSystemVersion, &uiVer );
	
	if (uiVer < 0x1040) {
		
		NSRunCriticalAlertPanel(@"Sorry",
								NSLocalizedString(@"Grater than MacOS 10.4 are necessary so that NetHack3D start.",@"")
								,@"OK",nil,nil);
		
		exit(EXIT_SUCCESS);
	}
*/	
	return NSApplicationMain(argc,  (const char **) argv);
}

/*
 * Add a slash to any name not ending in /. There must
 * be room for the /
 */
void
append_slash(name)
char *name;
{
	char *ptr;

	if (!*name)
		return;
	ptr = name + (strlen(name) - 1);
	if (*ptr != '/') {
		*++ptr = '/';
		*++ptr = '\0';
	}
	return;
}
