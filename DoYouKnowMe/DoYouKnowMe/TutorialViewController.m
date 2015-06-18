//
//  TutorialViewController.m
//  DoIKnowYou
//
//  Created by Arthur Alvarez on 6/8/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "TutorialViewController.h"
#import "ConnectionsViewController.h"

@interface TutorialViewController ()
{
    BOOL pageControlBeingUsed;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (strong, nonatomic) UIView *page1;
@property (strong, nonatomic) UIView *page2;
@property (strong, nonatomic) UIView *page3;
@property (strong, nonatomic) UIView *page4;
@property (strong, nonatomic) UIView *page5;
@property (strong, nonatomic) NSMutableArray *pages;
@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"passedTutorial"];
    
    int i = 0;
    int offset = -20;
    pageControlBeingUsed = NO;
    self.btnStart.hidden = YES;
    
    self.page1 = [[[NSBundle mainBundle] loadNibNamed:NSLocalizedString(@"Tutorial1", nil) owner:self options:nil] firstObject];
    self.page2 = [[[NSBundle mainBundle] loadNibNamed:NSLocalizedString(@"Tutorial2", nil) owner:self options:nil] firstObject];
    self.page3 = [[[NSBundle mainBundle] loadNibNamed:NSLocalizedString(@"Tutorial3", nil) owner:self options:nil] firstObject];
    self.page4 = [[[NSBundle mainBundle] loadNibNamed:NSLocalizedString(@"Tutorial4", nil) owner:self options:nil] firstObject];
    self.page5 = [[[NSBundle mainBundle] loadNibNamed:NSLocalizedString(@"Tutorial5", nil) owner:self options:nil] firstObject];
    
    self.pages = [[NSMutableArray alloc] init];
    
    [self.pages addObject:self.page1];
    [self.pages addObject:self.page2];
    [self.pages addObject:self.page3];
    [self.pages addObject:self.page4];
    [self.pages addObject:self.page5];
    
    
    self.scrollView.delegate = self;
    
    NSLog(@"Tamanho da tela: %f x %f", self.view.frame.size.height, self.view.frame.size.width);
    
    for(i = 0; i < 5; i++){
        ((UIView *)self.pages[i]).frame = CGRectOffset(((UIView *)self.pages[i]).frame, [self.scrollView contentSize].width, offset);
        
        [self.scrollView addSubview:((UIView *)self.pages[i])];
        
        self.scrollView.contentSize = CGSizeMake([self.scrollView contentSize].width + self.view.frame.size.width, self.view.frame.size.height + offset);
    }
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = i;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!pageControlBeingUsed){
        float page = floor(self.scrollView.contentOffset.x / self.view.frame.size.width);
        self.pageControl.currentPage = (int) page;
    }
    
    if(self.pageControl.currentPage == self.pageControl.numberOfPages - 1){
        self.btnStart.hidden = NO;
    }
    else{
        self.btnStart.hidden = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changePage:(id)sender {
    UIPageControl *pageControl = (UIPageControl *)sender;
    NSInteger currentPage = pageControl.currentPage;
    CGPoint offset = CGPointMake(currentPage * self.scrollView.frame.size.width, -20);
    [self.scrollView setContentOffset:offset animated:YES];
    pageControlBeingUsed = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UINavigationController *navController = [segue destinationViewController];
    ConnectionsViewController *vc = (ConnectionsViewController *)([navController viewControllers][0]);
    vc.cameFromTutorial = YES;
}

- (IBAction)buttonPressed:(id)sender {
    
    NSLog(@"CameFrom first: %d", self.cameFromFirstScreen);
    
    if(self.cameFromFirstScreen){
        [self performSegueWithIdentifier:@"startGame" sender:self];
    }
    else{
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
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
