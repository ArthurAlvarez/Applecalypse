//
//  Game.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 03/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "Game.h"
#import "ConnectionsViewController.h"
#import "SettingsViewController.h"
#import "GameViewController.h"
#import "VerifyAnswerViewController.h"
#import "ReceiveData.h"
#import "ReceiveFromGAME.h"
#import "ReceiveFromCVC.h"
#import "ReceiveFromSVC.h"
#import "ReceiveFromGVC.h"
#import "ReceiveFromVAVC.h"
#import "ReceiveFromRVC.h"

#pragma mark - Private Interface
@interface Game ()

@property UIViewController *rootViewController;

/// Dictionary to keep the questions from the Json file
@property NSDictionary *questionsJson;

/// Array to know which questions already were made
@property NSMutableArray *repeatedQuestions;

@end

#pragma mark - Implementation
@implementation Game

@synthesize fetchedResultsController, managedObjectContext;

#pragma mark - Initializer Methods
-(id)initWithSender:(UIViewController*)sender
{
	self = [super init];
	
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(peerDidChangeStateWithNotification:)
													 name:@"MCDidChangeStateNotification"
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didReceiveDataWithNotification:)
													 name:@"MCDidReceiveDataNotification"
												   object:nil];
		
		_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		_connectedDevices = [[NSMutableArray alloc] init];
		_repeatedQuestions = [[NSMutableArray alloc] init];
		_rootViewController = sender;
		[self readJsonFile];
	}
	
	return self;
}

#pragma mark - Connection Methods

-(void)initiateBrowsing
{
	[self pauseBrowsing];
	
	[_appDelegate.mcManager.browser startBrowsingForPeers];
	[_appDelegate.mcManager.advertiser startAdvertisingPeer];
}

-(void)pauseBrowsing
{
	[_appDelegate.mcManager.browser stopBrowsingForPeers];
	[_appDelegate.mcManager.advertiser stopAdvertisingPeer];
}

/**
 Initiate a new session. If there is another session, finish it and start a new one
 */
-(void)initiateSession:(NSString *)userName
{
	if (_appDelegate.mcManager.session != nil) [self finishSession];
		
	[_appDelegate.mcManager setupPeerAndSessionWithDisplayName:userName];
	[_appDelegate.mcManager advertiseSelf:YES];
	[_appDelegate.mcManager setupMCBrowser];
	_appDelegate.mcManager.advertiser.delegate = self;
	_appDelegate.mcManager.browser.delegate = self;
	[self initiateBrowsing];
}

/**
 Finish the currently session
 */
-(void)finishSession
{
	[self pauseBrowsing];
	
	[_appDelegate.mcManager.session disconnect];

	//_appDelegate.mcManager.peerID = nil;
	_appDelegate.mcManager.session = nil;
	_appDelegate.mcManager.browser = nil;
	[_appDelegate.mcManager advertiseSelf:NO];
	
	if ([_connectedDevices count] > 0) [_connectedDevices removeAllObjects];

}

-(void)sendData:(NSString *)dataToSend fromViewController:(UIViewController*)viewController to:(SendDataTo)device
{
	if (viewController == nil) dataToSend = [@"GAME" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[ConnectionsViewController class]]) dataToSend = [@"CVC" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[SettingsViewController class]]) dataToSend = [@"SVC" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[GameViewController class]]) dataToSend = [@"GVC" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[VerifyAnswerViewController class]]) dataToSend = [@"VAVC" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[ResultsViewController class]]) dataToSend = [@"RVC" stringByAppendingString:dataToSend];
	
	NSError *error;
	
	if (device == AllPeers) {
        
        NSMutableArray *peerIDS = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [_connectedDevices count]; i++)
            [peerIDS addObject:((OnlinePeer*)(_connectedDevices[i])).peerID];
        
		[_appDelegate.mcManager.session sendData:[dataToSend dataUsingEncoding:NSUTF8StringEncoding]
										 toPeers:peerIDS
										withMode:MCSessionSendDataReliable
										   error:&error];
	} else if (device == ConnectedPeer) {
		[_appDelegate.mcManager.session sendData:[dataToSend dataUsingEncoding:NSUTF8StringEncoding]
										 toPeers:@[_otherPlayer.peerID]
										withMode:MCSessionSendDataReliable
										   error:&error];
	}
	
	if (error) NSLog(@"%@", [error localizedDescription]);
    
    NSLog(@"Sent message %@ to %@", dataToSend, _otherPlayer.peerID);
}

-(void)sendData:(NSString *)dataToSend fromViewController:(UIViewController*)viewController toPeer:(NSString*)other
{
	if (viewController == nil) dataToSend = [@"GAME" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[ConnectionsViewController class]]) dataToSend = [@"CVC" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[SettingsViewController class]]) dataToSend = [@"SVC" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[GameViewController class]]) dataToSend = [@"GVC" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[VerifyAnswerViewController class]]) dataToSend = [@"VAVC" stringByAppendingString:dataToSend];
	else if ([viewController isKindOfClass:[ResultsViewController class]]) dataToSend = [@"RVC" stringByAppendingString:dataToSend];
	
	NSError *error;
	
	for (OnlinePeer *peer in _connectedDevices) {
		if (peer.peerID.displayName == other) {
			[_appDelegate.mcManager.session sendData:[dataToSend dataUsingEncoding:NSUTF8StringEncoding]
											 toPeers:@[peer.peerID]
											withMode:MCSessionSendDataReliable
											   error:&error];
            
            NSLog(@"Sent data: %@ to %@", dataToSend, other);
			break;
		}
	}
    
	
	if (error) NSLog(@"%@", [error localizedDescription]);
}

#pragma mark - Game Logic Methods

/**
 Increase the score if the answer is correct
 */
- (BOOL) addScore:(BOOL)isCorrect toPlayer:(int)player;
{
	
	if (isCorrect) [Player setScore:[Player getScore:player] + 1 fromPlayer:player];
	
	return [self checkEndGame];
}

/**
 Verifies if the game is finished
 */
- (BOOL) checkEndGame
{
	if ([GameSettings getGameLength] == [GameSettings getCurrentRound]) return YES;
	
	return NO;
}

/**
 Reads the JSON file containing the questions into a dictionary
 @author Arthur Alvarez
 */
-(void)readJsonFile{
	NSString *path = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"resource", nil) ofType:@"txt"];
	
	self.questionsJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:nil];
	
	if (self.questionsJson == nil) {
		NSLog(@"ERROR OPENING JSON!!");
	}
}

/**
 Gets the index of selected question and sends to the other peer
 @author Arthur Alvarez
 */
-(void)getQuestion
{
	NSNumber *numQuestions, *selectedQuestion;
	BOOL decided = NO, repeated = NO;
	
	numQuestions = [NSNumber numberWithInt:[[self.questionsJson objectForKey:@"size"]intValue]];
	
	while(decided == NO){
		selectedQuestion = [NSNumber numberWithInt:arc4random() % [numQuestions intValue]];
		
		repeated = NO;
		for(NSNumber *n in self.repeatedQuestions){
			if([selectedQuestion intValue] == [n intValue])
				repeated = YES;
		}
		
		if(repeated == NO){
			[self.repeatedQuestions addObject:[NSNumber numberWithInt:[selectedQuestion intValue]]];
			decided = YES;
		}
		else{
			NSLog(@"Repeated!");
		}
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self questionTextFromIndex:selectedQuestion];
	});
	
	[self sendData:[NSString stringWithFormat:@"*&*%@", selectedQuestion] fromViewController:nil to:ConnectedPeer];
}

-(void)questionTextFromIndex:(NSNumber *)index
{
	NSArray *controllers = [_rootViewController.navigationController viewControllers];
	NSDictionary *q = [self.questionsJson objectForKey:@"questions"];
	NSString *questionText = [NSString stringWithFormat:@"%@", [q objectForKey:[NSString stringWithFormat:@"%@", index]]];
	
	for (UIViewController *vc in controllers) {
		if ([vc isKindOfClass:[GameViewController class]]) {
			GameViewController *_vc;
			_vc = (GameViewController*) vc;
			
			[_vc setTheQuestion:questionText];
		}
	}
}

#pragma mark - Selectors

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    MCPeerID *sender = [[notification userInfo] objectForKey:@"peerID"];
    NSString *receivedInfo = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		if ([receivedInfo hasPrefix:@"GAME"]) {
			ReceiveFromGAME *_receiveData = [[ReceiveFromGAME alloc] init];
			
			_receiveData.game = self;
			[_receiveData receivedData:[receivedInfo stringByReplacingOccurrencesOfString:@"GAME" withString:@""]];
			
		} else if ([receivedInfo hasPrefix:@"CVC"]) {
			
			ReceiveFromCVC *_receiveData = [[ReceiveFromCVC alloc] init];
			for (UIViewController *vc in [_rootViewController.navigationController viewControllers]) {
				if ([vc isKindOfClass:[ConnectionsViewController class]]) {
					_receiveData.game = self;
					_receiveData.viewController = (ConnectionsViewController*) vc;
					break;
				}
			}
			[_receiveData receivedData:[receivedInfo stringByReplacingOccurrencesOfString:@"CVC" withString:@""] from:sender];
			
		} else if ([receivedInfo hasPrefix:@"SVC"]) {
			
			ReceiveFromSVC *_receiveData = [[ReceiveFromSVC alloc] init];
			for (UIViewController *vc in [_rootViewController.navigationController viewControllers]) {
				if ([vc isKindOfClass:[SettingsViewController class]]) {
					_receiveData.game = self;
					_receiveData.viewController = (SettingsViewController*) vc;
					break;
				}
			}
			[_receiveData receivedData:[receivedInfo stringByReplacingOccurrencesOfString:@"SVC" withString:@""]];
			
		} else if ([receivedInfo hasPrefix:@"GVC"]) {
			
			ReceiveFromGVC *_receiveData = [[ReceiveFromGVC alloc] init];
			for (UIViewController *vc in [_rootViewController.navigationController viewControllers]) {
				if ([vc isKindOfClass:[GameViewController class]]) {
					_receiveData.game = self;
					_receiveData.viewController = (GameViewController*) vc;
					break;
				}
			}
			[_receiveData receivedData:[receivedInfo stringByReplacingOccurrencesOfString:@"GVC" withString:@""]];
			
		} else if ([receivedInfo hasPrefix:@"VAVC"]) {
			
			ReceiveFromVAVC *_receiveData = [[ReceiveFromVAVC alloc] init];
			for (UIViewController *vc in [_rootViewController.navigationController viewControllers]) {
				if ([vc isKindOfClass:[VerifyAnswerViewController class]]) {
					_receiveData.game = self;
					_receiveData.viewController = (VerifyAnswerViewController*) vc;
					break;
				}
			}
			[_receiveData receivedData:[receivedInfo stringByReplacingOccurrencesOfString:@"VAVC" withString:@""]];
		} else if ([receivedInfo hasPrefix:@"RVC"]) {
			
			ReceiveFromRVC *_receiveData = [[ReceiveFromRVC alloc] init];
			for (UIViewController *vc in [_rootViewController.navigationController viewControllers]) {
				if ([vc isKindOfClass:[ResultsViewController class]]) {
					_receiveData.game = self;
					_receiveData.viewController = (ResultsViewController*) vc;
					break;
				}
			}
			[_receiveData receivedData:[receivedInfo stringByReplacingOccurrencesOfString:@"RVC" withString:@""]];
		}
	});
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
	MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
	MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
	dispatch_async(dispatch_get_main_queue(), ^{
		
        NSDictionary *dict = nil;
        
		if (state != MCSessionStateConnecting)
		{
			if (state == MCSessionStateConnected)
			{
                NSLog(@"Connected to %@", peerID.displayName);
                OnlinePeer *newPeer = [[OnlinePeer alloc] initWith:peerID];
				[_connectedDevices addObject:newPeer];
                dict = @{@"peerID": peerID, @"status": @"connected"};
			}
			else if (state == MCSessionStateNotConnected)
			{
                NSLog(@"Lost device %@", peerID);
                dict = @{@"peerID": peerID, @"status": @"disconnected"};
				if ([_connectedDevices count] > 0)
				{
					if ([peerID isEqual:_otherPlayer.peerID]) {
						[Player setPlayerID:-1];
					}
                    
                    for(int i = 0; i < [_connectedDevices count]; i++){
                        if(((OnlinePeer *)(_connectedDevices[i])).peerID == peerID){
                            [_connectedDevices removeObjectAtIndex:i];
                        }
                    }
                    
				}
			}
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"changeState"
															object:nil
														  userInfo:dict];
	});
}

#pragma mark - Nearby Service Browser and Advertise Delegates

/**
 Delegate for finding devices
 **/
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{	
    if(peerID != _appDelegate.mcManager.session.myPeerID){
        //Manda convite para conexao
        BOOL found = NO;
        for(OnlinePeer *p in _connectedDevices){
            if(p.peerID == peerID){
                found = YES;
            }
        }
        if(!found){
            NSLog(@"Found a nearby advertising peer %@", peerID);
            [[[_appDelegate mcManager] browser] invitePeer:peerID toSession:_appDelegate.mcManager.session withContext:nil timeout:60];
        }
    }
}

/**
 Delegate called when peer is lost
 **/
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
	//NSLog(@"Lost device %@", peerID);
}

/**
 Delegate fot accepting invitations
 **/
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept,
							 MCSession *session))invitationHandler
{
	NSLog(@"Accepted invite from %@", peerID);
	
	invitationHandler(YES, _appDelegate.mcManager.session);
}


- (void)save:(ScoreType)scoreType
{
	NSString *entityName;
	int player;
	
	managedObjectContext = [_appDelegate managedObjectContext];
	
	if (scoreType == MyScore) {
		entityName = @"MyScore";
		player = PLAYER1;
	} else {
		entityName = @"OtherScore";
		player = PLAYER2;
	}
	
	// Create a new managed object
	NSManagedObject *newScore = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
	[newScore setValue:_otherPlayer.nickName forKey:@"name"];
	[newScore setValue:[NSNumber numberWithFloat:[Player knowingPercent:player]] forKey:@"knowingPercent"];
	
	NSError *error = nil;
	// Save the object to persistent store
	if (![managedObjectContext save:&error]) {
		NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
	}
}

- (void)load:(ScoreType)scoreType
{
	NSString *entityName;

	managedObjectContext = [_appDelegate managedObjectContext];
	
	if (_scores == nil) _scores = [[NSArray alloc] init];
	
	if (scoreType == MyScore) entityName = @"MyScore";
	else entityName = @"OtherScore";
	
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	NSSortDescriptor *sortByKnowingPercent = [[NSSortDescriptor alloc] initWithKey:@"knowingPercent" ascending:NO];
	
	// Fetch the devices from persistent data store
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDesc];
	[fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortByKnowingPercent, nil]];
	
	NSError *error = nil;
	
	self.scores = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if (error != nil) NSLog(@"Can't Load! %@ %@", error, [error localizedDescription]);
}

@end
