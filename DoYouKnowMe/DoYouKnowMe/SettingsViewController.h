//
//  ConnectionsViewController.h
//  DoYouKnowMe
//
//  Created by Felipe Eulalio on 24/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Game.h"
#import "GameViewController.h"

@interface SettingsViewController : UIViewController <UIAlertViewDelegate>

@property Game *game;

- (void) canStart;
- (void) changePlayerID:(int)index;
- (void) changeGameLenght:(int)index;
- (void) changeTimeToAnswer:(int)index;

@end
