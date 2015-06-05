//
//  VerifyAnswerViewController.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "VerifyAnswerViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Connectivity.h"
#import "Player.h"
#import "AppDelegate.h"
#import "GameSettings.h"

#pragma mark - Properties

@interface VerifyAnswerViewController ()

{
	BOOL right;
}

///Interface Button where the user Accepts the answer
@property (weak, nonatomic) IBOutlet UIButton *btnAcceptAnswer;

///Interface Button where the user Rejects the answer
@property (weak, nonatomic) IBOutlet UIButton *btnRejectAnswer;

///Interface Label that shows local user answer
@property (weak, nonatomic) IBOutlet UILabel *myAsnwerLabel;

///Interface Label that shows the peer's answer
@property (weak, nonatomic) IBOutlet UILabel *hisAsnwerLabel;

/// Interface Indicator to show that the player is waiting for the other
/// to say if he is right or wrong
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingIndicator;

/// Label to show a message to the player, indicating to him answer if
/// the other player is right or wrong
@property (weak, nonatomic) IBOutlet UILabel *wOrRLabel;

@end

#pragma mark - Controller Implementation

@implementation VerifyAnswerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Setup of label texts
	self.myAsnwerLabel.text = _game.myAnswer;
	self.hisAsnwerLabel.text = _game.otherAnswer;
	
	//Modifies interface acording to user
	if([Player getPlayerID] == 1){
		NSLog(@"Player1");
		_wOrRLabel.hidden = NO;
		[_waitingIndicator stopAnimating];
	}
	else{
		NSLog(@"Player2");
		_wOrRLabel.hidden = YES;
		_btnAcceptAnswer.hidden = YES;
		_btnRejectAnswer.hidden = YES;
		[_waitingIndicator startAnimating];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

/**
 This method is called when the user presses btnAcceptAnswer or btnRejectAnswer
 @author Arthur Alvarez
 */
- (IBAction)judgeAnswer:(UIButton*)sender
{
    [self verifyAnswer:sender.tag == 1];
}

#pragma mark - Others Methods

- (void) verifyAnswer:(BOOL)isCorrect
{
	if ([Player getPlayerID] == 1) {
		if (!isCorrect) [_game sendData:@"#0" fromViewController:self];
		else [_game sendData:@"#1" fromViewController:self];
	} else if (!isCorrect) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

	if ([_game addScore:YES]) [self performSegueWithIdentifier:@"finalResults" sender:self];
	else {
		if ([Player getPlayerID] == 2) [self.delegate didShowImage:isCorrect];
        [[self navigationController] popViewControllerAnimated:YES];
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"finalResults"]) {
		self.delegate = segue.destinationViewController;
	}
	
	if ([Player getPlayerID] == 2) [self.delegate didShowImage:right];
}

@end
