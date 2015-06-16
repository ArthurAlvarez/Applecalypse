//
//  ReceiveData.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 04/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ReceiveData.h"

@implementation ReceiveData

-(void)receivedData:(NSString *)data
{
	NSLog(@"MustOverride");
}

-(void)receivedData:(NSString *)data from:(MCPeerID *)peer
{
    NSLog(@"MustOverride");
}

@end
