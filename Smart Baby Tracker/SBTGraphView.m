//
//  SBTGraphOverlayView.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTGraphView.h"
#import "SBTGraphPoint.h"
#import "SBTEncounter.h"
#import "SBTBaby.h"

@interface SBTGraphView()

{
    CGFloat vScale;
    CGFloat hScale;
    NSMutableArray *showPoints;
}

@end

@implementation SBTGraphView

-(void)drawRect:(CGRect)rect
{
    CGFloat currentYScale = [self.dataSource vertRange] / self.imageView.bounds.size.height;
    CGFloat currentXScale = [self.dataSource horizRange].endAge / self.imageView.bounds.size.width;
    CGFloat x = self.imageView.bounds.size.height;
    CGFloat b = self.scrollView.bounds.size.height;
    CGFloat c = self.scrollView.contentOffset.y;
    CGFloat a = x - (b + c);
    CGFloat maxMeasure = (a + b) * currentYScale;
    CGFloat minMeasure = a * currentYScale;
    CGFloat k = self.scrollView.contentOffset.x;
    CGFloat h = self.scrollView.bounds.size.width;
    CGFloat minAge = k * currentXScale;
    CGFloat maxAge = (k + h) * currentXScale;
    
    SBTAgeRange ageRange = {minAge, maxAge};
    NSArray *points = [self.dataSource dataPointsInRange:ageRange];
    if (!showPoints) showPoints = [NSMutableArray array];
    for (SBTEncounter *enc in points){
        SBTGraphPoint *pt = [[SBTGraphPoint alloc] init];
        pt.age = [enc.baby ageInDaysAtEncounter:enc].day;
        switch (self.measure) {
            case SBTWeight:
                pt.measurement = enc.weight;
                break;
            case SBTLength:
                pt.measurement = enc.length;
                break;
            case SBTStature:
                pt.measurement = enc.height;
                break;
            case SBTHeadCircumference:
                pt.measurement = enc.headCirc;
                break;
            case SBTBMI:
                pt.measurement = enc.BMI;
        }
        if (pt.measurement >= minMeasure && pt.measurement<= maxMeasure)
            [showPoints addObject:pt];
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (SBTGraphPoint *pt in showPoints){
        CGFloat x = pt.age / currentXScale;
        CGFloat y = pt.measurement / currentYScale;
        CGPoint p = CGPointMake(x, y);
        CGPoint pt1 = [self.scrollView convertPoint:p fromView:self.imageView];
        CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(pt1.x, pt1.y, 2.0, 2.0), &CGAffineTransformIdentity);
        CGContextAddPath(ctx, path);
        CGContextStrokePath(ctx);
        CGPathRelease(path);
    }
}

@end
