//
//  ReceiveFromCVC.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 04/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ReceiveFromCVC.h"

@implementation ReceiveFromCVC

-(void)receivedData:(NSString *)data
{
	if ([data isEqualToString:@"goNext"]) {
		[_viewController canGoNext];
	}
}

@end
