//
//  APICalls_Selector.h
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-24.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APICalls_Selector : NSObject
@property (nonatomic, assign) SEL theselector;
@property (nonatomic, strong) NSString *theurl;
@property (nonatomic, strong) NSObject *theclass;

@end
