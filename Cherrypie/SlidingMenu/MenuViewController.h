//
//  MenuViewController.h
//  SlideMenu
//
//  Created by Kyle Begeman on 1/13/13.
//  Copyright (c) 2013 Indee Box LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MenuViewController : UIViewController <UITableViewDataSource,  UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblMenu;
@property (nonatomic, strong) AppDelegate *appdel;
-(void)ReloadRegister;

@end
