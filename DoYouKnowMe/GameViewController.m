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
#import "ResultsViewController.h"

@interface GameViewController ()
{
    int shouldContinue;
    int currentAnswers;
    BOOL didAnswer;
    BOOL gameDidEnd;
    BOOL gameDidStart;
	BOOL otherWaiting;
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

/// Interface Label to show the raound that the game is
@property (weak, nonatomic) IBOutlet UILabel *showRound;

/// View that appear when the game is paused
@property (weak, nonatomic) IBOutlet PauseMenuView *pauseMenu;

#pragma mark - Controller Properties
/// Number that represents the score of the current player
@property (strong, nonatomic) NSNumber *playerScore;

/// Delegate for comunications
@property (strong, nonatomic) AppDelegate *appDelegate;

/// String containing the answer of the other user
@property (strong, nonatomic) NSString *otherAnswer;

/// Timer used for clock
@property (strong, nonatomic) NSTimer *clockTimer;

/// Timer used for syncronizing
@property (strong, nonatomic) NSTimer *syncTimer;

/// How much time the user still has
@property (strong, nonatomic) NSNumber *timeLeft;

/// Dictionary to keep the questions from the Json file
@property NSDictionary *questionsJson;

/// Array to know which questions already were made
@property NSMutableArray *repeatedQuestions;

@end

#pragma mark - Controller Implementation
@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    //Setup notification for receiving packets
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appDidEnterBG:)
												 name:@"didEnterBackGround"
											   object:nil];
	
    gameDidEnd = NO;
	
	self.repeatedQuestions = [[NSMutableArray alloc]init];
}

/**
 This method is called always when the view is to be showed
 */
-(void)viewWillAppear:(BOOL)animated{
    //Incrementa round corrente
    [GameSettings incrementRound];
    
    //Initializing properties
    gameDidStart = NO;
	
    [self readJsonFile];
	
    self.playerScore = [NSNumber numberWithInt:0];
	
    shouldContinue = currentAnswers = 0;
    didAnswer = NO;
	
    self.submitButton.enabled = YES;
	
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
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
	
	otherWaiting = YES;
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
    
    //Setup Player Label
    if([Player getPlayerID] == 1) {
        self.playerLabel.text = @"Pergunta sobre você";
        [self questionTextFromIndex:[self getQuestion]];
    }
    else{
        if(self.appDelegate.connectedPeer != nil){
            self.playerLabel.text = [NSString stringWithFormat:@"Pergunta sobre %@", self.appDelegate.connectedPeer.displayName];
        }
    }
	
	_showRound.text = [NSString stringWithFormat:@"%d/%d", [GameSettings getCurrentRound], [GameSettings getGameLength]];
}

/**
    Reads the JSON file containing the questions into a dictionary
    @author Arthur Alvarez
 */
-(void)readJsonFile{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"txt"];
    
    self.questionsJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:nil];
	
	if (self.questionsJson == nil) {
		NSLog(@"ERROR OPENING JSON!!");
	}
}

/**
    Gets the index of selected question and sends to the other peer
    @author Arthur Alvarez
 */
-(NSNumber *)getQuestion{
    NSNumber *numQuestions, *selectedQuestion;
    NSError *error;
    NSData *dataToSend;
    bool decided = NO, repeated = NO;
    
    
    numQuestions = [NSNumber numberWithInt:[[self.questionsJson objectForKey:@"size"]intValue]];
    NSLog(@"Size: %@", numQuestions);
    
    
    while(decided == NO){
        selectedQuestion = [NSNumber numberWithInt:arc4random() % [numQuestions intValue]];
        
        repeated = NO;
        for(NSNumber *n in self.repeatedQuestions){
            if([selectedQuestion intValue] == [n intValue])
                repeated = YES;
        }
        
        if(repeated == NO){
            [self.repeatedQuestions addObject:[NSNumber numberWithInt:[selectedQuestion intValue]]];
            decided = YES;
        }
        else{
            NSLog(@"Repeated!");
        }
    }
        
    NSLog(@"selected: %@", selectedQuestion);
    dataToSend = [[NSString stringWithFormat:@"*&*%@", selectedQuestion] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Sending question: %@", dataToSend);
    
    [_appDelegate.mcManager.session sendData:dataToSend
                                     toPeers:@[self.appDelegate.connectedPeer]
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    return selectedQuestion;
}

-(NSString *)questionTextFromIndex:(NSNumber *)index{
    NSDictionary *q = [self.questionsJson objectForKey:@"questions"];
    NSString *questionText = [NSString stringWithFormat:@"%@", [q objectForKey:[NSString stringWithFormat:@"%@", index]]];
    
    self.questionLabel.text = questionText;
    
    return questionText;
}

/**
 Sends the string containing the answer to the other player
 @author Arthur Alvarez
 */
-(void)sendAnswer:(NSString*)strAnswer
{
	NSError *error;
	NSData *dataToSend = [strAnswer dataUsingEncoding:NSUTF8StringEncoding];
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
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

#pragma mark - Selectors

/**
 This method go to other method to pause the game
 **/
-(void)appDidEnterBG:(NSNotification *)notification{
	NSLog(@"Entrou BG");
	[self pauseGame:self];
}

/**
 This method is called when the device received some data from other peers
 @author Arthur Alvarez
 */
-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedInfo = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"Received data: %@", receivedInfo);
        
        if([receivedInfo isEqualToString:@"@start"]){
            [GameSettings setOtherDidLoad:YES];
		} else if ([receivedInfo isEqualToString:@"@notwaiting"]) {
			otherWaiting = NO;
		} else if([receivedInfo hasPrefix:@"$"]) {
			
            self.otherAnswer = receivedInfo;
            
			if(currentAnswers == 0) {
				otherWaiting = NO;
				currentAnswers = 1;
			} else [self performSegueWithIdentifier:@"verifyAnswer" sender:self];
			
        } else if([receivedInfo hasPrefix:@"*&*"]){
			
			
            NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
            NSString *formatted = [receivedInfo stringByReplacingOccurrencesOfString:@"*&*" withString:@""];
            [self questionTextFromIndex:[f numberFromString:formatted]];
			
        } else if ([receivedInfo isEqualToString:@">"]){
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
        else if ([receivedInfo isEqualToString:@"||"]){
            shouldContinue = 0;
            
            [_clockTimer invalidate];
			
			[self.pauseMenu show];
        }
        
        else if ([receivedInfo isEqualToString:@"<"]){
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
    });
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

-(void)syncroGame {
	NSData *dataToSend = [[NSString stringWithFormat:@"@start"] dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error;
	
	if([GameSettings getOtherDidLoad] == YES && gameDidStart == NO){
		
		[_appDelegate.mcManager.session sendData:dataToSend
										 toPeers:@[self.appDelegate.connectedPeer]
										withMode:MCSessionSendDataReliable
										   error:&error];
		
		[self.syncTimer invalidate];
		self.syncTimer = nil;
		gameDidStart = YES;
		[self gameSetup];
		NSLog(@"Recebeu a info");
	} else {
		/* Syncronizing Players */
		
		NSLog(@"Sending ready_to_start: %@", dataToSend);
		
		[_appDelegate.mcManager.session sendData:dataToSend
										 toPeers:@[self.appDelegate.connectedPeer]
										withMode:MCSessionSendDataReliable
										   error:&error];
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
		}
	}
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

#pragma mark - Action Methods

/**
 This method calls the transition to the verification screen. Called when the user presses the submitButton
 @author Arthur Alvarez
 */
- (IBAction)answerPressed:(id)sender {
	
	if ([self.timeLeft intValue] == 0) {
		[self performSegueWithIdentifier:@"verifyAnswer" sender:self];
		
		return;
	}
	
    [self.view endEditing:YES];
    
    if(self.answerTextField.text.length > 0){
		
        [self sendAnswer:[NSString stringWithFormat:@"$%@", self.answerTextField.text]];
        
        if (currentAnswers == 0) {
            currentAnswers = 1;
			self.submitButton.enabled = NO;
			didAnswer = YES;
			[_waitingAnswer startAnimating];
		} else [self performSegueWithIdentifier:@"verifyAnswer" sender:self];

			
	} else [self performShakeAnimation:_answerTextField];
}


- (IBAction)pauseGame:(id)sender
{
	if ([_answerTextField isFirstResponder]) [_answerTextField resignFirstResponder];
	
	[_clockTimer invalidate];
	
    [self.pauseMenu show];
    
    NSError *error;
    NSData *dataToSend = [@"||" dataUsingEncoding:NSUTF8StringEncoding];
    
    [_appDelegate.mcManager.session sendData:dataToSend
                                     toPeers:@[self.appDelegate.connectedPeer ]
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
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
	
	NSError *error;
	NSData *dataToSend = [@"@notwaiting" dataUsingEncoding:NSUTF8StringEncoding];
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	
	if (otherWaiting) {
		[self sendAnswer:[NSString stringWithFormat:@"$%@", self.answerTextField.text]];
	}
	
    //Go to VerifyAnswerView
    if ([segue.identifier isEqualToString:@"verifyAnswer"]) {
        
        //Pass information to next view
        vc.yourAnswer = self.answerTextField.text;
        vc.hisAnswer = self.otherAnswer;
    }
    
    //Go to ResultsView
    else if([segue.identifier isEqualToString:@"finalResult"]){
        vc2.gameView = self;
    }
}

#pragma mark - Delegates
#pragma mark - PauseMenuView Delegate

-(void)resumeGame
{
	NSError *error;
	NSData *dataToSend;
	
		dataToSend = [@">" dataUsingEncoding:NSUTF8StringEncoding];
		
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
										 toPeers:@[self.appDelegate.connectedPeer]
										withMode:MCSessionSendDataReliable
										   error:&error];
	[self.pauseMenu hide];
}

-(void)endGame
{
	NSError *error;
	NSData *dataToSend;
	
	dataToSend = [@"<" dataUsingEncoding:NSUTF8StringEncoding];
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark - TextField Delegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
	
	[_waitingAnswer stopAnimating];
	
	[_submitButton setEnabled:YES];
	
	currentAnswers = 0;
	
	return YES;
	
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	[self.view endEditing:YES];
	
	if(self.answerTextField.text.length > 0){
		
		[self sendAnswer:[NSString stringWithFormat:@"$%@", self.answerTextField.text]];
		
		if (currentAnswers == 0) {
			currentAnswers = 1;
			self.submitButton.enabled = NO;
			didAnswer = YES;
			[_waitingAnswer startAnimating];
		} else [self performSegueWithIdentifier:@"verifyAnswer" sender:self];
		
	} else [self performShakeAnimation:_answerTextField];
	
	return YES;
}

@end
