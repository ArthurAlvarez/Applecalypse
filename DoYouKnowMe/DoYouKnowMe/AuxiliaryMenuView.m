//
//  PauseMenuView.m
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 17/05/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "AuxiliaryMenuView.h"

#pragma mark - Private Interface

@interface AuxiliaryMenuView ()

/// Visual Effect to make a blur effect
@property UIVisualEffectView *visualEffect;
/// Label to display some text
@property UILabel *label;
/// View to keep the buttons and the label
@property UIView *view;
/// Button to continue the game
@property UIButton *rightButton;
/// Button to end the game
@property UIButton *leftButton;

@end

#pragma mark - Implementation

@implementation AuxiliaryMenuView

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
	self.label = [[UILabel alloc] init];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.numberOfLines = 0;
	self.label.font = [UIFont fontWithName:@"VAGRoundedBT-Regular" size:20.0];
	self.label.textColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1];
	self.label.shadowColor = [UIColor blackColor];
	self.label.shadowOffset = CGSizeMake(1, 1);
	[self.view addSubview:self.label];
	
	// Set the End Game Button
	self.leftButton = [[UIButton alloc]init];
	self.leftButton.layer.cornerRadius = 10;
	self.leftButton.layer.backgroundColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1].CGColor;
	[self.leftButton setTitle:NSLocalizedString(_leftButtonTag, nil) forState:UIControlStateNormal];
	self.leftButton.titleLabel.font = [UIFont fontWithName:@"VAGRoundedBT-Regular" size:15.0];
	self.leftButton.titleLabel.textColor = [UIColor whiteColor];
	[self.leftButton addTarget:self
				   action:@selector(leftButtonAction:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.leftButton];
	
	// Set the Continue Button
	self.rightButton = [[UIButton alloc]init];
	self.rightButton.layer.cornerRadius = 10;
	self.rightButton.layer.backgroundColor = [UIColor colorWithHue:0.0333 saturation:0.51 brightness:1 alpha:1].CGColor;
	[self.rightButton setTitle:NSLocalizedString(_rightButtonTag, nil) forState:UIControlStateNormal];
	self.rightButton.titleLabel.font = [UIFont fontWithName:@"VAGRoundedBT-Regular" size:15.0];
	self.rightButton.titleLabel.textColor = [UIColor whiteColor];
	[self.rightButton addTarget:self
				   action:@selector(rightButtonAction:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.rightButton];
	
    if(self.type == 3){
        self.rightButton.hidden = YES;
    }
    
	[self setupConstraints];
}

/** 
 Set all the constraints
 */
-(void) setupConstraints
{
	[self.visualEffect setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.rightButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	NSDictionary *views = @{@"ve": self.visualEffect, @"v": self.view, @"lb": self.leftButton, @"rb": self.rightButton, @"pl": self.label};
	
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
	NSArray *vPosX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(<=50@900)-[v(<=300@1000)]-(<=50@900)-|"
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
	NSLayoutConstraint *vCenterX = [NSLayoutConstraint constraintWithItem:self.view
															 attribute:NSLayoutAttributeCenterX
															 relatedBy:NSLayoutRelationEqual
																toItem:self
															 attribute:NSLayoutAttributeCenterX
															multiplier:1
															  constant:0];
	NSLayoutConstraint *vHnW = [NSLayoutConstraint constraintWithItem:self.view
															attribute:NSLayoutAttributeHeight
															relatedBy:NSLayoutRelationEqual
															   toItem:self.view
															attribute:NSLayoutAttributeWidth
														   multiplier:1
															 constant:0];
	[self addConstraints:vPosX]; [self addConstraint:vPosY]; [self addConstraint:vCenterX]; [self addConstraint:vHnW];
	
	// Pause Label constraints
	NSArray *plPosX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[pl]-10-|"
															  options: 0
															  metrics:nil
																views:views];
	NSArray *plPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pl]"
															  options: 0
															  metrics:nil
																views:views];
	[self.view addConstraints:plPosX]; [self.view addConstraints:plPosY];
	
	// End Game Button constraints
	NSArray *lbWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[lb(==80)]"
																options: 0
																metrics:nil
																  views:views];
	NSLayoutConstraint *lbPosX;
	
	if (_type == 3) {
		lbPosX = [NSLayoutConstraint constraintWithItem:self.leftButton
															   attribute:NSLayoutAttributeCenterX
															   relatedBy:NSLayoutRelationEqual
																  toItem:self.view
															   attribute:NSLayoutAttributeCenterX
															  multiplier:1
																   constant:0];
	} else {
		lbPosX = [NSLayoutConstraint constraintWithItem:self.leftButton
															   attribute:NSLayoutAttributeTrailing
															   relatedBy:NSLayoutRelationEqual
																  toItem:self.view
															   attribute:NSLayoutAttributeCenterX
															  multiplier:1
																   constant:-20];
	}
	
	NSArray *lbPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pl]-10-[lb(==50)]-20-|"
															   options: 0
															   metrics:nil
																 views:views];
	[self.view addConstraints:lbWidth]; [self.view addConstraints:lbPosY]; [self.view addConstraint:lbPosX];
	
	// Continue Button constraints
	NSArray *rbWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rb(==80)]"
															   options: 0
															   metrics:nil
																 views:views];
	NSLayoutConstraint *rbPosX = [NSLayoutConstraint constraintWithItem:self.rightButton
															  attribute:NSLayoutAttributeLeading
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.view
															  attribute:NSLayoutAttributeCenterX
															 multiplier:1
															   constant:20];
	NSArray *rbPosY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pl]-10-[rb(==50)]-20-|"
															  options: 0
															  metrics:nil
																views:views];
	[self.view addConstraints:rbWidth]; [self.view addConstraints:rbPosY]; [self.view addConstraint:rbPosX];
}

#pragma mark - Action Methods
/**
 Method to when the button is selected, continue the game
 */
-(void) leftButtonAction:(UIButton *)sender
{
	[self.delegate leftButtonAction];
}

/**
 Method to when the button is selected, end the game
 */
-(void) rightButtonAction:(UIButton *)sender
{
	[self.delegate rightButtonAction];
}

#pragma mark - Public Methods
/**
 Method to show the view
 */
-(void) show
{
	if (_type == 1) self.label.text = [NSString stringWithFormat:NSLocalizedString(_messageTag, nil), _peerName];
	else if (_type == 2 || _type == 3) self.label.text = NSLocalizedString(_messageTag, nil);
	
	self.hidden = NO;
	self.alpha = 0;
	
	[UIView animateWithDuration:0.3
					 animations:^{
						 self.alpha = 1;
					 }
					 completion:nil];
}

/**
 Method to hide the view
 */
-(void) hide
{
	[UIView animateWithDuration:0.3
					 animations:^{
						 self.alpha = 0;
					 }
					 completion:^(BOOL completed){
						 self.hidden = YES;
					 }];
}

@end
