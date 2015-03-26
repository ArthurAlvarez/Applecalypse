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

#pragma mark - Private Interface

@interface ConnectionsViewController ()
{
	int canStart;
}

/// Interface Segmented Control to know which kind the player is
@property (weak, nonatomic) IBOutlet UISegmentedControl *questionTo;

/// Interface Button to start the game
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

/// Interface Text Field to edit the display name from the device
@property (weak, nonatomic) IBOutlet UITextField *txtName;

/// Interface Switch to set if the device is visible or not
@property (weak, nonatomic) IBOutlet UISwitch *swVisible;

/// Interface Label to show the name from the device that you are connected with
@property (weak, nonatomic) IBOutlet UILabel *connectedDevice;

/// Intarface Button to disconnect with the other device
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;

/// AppDelegate object to creat an access to the Connectivity class trough the app delegate
@property (nonatomic, strong) AppDelegate *appDelegate;

/// Array to keep the device tha you are connected with
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;

@property (weak, nonatomic) IBOutlet UILabel *waitingOtherLabel;


@end

#pragma mark - Implementation

@implementation ConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	// Iniciate the session
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
	[[_appDelegate mcManager] advertiseSelf:_swVisible.isOn];
	
	[_txtName setDelegate:self];
	
	[Player setScore:0];
	
	canStart = 0;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerDidChangeStateWithNotification:)
												 name:@"MCDidChangeStateNotification"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveDataWithNotification:)
												 name:@"MCDidReceiveDataNotification"
											   object:nil];
	
	_arrConnectedDevices = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

/**
 Method to browse for new devices
 **/
- (IBAction)browseForDevices:(id)sender
{
	[[_appDelegate mcManager] setupMCBrowser];
	[[[_appDelegate mcManager] browser] setDelegate:self];
	[self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
}

/**
 Method to alternate between visible or not
 **/
- (IBAction)toggleVisibility:(id)sender
{
	[_appDelegate.mcManager advertiseSelf:_swVisible.isOn];
}
- (IBAction)questionsTo:(id)sender {
	
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	NSData *dataToSend;
	
	if (_questionTo.selectedSegmentIndex == 0)
	{
		dataToSend = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
		[Player setPlayerID:1];
	}
	else
	{
		dataToSend = [@"0" dataUsingEncoding:NSUTF8StringEncoding];
		[Player setPlayerID:2];
	}
	
	NSLog(@"ID %d", [Player getPlayerID]);
	
	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:allPeers
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
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	
	[_appDelegate.mcManager.session disconnect];
	
	_txtName.enabled = YES;
	
	[_btnDisconnect setEnabled:NO];
	[_startBtn setEnabled:NO];
	[_arrConnectedDevices removeLastObject];
	[_connectedDevice setText:@""];
	
	[_appDelegate.mcManager.session sendData:[@"disconnect" dataUsingEncoding:NSUTF8StringEncoding]
									 toPeers:allPeers
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
}
- (IBAction)startGame:(id)sender {
	
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	
	canStart++;
	[_waitingOtherLabel setText:@"Esperando pelo outro jogador..."];

	[_appDelegate.mcManager.session sendData:[@"start" dataUsingEncoding:NSUTF8StringEncoding]
									 toPeers:allPeers
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (canStart == 2) [self performSegueWithIdentifier:@"startGame" sender:self];
	
}

#pragma mark - MCBrowserViewController Delegate

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
	[_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
	[_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[_txtName resignFirstResponder];
	
	_appDelegate.mcManager.peerID = nil;
	_appDelegate.mcManager.session = nil;
	_appDelegate.mcManager.browser = nil;
	
	if ([_swVisible isOn]) {
		[_appDelegate.mcManager.advertiser stop];
	}
	_appDelegate.mcManager.advertiser = nil;
	
	[_appDelegate.mcManager setupPeerAndSessionWithDisplayName:_txtName.text];
	[_appDelegate.mcManager setupMCBrowser];
	[_appDelegate.mcManager advertiseSelf:_swVisible.isOn];
	
	return YES;
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
	MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
	NSString *peerDisplayName = peerID.displayName;
	MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
	
	if (state != MCSessionStateConnecting)
	{
		if (state == MCSessionStateConnected)
		{
			[_arrConnectedDevices addObject:peerDisplayName];
		}
		else if (state == MCSessionStateNotConnected)
		{
			if ([_arrConnectedDevices count] > 0)
			{
				[_arrConnectedDevices removeLastObject];
			}
		}
		
		BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
		[_btnDisconnect setEnabled:!peersExist];
		[_startBtn setEnabled:!peersExist];
		[_txtName setEnabled:peersExist];
		
		if (!peersExist)
		{
			[_connectedDevice setText:peerDisplayName];
			NSLog(@"PEER EXIST! and is named %@", peerDisplayName);
		}
		else {
			NSLog(@"PEER DONT EXIST");
			[_connectedDevice setText:@""];
			[_waitingOtherLabel setText:@""];
			canStart = 0;
		}
	}
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
	NSString *receivedInfo = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	if ([receivedInfo isEqualToString:@"1"] || [receivedInfo isEqualToString:@"0"])
	{
		_questionTo.selectedSegmentIndex = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] integerValue];
		if ([receivedInfo isEqualToString:@"0"]) [Player setPlayerID:1];
		else [Player setPlayerID:2];
		NSLog(@"ID %d", [Player getPlayerID]);
	}
	else if ([receivedInfo isEqualToString:@"disconnect"])
	{
		[_appDelegate.mcManager.session disconnect];
		
		_txtName.enabled = YES;
		
		NSLog(@"RECEBEU DISCONNECT");
		
		[_btnDisconnect setEnabled:NO];
		[_startBtn setEnabled:NO];
		[_arrConnectedDevices removeLastObject];
		[_connectedDevice setText:@""];
	}
	else if ([receivedInfo isEqualToString:@"start"])
	{
		canStart++;
		if (canStart == 2) [self performSegueWithIdentifier:@"startGame" sender:self];
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
