//
//  SBTGraphView.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTGraphView.h"

@implementation SBTGraphView
{
    double vScale;
    double hScale;
}

-(void)drawRect:(CGRect)rect
{
    vScale = [self.dataSource valueForPercentile:97
                                          forAge:3
                                      forMeasure:self.measure];
}

@end
