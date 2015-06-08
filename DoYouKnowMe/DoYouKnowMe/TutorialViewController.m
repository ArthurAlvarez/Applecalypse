//
//  TutorialViewController.m
//  DoIKnowYou
//
//  Created by Arthur Alvarez on 6/8/15.
//  Copyright (c) 2015 Arthur Alvarez. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (strong, nonatomic) UIView *page1;
@property (strong, nonatomic) UIView *page2;
@property (strong, nonatomic) UIView *page3;
@property (strong, nonatomic) NSMutableArray *pages;
@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"passedTutorial"];
    
    int i = 0;
    
    self.btnStart.hidden = YES;
    
    self.page1 = [[[NSBundle mainBundle] loadNibNamed:@"Tutorial1" owner:self options:nil] lastObject];
    self.page2 = [[[NSBundle mainBundle] loadNibNamed:@"Tutorial2" owner:self options:nil] lastObject];
    self.page3 = [[[NSBundle mainBundle] loadNibNamed:@"Tutorial3" owner:self options:nil] lastObject];
    
    self.pages = [[NSMutableArray alloc] init];
    
    [self.pages addObject:self.page1];
    [self.pages addObject:self.page2];
    [self.pages addObject:self.page3];
    
    self.scrollView.delegate = self;
    
    for(i = 0; i < 3; i++){
        ((UIView *)self.pages[i]).frame = CGRectOffset(((UIView *)self.pages[i]).frame, [self.scrollView contentSize].width, 0);
        
        [self.scrollView addSubview:((UIView *)self.pages[i])];
        
        self.scrollView.contentSize = CGSizeMake([self.scrollView contentSize].width + self.view.frame.size.width, ((UIView *)self.pages[i]).frame.size.height);
    }
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = i;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float page = floor(self.scrollView.contentOffset.x / self.view.frame.size.width);
    
    self.pageControl.currentPage = (int) page;
    
    if(self.pageControl.currentPage == self.pageControl.numberOfPages - 1){
        self.btnStart.hidden = NO;
    }
    else{
        self.btnStart.hidden = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
