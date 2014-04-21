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
#import "SBTUnitsConvertor.h"

#define VERTICAL_RANGE_ADJUSTMENT 1.1f
#define GRAPH_RATIO 4.0

#define HEIGHT_TAB_POSITION 0
#define WEIGHT_TAB_POSITION 1
#define HEAD_CIRC_TAB_POSITION 3
#define BMI_TAB_POSITION 2

@interface SBTGraphViewController ()<UIScrollViewDelegate, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *graphView;
@property (weak, nonatomic) IBOutlet UIImageView *overlayView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (nonatomic) CGFloat maxVRange;
@property (nonatomic) CGFloat maxHRange;
@property (nonatomic) CGFloat graphBaseline;
@property (nonatomic, getter = isChildChart) BOOL childChart;

@end

@implementation SBTGraphViewController

# pragma mark - moving targets

-(CGFloat)maxVRange
{
    if (_maxVRange < 0.0){
        _maxVRange = [self.growthDataSource dataMeasurementRange97PercentForParameter:self.parameter
                                                                            forGender:self.baby.gender
                                                                             forChild:[self isChildChart]] * VERTICAL_RANGE_ADJUSTMENT;
    }
    return _maxVRange;
}

-(CGFloat)maxHRange
{
    if (_maxHRange < 0.0){
        _maxHRange = [self isChildChart] ? [self.growthDataSource dataAgeRangeForAge:[SBTGrowthDataSource infantAgeMaximum] + 1.0] : [SBTGrowthDataSource infantAgeMaximum];
    }
    return _maxHRange;
}

-(CGFloat)graphBaseline
{
    if (_graphBaseline < 0.0){
        _graphBaseline = [self.growthDataSource dataFloorForParameter:self.parameter];
    }
    return _graphBaseline;
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
    //TODO: Draw the axes
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path setLineWidth:1.0];
    [[UIColor SBTSuperLightGray] setStroke];
    [path setLineWidth:0.5];
    
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
    _maxVRange = -1.0;   // this forces the recalculation of same
    _maxHRange = -1.0;
    _graphBaseline = -1.0;
    NSInteger pos = [tabBar.items indexOfObject:item];
    switch (pos) {
        case HEIGHT_TAB_POSITION:
            self.parameter = [self isChildChart] ? SBTStature : SBTLength;
            break;
        case WEIGHT_TAB_POSITION:
            self.parameter = SBTWeight;
            break;
        case HEAD_CIRC_TAB_POSITION:
            self.parameter = SBTHeadCircumference;
            break;
        case BMI_TAB_POSITION:
            self.parameter = SBTBMI;
            break;
        default:
            break;
    }
    [self drawPercentiles];
}

-(void)selectParameter:(SBTGrowthParameter)parameter
{
    self.parameter = parameter;
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
    // if it is a child (not infant) chart, start the graph at the age break point
    CGFloat xStart = 0.0;
    if ([self isChildChart]) xStart = [SBTGrowthDataSource infantAgeMaximum] + 1.0;
    
    // set the baseline of the chart based on which graph is being displayed
    // ask the growthDataSource
    CGFloat yStart = [self.growthDataSource baselineForParameter:self.parameter childChart:[self isChildChart]];
    
    
    for (UIView *view in self.scrollView.subviews){
        [view removeFromSuperview];
    }
    
    // create an offscreen image and draw a 4x representation of the growth curve percentiles
    CGSize imageSize = CGSizeMake(self.scrollView.bounds.size.width * GRAPH_RATIO, self.scrollView.bounds.size.height * GRAPH_RATIO);
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    CGRect rect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor whiteColor] setFill];
    [path fill];
    
    // draw the background grid
    
    [[UIColor SBTSuperLightGray] setStroke];
    [path setLineWidth:2.0];
    
    // every year for child, every 2 mos for infant
    
    CGFloat spacing = 2 * DAYS_PER_MONTH;
    if ([self maxHRange] > (365.25 * 5.1)) spacing = 365.25;
    CGFloat age = xStart + spacing;
    while (age < [self maxHRange]) {
        
        CGFloat loc = (age / ([self maxHRange] - xStart)) * imageSize.width;
        CGPoint p = CGPointMake(loc, 0.0);
        [path moveToPoint:p];
        [path addLineToPoint:CGPointMake(p.x, imageSize.height)];
        
        [path stroke];
        age += spacing;
    }
    
    // now for each measure there is a different scale of grid line
    //          Metric          Standard
    // Wt       5 kg            10 lb
    // Len      5 cm            2 in
    // Ht       10 cm           4 in
    // BMI      None
    // HC       1 cm            0.5 in
    
    CGFloat stepSize;
    switch (self.parameter) {
        case SBTWeight:
            if ([[SBTUnitsConvertor preferredUnitForKey:MASS_UNIT_KEY] isEqualToString:K_KILOGRAMS]){
                stepSize = [self isChildChart] ? 5.0 : 2.0;
            }else{
                stepSize = [self isChildChart] ? 10.0 : 4.0;
                stepSize /= POUNDS_PER_KILOGRAM;
            }
            break;
        case SBTLength:
            if ([[SBTUnitsConvertor preferredUnitForKey:LENGTH_UNIT_KEY] isEqualToString:K_CENTIMETERS]){
                stepSize = 2.0;
            }else{
                stepSize = 1.0 / INCHES_PER_CENTIMETER;
            }
            break;
        case SBTStature:
            if ([[SBTUnitsConvertor preferredUnitForKey:LENGTH_UNIT_KEY] isEqualToString:K_CENTIMETERS]){
                stepSize = 5.0;
            }else{
                stepSize = 2.0 / INCHES_PER_CENTIMETER;
            }
            break;
        case SBTHeadCircumference:
            if ([[SBTUnitsConvertor preferredUnitForKey:LENGTH_UNIT_KEY] isEqualToString:K_CENTIMETERS]){
                stepSize = 2.0;
            }else{
                stepSize = 1.0 / INCHES_PER_CENTIMETER;
            }
            break;
        case SBTBMI:
            stepSize = -1.0;
        default:
            break;
    }
    if (stepSize > 0.0){
        int wholeSteps = rint(yStart/stepSize);
        CGFloat yBase = wholeSteps * stepSize;
        CGFloat measure = stepSize + yBase;
        while (measure < [self maxVRange]) {
            CGFloat loc = ((measure - yStart) / ([self maxVRange] - yStart)) * imageSize.height;
            loc = imageSize.height - loc;
            CGPoint p = CGPointMake(0.0, loc);
            [path moveToPoint:p];
            [path addLineToPoint:CGPointMake(imageSize.width, loc)];
            
            [path stroke];
            measure += stepSize;
        }
    }

    
    path = nil;
    NSMutableArray *pcts = [NSMutableArray arrayWithArray: @[@(P5), @(P10), @(P25), @(P50), @(P75), @(P90), @(P95)]];
    if (self.parameter == SBTBMI) [pcts insertObject:@(P85) atIndex:5];
    CGFloat measurement;
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
        CGFloat x = 1.0;
        measurement = [self.growthDataSource dataForPercentile:p forAge:xStart parameter:self.parameter andGender:self.baby.gender];
        CGFloat y = ((measurement - yStart) / ([self maxVRange] - yStart)) * imageSize.height;
        y = imageSize.height - y;
        [path moveToPoint:CGPointMake(x, y)];
        while (x < imageSize.width){
            age = xStart  + (x / imageSize.width) * ([self maxHRange] - xStart);
            measurement = [self.growthDataSource dataForPercentile:p forAge:age parameter:self.parameter andGender:self.baby.gender];
            y = ((measurement - yStart) / ([self maxVRange] - yStart)) * imageSize.height;
            y = imageSize.height - y;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Child Chart Segue"]){
        SBTGraphViewController *gvc = segue.destinationViewController;
        NSInteger age = [SBTGrowthDataSource infantAgeMaximum] + 1;  // guarantee that we get the older child data set
        [gvc setGrowthDataSource:[SBTGrowthDataSource growthDataSourceForAge:age]];
        [gvc setBaby:self.baby];
        if (self.parameter == SBTHeadCircumference) [self selectParameter:SBTWeight];
        [gvc setParameter:self.parameter];
        [gvc setChildChart:YES];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self selectParameter:self.parameter];
    
    // this flags these values as needing updates when they are accessed
    _maxVRange = -1.0;
    _maxHRange = -1.0;
    _graphBaseline = -1.0;
}

-(void)dealloc
{
    self.graphView = nil;
}

@end
