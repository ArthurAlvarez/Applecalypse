//
//  ViewController.m
//  DoYouKnowMe
//
//  Created by Arthur Alvarez on 3/24/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

/// Interface button in the initial screen. (Screen label: 'Jogar')
@property (weak, nonatomic) IBOutlet UIButton *btn_StartApp;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Starts the application from the initial view. This method is called when the user presses 'btn_StartButton'.
 @param sender: The object that called the method
 @author Arthur Alvarez
 */
- (IBAction)startApp:(id)sender {
    //TO DO
}

@end
