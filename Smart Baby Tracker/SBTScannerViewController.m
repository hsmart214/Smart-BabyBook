//
//  SBTScannerViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTScannerViewController.h"
#import "UIColor+SBTColors.h"
@import MobileCoreServices;

#define RETICLE_LINE_WIDTH 5.0f
#define RETICLE_LENGTH 20.0f

@interface SBTScannerViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate>

//@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) dispatch_queue_t captureQueue;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVMetadataMachineReadableCodeObject *lastRecognizedObject;
@property (weak, nonatomic) AVCaptureVideoPreviewLayer *pLayer; // we keep a reference to this so we can get rid of it
@property (weak, nonatomic) IBOutlet UIView *previewLayer;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImageView;

@end

@implementation SBTScannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up the overlay view
    CGSize size = self.overlayImageView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor SBTTransparentAluminum] setFill];
    CGFloat qtr = size.width/4.0;
    CGFloat third = size.height/3.0;
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0.0, 0.0);
    CGContextAddRect(ctx, CGRectMake(0.0, 0.0, qtr, size.height));
    CGContextAddRect(ctx, CGRectMake(3*qtr, 0.0, qtr, size.height));
    CGContextAddRect(ctx, CGRectMake(qtr, 0.0, 2*qtr, third));
    CGContextAddRect(ctx, CGRectMake(qtr, 2*third, 2*qtr, third));
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    CGContextBeginPath(ctx);
    CGFloat w = RETICLE_LINE_WIDTH;
    CGFloat l = RETICLE_LENGTH;
    CGContextSetLineWidth(ctx, w);
    CGContextMoveToPoint(ctx, qtr - w/2, third + l);
    CGContextAddLineToPoint(ctx, qtr - w/2, third - w/2);
    CGContextAddLineToPoint(ctx, qtr + l + w/2, third - w/2);
    
    UIColor *color = [self.view.tintColor colorWithAlphaComponent:0.5];
    [color setStroke];
    CGContextStrokePath(ctx);
    
    UIImage *overlay = UIGraphicsGetImageFromCurrentImageContext();
    
    self.overlayImageView.image = overlay;
    
    // set up and run the video preview layer
    
    self.captureQueue = dispatch_queue_create("capture_queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    
    self.captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    if(videoInput){
        [self.captureSession addInput:videoInput];
        [videoCaptureDevice lockForConfiguration:&error];
        if (error) {
            NSLog(@"Error locking capture device: %@", [error debugDescription]);
        }else{
            [videoCaptureDevice setVideoZoomFactor:1.5];
            [videoCaptureDevice unlockForConfiguration];
        }
    }else{
        NSLog(@"Error: %@", [error debugDescription]);
    }
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:metadataOutput];
    [metadataOutput setMetadataObjectsDelegate:self queue:self.captureQueue];
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeDataMatrixCode]];
    
    
    AVCaptureVideoPreviewLayer *pLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    pLayer.frame = self.view.layer.bounds;
    self.pLayer = pLayer;
    [self.previewLayer.layer addSublayer:pLayer];
    
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
                    [myWeakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
        }
    }
}

-(void)dealloc{
    self.captureQueue = nil;
    self.captureSession = nil;
    self.lastRecognizedObject = nil;
}


@end
