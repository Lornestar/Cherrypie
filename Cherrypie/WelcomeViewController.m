//
//  WelcomeViewController.m
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-25.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import "WelcomeViewController.h"
#import "PaymentTerminalViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.frame = CGRectMake(75, 75, 390, 220);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)btnClose_Clicked:(id)sender {
    PaymentTerminalViewController *payvc = self.parentViewController;
    [payvc CloseAllPopUpViewControllers];
}

@end
