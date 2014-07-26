//
//  APICalls.m
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-24.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import "APICalls.h"
#import "APICalls_Selector.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "AppDelegate.h"
#import "PTPusher.h"
#import "PTPusherConnection.h"

@implementation APICalls
@synthesize appdel;

-(void)Terminal:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass {
    appdel = [self getAppdel];
    //[tempdict setObject:@"889B8C77-042A-45F7-B63E-7D8EA19F81D0|22:45:19 01/13" forKey:@"uniqueid"];
    //[tempdict setObject:[appdel GetUniqueIDForCalls] forKey:@"uniqueid"];
    NSString *callurl= [appdel.rooturl stringByAppendingString:@"/Terminal"];
    [self DoAPICall:tempdict theselector:theselector theclass:theclass callurl:callurl];
}

-(void)User_Login:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass {
    appdel = [self getAppdel];
    NSString *callurl= [appdel.rooturl stringByAppendingString:@"/User/Login"];
    [self DoAPICall:tempdict theselector:theselector theclass:theclass callurl:callurl];
}

-(void)User_Signup:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass {
    appdel = [self getAppdel];
    NSString *callurl= [appdel.rooturl stringByAppendingString:@"/User/Signup"];
    [self DoAPICall:tempdict theselector:theselector theclass:theclass callurl:callurl];
}

-(void)BitcoinAddress:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass {
    appdel = [self getAppdel];
    NSString *callurl= [appdel.rooturl stringByAppendingString:@"/BitcoinAddress"];
    [self DoAPICall:tempdict theselector:theselector theclass:theclass callurl:callurl];
}

-(void)BitcoinAddress_Update:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass {
    appdel = [self getAppdel];
    NSString *callurl= [appdel.rooturl stringByAppendingString:@"/BitcoinAddress/Update"];
    [self DoAPICall:tempdict theselector:theselector theclass:theclass callurl:callurl];
}

-(void)Transaction_List:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass {
    appdel = [self getAppdel];
    NSString *callurl= [appdel.rooturl stringByAppendingString:@"/Transaction/List"];
    [self DoAPICall:tempdict theselector:theselector theclass:theclass callurl:callurl];
}



-(AppDelegate*)getAppdel{
    return [UIApplication sharedApplication].delegate;
}

-(BOOL)SelectorExists:(NSString*)callurl{
    BOOL selectorexists = NO;
    appdel = [UIApplication sharedApplication].delegate;
    for (APICalls_Selector *tempapiselector in appdel.APICallsArray){
        if ([tempapiselector.theurl isEqualToString:callurl]){
            selectorexists = YES;
        }
    }
    
    return selectorexists;
}

-(void)DoAPICall:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass callurl:(NSString*)callurl{
    appdel = [UIApplication sharedApplication].delegate;
    
    if (appdel.internetconnected == YES)
    {
        //check if selector is currently being called
        if ([self SelectorExists:callurl] == NO){
            //Post Payment
            [self SaveSelector:theselector theclass:theclass theurl:callurl];
            [appdel HUDProcessing];
            
            
            NSURL *url = [NSURL URLWithString:callurl];
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
            [httpClient setParameterEncoding:AFJSONParameterEncoding];
            NSMutableURLRequest *request =    [httpClient requestWithMethod:@"POST" path:callurl parameters:tempdict];
            [request setTimeoutInterval:30];
            AFJSONRequestOperation *operation =  [[AFJSONRequestOperation alloc] initWithRequest:request];
            [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseobject){
                [self HandleResponse:responseobject callurl:callurl];
                
            }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Error: %@",error);
                                                 [appdel HUDHide];
                                                 [self RemoveSelector:callurl];
                                                 
                                                 if (appdel.internetconnected == NO){
                                                     //not connected to internet
                                                     [appdel DisplayAlert:@"Internet Disconnected. Cannot complete request"];
                                                 }
                                                 else{
                                                     [appdel DisplayAlert:@"Your request could not be completed"];
                                                 }
                                                 
                                                 //check status of internet
                                                 [appdel connectedToInternet];
                                             }];
            
            
            [operation start];
            
            //check pusher state, if disconnected try connecting
            if (appdel.pusherclient.connection.connected == NO){
                [appdel TryConnectingtoPusher];
            }
        }
        else{
            //does exist, don't make call
            
        }
    }
    else{
        //check status of internet
        [appdel HUDError:@"Internet Disconnected"];
        [appdel connectedToInternet];
    }
    
}


-(void)SaveSelector:(SEL)theselector theclass:(NSObject*)theclass theurl:(NSString*)theurl{
    if (theselector != nil){
        APICalls_Selector *apiselector = [APICalls_Selector alloc];
        apiselector.theselector = theselector;
        apiselector.theclass = theclass;
        apiselector.theurl = theurl;
        [appdel.APICallsArray addObject:apiselector];
    }
}

-(NSMutableDictionary*)getMixpanelProperties:(NSMutableDictionary*)tempdict callurl:(NSString*)callurl{
    NSMutableDictionary *tempdict2 = [[NSMutableDictionary alloc] initWithDictionary:tempdict];
    [tempdict2 setObject:callurl forKey:@"url"];
    return tempdict2;
}

-(void)HandleResponse:(id)responseobject callurl:(NSString*)callurl{
    //call selector
    [appdel HUDHide];
    
    NSDictionary *jsonDict = (NSDictionary*)responseobject;
    
    
    APICalls_Selector *apiselector;
    int count = 0;
    int apiindex = 0;
    for (APICalls_Selector *tempapiselector in appdel.APICallsArray){
        if ([tempapiselector.theurl isEqualToString:callurl]){
            apiselector = tempapiselector;
            apiindex = count;
        }
        count ++;
    }
    if (apiselector){
        [self RemoveSelector:callurl];
    }
    if ((apiselector.theselector) &&  (apiselector.theclass)){
        [apiselector.theclass performSelector:apiselector.theselector withObject:jsonDict];
    }
}

-(void)RemoveSelector:(NSString*)callurl {
    APICalls_Selector *apiselector;
    int count = 0;
    int apiindex = 0;
    for (APICalls_Selector *tempapiselector in appdel.APICallsArray){
        if ([tempapiselector.theurl isEqualToString:callurl]){
            apiselector = tempapiselector;
            apiindex = count;
        }
        count ++;
    }
    if (apiselector){
        [appdel.APICallsArray removeObjectAtIndex:apiindex];
    }
}

@end
