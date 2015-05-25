//
//  FirstViewController.h
//  DoYouKnowMe
//
//  Created by Felipe Eulálio on 31/03/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "ResultsViewController.h"

@interface FirstViewController : UIViewController <MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@end
