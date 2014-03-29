//
//  SBTGraphOverlayView.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
#import "SBTGrowthDataSource.h"

typedef struct {CGFloat beginAge;
                CGFloat endAge;} SBTAgeRange;

@protocol SBTGraphViewDataSource <NSObject>

@required

-(NSArray *)dataPointsInRange:(SBTAgeRange)ageRange;
-(CGFloat)valueForPercentile:(SBTPercentile)percentile
                      forAge:(CGFloat)age
                  forMeasure:(SBTGrowthParameter)parameter;
-(SBTAgeRange)horizRange;
-(CGFloat)vertRange;
-(SBTGender)gender;

@end


@interface SBTGraphView : UIView

@property (nonatomic, weak) id<SBTGraphViewDataSource> dataSource;
@property (nonatomic, assign) SBTGrowthParameter measure;
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UIScrollView *scrollView;


@end
