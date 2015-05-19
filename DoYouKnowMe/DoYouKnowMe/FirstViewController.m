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
{
	/// Flag to know when the game can go to the next View
	int canGoNext;
}

#pragma mark - Interface Properties
/// Interface Text Field to edit the display name from the device
@property (weak, nonatomic) IBOutlet UITextField *txtName;

/// Label to say hello to the player
@property (weak, nonatomic) IBOutlet UILabel *helloLabel;

/// Label to ask the player's name
@property (weak, nonatomic) IBOutlet UILabel *askNameLabel;

/// Interface Button to look for another device
@property (weak, nonatomic) IBOutlet UIButton *browseBtn;

/// Interface Button to disconect with the other device
@property (weak, nonatomic) IBOutlet UIButton *disconectBtn;

/// Interface Label to show the name from the device that you are connected with
@property (weak, nonatomic) IBOutlet UILabel *connectedDevice;

/// Interface  Button to go to the next View
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

/// Interface Activity Indicator to show that the player is waiting the other
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingGoNext;

#pragma mark - Other Properties
/// AppDelegate object to creat an access to the Connectivity class trough the app delegate
@property (nonatomic, strong) AppDelegate *appDelegate;

/// Array to keep the device tha you are connected with
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;

@end

#pragma mark - Implementation

@implementation FirstViewController

#pragma mark - Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	// Iniciate the session
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [[_appDelegate mcManager] advertiseSelf:YES];
    _appDelegate.mcManager.advertiser.delegate = self;
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerDidChangeStateWithNotification:)
												 name:@"MCDidChangeStateNotification"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveDataWithNotification:)
												 name:@"MCDidReceiveDataNotification"
											   object:nil];
	
	// Set Tex Field delegate
	[_txtName setDelegate:self];
	
	// Hide buttons and labels
	_browseBtn.hidden = YES;
	_disconectBtn.hidden = YES;
	_connectedDevice.hidden = YES;
	_nextBtn.hidden = YES;
	
	_nextBtn.layer.cornerRadius = 5;
	_browseBtn.layer.cornerRadius = 5;
	
	// Initiates the array of connected devices
	_arrConnectedDevices = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	canGoNext = 0;
	[_waitingGoNext stopAnimating];
	
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	
	if ([allPeers count] == 0) {
		[_arrConnectedDevices removeAllObjects];
		
		_connectedDevice.hidden = YES;
		_nextBtn.hidden = YES;
	} else [self performSegueWithIdentifier:@"goNext" sender:self];
	
	[_nextBtn setEnabled:YES];
	
}

#pragma mark - Action Methods

/**
 Go back to the first view 
 */
- (IBAction)goBack:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

/**
 Method to browse for new devices
 **/
- (IBAction)browseForDevices:(id)sender
{
	[[_appDelegate mcManager] setupMCBrowser];
	[[[_appDelegate mcManager] browser] setDelegate:self];

    [[[_appDelegate mcManager] browser] startBrowsingForPeers];

	//_appDelegate.mcManager.browser.maximumNumberOfPeers = 1;
	//[self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
}

/**
 Method to disconnect with the other device
 **/
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
	
	[_waitingGoNext stopAnimating];
	
	canGoNext = 0;
}

/**
 Method to go to the next View
 **/
- (IBAction)goNext:(id)sender
{
	NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	
	if (canGoNext == 0) {
		canGoNext = 1;
		
		[_waitingGoNext startAnimating];
	} else [self performSegueWithIdentifier:@"goNext" sender:self];

	
	[_appDelegate.mcManager.session sendData:[@"!goNext" dataUsingEncoding:NSUTF8StringEncoding]
										 toPeers:allPeers
										withMode:MCSessionSendDataReliable
										error:&error];
	[_nextBtn setEnabled:NO];
}

#pragma mark - Selectors

/**
 Method to when the device change the state of the connection
 **/
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
				_connectedDevice.text = [NSString stringWithFormat:@"Você está conectado com %@", peerDisplayName];
				_connectedDevice .hidden = NO;
				_nextBtn.hidden = NO;
				[_browseBtn setEnabled:NO];
				_disconectBtn.hidden = NO;
				
				NSLog(@"PEER EXIST! and is named %@", peerDisplayName);
			}
			else
			{
				_connectedDevice.hidden = YES;
				_nextBtn.hidden = YES;
				[_browseBtn setEnabled:YES];
				_disconectBtn.hidden = YES;
				[_waitingGoNext stopAnimating];
				
				NSLog(@"PEER DONT EXIST");
			}
		});
	}
	
}

/**
 Method to the device receive some data
 **/
-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
	
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
	NSString *receivedInfo = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([receivedInfo isEqualToString:@"!disconnect"])
		{
			[_appDelegate.mcManager.session disconnect];
			
			NSLog(@"RECEBEU DISCONNECT");
			
			canGoNext = 0;
			_connectedDevice.hidden = YES;
			[_nextBtn setHidden:YES];
			[_waitingGoNext stopAnimating];
			
			_disconectBtn.hidden = YES;
		}
		else if ([receivedInfo isEqualToString:@"!goNext"]) {
			if (canGoNext == 0) canGoNext = 1;
			else canGoNext = 2;
				
			if (canGoNext == 2) [self performSegueWithIdentifier:@"goNext" sender:self];
		}
	
	});
	
}

#pragma mark - Auxiliary Methods

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

#pragma mark - Delegates
#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField.text length] > 0) {
		
		[_txtName resignFirstResponder];
		
		_appDelegate.mcManager.peerID = nil;
		_appDelegate.mcManager.session = nil;
		_appDelegate.mcManager.browser = nil;
		
		//[_appDelegate.mcManager.advertiser stop];
		//_appDelegate.mcManager.advertiser = nil;
		
		[_appDelegate.mcManager setupPeerAndSessionWithDisplayName:_txtName.text];
		[_appDelegate.mcManager setupMCBrowser];
		[_appDelegate.mcManager advertiseSelf:YES];
		_appDelegate.mcManager.advertiser.delegate = self;
		
		_browseBtn.hidden = NO;
		
	} else [self performShakeAnimation:_txtName];
	
	return YES;
}

#pragma mark - NearbyServiceBrowser Delegate

/**
 Delegate for finding devices
 **/
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
	NSLog(@"Found a nearby advertising peer %@", peerID);
	
	//Manda convite para conexao
	[[[_appDelegate mcManager] browser] invitePeer:peerID toSession:_appDelegate.mcManager.session withContext:nil timeout:60];
}

/**
 Delegate fot accepting invitations
 **/
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
	   withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL accept,
							 MCSession *session))invitationHandler{
	NSLog(@"Got invite from %@", peerID);
	
	//Aceita convite
	if (![_txtName.text isEqualToString:@""]) invitationHandler(YES, _appDelegate.mcManager.session);
}

/**
 Delegate called when peer is lost
 **/
- (void)browser:(MCNearbyServiceBrowser *)browser
	   lostPeer:(MCPeerID *)peerID{
	NSLog(@"Lost device %@", peerID);
}

#pragma mark - MCBrowserView Delegate

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
	//[_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
	//[_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

@end
