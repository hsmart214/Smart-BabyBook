//
//  SBTGraphView.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTGraphView.h"

#define GRAPH_RATIO 4.0f

@implementation SBTGraphView
{
    CGFloat vScale;
    CGFloat hScale;
    UIColor *babyBlue;
    UIColor *babyPink;
}

#pragma mark - UIScrollView Delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - life cycle

-(void)setUpOnce
{
    self.scrollView.delegate = self;
    babyBlue = [UIColor colorWithRed:200.0/255.0 green:230.0/255.0 blue:1.0 alpha:1.0];
    babyPink = [UIColor colorWithRed:1.0 green:200.0/255.0 blue:230.0/255.0 alpha:1.0];
    vScale = [self.dataSource vertRange] / (self.scrollView.bounds.size.height * GRAPH_RATIO);
    hScale = [self.dataSource horizRange].endAge / (self.scrollView.bounds.size.width * GRAPH_RATIO);
    
    // create an offscreen image and draw a 4x representation of the growth curve percentiles
    CGSize imageSize = CGSizeMake(self.scrollView.bounds.size.width * GRAPH_RATIO, self.scrollView.bounds.size.height * GRAPH_RATIO);
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    CGRect rect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor whiteColor] setFill];
    [path fill];
    path = nil;
    for (NSNumber *n in @[@(P3), @(P5), @(P10), @(P25), @(P50), @(P75), @(P90), @(P95), @(P97)]){
        NSLog(@"%@", n);
        SBTPercentile p = (SBTPercentile)[n integerValue];
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path setLineWidth:2.0];
        [path setLineJoinStyle:kCGLineJoinRound];
        if ([self.dataSource gender] == SBTMale){
            [babyBlue setStroke];
        }else{
            [babyPink setStroke];
        }
        CGFloat x = 0.0;
        CGFloat maxY = self.scrollView.bounds.size.height;
        CGFloat y = maxY -[self.dataSource valueForPercentile:p forAge:0.0 forMeasure:self.measure] / vScale;
        [path moveToPoint:CGPointMake(x, y)];
        while (x < imageSize.width){
            CGFloat age = x / hScale;
            y = maxY - [self.dataSource valueForPercentile:p forAge:age forMeasure:self.measure] / vScale;
            [path addLineToPoint:CGPointMake(x, y)];
            x += 1.0;
        }
        [path stroke];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = image;
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.imageView setBounds:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [self.scrollView setZoomScale:1.0/GRAPH_RATIO];
    [self setNeedsDisplay];
}

@end
