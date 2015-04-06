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
    bool didAnswer;
    bool gameDidEnd;
    bool gameDidStart;
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

#pragma mark - Controller Properties
///Number that represents the score of the current player
@property (strong, nonatomic) NSNumber *playerScore;

///Delegate for comunications
@property (strong, nonatomic) AppDelegate *appDelegate;

///String containing the answer of the other user
@property (strong, nonatomic) NSString *otherAnswer;

///Timer used for clock
@property (strong, nonatomic) NSTimer *clockTimer;

///Timer used for syncronizing
@property (strong, nonatomic) NSTimer *syncTimer;

///How much time the user still has
@property (strong, nonatomic) NSNumber *timeLeft;

@property UIAlertView *pause;

@property NSDictionary *questionsJson;

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
	
	_pause = [[UIAlertView alloc] initWithTitle:@"Jogo pausado"
										message:@"O que deseja fazer?"
									   delegate:self
							  cancelButtonTitle:@"Continuar"
							  otherButtonTitles:@"Terminar o jogo", nil];
    
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
    self.timeLeft = [NSNumber numberWithInt:20];
    self.timerLabel.text = [NSString stringWithFormat:@"%@", self.timeLeft];
    [_waitingAnswer stopAnimating]; [_waitingPause stopAnimating];
    self.answerTextField.text = @"";
    self.questionLabel.text = @"Carregando pergunta...";
    
    //while([GameSettings getOtherDidLoad ] == NO);
    self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(syncroGame)
                                                 userInfo:nil
                                                  repeats:YES];
	
	[_answerTextField setEnabled:YES];
}

/**
 This method is called when the view has appeared
 */
-(void)viewDidAppear:(BOOL)animated{

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
    MCPeerID *id;

    //Timer setup
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    
    //Setup Player Label
    if([Player getPlayerID] == 1){
        self.playerLabel.text = @"Pergunta sobre você";
        [self questionTextFromIndex:[self getQuestion]];
    }
    else{
        if(_appDelegate.mcManager.session.connectedPeers.count > 0){
            id = _appDelegate.mcManager.session.connectedPeers[0];
            self.playerLabel.text = [NSString stringWithFormat:@"Pergunta sobre %@", id.displayName];
        }
    }
	
	_showRound.text = [NSString stringWithFormat:@"%d/%d", [GameSettings getCurrentRound], [GameSettings getGameLength]];
}

-(void)syncroGame{
    NSData *dataToSend = [[NSString stringWithFormat:@"@start"] dataUsingEncoding:NSUTF8StringEncoding];
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    
    if([GameSettings getOtherDidLoad] == YES && gameDidStart == NO){
		
		[_appDelegate.mcManager.session sendData:dataToSend
										 toPeers:allPeers
										withMode:MCSessionSendDataReliable
										   error:&error];
		
        [self.syncTimer invalidate];
        self.syncTimer = nil;
        gameDidStart = YES;
        [self gameSetup];
		NSLog(@"Recebeu a info");
    }
    else{
        /* Syncronizing Players */
        
        NSLog(@"Sending ready_to_start: %@", dataToSend);
        
        [_appDelegate.mcManager.session sendData:dataToSend
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

/**
    Reads the JSON file containing the questions into a dictionary
    @author Arthur Alvarez
 */
-(void)readJsonFile{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"txt"];
    
    self.questionsJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:nil];
    
    //NSLog(@"%@", self.questionsJson);
}

/**
    Gets the index of selected question and sends to the other peer
    @author Arthur Alvarez
 */
-(NSNumber *)getQuestion{
    NSNumber *numQuestions, *selectedQuestion;
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
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
                                     toPeers:allPeers
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
        }
        
        else if([receivedInfo hasPrefix:@"$"]){
            
            self.otherAnswer = receivedInfo;
            
            if(currentAnswers == 0)
                currentAnswers = 1;
            else currentAnswers++;
            
            if(currentAnswers == 2)
                [self performSegueWithIdentifier:@"verifyAnswer" sender:self];
        }
        
        else if([receivedInfo hasPrefix:@"*&*"]){
            NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
            NSString *formatted = [receivedInfo stringByReplacingOccurrencesOfString:@"*&*" withString:@""];
            [self questionTextFromIndex:[f numberFromString:formatted]];
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
			
            [_pause show];
        }
        
        else if ([receivedInfo isEqualToString:@"@@@"]){
            [_pause dismissWithClickedButtonIndex:0 animated:YES];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
    });
}

/**
 this method is called when the state of the connection is changed
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
				if ([_pause isVisible]){
					[_pause dismissWithClickedButtonIndex:0 animated:YES];
					[_syncTimer invalidate];
					NSLog(@"Is visible and shoudl have been dismissed!!!!!!");
				}
            });
        }
        
    }
}

#pragma mark - Action Methods

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
	
    [_pause show];
    
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

- (IBAction)tapGestureRecognizer:(id)sender {
    [self.view endEditing:YES];
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
    
    //Stops timer
    [_clockTimer invalidate];
    
    VerifyAnswerViewController *vc = segue.destinationViewController;
    ResultsViewController *vc2 = segue.destinationViewController;
    
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
        
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
    
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	[self.view endEditing:YES];
	
	[_answerTextField setEnabled:NO];
	
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
	return NO;
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
