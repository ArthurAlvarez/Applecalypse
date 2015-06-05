//
//  ReceiveFromVAVC.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 04/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ReceiveFromVAVC.h"

@implementation ReceiveFromVAVC

-(void)receivedData:(NSString *)data
{
	if([data isEqualToString:@"#0"]) [_viewController verifyAnswer:NO];
	else if([data isEqualToString:@"#1"]) [_viewController verifyAnswer:YES];
}

@end
