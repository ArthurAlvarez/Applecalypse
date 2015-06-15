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
	
	else if ([data hasPrefix:@"!"]) {
		if ([data isEqualToString:@"!0"]) {
			[Player setPlayerID:PLAYER1];
			[GameSettings setGameType:REGULARMODE];
			[_viewController changePlayerID:0];
		} else if ([data isEqualToString:@"!1"]) {
			[Player setPlayerID:PLAYER2];
			[GameSettings setGameType:REGULARMODE];
			[_viewController changePlayerID:1];
		} else {
			[Player setPlayerID:PLAYER2];
			[GameSettings setGameType:ALTERNATEMODE];
			[_viewController changePlayerID:2];
		}
	}
	
	else if ([data isEqualToString:@"start"]) [_viewController canStart];
	
	else if ([data hasPrefix:@"()"]){
		int index = [[data stringByReplacingOccurrencesOfString:@"()" withString:@""] intValue];
		
		[_viewController changeGameLenght:index];
		[GameSettings setGameLenght:(5 + index * 5) * [GameSettings getGameType]];
		
	} else if ([data isEqualToString:@"goBack"]) [[_viewController navigationController] popToRootViewControllerAnimated:YES];
	
	else if ([data hasPrefix:@"."]) {
		int index = [[data stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
		
		[_viewController changeTimeToAnswer:index];
		[GameSettings setTime:20 + index * 10];
	}
}

@end
