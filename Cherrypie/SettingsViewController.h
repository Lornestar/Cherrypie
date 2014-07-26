//
//  SettingsViewController.h
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-22.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "WelcomeViewController.h"

@interface SettingsViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UIWebViewDelegate>

@property (nonatomic, strong) AppDelegate *appdel;
@property (strong, nonatomic) IBOutlet UIView *vwpassword;
@property (strong, nonatomic) IBOutlet UIView *vwaddress;
@property (strong, nonatomic) IBOutlet UIView *viewPreview2;

@property (strong, nonatomic) IBOutlet UIWebView *webvw_coinbase;
@property (strong, nonatomic) IBOutlet UITextField *txtpassword;
@property (strong, nonatomic) IBOutlet UILabel *lbladdress;
@property (weak, nonatomic) IBOutlet UIView *viewPreview;

@property (strong, nonatomic) IBOutlet UIButton *menubtn;



- (IBAction)btnClose_Clicked:(id)sender;

- (IBAction)btnScanQR_Clicked:(id)sender;
- (IBAction)btnConnectCoinbase_Clicked:(id)sender;
- (IBAction)btnCancel_Clicked:(id)sender;
- (IBAction)btnPassword_Clicked:(id)sender;
- (IBAction)btnMenu_Clicked:(id)sender;

@end
