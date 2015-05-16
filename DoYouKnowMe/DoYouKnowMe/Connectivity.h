//
//  Conectivity.h
//  DoYouKnowMe
//
//  Created by Felipe Eulalio on 24/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface Connectivity : NSObject <MCSessionDelegate>

/// Represents the device
@property (nonatomic, strong) MCPeerID *peerID;

/// Represents the current session that the device will create
@property (nonatomic, strong) MCSession *session;

/// Represents the default UI provided by Apple for browsing for other peers
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

/// Used from the current peer to advertise itself and make its discovery feasibl
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

/**
 Set the display name from the device to others
 **/
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;

/**
 Initialisation from the defautl view controller for searching other peers
 **/
-(void)setupMCBrowser;

/**
 Make the devise visible or not
 **/
-(void)advertiseSelf:(BOOL)shouldAdvertise;

@end

