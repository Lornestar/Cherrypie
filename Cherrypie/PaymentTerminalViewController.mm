//
//  PaymentTerminalViewController.m
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-24.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import "PaymentTerminalViewController.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "QRCodeViewController.h"
#import <QRCodeEncoderObjectiveCAtGithub/QREncoder.h>
#import <QRCodeEncoderObjectiveCAtGithub/DataMatrix.h>
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "SettingsViewController.h"
#import "APICalls.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "WelcomeViewController.h"

@interface PaymentTerminalViewController ()

@end

@implementation PaymentTerminalViewController
@synthesize currentnumericposition,currentnumericstring, menubtn, lblamount,appdel,imgqr,vwbuttons,btncancel, lbldemo, btnsimulate, currentterminalkey,tblview,txlist,lblemail;

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
    
    //add menubtn & slidemenu
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    
    [menubtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.menubtn];

    
	// Do any additional setup after loading the view.
    
    currentnumericposition = 1;
    appdel = [UIApplication sharedApplication].delegate;

    currentterminalkey = appdel.terminalkey;

    if ([currentterminalkey isEqualToString:@"0"]) //in demo mode
    {
        [self showDemoPopup];
    }
    
    [self SubscribePusher];
    [self showKeyboard];
    [self GetTxlist];
    
    if (appdel.hasprocessor == NO)
    {
        //popup settings, requires an address
        [self OpenWelcome];
    }
    
    lblemail.text = appdel.currentemail;
}

-(void)CloseAllPopUpViewControllers{
    for (UIViewController *tempcontroller in self.childViewControllers){
        
        [tempcontroller.view removeFromSuperview];
        [tempcontroller removeFromParentViewController];
        
    }
}

-(void)OpenWelcome
{
    WelcomeViewController *welcomevc = [self.storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    
    [self addChildViewController:welcomevc];
    [self.view addSubview:welcomevc.view];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnkeyboard:(UIButton*)sender {
    
    NSString *strreturn = @"";
    switch (sender.tag) {
        case 0:
            strreturn = @"0";
            break;
        case 1:
            strreturn = @"1";
            break;
        case 2:
            strreturn = @"2";
            break;
        case 3:
            strreturn = @"3";
            break;
        case 4:
            strreturn = @"4";
            break;
        case 5:
            strreturn = @"5";
            break;
        case 6:
            strreturn = @"6";
            break;
        case 7:
            strreturn = @"7";
            break;
        case 8:
            strreturn = @"8";
            break;
        case 9:
            strreturn = @"9";
            break;
        case 10:
            strreturn = @"delete";
            break;
        case 11:
            strreturn = @"00";
            break;
        case 12:{
            strreturn = @"enter";
            break;
        }
            
        default:
            break;
    }
    
    if (![strreturn isEqualToString:@"enter"]){
        //use decimal keyboard logic
        if([strreturn isEqualToString:@"delete"]){
            currentnumericstring = [self deleteamount:currentnumericstring keypadplace:currentnumericposition];
        }
        else{
            //lblAmount.text = [appdel NumberKeyboardAddChar:lblAmount.text thestring:thestring];
            //lblAmount.text = [NSString stringWithFormat:@"$ %@", lblAmount.text];
            if ([strreturn isEqualToString:@"00"]){
                currentnumericstring = [self enteramount:currentnumericstring newchar:@"0" keypadplace:currentnumericposition];
                currentnumericstring = [self enteramount:currentnumericstring newchar:@"0" keypadplace:currentnumericposition];
            }
            else{
                currentnumericstring = [self enteramount:currentnumericstring newchar:strreturn keypadplace:currentnumericposition];
            }
        }
        lblamount.text = currentnumericstring;
    }
    else{
        if (currentnumericposition > 1){
            [self GetQRcode];
        }
        else{
            [appdel DisplayAlert:@"Please enter amount"];
        }
    }
    
    
}

- (IBAction)btncancel_clicked:(id)sender {
    [self showKeyboard];
}

- (IBAction)btnsimulate_clicked:(id)sender {
    NSString *themessage = [NSString stringWithFormat:@"A payment of %@ has been received",lblamount.text];
    
    
    
    
    //add item to the txlist
    
    NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
    [tempdict setObject:[lblamount.text stringByReplacingOccurrencesOfString:@"$ " withString:@""] forKey:@"requestedamount"];
    [tempdict setObject:[lblamount.text stringByReplacingOccurrencesOfString:@"$ " withString:@""] forKey:@"receivedamount"];
    
    
    
    NSString *tempdate =[appdel dateToDotNet];
    [tempdict setObject:tempdate forKey:@"thedate"];
    
    NSMutableArray *temptxlist = [[NSMutableArray alloc] initWithArray:txlist];
    [temptxlist addObject:tempdict];
    
    txlist = temptxlist;
    [tblview reloadData];
    
    [appdel DisplayAlert:themessage];
    
    [self showKeyboard];
    [self resetAmount];
    
}

- (IBAction)btnLogout_Clicked:(id)sender {
    appdel.terminalkey = @"0";
    [appdel UserDefaults_UpdateUserInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnRefresh_Clicked:(id)sender {
    [self GetTxlist];
}

- (IBAction)btnSettings_Clicked:(id)sender {
    [self OpenWelcome];
}

- (IBAction)btnMenu_Clicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}



-(void)GetQRcode{
    
    NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
    [tempdict setObject:currentterminalkey forKey:@"terminalkey"];
    [tempdict setObject:[lblamount.text stringByReplacingOccurrencesOfString:@"$ " withString:@""] forKey:@"amountUSD"];
    
    APICalls *apicall = [APICalls alloc];
    [apicall BitcoinAddress:tempdict theselector:@selector(QRCode_Response:) theclass:self];
    
}

-(void)QRCode_Response:(NSMutableDictionary*)tempdict
{
    NSString *themessage = [tempdict objectForKey:@"message"];
    
    [self showQR];
    [self setQR:themessage];
}

-(void)GetTxlist{
    
    if ([currentterminalkey isEqualToString:@"4"])
    {
        //is demo mode
        [tblview reloadData];
    }
    else
    {
        NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
        [tempdict setObject:currentterminalkey forKey:@"terminalkey"];
        
        APICalls *apicall = [APICalls alloc];
        [apicall Transaction_List:tempdict theselector:@selector(GetTxlist_Response:) theclass:self];
    }
    
}

-(void)GetTxlist_Response:(NSMutableDictionary*)tempdict
{
    txlist = [tempdict objectForKey:@"transactionlist"];
    [tblview reloadData];
}

-(void)showDemoPopup{
    
    //[appdel DisplayAlert:@"Your terminal is not registered yet.  Your terminal will remain in demo mode until you register at www.cherrypiepayments.com"];
    
    currentterminalkey = @"4";
    
    lbldemo.hidden = NO;
}

-(NSString*)enteramount:(NSString*)thestring newchar:(NSString*)newchar keypadplace:(int)keypadplace{
    if ((keypadplace < 7) && (![newchar isEqualToString:@"."]) && (![newchar isEqualToString:@""])){
        thestring = [thestring stringByReplacingOccurrencesOfString:@"$ " withString:@""];
        thestring = [thestring stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        if (keypadplace == 1){
            if (![newchar isEqualToString:@"0"]){
                thestring = [NSString stringWithFormat:@"00%@", newchar];
            }
            else{
                currentnumericposition --;
                thestring = @"000";
            }
        }
        else if((keypadplace == 2) || (keypadplace == 3)){
            thestring = [thestring substringFromIndex:1];
            thestring = [NSString stringWithFormat:@"%@%@",thestring,newchar];
        }
        else{
            thestring = [NSString stringWithFormat:@"%@%@",thestring,newchar];
        }
        currentnumericposition++;
        
        thestring = [self adddollarsign:thestring];
    }
    return thestring;
}

-(NSString*)adddollarsign:(NSString*)strtemp{
    NSInteger strtemplength = [strtemp length];
    NSString *strtemp1 = [strtemp substringToIndex:strtemplength - 2];
    NSString *strtemp2 = [strtemp substringFromIndex:strtemplength -2];
    NSString *strreturn;
    strreturn = [NSString stringWithFormat:@"$ %@.%@",strtemp1, strtemp2];
    return  strreturn;
}

-(NSString*)deleteamount:(NSString*)thestring keypadplace:(int)keypadplace{
    
    if (keypadplace > 1){
        thestring = [thestring stringByReplacingOccurrencesOfString:@"$ " withString:@""];
        thestring = [thestring stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        if (keypadplace == 2){
            thestring = @"000";
        }
        else if(keypadplace < 5){
            thestring = [thestring substringToIndex:thestring.length - 1];
            thestring = [NSString stringWithFormat:@"0%@",thestring];
        }
        else{
            thestring = [thestring substringToIndex:thestring.length -1];
        }
        thestring = [self adddollarsign:thestring];
        currentnumericposition --;
    }
    
    return thestring;
}

-(void)setQR:(NSString*)themessage{
    
    int qrcodeImageDimension = 300;
    
    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:themessage];
    
    //then render the matrix
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    
    //put the image into the view
    //imgQRcode = [[UIImageView alloc] initWithImage:qrcodeImage];
    imgqr.image = qrcodeImage;
    
    
}

-(void)SubscribePusher{
    
    if (appdel.terminalkey)
    {
        appdel.pusherchannel = [appdel.pusherclient subscribeToChannelNamed:[NSString stringWithFormat:@"cherrypie%@",appdel.terminalkey]];
        
        //subscribe to Bitcoin
        [appdel.pusherchannel bindToEventNamed:@"payconfirmation" handleWithBlock:^(PTPusherEvent *channelEvent) {
            // channelEvent.data is a NSDictianary of the JSON object received
            NSDictionary *tempdict = channelEvent.data;
            NSString *themessage = [tempdict objectForKey:@"message"];
            
            [appdel DisplayAlert:themessage];
            
            [self showKeyboard];
            [self resetAmount];
            [self GetTxlist];
        }];
        
    }
}

-(void)resetAmount{
    lblamount.text = @"$ 0.00";
    currentnumericposition = 1;
}

-(void)showQR{
    imgqr.hidden = NO;
    vwbuttons.hidden = YES;
    btncancel.hidden = NO;
    if ([currentterminalkey isEqualToString:@"4"]){
        btnsimulate.hidden = NO;
    }
}

-(void)showKeyboard{
    imgqr.hidden = YES;
    vwbuttons.hidden = NO;
    btncancel.hidden = YES;
    btnsimulate.hidden = YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int thecount = 5;
    
    if (txlist.count < 5){
        thecount = txlist.count;
    }
    
    return thecount;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *lblrequested = (UILabel *)[cell viewWithTag:100];
    UILabel *lblreceived = (UILabel *)[cell viewWithTag:101];
    UILabel *lbldate = (UILabel *)[cell viewWithTag:102];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm:ss MM/dd"];
    
    NSDictionary *tempdict = [txlist objectAtIndex:indexPath.row];
    
    NSString *strdate =[tempdict objectForKey:@"thedate"];
    NSDate *tempdate =[appdel dateFromDotNet:strdate];
    
    lblrequested.text = [NSString stringWithFormat:@"$ %.2f",[[tempdict objectForKey:@"requestedamount"] doubleValue]];
    lblreceived.text =  [NSString stringWithFormat:@"$ %.2f",[[tempdict objectForKey:@"receivedamount"] doubleValue]];
    lbldate.text = [dateformatter stringFromDate:tempdate];
    
    
    return cell;
}



@end
