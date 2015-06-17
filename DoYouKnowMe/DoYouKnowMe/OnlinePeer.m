//
//  OnlinePeer.m
//  DoIKnowYou
//
//  Created by Arthur Alvarez on 6/16/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "OnlinePeer.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation OnlinePeer

-(id)initWith:(MCPeerID*)peerID{
    self = [super init];
    
    if (self) {
        self.peerID = peerID;
        self.nickName = [NSString stringWithFormat:@"%@", peerID.displayName];
    }
    
    return self;
}

-(void)change:(NSString*)NickName{
    self.nickName = NickName;
}
@end
