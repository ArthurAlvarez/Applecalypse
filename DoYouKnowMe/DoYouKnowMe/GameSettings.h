//
//  GameSettings.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/30/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

/**
 Holds information about the game settings
 */
#import <Foundation/Foundation.h>

@interface GameSettings : NSObject

+(void)setTime:(int)time;

+(int)getTime;

+(void)setRound:(int)round;

+(void)setGameLenght:(int)lenght;

+(void)incrementRound;

+(int)getGameLength;

+(int)getCurrentRound;

+(bool)getOtherDidLoad;

+(void)setOtherDidLoad:(bool)newState;
@end
