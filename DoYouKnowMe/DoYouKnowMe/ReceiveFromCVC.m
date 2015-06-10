//
//  ReceiveFromCVC.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 04/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ReceiveFromCVC.h"

@interface ReceiveFromCVC ()
{
    BOOL connecting;
}
@end

@implementation ReceiveFromCVC

-(void)receivedData:(NSString *)data
{
	if ([data hasPrefix:@"goNext"] && connecting == NO) {
        connecting = YES;
        
        NSLog(@"Received GoNext");
        NSString *other = [data substringFromIndex:6];

        [_viewController canGoNext];
        [_viewController connectToPlayer:other];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Convite"
                                                                       message:[NSString stringWithFormat:@"'%@' deseja jogar com você", other]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* acceptAction = [UIAlertAction actionWithTitle:@"Aceitar" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self accept];
                                                              }];
        
        UIAlertAction* rejectAction = [UIAlertAction actionWithTitle:@"Rejeitar" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self reject];
                                                              }];
        
        
        [alert addAction:acceptAction];
        [alert addAction:rejectAction];
        [_viewController presentViewController:alert animated:YES completion:nil];
    }
    
    else if ([data isEqualToString:@"disconnect"]) {
		[_viewController reloadData];
	}
    
    else if([data isEqualToString:@"acceptedNext"]){
        NSLog(@"Received acceptedNext");
        [_viewController canGoNext];
    }
    
    else if([data isEqualToString:@"rejected"]){
        connecting = NO;
        [_viewController rejectedInvitation];
    }
}

- (void) accept{
    NSLog(@"accepted");
    [_viewController canGoNext];
    [_viewController acceptInvitation];
}

- (void) reject{
    [_viewController sendReject];
    [_viewController rejectedInvitation];
    connecting = NO;
}
@end
