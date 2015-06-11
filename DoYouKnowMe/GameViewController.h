//
//  GameViewController.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "AuxiliaryMenuView.h"
#import "VerifyAnswerViewController.h"

@interface GameViewController : UIViewController <UIAlertViewDelegate, UIApplicationDelegate, UITextFieldDelegate, AuxiliaryMenuViewDelegate,VerifyAnswerControllerDelegate>

@property BOOL otherWaiting;

@property (weak, nonatomic) Game *game;

- (void) receivedAnswer;
- (void) resume;
- (IBAction) pauseGame:(id)sender;
- (void) setTheQuestion:(NSString*)question;

@end
