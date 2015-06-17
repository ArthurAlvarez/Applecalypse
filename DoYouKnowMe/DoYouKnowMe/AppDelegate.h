//
//  AppDelegate.h
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/24/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Connectivity.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

/// Object fraom the created class to let the class be used over the app delegate
@property (nonatomic, strong) Connectivity *mcManager;

@property (nonatomic, strong) MCPeerID *connectedPeer;

@end

