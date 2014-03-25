//
//  SBTGraphViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTGraphViewController.h"
#import "SBTGraphView.h"
#import "SBTBaby.h"

@interface SBTGraphViewController ()<SBTGraphViewDataSource>

@end

@implementation SBTGraphViewController

#pragma mark - Gestures

- (IBAction)pinch:(UIPinchGestureRecognizer *)sender {
    
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    
}

#pragma mark - SBTGraphViewDataSource

-(NSArray *)dataPointsInRange:(NSRange)ageRange
{
    NSMutableArray *points = [NSMutableArray array];
    return points;
}

-(CGFloat)valueForPercentile:(SBTPercentile)percentile
                      forAge:(CGFloat)age
                  forMeasure:(SBTGrowthParameter)parameter
{
    return 0.0;
}

-(CGFloat)horizRange
{
    return [self.growthDataSource dataAgeRange];
}

-(CGFloat)vertRange
{
    return [self.growthDataSource dataMeasurementRange97PercentForParameter:self.parameter
                                                                  forGender:self.baby.gender];
}

#pragma mark - View Life Cycle

-(void)viewDidLoad
{
    
}

@end
