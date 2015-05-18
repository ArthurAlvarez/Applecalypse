//
//  GameSettings.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/30/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "GameSettings.h"

@implementation GameSettings

///The length of a game round (default value is 5)
static int _gameLength = 5;
static int _currentRound = 0;
static bool _otherDidLoad = NO;
static int _timeToAnswer = 20;

+(void)setTime:(int)time
{
	_timeToAnswer = time;
}

+(int)getTime
{
	return _timeToAnswer;
}

+ (void) setRound:(int)round
{
	_currentRound = 0;
}

+(void)setGameLenght:(int)lenght
{
	_gameLength = lenght;
}

+(void)incrementRound{
    _currentRound++;
}

+(int)getGameLength{
    return _gameLength;
}

+(int)getCurrentRound{
    return _currentRound;
}

+(void)setOtherDidLoad:(bool)newState{
    _otherDidLoad = newState;
}

+(bool)getOtherDidLoad{
    return _otherDidLoad;
}

@end
