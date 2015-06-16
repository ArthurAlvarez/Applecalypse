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

typedef enum rejectCauseTypes{
    MYSELF, // Used when you cause yourself to reject
    REJECT, // When you get rejected by the other
    BUSY,   // When the other is busy connecting
    INGAME // When the other is in a game session
} RejectCause;

@property Game *game;
@property BOOL cameFromTutorial;
@property BOOL connecting;
@property BOOL connected;
@property (weak, nonatomic) IBOutlet AuxiliaryMenuView *acceptInviteView;
@property (weak, nonatomic) IBOutlet AuxiliaryMenuView *alertInviteView;

-(void) canGoNext;
-(void) connectToPlayer:(NSString *)playerName;
-(void) acceptInvitation;
-(void) rejectedInvitationWith:(RejectCause)cause;
-(void) sendRejectTo:(NSString*)peerName;
-(void) sendBusyTo:(NSString*)peerName;
-(void) reloadData;
-(void) ChangePeer:(MCPeerID *)Peer NicknameTo:(NSString *)Nickname;

@end
