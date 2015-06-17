//
//  MyScoresViewController.h
//  DoIKnowYou
//
//  Created by Felipe Eulalio on 16/06/15.
//  Copyright © 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "TabBarViewController.h"

@interface MyScoresViewController : UIViewController <UITableViewDataSource>

@property Game *game;

@end
