//
//  AppDelegate.m
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-05-30.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import "AppDelegate.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "Reachability.h"

@implementation AppDelegate
@synthesize HUD,rooturl,terminalkey,internetconnected,hasprocessor,pusherclient,pusherchannel,currentemail,currentbitcoinaddress,APICallsArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    rooturl = @"http://api.cherrypiepayments.com/cherrypieservice/service1.svc";
    
    //subscribe to pusher events
    pusherclient = [PTPusher pusherWithKey:@"541ccf91dddf23b35295" delegate:self encrypted:NO];
    [pusherclient connect];
    
    terminalkey = @"0";
    currentbitcoinaddress = @"";
    [self UserDefaults_Getterminalkey];
    
    APICallsArray = [[NSMutableArray alloc] init];
    
    internetconnected = YES;
    
    
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - HUD Methods

-(void)HUDProcessing{
    [self HUDHide];
    HUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
    HUD.labelText = @"Processing";
    HUD.dimBackground = YES;
    [HUD hide:YES afterDelay:30];
    [self.window addSubview:HUD];
}

-(void)HUDHide{
    [HUD removeFromSuperview];
}

-(void)HUDCompleted{
    [self HUDHide];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
   
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    HUD.labelText = @"Completed";
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}

-(void)HUDCheckMark:(NSString*)CustomMessage{
    [self HUDHide];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    HUD.labelText = CustomMessage;
    
    UITapGestureRecognizer *HUDSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HUDHide)];
    [HUD addGestureRecognizer:HUDSingleTap];
    
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}

-(void)HUDError:(NSString*)ErrorMessage{
    [self HUDHide];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
    
    // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
    // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mbhud_error.png"]];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    HUD.labelText = ErrorMessage;
    
    UITapGestureRecognizer *HUDSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HUDHide)];
    [HUD addGestureRecognizer:HUDSingleTap];
    
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

#pragma mark - Miscellaneous methods

-(void)DisplayAlert:(NSString*)themessage{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:themessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) connectedToInternet
{
    
    dispatch_queue_t my_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(my_queue_t, ^{
        /*
         NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"]];
         BOOL isconnected = ( URLString != NULL ) ? YES : NO;
         */
        
        NSString* link = [NSString stringWithFormat:@"%@/Connection", rooturl];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:link] cachePolicy:0 timeoutInterval:5];
        NSURLResponse* response=nil;
        NSError* error=nil;
        NSData* data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString* stringFromServer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        BOOL isconnected = ( ![stringFromServer isEqualToString:@""] ) ? YES : NO;
        
        if (isconnected){
            NSLog(@"REACHABLE!");
            
            //if connected to internet
            [self InternetConnectedEvent:1];
        }
        else{
            [self InternetConnectedEvent:2];
            
            NSLog(@"UNREACHABLE!");
        }
    });
}

-(void)InternetConnectedEvent:(int)eventtype{
    if (eventtype == 1){
        //Internet connected
        if (internetconnected == NO) //if currently think internet disconnected
        {
            internetconnected = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusInternetCheck" object:nil];
            
            [self HUDCheckMark:@"Internet Connected"];
        }
        else{
            internetconnected = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusInternetCheck" object:nil];
        }
    }
    else if (eventtype == 2){
        //Internet disconnected
        if (internetconnected == YES) //if currently think internet connected
        {
            internetconnected = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusInternetCheck" object:nil];
            
            [self HUDError:@"Internet Disconnected"];
        }
        else{
            internetconnected = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusInternetCheck" object:nil];
        }
    }
}



#pragma mark - PTPusherDelegate methods

- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection
{
    NSLog(@"[pusher] Pusher client connecting...");
    return YES;
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    NSLog(@"[pusher-%@] Pusher client connected", connection.socketID);
    
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    NSLog(@"[pusher] Pusher Connection failed with error: %@", error);
    
    if ([error.domain isEqualToString:(NSString *)kCFErrorDomainCFNetwork]) {
        // we probably have no internet connection, so lets check with Reachability
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        
        if ([reachability isReachable]) {
            // we appear to have a connection, so something else must have gone wrong
            NSLog(@"Internet reachable, is Pusher down?");
        }
        else {
            
            
        }
    }
}



-(void)TryConnectingtoPusher{
    [pusherclient connect];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
    
    NSLog(@"[pusher-%@] Pusher Connection disconnected with error: %@", pusher.connection.socketID, error);
    
    if (willAttemptReconnect) {
        NSLog(@"[pusher-%@] Client will attempt to reconnect automatically", pusher.connection.socketID);
    }
    
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
    NSLog(@"[pusher-%@] Client automatically reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
    return YES;
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    NSLog(@"[pusher-%@] Subscribed to channel %@", pusher.connection.socketID, channel);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    NSLog(@"[pusher-%@] Authorization failed for channel %@", pusher.connection.socketID, channel);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authorization Failed" message:[NSString stringWithFormat:@"Client with socket ID %@ could not be authorized to join channel %@", pusher.connection.socketID, channel.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
    NSLog(@"[pusher-%@] Received error event %@", pusher.connection.socketID, errorEvent);
}

-(NSDate*) dateFromDotNet:(NSString*)stringDate{
    
    NSDate *returnValue;
    if ([stringDate rangeOfString:@"Date("].location == NSNotFound)
    {
        //normal date
        //format is 2013-12-06T22:27:12.857Z
        //stringDate  = @"2013-12-06 22:27:12";
        stringDate = [stringDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        NSRange dotlocation = [stringDate rangeOfString:@"."];
        stringDate = [stringDate substringToIndex:dotlocation.location];
        
        NSDateFormatter * Dateformats= [[NSDateFormatter alloc] init];
        
        [Dateformats setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        returnValue=[Dateformats dateFromString:stringDate];
    }
    else{
        //dot net date
        if ([stringDate isMemberOfClass:[NSNull class]]) {
            returnValue=nil;
        }
        else  {
            NSInteger offset = 0;//[[NSTimeZone defaultTimeZone] secondsFromGMT];
            returnValue= [[NSDate dateWithTimeIntervalSince1970:[[stringDate substringWithRange:NSMakeRange(6, 10)] intValue]]  dateByAddingTimeInterval:offset];
            
        }
    }
    
    return returnValue;
}

-(NSString*) dateToDotNet{
    double timeSince1970=[[NSDate date] timeIntervalSince1970];
    NSInteger offset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    offset=offset/3600;
    double nowMillis = 1000.0 * (timeSince1970);
    NSString *dotNetDate=[NSString stringWithFormat:@"/Date(%.0f%+03d00)/",nowMillis,offset] ;
    return  dotNetDate;
}

-(void)UserDefaults_UpdateUserInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:terminalkey forKey:@"terminalkey"];
    [defaults setObject:currentemail forKey:@"currentemail"];
    [defaults setObject:currentbitcoinaddress forKey:@"currentbitcoinaddress"];
    [defaults setBool:hasprocessor forKey:@"hasprocessor"];
    [defaults synchronize];
}

-(void)UserDefaults_Getterminalkey{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strtemp =[defaults objectForKey:@"terminalkey"];
    if (strtemp){
        terminalkey = strtemp;
    }
    
    strtemp =[defaults objectForKey:@"currentemail"];;
    if (strtemp){
        currentemail = strtemp;
    }
    
    strtemp =[defaults objectForKey:@"currentbitcoinaddress"];;
    if (strtemp){
        currentbitcoinaddress = strtemp;
    }
    
    BOOL hasprocessorbool = NO;
    hasprocessorbool = [defaults boolForKey:@"hasprocessor"];
    if (hasprocessorbool)
    {
        hasprocessor = hasprocessorbool;
    }
}

@end
