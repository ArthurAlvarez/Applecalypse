//
//  ReceiveFromGVC.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 04/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ReceiveFromGVC.h"

@implementation ReceiveFromGVC

-(void)receivedData:(NSString *)data
{
	if([data isEqualToString:@"@start"]) [GameSettings setOtherDidLoad:YES];
	
	else if ([data isEqualToString:@"editing"]) [_viewController clearCurrentAnswers];
	
	else if ([data isEqualToString:@"@notwaiting"]) _viewController.otherWaiting = NO;
	
	else if([data hasPrefix:@"$"]) {
		self.game.otherAnswer = [data stringByReplacingOccurrencesOfString:@"$" withString:@""];
		
		[_viewController receivedAnswer];
	} else if([data hasPrefix:@"*&*"]){
		NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
		NSString *formatted = [data stringByReplacingOccurrencesOfString:@"*&*" withString:@""];
		[self.game questionTextFromIndex:[f numberFromString:formatted]];
		
	} else if ([data isEqualToString:@">"]) [_viewController resume];
	
	else if ([data isEqualToString:@"||"]) [_viewController pauseGame:self];
	
	else if ([data isEqualToString:@"<"]) [[_viewController navigationController] popToRootViewControllerAnimated:YES];
	
}

@end
