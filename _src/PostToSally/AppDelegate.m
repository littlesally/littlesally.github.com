//
//  AppDelegate.m
//  PostToSally
//
//  Created by Nik Reiman on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <Collaboration/Collaboration.h>

@implementation AppDelegate

@synthesize window = _window;

@synthesize subjectTextField = _subjectTextField;
@synthesize pictureTextField = _pictureTextField;
@synthesize entryTextField = _entryTextField;

@synthesize previewImageView = _previewImageView;

- (void)dealloc {
  [super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
  return YES;
}

#define LIVE_GIT_OPERATIONS 1

- (void)gitPull {
#if LIVE_GIT_OPERATIONS
  NSLog(@"Pulling from repo...");
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *repoPath = [bundlePath stringByAppendingString:@"/../../"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.currentDirectoryPath = repoPath;
  task.launchPath = @"/usr/local/bin/git";
  task.arguments = [NSArray arrayWithObject:@"pull"];
  [task launch];
  [task waitUntilExit];
#endif
}

- (void)gitPush {
#if LIVE_GIT_OPERATIONS
  NSLog(@"Pushing to repo...");
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *repoPath = [bundlePath stringByAppendingString:@"/../../"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.currentDirectoryPath = repoPath;
  task.launchPath = @"/usr/local/bin/git";
  task.arguments = [NSArray arrayWithObject:@"push"];
  [task launch];
  [task waitUntilExit];
#endif
}

- (void)gitCommit:(NSString*)message {
#if LIVE_GIT_OPERATIONS
  NSLog(@"Committing to git");
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *repoPath = [bundlePath stringByAppendingString:@"/../../"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.currentDirectoryPath = repoPath;
  task.launchPath = @"/usr/local/bin/git";
  task.arguments = [NSArray arrayWithObjects:@"commit", @"-m", message, nil];
  [task launch];
  [task waitUntilExit];
#endif
}

- (void)addFileToGit:(NSString*)filename {
#if LIVE_GIT_OPERATIONS
  NSLog(@"Adding %@ to git", filename);
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *repoPath = [bundlePath stringByAppendingString:@"/../../"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.currentDirectoryPath = repoPath;
  task.launchPath = @"/usr/local/bin/git";
  task.arguments = [NSArray arrayWithObjects:@"add", filename, nil];
  [task launch];
  [task waitUntilExit];
#endif
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self gitPull];
}

- (IBAction)browseButtonPressed:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  openPanel.canChooseFiles = YES;
  openPanel.canChooseDirectories = NO;
  openPanel.allowsMultipleSelection = NO;
  [openPanel runModal];
  [_pictureTextField setStringValue:openPanel.filename];
  NSImage *previewImage = [[[NSImage alloc] initWithContentsOfURL:openPanel.URL] autorelease];
  [_previewImageView setImage:previewImage];
}

- (IBAction)goButtonPressed:(id)sender {
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *postsPath = [bundlePath stringByAppendingString:@"/../../_posts/"];
  NSString *imagesPath = [bundlePath stringByAppendingString:@"/../../images/"];
  NSString *subject = _subjectTextField.stringValue;
  NSMutableString *postName = [[[NSMutableString alloc] initWithString:subject] autorelease];

  NSRange spaceRange = [postName rangeOfString:@" "];
  if(spaceRange.location != NSNotFound) {
    [postName replaceOccurrencesOfString:@" " withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [postName length])];
  }

  NSDate *today = [NSDate date];
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d-" allowNaturalLanguage:NO] autorelease];
  NSString *formattedDateString = [dateFormatter stringFromDate:today];

  NSString *finalPostName = [[formattedDateString stringByAppendingString:postName] stringByAppendingString:@".md"];
  NSString *postFileName = [postsPath stringByAppendingString:finalPostName];
  NSLog(@"Creating post at %@", postFileName);

  const char *postFileNameCString = [postFileName cStringUsingEncoding:NSASCIIStringEncoding];
  FILE *postFile = fopen(postFileNameCString, "w");
  fprintf(postFile, "---\n");
  fprintf(postFile, "layout: default\n");
  fprintf(postFile, "title: %s\n", [subject cStringUsingEncoding:NSASCIIStringEncoding]);
  CBIdentity *identity = [CBIdentity identityWithName:NSUserName() authority:[CBIdentityAuthority defaultIdentityAuthority]];
  fprintf(postFile, "author: %s\n", [identity.fullName cStringUsingEncoding:NSASCIIStringEncoding]);
  fprintf(postFile, "---\n\n");

  if([_pictureTextField stringValue].length > 0) {
    const char *pictureSrc = [[_pictureTextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *pictureFileType = strrchr(pictureSrc, '.');
    NSString *fileExtension = [NSString stringWithCString:pictureFileType encoding:NSASCIIStringEncoding];
    NSString *pictureDestFilename = [[formattedDateString stringByAppendingString:postName] stringByAppendingString:fileExtension];
    NSString *pictureDest = [imagesPath stringByAppendingString:pictureDestFilename];
    NSLog(@"Pic dest: %@", pictureDest);
    NSArray *arguments = [NSArray arrayWithObjects:@"-v", [_pictureTextField stringValue], pictureDest, nil];
    [NSTask launchedTaskWithLaunchPath:@"/bin/cp" arguments:arguments];
    fprintf(postFile, "![Picture](/images/%s)\n\n", [pictureDestFilename cStringUsingEncoding:NSASCIIStringEncoding]);
    [self addFileToGit:[@"./images/" stringByAppendingString:pictureDestFilename]];
  }

  fprintf(postFile, "%s\n", [[_entryTextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
  fclose(postFile);
  [self addFileToGit:postFileName];
  [self gitCommit:subject];
  [self gitPush];
}

@end
