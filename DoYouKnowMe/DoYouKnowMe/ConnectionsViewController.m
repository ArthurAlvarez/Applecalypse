//
//  ConnectionsViewController.m
//  DoYouKnowMe
//
//  Created by Felipe Eulalio on 24/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "AppDelegate.h"
#import "Player.h"
#import "GameSettings.h"

#pragma mark - Private Interface

@interface ConnectionsViewController ()
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

#pragma mark - Others Properties
/// AppDelegate object to creat an access to the Connectivity class trough the app delegate
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

#pragma mark - Implementation

@implementation ConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[_questionTo setTitle:[NSString stringWithFormat:@"%@", self.appDelegate.connectedPeer.displayName]
		forSegmentAtIndex:1];
	
	[_waitingIndicator stopAnimating];
	
	[Player setPlayerID:-1];
	
	canStart = 0;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerDidChangeStateWithNotification:)
												 name:@"MCDidChangeStateNotification"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveDataWithNotification:)
												 name:@"MCDidReceiveDataNotification"
											   object:nil];
	
	_startBtn.layer.cornerRadius = 5;
	
}
/**
 Set all constants  and infos
 */
-(void) viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:YES];
	
	_startBtn.hidden = YES;
	
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
	NSError *error;
	NSData *dataToSend;
	
	if (_questionTo.selectedSegmentIndex == 0)
	{
		dataToSend = [@"!1" dataUsingEncoding:NSUTF8StringEncoding];
		[Player setPlayerID:1];
	}
	else
	{
		dataToSend = [@"!0" dataUsingEncoding:NSUTF8StringEncoding];
		[Player setPlayerID:2];
	}
	
	NSLog(@"ID %d", [Player getPlayerID]);
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
	_startBtn.hidden = NO;
}

/**
 Defines the number of questions that the game will have
 **/
- (IBAction)numberOfQuestons:(id)sender
{
	NSError *error;
	NSData *dataToSend = [[NSString stringWithFormat:@"()%ld", (long)_numberOfQuestions.selectedSegmentIndex]
						  dataUsingEncoding:NSUTF8StringEncoding];
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
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
}

/**
 Set the time that the players have to answer the questions
 */
- (IBAction)timeToAnswer:(id)sender
{
	NSError *error;
	NSData *dataToSend = [[NSString stringWithFormat:@"....%ld", (long)_timeToAnswer.selectedSegmentIndex]
						  dataUsingEncoding:NSUTF8StringEncoding];
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
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
}

/** 
 Method to disconnect with the other device
 **/
- (IBAction)disconnect:(id)sender
{
	NSError *error;
	
	[_appDelegate.mcManager.session disconnect];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[_btnDisconnect setEnabled:NO];
		[_startBtn setEnabled:NO];
	});
	
	[_appDelegate.mcManager.session sendData:[@"!disconnect" dataUsingEncoding:NSUTF8StringEncoding]
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	[Player setPlayerID:-1];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

/**
 Method to start the game. Verifies if both players had pressed the button. If both had pressed,
 initiates the game, otherwise, show to the player that he is waiting for the other player
 **/
- (IBAction)startGame:(id)sender {
	
	NSError *error;
	
	[_startBtn setEnabled:NO];
	
	if (canStart == 0) {
		canStart = 1;
		[_waitingOtherLabel setText:@"Esperando pelo outro jogador..."];
	 
		[_waitingIndicator startAnimating];
	} else [self performSegueWithIdentifier:@"startGame" sender:self];;
	

	[_appDelegate.mcManager.session sendData:[@"!start" dataUsingEncoding:NSUTF8StringEncoding]
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
}

- (IBAction)goBack:(id)sender
{
	NSError *error;
	
	[_appDelegate.mcManager.session sendData:[@"!goBack" dataUsingEncoding:NSUTF8StringEncoding]
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark - Selectors

/**
 Methodd to verify when the connection chances its state
 **/
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
		dispatch_async(dispatch_get_main_queue(), ^{
			BOOL peersExist = ([_appDelegate.mcManager.session.connectedPeers count] == 0);
			[_btnDisconnect setEnabled:!peersExist];
			[_startBtn setEnabled:!peersExist];
			
			if (peersExist){
				[_waitingOtherLabel setText:@""];
				[_waitingIndicator stopAnimating];
				canStart = 0;
				
				if (!didTouchInDisconnect && !alreadyShownAlert &&
					![self.appDelegate.mcManager.session.connectedPeers containsObject:self.appDelegate.connectedPeer]) {
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

/**
 Method to when the devide receive some data
 **/
-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
	NSString *receivedInfo = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	dispatch_async(dispatch_get_main_queue(), ^{
        
        if([receivedInfo isEqualToString:@"@start"]){
            NSLog(@"Received start");
            [GameSettings setOtherDidLoad:YES];
        }
		else if ([receivedInfo isEqualToString:@"!1"] || [receivedInfo isEqualToString:@"!0"]){
			
			if ([receivedInfo isEqualToString:@"!0"])
			{
				[Player setPlayerID:1];
				_questionTo.selectedSegmentIndex = 0;
			}
			else
			{
				[Player setPlayerID:2];
				_questionTo.selectedSegmentIndex = 1;
			}
			
			_startBtn.hidden = NO;
			
			NSLog(@"ID %d", [Player getPlayerID]);
		}
		else if ([receivedInfo isEqualToString:@"!disconnect"]){
			[_appDelegate.mcManager.session disconnect];
			
			NSLog(@"RECEBEU DISCONNECT");
			
			[_btnDisconnect setEnabled:NO];
			
			[[self navigationController] popToRootViewControllerAnimated:YES];
		}
		else if ([receivedInfo isEqualToString:@"!start"]){
			if (canStart == 0) {
				canStart = 1;
			} else
				if ([Player getPlayerID] != -1) [self performSegueWithIdentifier:@"startGame" sender:self];
			
		}
		else if ([receivedInfo hasPrefix:@"()"]){
			int index = [[receivedInfo stringByReplacingOccurrencesOfString:@"()" withString:@""] intValue];
			
			_numberOfQuestions.selectedSegmentIndex = index;
			
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
			
		}
		else if ([receivedInfo isEqualToString:@"!goBack"]){
			[[self navigationController] popToRootViewControllerAnimated:YES];
		}
		else if ([receivedInfo hasPrefix:@"...."]) {
			int index = [[receivedInfo stringByReplacingOccurrencesOfString:@"...." withString:@""] intValue];

			_timeToAnswer.selectedSegmentIndex = index;

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
		}
	});

}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *tittle = [alertView buttonTitleAtIndex:buttonIndex];
	
	if ([tittle isEqualToString:@"Ok"]) {
		[[self navigationController] popToRootViewControllerAnimated:YES];
	}
	
	
}

@end
