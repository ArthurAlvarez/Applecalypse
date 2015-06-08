//
//  Game.h
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 03/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Player.h"
#import "GameSettings.h"
#import "AppDelegate.h"
#import "Connectivity.h"

@interface Game : NSObject <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property AppDelegate *appDelegate;
@property MCPeerID *otherPlayer;
@property NSMutableArray *connectedDevices;
@property NSString *otherAnswer;
@property NSString *myAnswer;

- (id) initWithSender:(UIViewController*)sender;
- (void) initiateBrowsing;
- (void) pauseBrowsing;
- (void) initiateSession:(NSString*)userName;
- (void) finishSession;
- (void) sendData:(NSString*)dataToSend fromViewController:(UIViewController*)viewController;
- (BOOL) addScore:(BOOL)isCorrect;
- (void) getQuestion;
- (void) questionTextFromIndex:(NSNumber *)index;


@end
