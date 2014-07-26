//
//  LoginViewController.m
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-15.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import "LoginViewController.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "InitViewController.h"
#import "APICalls.h"


@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize appdel,txtemail,txtpassword,currentterminalkey,btnLogin,btnRegister;

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
    
    appdel = [UIApplication sharedApplication].delegate;
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [txtemail becomeFirstResponder];
    
    if (![appdel.terminalkey isEqualToString:@"0"])
    {
        currentterminalkey = appdel.terminalkey;
        [self OpenInitvc];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTerminal{
    
    NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
    [tempdict setObject:[[[UIDevice currentDevice] identifierForVendor]UUIDString] forKey:@"androidid"];
    
    APICalls *apicall = [APICalls alloc];
    [apicall Terminal:tempdict theselector:@selector(initTerminal_Response:) theclass:self];
    
    }

-(void)initTerminal_Response:(NSMutableDictionary*)tempdict
{
    appdel.terminalkey = [tempdict objectForKey:@"terminalkey"];
    appdel.hasprocessor = [[tempdict objectForKey:@"hasprocessor"] boolValue];
}

- (IBAction)btnLogin_Clicked:(id)sender {
    if ([[btnLogin currentTitle] isEqualToString:@"Login"]) //intention to login
    {
        [self DoLogin];
    }
    else{ //intention to register
        [self DoRegister];
    }
    
}

-(void)DoRegister{
    
    NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
    [tempdict setObject:txtemail.text forKey:@"email"];
    [tempdict setObject:txtpassword.text forKey:@"password"];
    [tempdict setObject:[[[UIDevice currentDevice] identifierForVendor]UUIDString] forKey:@"androidid"];
    
    APICalls *apicall = [APICalls alloc];
    [apicall User_Signup:tempdict theselector:@selector(Register_Response:) theclass:self];

}

-(void)Register_Response:(NSMutableDictionary*)tempdict
{
    [self DoLogin];
}

-(void)DoLogin{
    appdel.currentemail = txtemail.text;
    
    NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
    [tempdict setObject:txtemail.text forKey:@"email"];
    [tempdict setObject:txtpassword.text forKey:@"password"];
    [tempdict setObject:[[[UIDevice currentDevice] identifierForVendor]UUIDString] forKey:@"androidid"];
    
    APICalls *apicall = [APICalls alloc];
    [apicall User_Login:tempdict theselector:@selector(Login_Response:) theclass:self];
    
 
}

-(void)Login_Response:(NSMutableDictionary*)tempdict
{
    BOOL isvalid = [[tempdict objectForKey:@"isvalid"] boolValue];
    appdel.terminalkey = [[tempdict objectForKey:@"terminalkey"] stringValue];
    
    if ([tempdict objectForKey:@"bitcoinaddress"] != [NSNull null])
    {
        appdel.currentbitcoinaddress =[tempdict objectForKey:@"bitcoinaddress"];
    }
    appdel.hasprocessor = [[tempdict objectForKey:@"hasaddress"] boolValue];
    
    if (isvalid)
    {
        //open initpage
        [appdel UserDefaults_UpdateUserInfo];
        currentterminalkey = appdel.terminalkey;
        [self OpenInitvc];
    }
    else
    {
        //popup
        [appdel DisplayAlert:@"Invalid email/password combination."];
    }
}


- (IBAction)btnTryDemo_Clicked:(id)sender {
    currentterminalkey = @"0";
    appdel.terminalkey = @"0";
    [self OpenInitvc];
}

- (IBAction)btnRegister_Clicked:(id)sender {
    if ([[btnLogin currentTitle] isEqualToString:@"Login"])
    {
        [btnLogin setTitle:@"Register" forState:UIControlStateNormal];
        [btnRegister setTitle:@"Login" forState:UIControlStateNormal];
    }
    else{
        [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
        [btnRegister setTitle:@"Register" forState:UIControlStateNormal];
    }
}

-(void)OpenInitvc{
    
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [btnRegister setTitle:@"Register" forState:UIControlStateNormal];
    
    txtemail.text = @"";
    txtpassword.text = @"";
    
    
    [self performSegueWithIdentifier: @"segueinit" sender: self];
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueinit"])
    {
        //InitViewController *initvc = [segue destinationViewController];
        //initvc.currentterminalkey = currentterminalkey;
        
    }
}

@end
