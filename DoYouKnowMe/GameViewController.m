//
//  GameViewController.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "GameViewController.h"
#import "Player.h"
#import "Connectivity.h"
#import "AppDelegate.h"
#import "VerifyAnswerViewController.h"
#import "GameSettings.h"

@interface GameViewController ()
{
	int shouldContinue;
	int currentAnswers;
	bool didAnswer;
}

# pragma mark - Interface Properties
/// Interface label that shows the time left for answering the game question
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

/// Interface label that shows the current game question
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

///Interface label that shows who the question is about
@property (weak, nonatomic) IBOutlet UILabel *playerLabel;

///Interface TextField where the user inputs the answer to the game question
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;

/// Interface Button that the user presses to submit the answer
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

/// Interface Activity Indicator View to show the player that he is waiting for the other answer
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingAnswer;

/// Interface Button to pause the game
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;

/// Interface Activity Indicator View to show the player that he is waiting the other player to
/// continue the game
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingPause;

#pragma mark - Controller Properties
///Number that represents the score of the current player
@property (strong, nonatomic) NSNumber *playerScore;

///Delegate for comunications
@property (strong, nonatomic) AppDelegate *appDelegate;

///String containing the answer of the other user
@property (strong, nonatomic) NSString *otherAnswer;

///Timer used for clock
@property (strong, nonatomic) NSTimer *clockTimer;

///How much time the user still has
@property (strong, nonatomic) NSNumber *timeLeft;

@property UIAlertView *pause;

@end

#pragma mark - Controller Implementation
@implementation GameViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
    MCPeerID *id;
    //Incrementa round corrente
    [GameSettings incrementRound];
    if([GameSettings getCurrentRound] > [GameSettings getGameLength]){
        [self performSegueWithIdentifier:@"finalResults" sender:self];
    }
    NSLog(@"Current round: %d, GameLength: %d", [GameSettings getCurrentRound], [GameSettings getGameLength]);
	//NSLog(@"Current Score: %d", [Player getScore]);
	
	//Setup notification for receiving packets
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveDataWithNotification:)
												 name:@"MCDidReceiveDataNotification"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerDidChangeStateWithNotification:)
												 name:@"MCDidChangeStateNotification"
											   object:nil];
	
	//Initializing properties
	self.playerScore = [NSNumber numberWithInt:0];
	shouldContinue = currentAnswers = 0;
	didAnswer = NO;
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.timeLeft = [NSNumber numberWithInt:20];
	[_waitingAnswer stopAnimating]; [_waitingPause stopAnimating];
	
	//Timer setup
	self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    
    //Setup Player Label
    if([Player getPlayerID] == 1){
        self.playerLabel.text = @"Pergunta sobre você";
    }
    else{
        id = _appDelegate.mcManager.session.connectedPeers[0];
        self.playerLabel.text = [NSString stringWithFormat:@"Pergunta sobre %@", id.displayName];
    }
	
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/**
 This method is called when the device received some data from other peers
 @author Arthur Alvarez
 */
-(void)didReceiveDataWithNotification:(NSNotification *)notification{
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
	NSString *receivedInfo = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		if([receivedInfo hasPrefix:@"$"]){
			
			self.otherAnswer = receivedInfo;
			
			if(currentAnswers == 0)
				currentAnswers = 1;
			else currentAnswers++;
			
			if(currentAnswers == 2)
				[self performSegueWithIdentifier:@"verifyAnswer" sender:self];
		}
		
		else if ([receivedInfo isEqualToString:@"!"]){
			if (shouldContinue == 0) shouldContinue = 1;
			else {
				[_waitingPause stopAnimating];
				
				_clockTimer = [NSTimer scheduledTimerWithTimeInterval:1
															   target:self
															 selector:@selector(updateTimerLabel)
															 userInfo:nil
															  repeats:YES];
				
			}
		}
		else if ([receivedInfo isEqualToString:@"!!"]){
			shouldContinue = 0;
			
			[_clockTimer invalidate];
			
			_pause = [[UIAlertView alloc] initWithTitle:@"Jogo pausado"
															message:@"O que deseja fazer?"
														   delegate:self
												  cancelButtonTitle:@"Continuar"
												  otherButtonTitles:@"Terminar o jogo", nil];
			
			[_pause show];
		}
		
		else if ([receivedInfo isEqualToString:@"@@@"]){
			[_pause dismissWithClickedButtonIndex:0 animated:YES];
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	});
}


-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
	
	MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
	
	if (state != MCSessionStateConnecting)
	{
		if (state == MCSessionStateNotConnected)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[_clockTimer invalidate];
				
				UIAlertView *lostConnection = [[UIAlertView alloc]initWithTitle:@"Conexão perdida"
																		message:@"A conexão com o outro jogador foi perdida..."
																	   delegate:self cancelButtonTitle:@"Terminar o jogo"
															  otherButtonTitles:nil];
				
				[lostConnection show];
			});
		}
		
	}
}

/**
 This method calls the transition to the verification screen. Called when the user presses the submitButton
 @author Arthur Alvarez
 */
- (IBAction)answerPressed:(id)sender {
	
	[self.view endEditing:YES];
	
	if(self.answerTextField.text.length > 0){
		
		[self sendAnswer:[NSString stringWithFormat:@"$%@", self.answerTextField.text]];
		
		if (currentAnswers == 0) {
			currentAnswers = 1;
		} else currentAnswers++;
		
		if(currentAnswers == 2)
		{
			[self performSegueWithIdentifier:@"verifyAnswer" sender:self];
		}
		else
		{
			self.submitButton.enabled = NO;
			didAnswer = YES;
			[_waitingAnswer startAnimating];
		}
		
	}
}


- (IBAction)pauseGame:(id)sender
{
	[_clockTimer invalidate];
	
	UIAlertView *pause = [[UIAlertView alloc] initWithTitle:@"Jogo pausado"
													message:@"O que deseja fazer?"
												   delegate:self
										  cancelButtonTitle:@"Continuar"
										  otherButtonTitles:@"Terminar o jogo", nil];
	[pause show];
	
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	NSData *dataToSend = [@"!!" dataUsingEncoding:NSUTF8StringEncoding];
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:allPeers
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
	shouldContinue = 0;
}

/**
 Sends the string containing the answer to the other player
 @author Arthur Alvarez
 */
-(void)sendAnswer:(NSString*)strAnswer
{
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	NSData *dataToSend = [strAnswer dataUsingEncoding:NSUTF8StringEncoding];
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:allPeers
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
}

/**
 This method is called upon transition to the next view
 @author Arthur Alvarez
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	VerifyAnswerViewController *vc = segue.destinationViewController;
	
	if ([segue.identifier isEqualToString:@"verifyAnswer"]) {
		
		//Pass information to next view
		vc.yourAnswer = self.answerTextField.text;
		vc.hisAnswer = self.otherAnswer;
	}
}

/**
 This method is called when the timer expires. By default, when this happens the answer from local user is "Nao sei"
 @author Arthur Alvarez
 */
-(void) userDidNotAnswer{
	self.answerTextField.text = @"Não sei";
	[self answerPressed:self];
	
}

/**
 Updates the timer label and calculates elapsed time
 @author Arthur Alvarez
 */
-(void) updateTimerLabel{
	if([self.timeLeft intValue] > 0){
		self.timeLeft = [NSNumber numberWithInt:[self.timeLeft intValue] - 1];
		self.timerLabel.text = [NSString stringWithFormat:@"%@", self.timeLeft];
		
		
		if([self.timeLeft intValue] == 0 && didAnswer == NO){
			[self userDidNotAnswer];
		}
	}
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *tittle = [alertView buttonTitleAtIndex:buttonIndex];
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
		NSError *error;
	NSData *dataToSend;
	
	if ([tittle isEqualToString:@"Continuar"]) {
		dataToSend = [@"!" dataUsingEncoding:NSUTF8StringEncoding];
		
		if (shouldContinue == 0){
			shouldContinue = 1;
			[_waitingPause startAnimating];
		} else {
			_clockTimer = [NSTimer scheduledTimerWithTimeInterval:1
														   target:self
														 selector:@selector(updateTimerLabel)
														 userInfo:nil
														  repeats:YES];
		}
		
		[_appDelegate.mcManager.session sendData:dataToSend
										 toPeers:allPeers
										withMode:MCSessionSendDataReliable
										   error:&error];
		
	} else if ([tittle isEqualToString:@"Terminar o jogo"]){
		dataToSend = [@"@@@" dataUsingEncoding:NSUTF8StringEncoding];
		
		[_appDelegate.mcManager.session sendData:dataToSend
											 toPeers:allPeers
											withMode:MCSessionSendDataReliable
											   error:&error];
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	
	
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
