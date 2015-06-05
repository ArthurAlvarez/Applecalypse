//
//  VerifyAnswerViewController.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Game.h"

@protocol VerifyAnswerControllerDelegate <NSObject>

- (void) didShowImage:(BOOL)right;

@end

@interface VerifyAnswerViewController : UIViewController

@property Game *game;

@property (strong, nonatomic) NSString *yourAnswer;

@property (strong, nonatomic) NSString *hisAnswer;

@property (weak) id<VerifyAnswerControllerDelegate> delegate;

- (void) verifyAnswer:(BOOL)isCorrect;

@end
