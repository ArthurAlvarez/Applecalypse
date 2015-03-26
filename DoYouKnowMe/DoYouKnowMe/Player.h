//
//  Player.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/26/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

/**
    Sets the value of static variable ID.
    1 for player 1, 2 for player 2;
    @author Arthur Alvarez
 */
+(void)setPlayerID:(int)ID;

/**
 Gets the value of static variable ID.
 1 for player 1, 2 for player 2;
 @author Arthur Alvarez
 */
+(int)getPlayerID;


/**
 Sets the score of player 2.
 @author Arthur Alvarez
 */
+(void)setScore:(int)newScore;
/**
 Gets the score of player  2.
 @author Arthur Alvarez
 */
+(int)getScore;

@end
