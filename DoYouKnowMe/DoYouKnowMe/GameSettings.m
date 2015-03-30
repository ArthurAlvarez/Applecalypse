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

+(void)incrementRound{
    _currentRound++;
}

+(int)getGameLength{
    return _gameLength;
}

+(int)getCurrentRound{
    return _currentRound;
}

@end
