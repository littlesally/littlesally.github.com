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
@synthesize statusTextField = _statusTextField;

@synthesize previewImageView = _previewImageView;

- (void)dealloc {
  [super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
  return YES;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
  BOOL retval = NO;
  if(commandSelector == @selector(insertNewline:)) {
    retval = YES;
    [fieldEditor insertNewlineIgnoringFieldEditor:nil];
  }
  return retval;
}

- (void)startTask:(NSString *)task {
  [_statusTextField setStringValue:task];
  NSLog(@"Staring task: %@", task);
}

- (void)stopTask {
  [_statusTextField setStringValue:@""];
}

#define LIVE_GIT_OPERATIONS 1

- (void)gitPull {
#if LIVE_GIT_OPERATIONS
  [self startTask:@"Pulling from GitHub"];
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *repoPath = [bundlePath stringByAppendingString:@"/../../"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.currentDirectoryPath = repoPath;
  task.launchPath = @"/usr/local/bin/git";
  task.arguments = [NSArray arrayWithObject:@"pull"];
  [task launch];
  [task waitUntilExit];
  [self stopTask];
#endif
}

- (void)gitPush {
#if LIVE_GIT_OPERATIONS
  [self startTask:@"Pushing to GitHub"];
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *repoPath = [bundlePath stringByAppendingString:@"/../../"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.currentDirectoryPath = repoPath;
  task.launchPath = @"/usr/local/bin/git";
  task.arguments = [NSArray arrayWithObject:@"push"];
  [task launch];
  [task waitUntilExit];
  [self stopTask];
#endif
}

- (void)gitCommit:(NSString*)message {
#if LIVE_GIT_OPERATIONS
  [self startTask:@"Committing files"];
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *repoPath = [bundlePath stringByAppendingString:@"/../../"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.currentDirectoryPath = repoPath;
  task.launchPath = @"/usr/local/bin/git";
  task.arguments = [NSArray arrayWithObjects:@"commit", @"-m", message, nil];
  [task launch];
  [task waitUntilExit];
  [self stopTask];
#endif
}

- (void)addFileToGit:(NSString*)filename {
#if LIVE_GIT_OPERATIONS
  [self startTask:[@"Adding file: " stringByAppendingString:filename]];
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  NSString *repoPath = [bundlePath stringByAppendingString:@"/../../"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.currentDirectoryPath = repoPath;
  task.launchPath = @"/usr/local/bin/git";
  task.arguments = [NSArray arrayWithObjects:@"add", filename, nil];
  [task launch];
  [task waitUntilExit];
  [self stopTask];
#endif
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  CGFloat windowWidth = [userDefaults floatForKey:kPreferenceKeyWindowWidth];
  CGFloat windowHeight = [userDefaults floatForKey:kPreferenceKeyWindowHeight];
  if(windowWidth > 0 && windowHeight > 0) {
    NSRect windowFrame = self.window.frame;
    windowFrame.size.width = windowWidth;
    windowFrame.size.height = windowHeight;
    [self.window setFrame:windowFrame display:NO];
  }

  [self gitPull];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setFloat:self.window.frame.size.width forKey:kPreferenceKeyWindowWidth];
  [userDefaults setFloat:self.window.frame.size.height forKey:kPreferenceKeyWindowHeight];
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

- (void)resizePicture:(NSString *)pictureFilename {
  NSImage *previewImage = _previewImageView.image;
  if(previewImage.size.width < 800 && previewImage.size.height < 800) {
    return;
  }

  [self startTask:@"Resizing picture"];
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.launchPath = @"/usr/local/bin/mogrify";
  task.arguments = [NSArray arrayWithObjects:@"-resize", @"800x800", pictureFilename, nil];
  [task launch];
  [task waitUntilExit];
  [self stopTask];
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
    [self resizePicture:pictureDest];
    fprintf(postFile, "![Picture](/images/%s)\n\n", [pictureDestFilename cStringUsingEncoding:NSASCIIStringEncoding]);
    [self addFileToGit:pictureDest];
  }

  if([_entryTextField stringValue] == nil) {
    [self startTask:@"Error making post!"];
    return;
  }

  fprintf(postFile, "%s\n", [[_entryTextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
  fclose(postFile);

  [self addFileToGit:postFileName];
  [self gitCommit:subject];
  [self gitPush];
}

@end
