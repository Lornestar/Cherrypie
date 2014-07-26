//
//  QRCodeViewController.m
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-05-30.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import "QRCodeViewController.h"
#import <QRCodeEncoderObjectiveCAtGithub/QREncoder.h>
#import <QRCodeEncoderObjectiveCAtGithub/DataMatrix.h>


@interface QRCodeViewController ()

@end

@implementation QRCodeViewController
@synthesize imgqr;

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
    
    self.view.frame = CGRectMake(0, 220, 400, 456);
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setQR:(NSString*)themessage{
    
     int qrcodeImageDimension = 400;
    
    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:themessage];
    
    //then render the matrix
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    
    //put the image into the view
    //imgQRcode = [[UIImageView alloc] initWithImage:qrcodeImage];
    imgqr.image = qrcodeImage;
    
    
}

@end
