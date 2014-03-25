//
//  SBTGraphView.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTGrowthDataSource.h"

@protocol SBTGraphViewDataSource <NSObject>

@required

-(NSArray *)dataPointsInRange:(NSRange)ageRange;
-(CGFloat)valueForPercentile:(SBTPercentile)percentile
                      forAge:(CGFloat)age
                  forMeasure:(SBTGrowthParameter)parameter;
-(CGFloat)horizRange;
-(CGFloat)vertRange;

@end

@interface SBTGraphView : UIView

@property (nonatomic, weak) id<SBTGraphViewDataSource> dataSource;
@property (nonatomic, assign) SBTGrowthParameter measure;

@end
