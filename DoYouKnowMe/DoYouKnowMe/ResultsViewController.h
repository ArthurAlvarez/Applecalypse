//
//  ResultsViewController.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/30/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "GameViewController.h"
#import "VerifyAnswerViewController.h"

@interface ResultsViewController : UIViewController <VerifyAnswerControllerDelegate>

@property Game *game;

@property (strong, nonatomic) GameViewController *gameView;

@end
