//
//  Player.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/26/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "Player.h"

@implementation Player

/*
    Player1: Responds questions about himself
    Player2: Responds questions about the other player
*/

static int _playerID; // 1 for Player1, 2 for Player2
static int _score; // Score of player 2

+(void) setPlayerID:(int)ID{
    _playerID = ID;
}

+(int) getPlayerID{
    return _playerID;
}

+(void) setScore:(int)newScore{
    _score = newScore;
}

+(int) getScore{
    return _score;
}

+(float)knowingPercent
{
	// oi
	return (float) _score/[GameSettings getGameLength];
}

@end
