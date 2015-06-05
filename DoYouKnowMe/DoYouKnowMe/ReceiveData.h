//
//  ReceiveData.h
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 04/06/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@interface ReceiveData : NSObject

@property (weak) Game *game;

- (void)receivedData:(NSString*)data;

@end
