//
//  SBTScannerViewController.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
@import AVFoundation;

@protocol SBTCaptureDelegate <NSObject>

-(void) camera:(id)sender didCaptureBarcode:(AVMetadataMachineReadableCodeObject *)barcode;

@end


@interface SBTScannerViewController : UIViewController

@property (weak, nonatomic) id<SBTCaptureDelegate> delegate;

@end
