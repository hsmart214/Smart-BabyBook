//
//  SBTGrowthChart.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTGrowthDataSource.h"

@implementation SBTGrowthDataSource

-(double)percentileForAge:(NSInteger)days forParameter:(SBTGrowthParameter)parameter
{
    NSAssert(NO, @"Should not be calling the superclass method for SBTGrowthDataSource");
    return 0.0;
}

@end
