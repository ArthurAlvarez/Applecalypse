//
//  AppDelegate.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/24/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conectivity.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) Conectivity *mcManager;


@end

