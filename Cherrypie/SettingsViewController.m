//
//  SettingsViewController.m
//  Cherrypie
//
//  Created by Lorne Lantz on 2014-06-22.
//  Copyright (c) 2014 Lorne Lantz. All rights reserved.
//

#import "SettingsViewController.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "InitViewController.h"
#import "APICalls.h"
#import "MenuViewController.h"

@interface SettingsViewController ()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;

-(BOOL)startReading;
-(void)stopReading;
-(void)loadBeepSound;

@end

@implementation SettingsViewController
@synthesize appdel, vwpassword,vwaddress,txtpassword,lbladdress,viewPreview,viewPreview2, webvw_coinbase, menubtn;

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
    
    appdel = [UIApplication sharedApplication].delegate;
    
//    self.view.frame = CGRectMake(50, 50, 356, 400);
    
    if (appdel.hasprocessor)
    {
        //show password
        [self ShowPassword];
    }
    else{
        //hide password
        [self ShowAddress];
    }
    
    lbladdress.text = appdel.currentbitcoinaddress;
    if (appdel.currentbitcoinaddress == @"")
    {
        lbladdress.text = @"No address entered";
    }

}

-(void)ShowPassword
{
    vwpassword.hidden = NO;
    vwaddress.hidden = YES;
    [txtpassword becomeFirstResponder];
}

-(void)ShowAddress
{
    vwpassword.hidden = YES;
    vwaddress.hidden = NO;
    [txtpassword resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)Checkpassword{
    
    NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
    [tempdict setObject:appdel.currentemail forKey:@"email"];
    [tempdict setObject:txtpassword.text forKey:@"password"];
    [tempdict setObject:[[[UIDevice currentDevice] identifierForVendor]UUIDString] forKey:@"androidid"];
    
    APICalls *apicall = [APICalls alloc];
    [apicall User_Login:tempdict theselector:@selector(Checkpassword_Response:) theclass:self];
    
}

-(void)Checkpassword_Response:(NSMutableDictionary*)tempdict
{
    BOOL isvalid = [[tempdict objectForKey:@"isvalid"] boolValue];
    
    [appdel HUDHide];
    
    if (isvalid)
    {
        //open initpage
        [self ShowAddress];
    }
    else
    {
        //popup
        [appdel DisplayAlert:@"Invalid password."];
    }
}



#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:viewPreview2.layer.bounds];
    [viewPreview2.layer addSublayer:_videoPreviewLayer];
    
    
    // Start video capture.
    [_captureSession startRunning];
    
    viewPreview.hidden = NO;
    viewPreview2.hidden = NO;
    
    return YES;
}

-(void)UpdateAddress:(NSString*)thestring
{
    if ([thestring rangeOfString:@"bitcoin:"].location != NSNotFound)
    {
        thestring = [thestring stringByReplacingOccurrencesOfString:@"bitcoin:" withString:@""];
    }
    
    [lbladdress performSelectorOnMainThread:@selector(setText:) withObject:thestring waitUntilDone:NO];
    
    appdel.currentbitcoinaddress = thestring;
    [appdel UserDefaults_UpdateUserInfo];
    
    //update address on server
    NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
    [tempdict setObject:appdel.terminalkey forKey:@"terminalkey"];
    [tempdict setObject:thestring forKey:@"bitcoinaddress"];
    
    APICalls *apicall = [APICalls alloc];
    [apicall BitcoinAddress_Update:tempdict theselector:@selector(UpdateAddress_Response:) theclass:self];
}

-(void)UpdateAddress_Response:(NSMutableDictionary*)tempdict
{
    appdel.hasprocessor = YES;
    [appdel UserDefaults_UpdateUserInfo];
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
    
    viewPreview.hidden = YES;
    viewPreview2.hidden = YES;
}


-(void)loadBeepSound{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    
    NSError *error;
    
    // Initialize the audio player object using the NSURL object previously set.
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.

            [self UpdateAddress:[metadataObj stringValue]];
           
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            //[_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            
            _isReading = NO;
            
            // If the audio player is not nil, then play the sound effect.
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        }
    }
    
}

- (IBAction)btnClose_Clicked:(id)sender {
//    InitViewController *initvc = self.parentViewController;
//    [initvc CloseAllPopUpViewControllers];
}

- (IBAction)btnScanQR_Clicked:(id)sender {
    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        if ([self startReading]) {
            // If the startReading methods returns YES and the capture session is successfully
            // running, then change the start button title and the status message.
            //[_bbitemStart setTitle:@"Stop"];
            //[_lblStatus setText:@"Scanning for QR Code..."];
        }
        
    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
        // The bar button item's title should change again.
        //[_bbitemStart setTitle:@"Start!"];
    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    _isReading = !_isReading;

}

- (IBAction)btnConnectCoinbase_Clicked:(id)sender {
    webvw_coinbase.hidden = NO;
    
    NSURL*url=[NSURL URLWithString:@"https://coinbase.com/oauth/authorize?response_type=code&client_id=d14bb3dfe7a2b097c4bdfa31eedc429c48ae4ca077560310f8cac2f783c8a805&redirect_uri=http://www.cherrypiepayments.com/loggedin/coinbasecallback.aspx&scope=addresses"];
    NSURLRequest*request=[NSURLRequest requestWithURL:url];
    [webvw_coinbase loadRequest:request];

}

- (IBAction)btnCancel_Clicked:(id)sender {
    [self stopReading];
}

- (IBAction)btnPassword_Clicked:(id)sender {
    [self Checkpassword];
}

- (IBAction)btnMenu_Clicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

# pragma mark - Webview events

- (void)webViewDidStartLoad:(UIWebView *)webView {
 NSString *tempstr = webView.request.URL.absoluteString;
    
    if ([tempstr rangeOfString:@"http://www.cherrypiepayments.com/loggedin/coinbasecallback.aspx?code"].location != NSNotFound)
    {
        
    }
    [appdel HUDProcessing];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
NSString *tempstr = webView.request.URL.absoluteString;
    
    [appdel HUDHide];
    
    if ([tempstr rangeOfString:@"http://www.cherrypiepayments.com/loggedin/coinbasecallback.aspx?code"].location != NSNotFound)
    {
        //contains code, so was approved
        
            //doesn't contain terminal key, so insert it and redirect
            NSURL*url=[NSURL URLWithString:[NSString stringWithFormat:@"%@&terminalkey=%@",tempstr,appdel.terminalkey]];
            NSURLRequest*request=[NSURLRequest requestWithURL:url];
            [webvw_coinbase loadRequest:request];
        
        

    }
    else if ([tempstr rangeOfString:@"http://www.cherrypiepayments.com/loggedin/coinbasecallback.aspx?error"].location != NSNotFound){
        //didn't go through
        
        [self ShowAddress];
         webvw_coinbase.hidden = YES;
    }
    else if ([tempstr rangeOfString:@"http://www.cherrypiepayments.com/Loggedin/Signin.aspx"].location != NSNotFound)
    {
            //contains terminal key, so process complete
            appdel.hasprocessor = YES;
            appdel.currentbitcoinaddress = @"coinbase";
            [appdel UserDefaults_UpdateUserInfo];
            
            lbladdress.text = @"coinbase";
            [self ShowAddress];
            webvw_coinbase.hidden = YES;
            
    }
    
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
 
}

@end
