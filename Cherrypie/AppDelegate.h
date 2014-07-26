//
//  AppDelegate.h
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-05-30.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>
#import "PTPusherAPI.h"
#import "PTPusherChannel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *rooturl;
@property (nonatomic, strong) NSString *terminalkey;
@property (nonatomic, strong) NSString *currentemail;
@property (nonatomic, assign) BOOL internetconnected;
@property (nonatomic, strong) PTPusher *pusherclient;
@property (nonatomic, strong) PTPusherChannel *pusherchannel;
@property (nonatomic, assign) BOOL hasprocessor;
@property (nonatomic, strong) NSString *currentbitcoinaddress;
@property (nonatomic, strong) NSMutableArray *APICallsArray;

-(void)HUDProcessing;
-(void)HUDHide;
-(void)HUDCompleted;
-(void)HUDError:(NSString*)ErrorMessage;

-(void)TryConnectingtoPusher;

-(void)DisplayAlert:(NSString*)themessage;
-(void)connectedToInternet;
-(NSDate*) dateFromDotNet:(NSString*)stringDate;
-(NSString*) dateToDotNet;
-(void)UserDefaults_UpdateUserInfo;

@end
