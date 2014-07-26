//
//  PaymentTerminalViewController.h
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-24.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PaymentTerminalViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblamount;

- (IBAction)btnkeyboard:(id)sender;
- (IBAction)btncancel_clicked:(id)sender;
- (IBAction)btnsimulate_clicked:(id)sender;
- (IBAction)btnLogout_Clicked:(id)sender;
- (IBAction)btnRefresh_Clicked:(id)sender;
- (IBAction)btnSettings_Clicked:(id)sender;
- (IBAction)btnMenu_Clicked:(id)sender;



@property (strong, nonatomic) IBOutlet UIView *vwbuttons;
@property (nonatomic, assign) int currentnumericposition;
@property (nonatomic, strong) NSString *currentnumericstring;
@property (nonatomic, strong) AppDelegate *appdel;
@property (strong, nonatomic) IBOutlet UIImageView *imgqr;
@property (strong, nonatomic) IBOutlet UIButton *btncancel;
@property (strong, nonatomic) IBOutlet UILabel *lbldemo;
@property (strong, nonatomic) IBOutlet UIButton *btnsimulate;
@property (strong, nonatomic) NSString *currentterminalkey;
@property (strong, nonatomic) IBOutlet UITableView *tblview;
@property (strong, nonatomic) NSArray *txlist;
@property (strong, nonatomic) IBOutlet UILabel *lblemail;

@property (strong, nonatomic) IBOutlet UIButton *menubtn;

-(void)CloseAllPopUpViewControllers;

@end
