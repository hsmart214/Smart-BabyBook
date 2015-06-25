//
//  SBTScannerViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTScannerViewController.h"
@import MobileCoreServices;

@interface SBTScannerViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate>

//@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) dispatch_queue_t captureQueue;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVMetadataMachineReadableCodeObject *lastRecognizedObject;
@property (weak, nonatomic) AVCaptureVideoPreviewLayer *pLayer; // we keep a reference to this so we can get rid of it

@end

@implementation SBTScannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.captureQueue = dispatch_queue_create("capture_queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    
    self.captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    if(videoInput)
        [self.captureSession addInput:videoInput];
    else
        NSLog(@"Error: %@", error);
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:metadataOutput];
    [metadataOutput setMetadataObjectsDelegate:self queue:self.captureQueue];
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeDataMatrixCode]];
    
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    previewLayer.frame = self.view.layer.bounds;
    self.pLayer = previewLayer;
    [self.view.layer addSublayer:previewLayer];
    
    [self.captureSession startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([self.captureSession isRunning]){
        __weak SBTScannerViewController *myWeakSelf = self;
        for(AVMetadataObject *metadataObject in metadataObjects)
        {
            AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
            if (![readableObject.stringValue isEqualToString:self.lastRecognizedObject.stringValue]){
                self.lastRecognizedObject = readableObject;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [myWeakSelf.delegate camera:self didCaptureBarcode:readableObject];
                    [myWeakSelf.captureSession stopRunning];
                    [myWeakSelf.pLayer removeFromSuperlayer];
                    [myWeakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }
    }
}


@end
