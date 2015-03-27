//
//  VerifyAnswerViewController.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/25/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "VerifyAnswerViewController.h"
#import "Connectivity.h"
#import "Player.h"
#import "AppDelegate.h"

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

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingIndicator;


///Delegate for comunications
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

#pragma mark - Controller Implementation

@implementation VerifyAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Setup of label texts
    self.playerLabel.text = [NSString stringWithFormat:@"Player %d", [Player getPlayerID]];
    self.myAsnwerLabel.text = [_yourAnswer stringByReplacingOccurrencesOfString:@"$" withString:@""];
    self.hisAsnwerLabel.text =[_hisAnswer stringByReplacingOccurrencesOfString:@"$" withString:@""];
    
    //Modifies interface acording to user
    if([Player getPlayerID] == 1){
        NSLog(@"Player1");
        [self.btnAcceptAnswer setHidden:NO];
        [self.btnRejectAnswer setHidden:NO];
		[_waitingIndicator stopAnimating];
    }
    else{
        NSLog(@"Player2");
        [self.btnAcceptAnswer setHidden: YES];
        [self.btnRejectAnswer setHidden:YES];
		[_waitingIndicator startAnimating];
    }
    
    //Setup of comunications
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 This method is called when the user presses btnAcceptAnswer
@author Arthur Alvarez
 */
- (IBAction)acceptAnswer:(id)sender {
    [self sendAnswer:@"#1"];
    [self performSegueWithIdentifier:@"backToGame" sender:self];
}

/**
 This method is called when the user presses btnRejectAnswer
 @author Arthur Alvarez
 */
- (IBAction)rejectAnswer:(id)sender {
    [self sendAnswer:@"#0"];
    [self performSegueWithIdentifier:@"backToGame" sender:self];
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
		if([receivedInfo isEqualToString:@"#0"] || [receivedInfo isEqualToString:@"#1"])
			[self performSegueWithIdentifier:@"backToGame" sender:self];
	});
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
