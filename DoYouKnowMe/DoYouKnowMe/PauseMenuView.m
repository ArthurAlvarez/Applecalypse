//
//  PauseMenuView.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 17/05/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "PauseMenuView.h"

#pragma mark - Private Interface

@interface PauseMenuView ()

/// Visual Effect to make a blur effect
@property UIVisualEffectView *visualEffect;
/// Label to display some text
@property UILabel *pauseLabel;
/// View to keep the buttons and the label
@property UIView *view;
/// Button to continue the game
@property UIButton *continueButton;
/// Button to end the game
@property UIButton *endGameButton;

@end

#pragma mark - Implementation

@implementation PauseMenuView

#pragma mark - Methods
#pragma mark - Init Methods

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self setupView];
}

-(void)prepareForInterfaceBuilder
{
	[self setupView];
}

#pragma makr - Setup Methods

/**
 Set the view and its subviews
 */
-(void) setupView
{
	self.backgroundColor = [UIColor clearColor];
	
	// Set the Visual Effect
	self.visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
	[self addSubview:self.visualEffect];
	
	// Set the View
	self.view = [[UIView alloc] init];
	self.view.layer.cornerRadius = 15;
	self.view.layer.borderWidth = 1;
	self.view.layer.borderColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1].CGColor;
	self.view.backgroundColor = [UIColor colorWithHue:0.52222 saturation:0.85 brightness:0.56 alpha:1];
	[self addSubview:self.view];
	
	// Set the label
	self.pauseLabel = [[UILabel alloc] init];
	self.pauseLabel.textAlignment = NSTextAlignmentCenter;
	self.pauseLabel.text = [NSString stringWithFormat:@"Jogo pausado\n\nO que deseja fazer?"];
	self.pauseLabel.numberOfLines = 0;
	self.pauseLabel.font = [UIFont fontWithName:@"VAGRoundedBT-Regular" size:20.0];
	self.pauseLabel.textColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1];
	self.pauseLabel.shadowColor = [UIColor blackColor];
	self.pauseLabel.shadowOffset = CGSizeMake(1, 1);
	[self.view addSubview:self.pauseLabel];
	
	// Set the End Game Button
	self.endGameButton = [[UIButton alloc]init];
	self.endGameButton.layer.cornerRadius = 10;
	self.endGameButton.layer.backgroundColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1].CGColor;
	[self.endGameButton setTitle:@"Terminar" forState:UIControlStateNormal];
	self.endGameButton.titleLabel.font = [UIFont fontWithName:@"VAGRoundedBT-Regular" size:15.0];
	self.endGameButton.titleLabel.textColor = [UIColor whiteColor];
	[self.endGameButton addTarget:self
				   action:@selector(endGame:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.endGameButton];
	
	// Set the Continue Button
	self.continueButton = [[UIButton alloc]init];
	self.continueButton.layer.cornerRadius = 10;
	self.continueButton.layer.backgroundColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1].CGColor;
	[self.continueButton setTitle:@"Continuar" forState:UIControlStateNormal];
	self.continueButton.titleLabel.font = [UIFont fontWithName:@"VAGRoundedBT-Regular" size:15.0];
	self.continueButton.titleLabel.textColor = [UIColor whiteColor];
	[self.continueButton addTarget:self
				   action:@selector(resumeGame:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.continueButton];
	
	[self setupConstraints];
}

/** 
 Set all the constraints
 */
-(void) setupConstraints
{
	[self.visualEffect setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.pauseLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.endGameButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.continueButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	NSDictionary *views = @{@"ve": self.visualEffect, @"v": self.view, @"egb": self.endGameButton, @"cb": self.continueButton, @"pl": self.pauseLabel};
	
	// Visual Effect constraints
	NSArray *vePosX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ve]|"
															  options: 0
															  metrics:nil
																views:views];
	NSArray *vePosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ve]|"
															  options: 0
															  metrics:nil
																views:views];
	[self addConstraints:vePosX]; [self addConstraints:vePosY];
	
	// View constraints
	NSArray *vPosX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[v]-50-|"
															 options: 0
															 metrics:nil
															   views:views];
	NSLayoutConstraint *vPosY = [NSLayoutConstraint constraintWithItem:self.view
												  attribute:NSLayoutAttributeCenterY
												  relatedBy:NSLayoutRelationEqual
													 toItem:self
												  attribute:NSLayoutAttributeCenterY
												 multiplier:1
												   constant:0];
	NSLayoutConstraint *vHnW = [NSLayoutConstraint constraintWithItem:self.view
															attribute:NSLayoutAttributeHeight
															relatedBy:NSLayoutRelationEqual
															   toItem:self.view
															attribute:NSLayoutAttributeWidth
														   multiplier:1
															 constant:0];
	[self addConstraints:vPosX]; [self addConstraint:vPosY]; [self addConstraint:vHnW];
	
	// Pause Label constraints
	NSArray *plPosX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pl]|"
															  options: 0
															  metrics:nil
																views:views];
	NSArray *plPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pl]"
															  options: 0
															  metrics:nil
																views:views];
	[self.view addConstraints:plPosX]; [self.view addConstraints:plPosY];
	
	// End Game Button constraints
	NSArray *egbWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[egb(==80)]"
																options: 0
																metrics:nil
																  views:views];
	NSLayoutConstraint *egbPosX = [NSLayoutConstraint constraintWithItem:self.endGameButton
															   attribute:NSLayoutAttributeLeading
															   relatedBy:NSLayoutRelationEqual
																  toItem:self.view
															   attribute:NSLayoutAttributeCenterX
															  multiplier:1
																constant:20];
	NSArray *egbPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pl]-10-[egb(==50)]-20-|"
															   options: 0
															   metrics:nil
																 views:views];
	[self.view addConstraints:egbWidth]; [self.view addConstraints:egbPosY]; [self.view addConstraint:egbPosX];
	
	// Continue Button constraints
	NSArray *cbWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[cb(==80)]"
															   options: 0
															   metrics:nil
																 views:views];
	NSLayoutConstraint *cbPosX = [NSLayoutConstraint constraintWithItem:self.continueButton
															  attribute:NSLayoutAttributeTrailing
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.view
															  attribute:NSLayoutAttributeCenterX
															 multiplier:1
															   constant:-20];
	NSArray *cbPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pl]-10-[cb(==50)]-20-|"
															  options: 0
															  metrics:nil
																views:views];
	[self.view addConstraints:cbWidth]; [self.view addConstraints:cbPosY]; [self.view addConstraint:cbPosX];
}

#pragma mark - Action Methods

/**
 Method to when the button is selected, continue the game
 */
-(void) resumeGame:(UIButton *)sender
{
	[self.delegate resumeGame];
}

/**
 Method to when the button is selected, end the game
 */
-(void) endGame:(UIButton *)sender
{
	[self.delegate endGame];
}

#pragma mark - Public Methods
/**
 Method to show the view
 */
-(void) show
{
	self.hidden = NO;
}

/**
 Method to hide the view
 */
-(void) hide
{
	self.hidden = YES;
}

@end
