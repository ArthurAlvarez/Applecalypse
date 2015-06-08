//
//  ReceivedFromGAME.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 08/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ReceiveFromGAME.h"

@implementation ReceiveFromGAME

-(void)receivedData:(NSString *)data
{
	if([data hasPrefix:@"*&*"]){
		NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
		NSString *formatted = [data stringByReplacingOccurrencesOfString:@"*&*" withString:@""];
		[self.game questionTextFromIndex:[f numberFromString:formatted]];
	}
}
@end
