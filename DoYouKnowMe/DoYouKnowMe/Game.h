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
#import <CoreData/CoreData.h>

typedef enum : NSUInteger {
	AllPeers,
	ConnectedPeer,
} SendDataTo;

typedef enum : NSUInteger {
	MyScore,
	OtherScore,
} ScoreType;

@interface Game : NSObject <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property AppDelegate *appDelegate;
@property OnlinePeer *otherPlayer;
@property NSMutableArray *connectedDevices;
@property NSString *otherAnswer;
@property NSString *myAnswer;
@property (strong) NSArray *scores;

- (id) initWithSender:(UIViewController*)sender;
- (void) initiateBrowsing;
- (void) pauseBrowsing;
- (void) initiateSession:(NSString*)userName;
- (void) finishSession;
- (void) sendData:(NSString*)dataToSend fromViewController:(UIViewController*)viewController to:(SendDataTo)device;
- (void) sendData:(NSString *)dataToSend fromViewController:(UIViewController*)viewController toPeer:(NSString*)other;
- (BOOL) addScore:(BOOL)isCorrect toPlayer:(int)player;
- (void) getQuestion;
- (void) questionTextFromIndex:(NSNumber *)index;
- (void) save:(ScoreType)scoreType;
- (void) load:(ScoreType)scoreType;


@end
