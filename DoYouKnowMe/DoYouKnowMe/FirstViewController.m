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

/// Interface Activity Indicator to show that the player is waiting the other
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingGoNext;

/// Table view to display the connected devices
@property (weak, nonatomic) IBOutlet UITableView *connectedDevices;

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
	_connectedDevices.hidden = YES;

	_browseBtn.layer.cornerRadius = 5;
	
	// Initiates the array of connected devices
	_arrConnectedDevices = [[NSMutableArray alloc] init];
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
		self.connectedDevices.hidden = true;
	}
	
	self.connectedDevices.allowsSelection = YES;

	[self.connectedDevices reloadData];
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
}

/**
 Method to disconnect with the other device
 **/
- (IBAction)Disconect:(id)sender
{
	NSError *error;
	
	[_appDelegate.mcManager.session disconnect];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_disconectBtn.hidden = YES;
	});
	
	[_appDelegate.mcManager.session sendData:[@"!disconnect" dataUsingEncoding:NSUTF8StringEncoding]
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
	
	[Player setPlayerID:-1];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
	[_waitingGoNext stopAnimating];
	
	canGoNext = 0;
	
	[self.connectedDevices reloadData];
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
			dispatch_async(dispatch_get_main_queue(), ^{
				[_arrConnectedDevices addObject:peerDisplayName];
				[self.connectedDevices reloadData];
			});
		}
		else if (state == MCSessionStateNotConnected)
		{
			if ([_arrConnectedDevices count] > 0)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					[_arrConnectedDevices removeObject:peerDisplayName];
					[self.connectedDevices reloadData];
				});
			}
		}
		
		BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
		[_txtName setEnabled:peersExist];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!peersExist)
			{
				[_browseBtn setEnabled:NO];
				_disconectBtn.hidden = NO;
				_connectedDevices.hidden = NO;
				if (canGoNext == 0) _connectedDevices.allowsSelection = YES;
				
				NSLog(@"PEER EXIST! and is named %@", peerDisplayName);
			}
			else
			{
				[_browseBtn setEnabled:YES];
				_disconectBtn.hidden = YES;
				[_waitingGoNext stopAnimating];
				_connectedDevices.hidden = YES;
				
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

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	self.appDelegate.connectedPeer = [self.appDelegate.mcManager.session.connectedPeers objectAtIndex:indexPath.row];
	
	NSError *error;
	
	if (canGoNext == 0) {
		canGoNext = 1;
		
		[_waitingGoNext startAnimating];
	} else [self performSegueWithIdentifier:@"goNext" sender:self];
	
	self.connectedDevices.allowsSelection = NO;
	
	[_appDelegate.mcManager.session sendData:[@"!goNext" dataUsingEncoding:NSUTF8StringEncoding]
									 toPeers:@[self.appDelegate.connectedPeer]
									withMode:MCSessionSendDataReliable
									   error:&error];
}


#pragma mark - Datasources
#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.arrConnectedDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.backgroundColor = tableView.backgroundColor;
	
	cell.textLabel.font = self.helloLabel.font;
	cell.textLabel.textColor = self.helloLabel.textColor;
	cell.textLabel.text = [self.arrConnectedDevices objectAtIndex:indexPath.row];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}



@end
