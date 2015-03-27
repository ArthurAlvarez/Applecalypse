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

@interface GameViewController ()
{
    int currentAnswers;
    bool didAnswer;
}

# pragma mark - Interface Properties
///Interface label that shows the time left for answering the game question
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

///Interface label that shows the current game question
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

///Interface TextField where the user inputs the answer to the game question
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;

///Interface Button that the user presses to submit the answer
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingIndicator;

#pragma mark - Controller Properties
///Number that represents the score of the current player
@property (strong, nonatomic) NSNumber *playerScore;

@property (strong, nonatomic) NSNumber *currentAnswers;

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) NSString *otherAnswer;

@property (strong, nonatomic) NSTimer *clockTimer;

@property (strong, nonatomic) NSNumber *timeLeft;

@end

#pragma mark - Controller Implementation
@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[_waitingIndicator stopAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    //Initializing properties
    self.playerScore = [NSNumber numberWithInt:0];
    currentAnswers = 0;
    didAnswer = NO;
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.timeLeft = [NSNumber numberWithInt:20];
    
    //Timer setup
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    });
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
			[_waitingIndicator startAnimating];
		}
		
    }
}

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

-(void) userDidNotAnswer{
    self.answerTextField.text = @"Não sei";
    [self answerPressed:self];

}

-(void) updateTimerLabel{
    if([self.timeLeft intValue] >= 0){
        self.timeLeft = [NSNumber numberWithInt:[self.timeLeft intValue] - 1];
        self.timerLabel.text = [NSString stringWithFormat:@"%@", self.timeLeft];
        
        
        if([self.timeLeft intValue] == -1 && didAnswer == NO){
            [self userDidNotAnswer];
        }
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
