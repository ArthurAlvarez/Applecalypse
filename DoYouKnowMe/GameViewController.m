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
#import "GameSettings.h"
#import "ResultsViewController.h"
#import <AudioToolbox/AudioToolbox.h>


@interface GameViewController()
{
    int shouldContinue;
    int currentAnswers;
    BOOL didAnswer;
    BOOL gameDidEnd;
    BOOL gameDidStart;
	BOOL alreadyPerformedSegue;
}

# pragma mark - Interface Properties
/// Interface label that shows the time left for answering the game question
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

/// Interface label that shows the current game question
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

///Interface TextField where the user inputs the answer to the game question
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;

/// Interface Activity Indicator View to show the player that he is waiting for the other answer
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingAnswer;

/// Interface Button to pause the game
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;

/// Interface Activity Indicator View to show the player that he is waiting the other player to
/// continue the game
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingPause;

/// Interface Label to show the raound that the game is
@property (weak, nonatomic) IBOutlet UILabel *showRound;

/// View that appear when the game is paused
@property (weak, nonatomic) IBOutlet PauseMenuView *pauseMenu;

/// ImageView to show a baloon with the question
@property (weak, nonatomic) IBOutlet UIImageView *question;

/// ImageView to display a baloon to the answer
@property (weak, nonatomic) IBOutlet UIImageView *answer;

@property (weak, nonatomic) IBOutlet UIImageView *showROrW;

@property (weak, nonatomic) IBOutlet UILabel *questionsAbout;

#pragma mark - Controller Properties
/// Number that represents the score of the current player
@property (strong, nonatomic) NSNumber *playerScore;

/// String containing the answer of the other user
@property (strong, nonatomic) NSString *otherAnswer;

/// Timer used for clock
@property (strong, nonatomic) NSTimer *clockTimer;

/// Timer used for syncronizing
@property (strong, nonatomic) NSTimer *syncTimer;

/// How much time the user still has
@property (strong, nonatomic) NSNumber *timeLeft;

/// Feedback sound
@property SystemSoundID rightAudio;

/// Feedback sound
@property SystemSoundID wrongAudio;

@end

#pragma mark - Controller Implementation
@implementation GameViewController

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
	
    //Setup notification for receiving packets
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"changeState"
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appDidEnterBG:)
												 name:@"didEnterBackGround"
											   object:nil];
	
    gameDidEnd = NO;
	
	UITapGestureRecognizer *touchToAnswer = [[UITapGestureRecognizer alloc] initWithTarget:self.answer action:@selector(startAnswering:)];
	[self.answer addGestureRecognizer:touchToAnswer];
	
	if ([Player getPlayerID] == 1) {
		self.question.image = [UIImage imageNamed:@"QuestionSelf"];
		self.questionsAbout.text = @"Pergunta sobre você";
	} else {
		self.question.image = [UIImage imageNamed:@"OtherAnswer"];
		self.questionsAbout.text = [NSString stringWithFormat:@"Pergunta sobre %@", _game.otherPlayer.displayName];
	}
    
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"sound_error"
                                              withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_wrongAudio);
    
    
    NSURL *soundURL2 = [[NSBundle mainBundle] URLForResource:@"sound_right"
                                              withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL2, &_rightAudio);
    
	self.showROrW.hidden = true;
}

/**
 This method is called always when the view is to be showed
 */
-(void)viewWillAppear:(BOOL)animated{
    //Incrementa round corrente
    [GameSettings incrementRound];
	
	
	if ([Player getPlayerID] == 1) [_game getQuestion];
    
    //Initializing properties
    gameDidStart = NO;
	
//    [self readJsonFile];
	
    self.playerScore = [NSNumber numberWithInt:0];
	
    shouldContinue = currentAnswers = 0;
    didAnswer = NO;
	
    self.timeLeft = [NSNumber numberWithInt:[GameSettings getTime]];
    self.timerLabel.text = [NSString stringWithFormat:@"%@", self.timeLeft];
	
    [_waitingAnswer stopAnimating]; [_waitingPause stopAnimating];
	
    self.answerTextField.text = @"";
    self.questionLabel.text = @"Carregando pergunta...";
	
	self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
													  target:self
													selector:@selector(syncroGame)
													userInfo:nil
													 repeats:YES];
	
	[_answerTextField setEnabled:YES];
	[self.pauseMenu hide];
	
	_otherWaiting = YES;
	alreadyPerformedSegue = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (![self.showROrW isHidden]) {
		[UIView animateWithDuration:0.1
						 animations:^{
							 self.showROrW.alpha = 0;
						 }
						 completion:^(BOOL completed){
							 self.showROrW.hidden = YES;
							 self.showROrW.alpha = 1;
						 }];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Others Methods

/**
 Starts the flow of game
 @author Arthur Alvarez
 */
-(void)gameSetup{
	
    //Timer setup
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1
													   target:self
													 selector:@selector(updateTimerLabel)
													 userInfo:nil
													  repeats:YES];
	
	_showRound.text = [NSString stringWithFormat:@"%d/%d", [GameSettings getCurrentRound], [GameSettings getGameLength]];
}

/**
 Perform a shake animation at the textfield when it is empty
 */
- (void) performShakeAnimation:(UIView *)object {
	
	CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
	
	[shake setDuration:0.1];
	[shake setRepeatCount:2];
	[shake setAutoreverses:YES];
	
	[shake setFromValue:[NSValue valueWithCGPoint: CGPointMake(object.center.x - 5, object.center.y)]];
	
	[shake setToValue:[NSValue valueWithCGPoint: CGPointMake(object.center.x + 5, object.center.y)]];
	
	[object.layer addAnimation:shake forKey:@"position"];
}

- (void) receivedAnswer
{
	if(currentAnswers == 0) {
		_otherWaiting = NO;
		currentAnswers = 1;
	} else if (!alreadyPerformedSegue) [self performSegueWithIdentifier:@"verifyAnswer" sender:self];
}

/** 
 Set the label to display the question
 */
- (void) setTheQuestion:(NSString*)question
{
	_questionLabel.text = question;
}

#pragma mark - Selectors

/**
 This method go to other method to pause the game
 **/
-(void)appDidEnterBG:(NSNotification *)notification{
	NSLog(@"Entrou BG");
	[self pauseGame:self];
}

/**
 This method is called when the state of the connection is changed
 **/
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting)
    {
        if (state == MCSessionStateNotConnected)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_clockTimer invalidate];
				
				[_syncTimer invalidate];
            });
        }
        
    }
}

-(void)syncroGame
{
	if([GameSettings getOtherDidLoad] == YES && gameDidStart == NO){
		
		[self.syncTimer invalidate];
		self.syncTimer = nil;
		gameDidStart = YES;
		[self gameSetup];
		NSLog(@"Recebeu a info");
	}
	
	[_game sendData:@"@start" fromViewController:self];
}

/**
 This method is called when the timer expires. By default, when this happens the answer from local user is "Nao sei"
 @author Arthur Alvarez
 */
-(void) userDidNotAnswer{
	if (_answerTextField.text.length == 0) self.answerTextField.text = @"Não sei";
	
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

-(void) startAnswering:(UITapGestureRecognizer *)tap
{
	NSLog(@"ENTROU");
	[self.answerTextField becomeFirstResponder];
}

#pragma mark - Action Methods

/**
 This method calls the transition to the verification screen. Called when the user presses the submitButton
 @author Arthur Alvarez
 */
- (IBAction)answerPressed:(id)sender {
	
    [self.view endEditing:YES];
    
    if(self.answerTextField.text.length > 0){
		
        [_game sendData:[NSString stringWithFormat:@"$%@", self.answerTextField.text] fromViewController:self];
        
        if (currentAnswers == 0) {
            currentAnswers = 1;
			didAnswer = YES;
			[_waitingAnswer startAnimating];
		} else [self performSegueWithIdentifier:@"verifyAnswer" sender:self];

			
	} else [self performShakeAnimation:_answerTextField];
}


- (IBAction)pauseGame:(id)sender
{
	if ([_answerTextField isFirstResponder]) [_answerTextField resignFirstResponder];
	
	[_clockTimer invalidate];
	
	if ([sender isKindOfClass:[UIButton class]]) {
		[_game sendData:@"||" fromViewController:self];
	}
	
	[self.pauseMenu show];
    shouldContinue = 0;
	
}

- (IBAction)tapGestureRecognizer:(id)sender {
    [self.view endEditing:YES];
}

/**
 This method is called upon transition to the next view
 @author Arthur Alvarez
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
    //Stops timer
    [_clockTimer invalidate];
    
    VerifyAnswerViewController *vc = segue.destinationViewController;
    ResultsViewController *vc2 = segue.destinationViewController;
	
	[_game sendData:@"@notwaiting" fromViewController:self];
	
	alreadyPerformedSegue = YES;
	
	if (_otherWaiting) {
		[_game sendData:[NSString stringWithFormat:@"$%@", self.answerTextField.text] fromViewController:self];
	}
	
    //Go to VerifyAnswerView
    if ([segue.identifier isEqualToString:@"verifyAnswer"]) {
		vc.game = _game;
		
		vc.delegate = self;
    }
    
    //Go to ResultsView
    else if([segue.identifier isEqualToString:@"finalResult"]){
		
        vc2.gameView = self;
    }
}

#pragma mark - Delegates

#pragma mark - VerifyAnswerControllerDelegate Delegate

-(void)didShowImage: (BOOL)right
{
	if (right) self.showROrW.image = [UIImage imageNamed:@"right-mark"];
	else self.showROrW.image = [UIImage imageNamed:@"wrong-mark"];
	
	self.showROrW.hidden = NO;
    
    if(right) AudioServicesPlaySystemSound(_rightAudio);
    else AudioServicesPlayAlertSound(_wrongAudio);
}

#pragma mark - PauseMenuView Delegate

-(void)resumeGame
{	
		if (shouldContinue == 0){
			[_game sendData:@">" fromViewController:self];
			shouldContinue = 1;
			[_waitingPause startAnimating];
		} else {
			_clockTimer = [NSTimer scheduledTimerWithTimeInterval:1
														   target:self
														 selector:@selector(updateTimerLabel)
														 userInfo:nil
														  repeats:YES];
			[self.pauseMenu hide];
		}
}

-(void)endGame
{
	[_game sendData:@"<" fromViewController:self];
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark - TextField Delegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
	
	[_waitingAnswer stopAnimating];
		
	currentAnswers = 0;
	
	return YES;
	
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	[self.view endEditing:YES];
	
	if(self.answerTextField.text.length > 0){
		
		[_game sendData:[NSString stringWithFormat:@"$%@", self.answerTextField.text] fromViewController:self];
		_game.myAnswer = self.answerTextField.text;
		
		if (currentAnswers == 0) {
			currentAnswers = 1;
			didAnswer = YES;
			[_waitingAnswer startAnimating];
		} else [self performSegueWithIdentifier:@"verifyAnswer" sender:self];
		
	} else [self performShakeAnimation:_answerTextField];
	
	return YES;
}

@end
