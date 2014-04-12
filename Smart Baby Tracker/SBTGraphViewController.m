//
//  SBTGraphViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTGraphViewController.h"
#import "SBTBaby.h"
#import "UIColor+SBTColors.h"

#define VERTICAL_RANGE_ADJUSTMENT 1.1f
#define GRAPH_RATIO 4.0

#define HEIGHT_TAB_POSITION 0
#define WEIGHT_TAB_POSITION 1
#define HEAD_CIRC_TAB_POSITION 2
#define BMI_TAB_POSITION 3

@interface SBTGraphViewController ()<UIScrollViewDelegate, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *graphView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@end

@implementation SBTGraphViewController

# pragma mark - moving targets

-(CGFloat)maxVRange
{
    return [self.growthDataSource dataMeasurementRange97PercentForParameter:self.parameter
                                                                  forGender:self.baby.gender] * VERTICAL_RANGE_ADJUSTMENT;
}

-(CGFloat)maxHRange
{
    return [self.growthDataSource dataAgeRange];
}

-(CGFloat)currentVMeasurePerPoint
{
    // this will be the ratio of metric measurement units per point on the screen at the current zoom scale
    CGFloat ratio = [self maxVRange] / self.graphView.bounds.size.height;
    return ratio;
}

-(CGFloat)currentHMeasurePerPoint
{
    CGFloat ratio = [self maxHRange] / self.graphView.bounds.size.width;
    return ratio;
}

-(void)setAxesForContentOffset:(CGPoint)offset andScale:(CGFloat)scale
{
    
}

#pragma mark - Target/Action


#pragma mark - UIScrollView Delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.graphView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setAxesForContentOffset:scrollView.contentOffset andScale:scrollView.contentScaleFactor];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setAxesForContentOffset:scrollView.contentOffset andScale:scrollView.contentScaleFactor];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    NSLog (@"Zoom scale: %1.2f", scale);
    NSLog (@"V: %1.2f, H: %1.2f", [self currentVMeasurePerPoint], [self currentHMeasurePerPoint]);
}

#pragma mark - UITabBar Delegate

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger pos = [tabBar.items indexOfObject:item];
    switch (pos) {
        case HEIGHT_TAB_POSITION:
            self.parameter = SBTStature;
            [self drawPercentiles];
            break;
        case WEIGHT_TAB_POSITION:
            self.parameter = SBTWeight;
            [self drawPercentiles];
            break;
        case HEAD_CIRC_TAB_POSITION:
            self.parameter = SBTHeadCircumference;
            [self drawPercentiles];
            break;
        case BMI_TAB_POSITION:
            self.parameter = SBTBMI;
            [self drawPercentiles];
            break;
        default:
            break;
    }
}

-(void)selectParameter:(SBTGrowthParameter)parameter
{
    switch (parameter) {
        case SBTStature:
        case SBTLength:
            [self.tabBar setSelectedItem:self.tabBar.items[HEIGHT_TAB_POSITION]];
            break;
        case SBTWeight:
            [self.tabBar setSelectedItem:self.tabBar.items[WEIGHT_TAB_POSITION]];
            break;
        case SBTHeadCircumference:
            [self.tabBar setSelectedItem:self.tabBar.items[HEAD_CIRC_TAB_POSITION]];
            break;
        case SBTBMI:
            [self.tabBar setSelectedItem:self.tabBar.items[BMI_TAB_POSITION]];
            break;
    }
}

#pragma mark - View Life Cycle

-(void)viewDidLayoutSubviews
{
    [self drawPercentiles];
}

-(void)drawPercentiles
{
    for (UIView *view in self.scrollView.subviews){
        [view removeFromSuperview];
    }
    CGFloat vScale = [self maxVRange] / (self.scrollView.bounds.size.height * GRAPH_RATIO);
    CGFloat hScale = [self maxHRange] / (self.scrollView.bounds.size.width * GRAPH_RATIO);
    
    // create an offscreen image and draw a 4x representation of the growth curve percentiles
    CGSize imageSize = CGSizeMake(self.scrollView.bounds.size.width * GRAPH_RATIO, self.scrollView.bounds.size.height * GRAPH_RATIO);
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    CGRect rect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor whiteColor] setFill];
    [path fill];
    path = nil;
    for (NSNumber *n in @[@(P5), @(P10), @(P25), @(P50), @(P75), @(P90), @(P95)]){
        SBTPercentile p = (SBTPercentile)[n integerValue];
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path setLineWidth:2.0];
        [path setLineJoinStyle:kCGLineJoinRound];
        if ([self.baby gender] == SBTMale){
            [[UIColor SBTBabyBlue] setStroke];
        }else{
            [[UIColor SBTBabyPink] setStroke];
        }
        CGFloat x = 0.0;
        CGFloat maxY = self.scrollView.bounds.size.height * GRAPH_RATIO;
        CGFloat measurement = [self.growthDataSource dataForPercentile:p forAge:0.0 parameter:self.parameter andGender:self.baby.gender];
        CGFloat y = maxY - measurement / vScale;
        [path moveToPoint:CGPointMake(x, y)];
        while (x < imageSize.width){
            CGFloat age = x * hScale;
            y = maxY - [self.growthDataSource dataForPercentile:p forAge:age parameter:self.parameter andGender:self.baby.gender] / vScale;
            [path addLineToPoint:CGPointMake(x, y)];
            x += 1.0;
        }
        [path stroke];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.graphView = [[UIImageView alloc] initWithImage:image];
    [self.scrollView addSubview:self.graphView];
    self.scrollView.contentSize = image.size;
    [self.scrollView setZoomScale:1.0/GRAPH_RATIO];
    UIGraphicsEndImageContext();
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self selectParameter:self.parameter];
}

-(void)dealloc
{
    self.graphView = nil;
}

@end
