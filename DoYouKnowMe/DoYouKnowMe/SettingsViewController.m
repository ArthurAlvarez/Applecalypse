//
//  ConnectionsViewController.m
//  DoYouKnowMe
//
//  Created by Felipe Eulalio on 24/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "Player.h"
#import "GameSettings.h"

#pragma mark - Private Interface

@interface SettingsViewController ()
{
	/// Flag to show when the game can start
	int canStart;
	
	BOOL didTouchInDisconnect;
	
	BOOL alreadyShownAlert;
}

#pragma mark - Interface Propeties
/// Interface Segmented Control to know which kind the player is
@property (weak, nonatomic) IBOutlet UISegmentedControl *questionTo;

/// Interface Segmented Control to know how many questions the game will have
@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOfQuestions;

/// Interface Segmented Control to select the time to answer the question
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeToAnswer;

/// Interface Button to start the game
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

/// Intarface Button to disconnect with the other device
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;

/// Interface Label to show a message to the player know that he is waiting the other player
@property (weak, nonatomic) IBOutlet UILabel *waitingOtherLabel;

/// Interface Indicator to show to the player that he is waiting to the other player
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingIndicator;

@end

#pragma mark - Implementation

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
		
	[_questionTo setTitle:[NSString stringWithFormat:@"%@", _game.otherPlayer.displayName]
		forSegmentAtIndex:1];
	
	[_waitingIndicator stopAnimating];
	
	[Player setPlayerID:-1];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerDidChangeStateWithNotification:)
												 name:@"changeState"
											   object:nil];
	
	_startBtn.layer.cornerRadius = 5;
	
}
/**
 Set all constants  and infos
 */
-(void) viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:YES];
	
	_startBtn.hidden = YES;
	_startBtn.enabled = YES;
	
	[_waitingIndicator stopAnimating];
	[_waitingOtherLabel setText:@""];
	
	[Player setScore:0];
	canStart = 0;
	
	[GameSettings setGameLenght:5];
	[GameSettings setRound:0];
	
	didTouchInDisconnect = NO;
	
	int indexNOQ = (int)_numberOfQuestions.selectedSegmentIndex;
	
	switch (indexNOQ) {
		case 0:
			[GameSettings setGameLenght:5];
			break;
		case 1:
			[GameSettings setGameLenght:10];
			break;
		case 2:
			[GameSettings setGameLenght:15];
			break;
		default:
			break;
	}
	int indexTTA = (int)_timeToAnswer.selectedSegmentIndex;
	
	switch (indexTTA) {
		case 0:
			[GameSettings setTime:20];
			break;
		case 1:
			[GameSettings setTime:30];
			break;
		case 2:
			[GameSettings setTime:40];
			break;
		default:
			break;
	}
	
	if ([Player getPlayerID] != -1) self.startBtn.hidden = NO;

	alreadyShownAlert = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

/**
 Method to select to who the questions are going to be made
 **/
- (IBAction)questionsTo:(id)sender
{

	
	if (_questionTo.selectedSegmentIndex == 0)
	{
		[_game sendData:@"!1" fromViewController:self];
		[Player setPlayerID:1];
	}
	else
	{
		[_game sendData:@"!0" fromViewController:self];
		[Player setPlayerID:2];
	}
	
	_startBtn.hidden = NO;
}

/**
 Defines the number of questions that the game will have
 **/
- (IBAction)numberOfQuestons:(id)sender
{
	int index = (int)_numberOfQuestions.selectedSegmentIndex;
	
	switch (index) {
		case 0:
			[GameSettings setGameLenght:5];
			break;
		case 1:
			[GameSettings setGameLenght:10];
			break;
		case 2:
			[GameSettings setGameLenght:15];
			break;
		default:
			break;
	}
	
	[_game sendData:[NSString stringWithFormat:@"()%d", index] fromViewController:self];
	
}

/**
 Set the time that the players have to answer the questions
 */
- (IBAction)timeToAnswer:(id)sender
{
	int index = (int)_timeToAnswer.selectedSegmentIndex;
	
	switch (index) {
		case 0:
			[GameSettings setTime:20];
			break;
		case 1:
			[GameSettings setTime:30];
			break;
		case 2:
			[GameSettings setTime:40];
			break;
		default:
			break;
	}
	
	[_game sendData:[NSString stringWithFormat:@".%d", index] fromViewController:self];
}

/** 
 Method to disconnect with the other device
 **/
- (IBAction)disconnect:(id)sender
{
	[_game finishSession];
	[Player setPlayerID:-1];
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

/**
 Method to start the game. Verifies if both players had pressed the button. If both had pressed,
 initiates the game, otherwise, show to the player that he is waiting for the other player
 **/
- (IBAction)startGame:(id)sender {
	
	NSError *error;
	
	[_startBtn setEnabled:NO];
	
	[self canStart];
	
	[_waitingOtherLabel setText:@"Esperando pelo outro jogador..."];
	
	[_waitingIndicator startAnimating];
	
	
	[_game sendData:@"!start" fromViewController:self];
}

- (IBAction)goBack:(id)sender
{
	[_game sendData:@"!goBack" fromViewController:self];
	
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark - Selectors

/**
 Methodd to verify when the connection chances its state
 **/
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
	dispatch_async(dispatch_get_main_queue(), ^{
		BOOL peersExist = ([_game.connectedDevices count] == 0);
		[_btnDisconnect setEnabled:!peersExist];
		[_startBtn setEnabled:!peersExist];
		
		if (peersExist){
			[_waitingOtherLabel setText:@""];
			[_waitingIndicator stopAnimating];
			canStart = 0;
			
			if (!didTouchInDisconnect && !alreadyShownAlert &&
				![_game.connectedDevices containsObject:_game.otherPlayer]) {
				alreadyShownAlert = YES;
				
				UIAlertView *disconected = [[UIAlertView alloc] initWithTitle:@"Conexao perdida"
																	  message:@"A conexão com seu amigo foi perdida"
																	 delegate:self
															cancelButtonTitle:@"Ok"
															otherButtonTitles: nil];
				[disconected show];
			}
			
		} else {
			if (canStart != 0) canStart = 0;
			[_startBtn setEnabled:YES];
		}
	});
	
}

#pragma mark - Auxiliary Methods

- (void) changePlayerID:(int)index
{
	_questionTo.selectedSegmentIndex = index;
	_startBtn.hidden = NO;
}

- (void) changeGameLenght:(int)index
{
	_numberOfQuestions.selectedSegmentIndex = index;
}

- (void) changeTimeToAnswer:(int)index
{
	_timeToAnswer.selectedSegmentIndex = index;
}

- (void) canStart
{
	if (canStart == 0) canStart = 1;
	else [self performSegueWithIdentifier:@"startGame" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UIViewController *vc = segue.destinationViewController;
	
	if ([vc isKindOfClass:[GameViewController class]]) {
		((GameViewController*) vc).game = _game;
	}
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *tittle = [alertView buttonTitleAtIndex:buttonIndex];
	
	if ([tittle isEqualToString:@"Ok"]) { [[self navigationController] popToRootViewControllerAnimated:YES]; }
}

@end
