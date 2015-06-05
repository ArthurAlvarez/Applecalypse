//
//  ReceiveFromSVC.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 04/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ReceiveFromSVC.h"

@implementation ReceiveFromSVC

-(void)receivedData:(NSString *)data
{
	if([data isEqualToString:@"@start"]) [GameSettings setOtherDidLoad:YES];
	
	else if ([data isEqualToString:@"!1"] || [data isEqualToString:@"!0"]) {
		if ([data isEqualToString:@"!0"])
		{
			[Player setPlayerID:1];
			[_viewController changePlayerID:0];
		}
		else {
			[Player setPlayerID:2];
			[_viewController changePlayerID:1];
		}
	} else if ([data isEqualToString:@"!disconnect"]) [[_viewController navigationController] popToRootViewControllerAnimated:YES];
	
	else if ([data isEqualToString:@"!start"]) [_viewController canStart];
	
	else if ([data hasPrefix:@"()"]){
		int index = [[data stringByReplacingOccurrencesOfString:@"()" withString:@""] intValue];
		
		[_viewController changeGameLenght:index];
		[GameSettings setGameLenght:5 + index * 5];
		
	} else if ([data isEqualToString:@"!goBack"]) [[_viewController navigationController] popToRootViewControllerAnimated:YES];
	
	else if ([data hasPrefix:@"."]) {
		int index = [[data stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
		
		[_viewController changeTimeToAnswer:index];
		[GameSettings setTime:20 + index * 10];
	}
}

@end
