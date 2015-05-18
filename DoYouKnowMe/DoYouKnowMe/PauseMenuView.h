//
//  PauseMenuView.h
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 17/05/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - PauseMenuView Delegate

@protocol PauseMenuViewDelegate <NSObject>

/**
 Method to resume the game.
 */
-(void) resumeGame;

/**
 Method to end the game
 */
-(void) endGame;

@end

IB_DESIGNABLE

#pragma mark - Public Interface

@interface PauseMenuView : UIView

#pragma mark - Properties

@property (weak) IBOutlet id<PauseMenuViewDelegate> delegate;

#pragma mark - Methods

-(void) show;

-(void) hide;

@end
