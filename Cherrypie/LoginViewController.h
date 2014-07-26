//
//  LoginViewController.h
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-15.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginViewController : UIViewController

@property (nonatomic, strong) AppDelegate *appdel;

@property (strong, nonatomic) IBOutlet UITextField *txtemail;
@property (strong, nonatomic) IBOutlet UITextField *txtpassword;
@property (strong, nonatomic) NSString *currentterminalkey;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;

- (IBAction)btnLogin_Clicked:(id)sender;
- (IBAction)btnTryDemo_Clicked:(id)sender;
- (IBAction)btnRegister_Clicked:(id)sender;


@end
