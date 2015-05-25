//
//  AppDelegate.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/24/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connectivity.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/// Object fraom the created class to let the class be used over the app delegate
@property (nonatomic, strong) Connectivity *mcManager;

@property (nonatomic, strong) MCPeerID *connectedPeer;

@end

