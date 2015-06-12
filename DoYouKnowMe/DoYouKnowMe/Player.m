//
//  Player.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/26/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "Player.h"

int const PLAYER1 = 1;
int const PLAYER2 = 2;

@implementation Player
/*
    Player1: Responds questions about himself
    Player2: Responds questions about the other player
*/

static int _playerID; // 1 for Player1, 2 for Player2
static int _myScore; // Score of player 1
static int _otherScore; // Score of player 1

+(void) setPlayerID:(int)ID{
    _playerID = ID;
}

+(int) getPlayerID{
    return _playerID;
}

+(void) alternatePlayerID
{
	if (_playerID == PLAYER1) _playerID = PLAYER2;
	else _playerID = PLAYER1;
}

+(void) setScore:(int)newScore fromPlayer:(int)player{
	if (player == PLAYER1) _myScore = newScore;
	else if (player == PLAYER2) _otherScore = newScore;
}

+(int) getScore:(int)player{
	if (player == PLAYER1) return _myScore;
	else if (player == PLAYER2) return _otherScore;
	
	return 0;
}

+(float)knowingPercent:(int)player
{
	int divisor = [GameSettings getGameLength]/[GameSettings getGameType];
	
	if (player == PLAYER1) return (float) _myScore/divisor;
	else if (player == PLAYER2) return (float) _otherScore/divisor;
	
	return 0;
}

@end
