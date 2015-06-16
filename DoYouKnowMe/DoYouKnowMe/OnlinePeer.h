//
//  OnlinePeer.h
//  DoIKnowYou
//
//  Created by Arthur Alvarez on 6/16/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface OnlinePeer : NSObject
@property MCPeerID *peerID;
@property NSString* nickName;
-(id)initWith:(MCPeerID*)peerID;
@end
