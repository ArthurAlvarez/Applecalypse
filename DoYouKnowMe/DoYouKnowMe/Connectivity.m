//
//  Conectivity.m
//  DoYouKnowMe
//
//  Created by Felipe Eulalio on 24/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "Connectivity.h"

@implementation Connectivity


-(id)init{
	self = [super init];
	
	if (self) {
		_peerID = nil;
		_session = nil;
		_browser = nil;
		_advertiser = nil;
	}
	
	return self;
}

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName{
    if (_peerID == nil){
        _peerID = [[OnlinePeer alloc] initWith:[[MCPeerID alloc] initWithDisplayName:displayName]];
        
    }
    else{
        _peerID.nickName = displayName;
        NSLog(@"Recycling current peer with new name: %@", displayName);
    }
        _session = [[MCSession alloc] initWithPeer:_peerID.peerID];
        _session.delegate = self;
}

-(void)setupMCBrowser{
	_browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID.peerID serviceType:@"doyouknowme"];
}

-(void)advertiseSelf:(BOOL)shouldAdvertise{
	if (shouldAdvertise)
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID.peerID discoveryInfo:nil serviceType:@"doyouknowme"];
}

#pragma mark - MCSession Delegate

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
	NSDictionary *dict = @{@"peerID": peerID,
						   @"state" : [NSNumber numberWithInt:state]};
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
														object:nil
													  userInfo:dict];
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
	NSDictionary *dict = @{@"data": data,
						   @"peerID": peerID};
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
														object:nil
													  userInfo:dict];
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
	
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
	
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
	
}

- (void) session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
}


@end
