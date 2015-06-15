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
    NSString *other = [data substringFromIndex:6];
    
    if([data hasPrefix:@"goNext"] && _viewController.connected == YES){
        NSLog(@"Received GoNext");
        NSLog(@"Sending busy to %@", other);
        [_viewController sendBusyTo: other];
    }
    
	if ([data hasPrefix:@"goNext"] && _viewController.connecting == NO) {
        _viewController.connecting = YES;
        
        NSLog(@"Received GoNext");

        [_viewController canGoNext];
        [_viewController connectToPlayer:other];
		
		_viewController.acceptInviteView.peerName = other;
        
		[_viewController.acceptInviteView show];
    }
	
	else if ([data hasPrefix:@"goNext"] && _viewController.connecting == YES) {
        NSLog(@"Sending busy to %@", other);
		[_viewController sendBusyTo:other];
	}
    else if ([data isEqualToString:@"disconnect"]) {
		[_viewController reloadData];
	}
    
    else if([data isEqualToString:@"acceptedNext"]){
        NSLog(@"Received acceptedNext");
        _viewController.connecting = NO;
        [_viewController canGoNext];
    }
    
    else if([data isEqualToString:@"rejected"]){
        _viewController.connecting = NO;
        [_viewController rejectedInvitationWith:REJECT];
    }
    
    else if([data isEqualToString:@"busy"]){
        NSLog(@"got busy");
        _viewController.connecting = NO;
        [_viewController rejectedInvitationWith:BUSY];
    }
}

@end
