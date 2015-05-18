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
///Interface Button where the user Accepts the answer
@property (weak, nonatomic) IBOutlet UIButton *btnAcceptAnswer;

///Interface Button where the user Rejects the answer
@property (weak, nonatomic) IBOutlet UIButton *btnRejectAnswer;

///Interface Label that identifies local user
@property (weak, nonatomic) IBOutlet UILabel *playerLabel;

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

/// Interface Label to show the name of the other player
@property (weak, nonatomic) IBOutlet UILabel *showFriendName;

///Delegate for comunications
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

#pragma mark - Controller Implementation

@implementation VerifyAnswerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
    //Setup of comunications
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
	//Setup of label texts
    self.playerLabel.text = _appDelegate.mcManager.session.myPeerID.displayName;
	self.myAsnwerLabel.text = [_yourAnswer stringByReplacingOccurrencesOfString:@"$" withString:@""];
	self.hisAsnwerLabel.text =[_hisAnswer stringByReplacingOccurrencesOfString:@"$" withString:@""];
	MCPeerID *friend = _appDelegate.mcManager.session.connectedPeers[0];
	_showFriendName.text = [NSString stringWithFormat:@"%@:", friend.displayName];
	
	//Modifies interface acording to user
	if([Player getPlayerID] == 1){
		NSLog(@"Player1");
		_wOrRLabel.hidden = NO;
		[self.btnAcceptAnswer setHidden:NO];
		[self.btnRejectAnswer setHidden:NO];
		[_waitingIndicator stopAnimating];
	}
	else{
		NSLog(@"Player2");
		_wOrRLabel.hidden = YES;
		[self.btnAcceptAnswer setHidden: YES];
		[self.btnRejectAnswer setHidden:YES];
		[_waitingIndicator startAnimating];
	}
	
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

/**
 This method is called when the user presses btnAcceptAnswer
 @author Arthur Alvarez
 */
- (IBAction)acceptAnswer:(id)sender {
	[self sendAnswer:@"#1"];
	[Player setScore:[Player getScore] +1];
    [self checkEndGame];
}

/**
 This method is called when the user presses btnRejectAnswer
 @author Arthur Alvarez
 */
- (IBAction)rejectAnswer:(id)sender {
	[self sendAnswer:@"#0"];
    [self checkEndGame];
}

/**
 This method is called when Player1 evaluates the answer and sends the result to Player2
 */
-(void)sendAnswer:(NSString*)strAnswer
{
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	NSData *dataToSend = [strAnswer dataUsingEncoding:NSUTF8StringEncoding];
	
	NSLog(@"Sending Data to: %@", allPeers);
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:allPeers
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
}

#pragma mark - Selectors

/**
 This method is called when the device receives data from other connected devices
 @author Arthur Alvarez
 */
-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
	NSString *receivedInfo = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
 
	NSLog(@"Received Data: %@", receivedInfo);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
        if([receivedInfo isEqualToString:@"#0"]){
            NSLog(@"Vibrate");
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            [self checkEndGame];
        }
		else if([receivedInfo isEqualToString:@"#1"]){
            NSLog(@"Somando pontuacao");
            [Player setScore:[Player getScore] +1];
            [self checkEndGame];
        }
	});
}

#pragma mark - Others Methods

-(void)checkEndGame{
    //Verifica fim do jogo
    if([GameSettings getCurrentRound] == [GameSettings getGameLength]){
        NSLog(@"Segue");
        [self performSegueWithIdentifier:@"finalResults" sender:self];
    }
    else
        [[self navigationController] popViewControllerAnimated:YES];
}

@end
