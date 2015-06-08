//
//  FirstViewController.h
//  DoYouKnowMe
//
//  Created by Felipe Eulálio on 31/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Game.h"
#import "ResultsViewController.h"
#import "SettingsViewController.h"

@interface ConnectionsViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property Game *game;
@property BOOL cameFromTutorial;
- (void) canGoNext;

@end
