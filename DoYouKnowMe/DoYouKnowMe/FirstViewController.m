//
//  FirstViewController.m
//  DoYouKnowMe
//
//  Created by Felipe Eulálio on 31/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "Player.h"

#pragma mark - Private Interface

@interface FirstViewController ()

#pragma mark - Interface Properties
/// Interface Text Field to edit the display name from the device
@property (weak, nonatomic) IBOutlet UITextField *txtName;

/// Interface Label to show the name of the friend that you are connected with
@property (weak, nonatomic) IBOutlet UILabel *browseLabel;

/// Interface Button to look for another device
@property (weak, nonatomic) IBOutlet UIButton *browseBtn;

/// Interface Button to disconect with the other device
@property (weak, nonatomic) IBOutlet UIButton *disconectBtn;

/// Interface Label to show the name from the device that you are connected with
@property (weak, nonatomic) IBOutlet UILabel *connectedDevice;

/// Interface  Button to go to the next View
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

#pragma mark - Other Properties
/// AppDelegate object to creat an access to the Connectivity class trough the app delegate
@property (nonatomic, strong) AppDelegate *appDelegate;

/// Array to keep the device tha you are connected with
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;

@end

@implementation FirstViewController

#pragma mark - Initial Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	// Iniciate the session
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
	[[_appDelegate mcManager] advertiseSelf:YES];
	
	[_txtName setDelegate:self];
	
	// Disable buttons and labels, but the initial ones
	_browseLabel.hidden = YES;
	_browseBtn.hidden = YES;
	_disconectBtn.hidden = YES;
	_connectedDevice.hidden = YES;
	_nextBtn.hidden = YES;
	
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

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	
	if ([allPeers count] == 0) {
		[_arrConnectedDevices removeAllObjects];
		
		_connectedDevice.hidden = YES;
		_nextBtn.hidden = YES;
	}
}

/**
 Method to browse for new devices
 **/
- (IBAction)browseForDevices:(id)sender
{
	[[_appDelegate mcManager] setupMCBrowser];
	[[[_appDelegate mcManager] browser] setDelegate:self];
	
	_appDelegate.mcManager.browser.maximumNumberOfPeers = 1;
	
	[self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
}

- (IBAction)Disconect:(id)sender
{
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	
	[_appDelegate.mcManager.session disconnect];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_disconectBtn.hidden = YES;
	});
	
	[_appDelegate.mcManager.session sendData:[@"!disconnect" dataUsingEncoding:NSUTF8StringEncoding]
									 toPeers:allPeers
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	[Player setPlayerID:-1];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
	[_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
	[_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[_txtName resignFirstResponder];
	
	_appDelegate.mcManager.peerID = nil;
	_appDelegate.mcManager.session = nil;
	_appDelegate.mcManager.browser = nil;
	
	[_appDelegate.mcManager.advertiser stop];
	_appDelegate.mcManager.advertiser = nil;
	
	[_appDelegate.mcManager setupPeerAndSessionWithDisplayName:_txtName.text];
	[_appDelegate.mcManager setupMCBrowser];
	[_appDelegate.mcManager advertiseSelf:YES];
	
	_browseLabel.hidden = NO;
	_browseBtn.hidden = NO;
	
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
			if ([_arrConnectedDevices count] > 0)
			{
					[_arrConnectedDevices removeAllObjects];
			}
			[_arrConnectedDevices addObject:peerDisplayName];
		}
		else if (state == MCSessionStateNotConnected)
		{
			if ([_arrConnectedDevices count] > 0)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					[_arrConnectedDevices removeAllObjects];
				});
			}
		}
		
		BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
		[_txtName setEnabled:peersExist];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!peersExist)
			{
				_connectedDevice.text = [NSString stringWithFormat:@"Ok, você está conectado com %@", peerDisplayName];
				_connectedDevice .hidden = NO;
				_nextBtn.hidden = NO;
				[_browseBtn setEnabled:NO];
				_disconectBtn.hidden = NO;
				
				NSLog(@"PEER EXIST! and is named %@", peerDisplayName);
			}
			else
			{
				_connectedDevice .hidden = YES;
				_nextBtn.hidden = YES;
				[_browseBtn setEnabled:YES];
				_disconectBtn.hidden = YES;
				NSLog(@"PEER DONT EXIST");
			}
		});
	}
	
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
	
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
	NSString *receivedInfo = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([receivedInfo isEqualToString:@"!disconnect"])
		{
			[_appDelegate.mcManager.session disconnect];
			
			NSLog(@"RECEBEU DISCONNECT");
			
			_disconectBtn.hidden = YES;
		}
	
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
