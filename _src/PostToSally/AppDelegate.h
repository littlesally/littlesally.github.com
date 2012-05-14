//
//  AppDelegate.h
//  PostToSally
//
//  Created by Nik Reiman on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *subjectTextField;
@property (assign) IBOutlet NSTextField *pictureTextField;
@property (assign) IBOutlet NSTextField *entryTextField;

@property (assign) IBOutlet NSImageView *previewImageView;

- (IBAction)browseButtonPressed:(id)sender;
- (IBAction)goButtonPressed:(id)sender;

@end
