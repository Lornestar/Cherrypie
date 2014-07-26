//
//  APICalls.h
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-24.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface APICalls : NSObject

@property (nonatomic, strong) AppDelegate *appdel;

-(void)Terminal:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass;

-(void)User_Login:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass;

-(void)User_Signup:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass;

-(void)BitcoinAddress:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass;

-(void)Transaction_List:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass;

-(void)BitcoinAddress_Update:(NSMutableDictionary*)tempdict theselector:(SEL)theselector theclass:(NSObject*)theclass;

@end
