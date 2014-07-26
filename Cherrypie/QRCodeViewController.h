//
//  QRCodeViewController.h
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-05-30.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imgqr;

-(void)setQR:(NSString*)themessage;

@end
