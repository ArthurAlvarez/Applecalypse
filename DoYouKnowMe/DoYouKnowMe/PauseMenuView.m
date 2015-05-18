//
//  PauseMenuView.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 17/05/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "PauseMenuView.h"

@implementation PauseMenuView
/// Visual Effect to make a blur effect
UIVisualEffectView *visualEffect;
/// Label to display some text
UILabel *pauseLabel;
/// View to keep the buttons and the label
UIView *view;
/// Button to continue the game
UIButton *continueButton;
/// Button to end the game
UIButton *endGameButton;

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
	visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
	[self addSubview:visualEffect];
	
	// Set the View
	view = [[UIView alloc] init];
	view.layer.cornerRadius = 15;
	view.layer.backgroundColor = [UIColor colorWithHue:0.52222 saturation:0.85 brightness:0.56 alpha:1].CGColor;
	[self addSubview:view];
	
	// Set the label
	pauseLabel = [[UILabel alloc] init];
	pauseLabel.textAlignment = NSTextAlignmentCenter;
	pauseLabel.text = [NSString stringWithFormat:@"Jogo pausado\n\nO que deseja fazer?"];
	pauseLabel.numberOfLines = 0;
	pauseLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20.0];
	pauseLabel.textColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1];
	pauseLabel.shadowColor = [UIColor blackColor];
	pauseLabel.shadowOffset = CGSizeMake(1, 1);
	[view addSubview:pauseLabel];
	
	// Set the End Game Button
	endGameButton = [[UIButton alloc]init];
	endGameButton.layer.cornerRadius = 10;
	endGameButton.layer.backgroundColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1].CGColor;
	[endGameButton setTitle:@"Terminar" forState:UIControlStateNormal];
	endGameButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:15.0];
	endGameButton.titleLabel.textColor = [UIColor whiteColor];
	[endGameButton addTarget:self
				   action:@selector(endGame:)
		 forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:endGameButton];
	
	// Set the Continue Button
	continueButton = [[UIButton alloc]init];
	continueButton.layer.cornerRadius = 10;
	continueButton.layer.backgroundColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1].CGColor;
	[continueButton setTitle:@"Continuar" forState:UIControlStateNormal];
	continueButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:15.0];
	continueButton.titleLabel.textColor = [UIColor whiteColor];
	[continueButton addTarget:self
				   action:@selector(resumeGame:)
		 forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:continueButton];
	
	[self setupConstraints];
}

/** 
 Set all the constraints
 */
-(void) setupConstraints
{
	[visualEffect setTranslatesAutoresizingMaskIntoConstraints:NO];
	[view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[pauseLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	[endGameButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	[continueButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(visualEffect, view, endGameButton, continueButton, pauseLabel);
	
	// Visual Effect constraints
	NSArray *vePosX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[visualEffect]|"
															  options: 0
															  metrics:nil
																views:views];
	NSArray *vePosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[visualEffect]|"
															  options: 0
															  metrics:nil
																views:views];
	[self addConstraints:vePosX]; [self addConstraints:vePosY];
	
	// View constraints
	NSArray *vPosX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[view]-50-|"
															 options: 0
															 metrics:nil
															   views:views];
	NSArray *vPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[view]-200-|"
															 options: 0
															 metrics:nil
															   views:views];
	[self addConstraints:vPosX]; [self addConstraints:vPosY];
	
	// Pause Label constraints
	NSArray *plPosX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pauseLabel]|"
															  options: 0
															  metrics:nil
																views:views];
	NSArray *plPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pauseLabel]"
															  options: 0
															  metrics:nil
																views:views];
	[view addConstraints:plPosX]; [view addConstraints:plPosY];
	
	// End Game Button constraints
	NSArray *egbWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[endGameButton(==80)]"
																options: 0
																metrics:nil
																  views:views];
	NSLayoutConstraint *egbPosX = [NSLayoutConstraint constraintWithItem:endGameButton
															   attribute:NSLayoutAttributeLeading
															   relatedBy:NSLayoutRelationEqual
																  toItem:view
															   attribute:NSLayoutAttributeCenterX
															  multiplier:1
																constant:20];
	NSArray *egbPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pauseLabel]-10-[endGameButton(==50)]-20-|"
															   options: 0
															   metrics:nil
																 views:views];
	[view addConstraints:egbWidth]; [view addConstraints:egbPosY]; [view addConstraint:egbPosX];
	
	// Continue Button constraints
	NSArray *cbWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[continueButton(==80)]"
															   options: 0
															   metrics:nil
																 views:views];
	NSLayoutConstraint *cbPosX = [NSLayoutConstraint constraintWithItem:continueButton
															  attribute:NSLayoutAttributeTrailing
															  relatedBy:NSLayoutRelationEqual
																 toItem:view
															  attribute:NSLayoutAttributeCenterX
															 multiplier:1
															   constant:-20];
	NSArray *cbPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pauseLabel]-10-[continueButton(==50)]-20-|"
															  options: 0
															  metrics:nil
																views:views];
	[view addConstraints:cbWidth]; [view addConstraints:cbPosY]; [view addConstraint:cbPosX];
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
