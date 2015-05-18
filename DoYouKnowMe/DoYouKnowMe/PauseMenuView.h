//
//  PauseMenuView.h
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 17/05/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PauseMenuViewDelegate <NSObject>

-(void) resumeGame;
-(void) endGame;

@end

IB_DESIGNABLE

@interface PauseMenuView : UIView

@property (weak) IBOutlet id<PauseMenuViewDelegate> delegate;

-(void) show;
-(void) hide;

@end
