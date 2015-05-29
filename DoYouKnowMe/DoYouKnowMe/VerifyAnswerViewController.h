//
//  VerifyAnswerViewController.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol VerifyAnswerControllerDelegate <NSObject>

- (void) didShowImage:(BOOL)right;

@end


@interface VerifyAnswerViewController : UIViewController

@property (strong, nonatomic) NSString *yourAnswer;

@property (strong, nonatomic) NSString *hisAnswer;

@property (weak) id<VerifyAnswerControllerDelegate> delegate;

@end
