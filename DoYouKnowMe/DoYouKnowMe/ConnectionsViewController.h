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
#import "AuxiliaryMenuView.h"

@interface ConnectionsViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, AuxiliaryMenuViewDelegate>

@property Game *game;
@property BOOL cameFromTutorial;
@property BOOL connecting;
@property (weak, nonatomic) IBOutlet AuxiliaryMenuView *acceptInviteView;

- (void) canGoNext;
- (void) connectToPlayer:(NSString *)playerName;
-(void) acceptInvitation;
-(void) rejectedInvitation;
-(void) sendRejectTo:(NSString*)peerName;
- (void) reloadData;

@end
