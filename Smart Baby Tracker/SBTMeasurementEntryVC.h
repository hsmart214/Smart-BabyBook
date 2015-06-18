//
//  SBTMeasurementEntryVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 6/12/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

@import UIKit;

@protocol SBTMeasurementReturnDelegate <NSObject>
@required
-(void)measurementReturnDelegate:(id)delegate returnedMeasurement:(double)measurement forParameter:(SBTGrowthParameter)parameter;

@end

@interface SBTMeasurementEntryVC : UIViewController

@property (nonatomic) SBTGrowthParameter parameter;
@property (nonatomic) double measure;
@property (nonatomic, getter=isInfant) BOOL infant;
@property (weak, nonatomic) id<SBTMeasurementReturnDelegate> delegate;

@end
