//
//  ConnectionsViewController.m
//  DoYouKnowMe
//
//  Created by Felipe Eulalio on 24/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "AppDelegate.h"

#pragma mark - Private Interface

@interface ConnectionsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *questionTo;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UISwitch *swVisible;
@property (weak, nonatomic) IBOutlet UILabel *connectedDevice;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;

@end

#pragma mark - Implementation

@implementation ConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
	[[_appDelegate mcManager] advertiseSelf:_swVisible.isOn];
	
	[_txtName setDelegate:self];
	
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

- (IBAction)browseForDevices:(id)sender
{
	[[_appDelegate mcManager] setupMCBrowser];
	[[[_appDelegate mcManager] browser] setDelegate:self];
	[self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
}

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
	}
	else
	{
		 dataToSend = [@"0" dataUsingEncoding:NSUTF8StringEncoding];
	}

	[_appDelegate.mcManager.session sendData:dataToSend
									 toPeers:allPeers
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
}

- (IBAction)disconnect:(id)sender
{
	[_appDelegate.mcManager.session disconnect];
	
	_txtName.enabled = YES;
	
	[_arrConnectedDevices removeAllObjects];
	[_connectedDevice setText:@""];
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
				[_arrConnectedDevices removeAllObjects];
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
		}
	}
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
	
	NSLog(@"index: %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
	
	_questionTo.selectedSegmentIndex = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] integerValue];
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
