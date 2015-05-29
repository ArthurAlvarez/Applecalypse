//
//  GameViewController.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PauseMenuView.h"
#import "VerifyAnswerViewController.h"

@interface GameViewController : UIViewController <UIAlertViewDelegate, UIApplicationDelegate, UITextFieldDelegate, PauseMenuViewDelegate,VerifyAnswerControllerDelegate>

@end
