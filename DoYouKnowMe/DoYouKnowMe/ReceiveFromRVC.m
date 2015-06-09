//
//  ReceiveFromRVC.m
//  
//
//  Created by Felipe Eulalio on 09/06/15.
//
//

#import "ReceiveFromRVC.h"

@implementation ReceiveFromRVC

-(void)receivedData:(NSString *)data
{
	if([data isEqualToString:@"endGame"]) [_viewController playWithOther:self];
	else if([data isEqualToString:@"playAgain"]) [_viewController playWithSame:self];
}

@end
