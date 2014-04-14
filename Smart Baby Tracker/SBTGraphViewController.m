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
@property (weak, nonatomic) IBOutlet UIImageView *overlayView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (readonly) CGFloat maxVRange;

@end

@implementation SBTGraphViewController
@synthesize maxVRange = _maxVRange;

# pragma mark - moving targets

-(CGFloat)maxVRange
{
    if (!_maxVRange){
        _maxVRange = [self.growthDataSource dataMeasurementRange97PercentForParameter:self.parameter
                                                                      forGender:self.baby.gender] * VERTICAL_RANGE_ADJUSTMENT;
    }
    return _maxVRange;
}

-(CGFloat)maxHRange
{
    return [self.growthDataSource dataAgeRange];
}

-(CGFloat)currentVMeasurePerPoint
{
    CGFloat ratio = [self maxVRange] / self.graphView.bounds.size.height;
    return ratio;
}

-(CGFloat)currentHMeasurePerPoint
{
    CGFloat ratio = [self maxHRange] / self.graphView.bounds.size.width;
    return ratio;
}

-(CGRect)currentMeasureVisibleExtents
{
    // The tricky part is that this is a rect in the screen oriented coordinates - x,y == TOP LEFT!!!
    // So... the y represents the max measure.  The min is given by (maxVRange - y - size.height)
    CGRect ptRect = [self.graphView convertRect:self.overlayView.bounds fromView:self.overlayView];
    CGFloat hRatio = [self currentHMeasurePerPoint];
    CGFloat vRatio = [self currentVMeasurePerPoint];
    CGRect mRect = CGRectMake(ptRect.origin.x * hRatio, ptRect.origin.y * vRatio, ptRect.size.width * hRatio, ptRect.size.height * vRatio);
    return mRect;
}

-(void)adjustAxesForContentOffset:(CGPoint)offset andScale:(CGFloat)scale
{
    // axes will be drawn for display units based on user preferences
    // draw these into an image context, then set the image as the UIImage of the overlayView
    UIGraphicsBeginImageContextWithOptions(self.overlayView.bounds.size, NO, 0.0);
    
//    CGFloat yExtent = self.overlayView.bounds.size.height;
//    CGFloat xExtent = self.overlayView.bounds.size.width;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path setLineWidth:1.0];
//    [path moveToPoint:CGPointMake(0, yExtent - 10)];
//    [path addLineToPoint:CGPointMake(xExtent, yExtent - 10)];
//    [path moveToPoint:CGPointMake(xExtent - 10, 0)];
//    [path addLineToPoint:CGPointMake(xExtent - 10, yExtent)];
//    [[UIColor lightGrayColor] setStroke];
//    [path stroke];
    
    // get the beginning and end of visible portions of each axis in METRIC MEASUREMENT UNITS
    
    CGRect r = [self currentMeasureVisibleExtents];
    CGPoint orig = CGPointMake(r.origin.x, self.maxVRange - r.origin.y - r.size.height);
    CGPoint maxPt = CGPointMake(orig.x + r.size.width, orig.y + r.size.height);
    //TODO: Move the crosshair code into the scroll view image
    // and only draw labels along the edges here
    // draw faint crosshair lines every year and every 10 kg
    [[UIColor SBTSuperLightGray] setStroke];
    [path setLineWidth:0.5];
    
    for (int y = 5; y < maxPt.y; y += 5){
        if (y > orig.y){
            CGFloat loc = (y - orig.y) / ([self currentVMeasurePerPoint] / self.scrollView.zoomScale);
            CGPoint p = CGPointMake(0.0, loc);
            [path moveToPoint:p];
            [path addLineToPoint:CGPointMake(self.overlayView.bounds.size.width, p.y)];
        }
        [path stroke];
    }
    
    for (int x = 1; x < 20; x++){
        CGFloat days = x * 365.25;
        if (days > orig.x && days < maxPt.x){
            CGFloat loc = (days - orig.x) / ([self currentHMeasurePerPoint] / self.scrollView.zoomScale);
            CGPoint p = CGPointMake(loc, 0.0);
            [path moveToPoint:p];
            [path addLineToPoint:CGPointMake(p.x, self.overlayView.bounds.size.height)];
        }
        [path stroke];
    }
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.overlayView.image = image;
    UIGraphicsEndImageContext();
}

#pragma mark - Target/Action


#pragma mark - UIScrollView Delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.graphView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustAxesForContentOffset:scrollView.contentOffset andScale:scrollView.contentScaleFactor];
//    CGRect r = [self currentMeasureVisibleExtents];
//    CGFloat minMeasure = self.maxVRange - r.origin.y - r.size.height;
//    NSLog(@"Current visible extents: origin -> %1.1f, %1.1f \n range -> %1.1f, %1.1f", r.origin.x, minMeasure, r.size.width, r.size.height);
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self adjustAxesForContentOffset:scrollView.contentOffset andScale:scrollView.contentScaleFactor];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self adjustAxesForContentOffset:scrollView.contentOffset andScale:scale];
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
    NSMutableArray *pcts = [NSMutableArray arrayWithArray: @[@(P5), @(P10), @(P25), @(P50), @(P75), @(P90), @(P95)]];
    if (self.parameter == SBTBMI) [pcts insertObject:@(P85) atIndex:5];
    for (NSNumber *n in pcts){
        SBTPercentile p = (SBTPercentile)[n integerValue];
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path setLineWidth:2.0];
        if ([n integerValue] == (NSInteger)P50 || [n integerValue] == (NSInteger)P85) [path setLineWidth:4.0];
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
