//
//  QiniuViewController.m
//  QiniuDemo
//
//  Created by Hugh Lv on 12-11-14.
//  Copyright (c) 2012年 Shanghai Qiniu Information Technologies Co., Ltd. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "QiniuViewController.h"
#import "../../QiniuSDK/QiniuAuthPolicy.h"

// NOTE: Please replace with your own accessKey/secretKey.
// You can find your keys on https://dev.qiniutek.com/

#define kAccessKey @"<Please put your accessKey here>"
#define kSecretKey @"<Please put your secretKey here. DO NOT share with others.>"

@interface QiniuViewController ()

@end

@implementation QiniuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_pictureViewer release];
    [_progressBar release];
    [_uploadStatus release];
    [_uploadButton release];
    [popoverController release];

    [super dealloc];
}
- (void)viewDidUnload {
    [self setPictureViewer:nil];
    [self setProgressBar:nil];
    [self setUploadStatus:nil];
    [self setUploadButton:nil];
    [super viewDidUnload];
}
- (IBAction)uploadButtonPressed:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:CGRectMake(100, 50, 200, 300)
                                     inView:self.view
                   permittedArrowDirections:UIPopoverArrowDirectionUp
                                   animated:YES];
            popoverController = popover;
            popover.delegate = self;
        } else {
            [self presentModalViewController:imagePicker animated:YES];
        }
    }
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    [self performSelectorInBackground:@selector(uploadContent:) withObject:theInfo];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

// Progress updated.
- (void)uploadProgressUpdated:(NSString *)filePath percent:(float)percent
{
    self.progressBar.progress = percent;
    
    [self.progressBar setNeedsDisplay];
    
    NSString *message = [NSString stringWithFormat:@"Progress of uploading %@ is: %.2f%%",  filePath, percent * 100];
    NSLog(@"%@", message);
    
    [self.uploadStatus setText:message];
}

// Upload completed successfully.
- (void)uploadSucceeded:(NSString *)filePath hash:(NSString *)hash
{
    NSString *message = [NSString stringWithFormat:@"Successfully uploaded %@ with hash: %@",  filePath, hash];
    NSLog(@"%@", message);
    
    [self.uploadStatus setText:message];
}

// Upload failed.
//
// (NSError *)error:
//      ErrorDomain - QiniuSimpleUploader
//      Code - It could be a general error (< 100) or a HTTP status code (>100)
//      Message - You can use this line of code to retrieve the message: [error.userInfo objectForKey:@"error"]
- (void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"Failed uploading %@ with error: %@",  filePath, error];
    NSLog(@"%@", message);
    
    self.progressBar.progress = 0; // Reset
    [self.progressBar setNeedsDisplay];
    
    [self.uploadStatus setText:message];
}

- (void)uploadContent:(NSDictionary *)theInfo {
    
    //obtaining saving path
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
    
    [formatter release];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [theInfo objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] || [mediaType isEqualToString:(NSString *)ALAssetTypePhoto]) {
        
        NSString *key = [NSString stringWithFormat:@"%@%@", timeDesc, @".jpg"];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
        NSLog(@"Upload Path: %@", filePath);
        
        NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerOriginalImage], 0.6);
        [webData writeToFile:filePath atomically:YES];
        
        [self uploadFile:filePath bucket:@"bucket" key:key];
    }
}

- (void)uploadFile:(NSString *)filePath bucket:(NSString *)bucket key:(NSString *)key {
    
    self.progressBar.progress = 0;
    [self.progressBar setNeedsDisplay];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]) {
        
        QiniuAuthPolicy *policy = [[QiniuAuthPolicy alloc] init];
        policy.scope = @"bucket";
        
        NSString *token = [policy makeToken:kAccessKey secretKey:kSecretKey];
        
        [policy release];
        
        NSLog(@"UpToken: %@", token);
        
        QiniuSimpleUploader *uploader = [[QiniuSimpleUploader alloc] init];
        uploader.token = token;
        uploader.delegate = self;
        
        [uploader upload:filePath bucket:bucket key:key extraParams:nil];
    }
}
@end
