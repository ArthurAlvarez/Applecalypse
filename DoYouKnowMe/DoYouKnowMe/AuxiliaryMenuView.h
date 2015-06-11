//
//  PauseMenuView.h
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 17/05/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - PauseMenuView Delegate

@protocol AuxiliaryMenuViewDelegate <NSObject>

/**
 Method to resume the game.
 */
-(void) leftButtonAction;

/**
 Method to end the game
 */
-(void) rightButtonAction;

@end

IB_DESIGNABLE

#pragma mark - Public Interface

@interface AuxiliaryMenuView : UIView

#pragma mark - Properties

@property (nonatomic) IBInspectable NSString *leftButtonTag;
@property (nonatomic) IBInspectable NSString *rightButtonTag;
@property (nonatomic) IBInspectable NSString *messageTag;
@property (nonatomic) IBInspectable int type;

@property NSString *peerName;

@property (weak) IBOutlet id<AuxiliaryMenuViewDelegate> delegate;

#pragma mark - Methods

-(void) show;

-(void) hide;

@end
