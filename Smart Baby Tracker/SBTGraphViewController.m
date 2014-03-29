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
#import "UIColor+SBTColors.h"

#define VERTICAL_RANGE_ADJUSTMENT 1.1f
#define GRAPH_RATIO 4.0

@interface SBTGraphViewController ()<SBTGraphViewDataSource, UIGestureRecognizerDelegate>

{
    CGFloat currentHRange, currentVRange, maxHRange, maxVRange;
    CGFloat measureMin, measureMax;
    SBTAgeRange currentAgeRange;
    CGFloat hScale, vScale;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet SBTGraphView *graphView;

@end

@implementation SBTGraphViewController

#pragma mark - Gestures

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) ||
        ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]])){
        return YES;
    }
    return NO;
}

- (void)pinch:(UIPinchGestureRecognizer *)sender {
    // must remember not to confuse measurement values and points.
    // all operations on the geometry of the view must be in points
    // but min and max values for age are kept as DAYS
    // and min and max values of the measure will be in METRIC UNITS
    // the axes will display MONTHS and DISPLAY UNITS
    // this will be tricky to keep straight.
    
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        // adjust the age spread based on the pinch
        CGFloat ageSpread = currentAgeRange.endAge - currentAgeRange.beginAge;
        CGFloat ageSpreadDifference = ageSpread - ageSpread / sender.scale;
        
        // allocate the new spread on either side of the pinch location proportionally
        CGPoint loc = [sender locationInView:self.scrollView];
        CGFloat fracX = loc.x / self.scrollView.bounds.size.width;
        CGFloat diffX = fracX * ageSpreadDifference;
        currentAgeRange.beginAge += diffX;
        currentAgeRange.endAge -= (1 - fracX) * ageSpreadDifference;
        
        // adjust the measure spread based on the pinch scale
        CGFloat measureSpread = measureMax - measureMin;
        CGFloat measureSpreadDifference = measureSpread - measureSpread / sender.scale;
        
        // allocate the new spread on either side of the pinch location proportionally
        CGFloat fracY = loc.y / self.scrollView.bounds.size.height;
        CGFloat diffY = fracY * measureSpreadDifference;
        measureMin += diffY;
        measureMax -= (1 - fracY) *measureSpreadDifference;
        
        // adjust the offset by the proportion of the differences toward the upper left
        // remember this is in points
        CGPoint offset = self.scrollView.contentOffset;
        offset.x += diffX * self.scrollView.bounds.size.width / ageSpread;
        offset.y += diffY * self.scrollView.bounds.size.height / measureSpread;
        [self.scrollView setContentOffset:offset];
        
        [self.scrollView setZoomScale:self.scrollView.zoomScale * sender.scale];
        [sender setScale:1.0];
        [self.graphView setNeedsDisplay];
    }else if (sender.state == UIGestureRecognizerStateEnded){
        NSLog(@"Pinch resulted in bounds - W:%1.1f, H:%1.1f", self.graphView.bounds.size.width, self.graphView.bounds.size.height);
    }
}

- (void)pan:(UIPanGestureRecognizer *)sender {
    // this method affects the content offset in points, which will be directly taken from the translation
    // we will need to update the min and max values for the age and the measure, and shift the axes
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        CGPoint trans = [sender translationInView:self.view];
        //        if (currentAgeRange.beginAge + trans.x >= 0.0 && currentAgeRange.endAge + trans.x <= maxHRange){
            currentAgeRange.beginAge += trans.x;
            currentAgeRange.endAge += trans.x;
        //        }
        CGPoint p = self.scrollView.contentOffset;
        [self.scrollView setContentOffset:CGPointMake(p.x - trans.x, p.y - trans.y)];
        [sender setTranslation:CGPointZero inView:self.view];
        [self.graphView setNeedsDisplay];
    }
}

#pragma mark - SBTGraphViewDataSource

-(SBTGender)gender
{
    return self.baby.gender;
}

-(NSArray *)dataPointsInRange:(SBTAgeRange)ageRange
{
    NSMutableArray *points = [NSMutableArray array];
    NSArray *encounters = [self.baby encountersList];
    for (SBTEncounter *enc in encounters){
        CGFloat age = [self.baby ageInDaysAtEncounter:enc].day;
        if (age <= ageRange.beginAge && age <= ageRange.endAge) {
            [points addObject:enc];
        }
    }
    return points;
}

-(CGFloat)valueForPercentile:(SBTPercentile)percentile
                      forAge:(CGFloat)age
                  forMeasure:(SBTGrowthParameter)parameter
{
    return [self.growthDataSource dataForPercentile:percentile
                                             forAge:age
                                          parameter:parameter
                                          andGender:self.baby.gender];
}

-(SBTAgeRange)horizRange
{
    return currentAgeRange;
}

-(CGFloat)vertRange
{
    return measureMax - measureMin;
}

#pragma mark - UIScrollView Delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.graphView;
}

#pragma mark - View Life Cycle

-(void)viewDidLayoutSubviews
{
    [(UIImageView *)[self.graphView.subviews firstObject] removeFromSuperview];
    [self setUpOnce];
}

-(void)setUpOnce
{
    self.scrollView.delegate = self;
    vScale = [self vertRange] / (self.scrollView.bounds.size.height * GRAPH_RATIO);
    hScale = [self horizRange].endAge / (self.scrollView.bounds.size.width * GRAPH_RATIO);
    
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
        CGFloat measurement = [self valueForPercentile:p forAge:0.0 forMeasure:self.parameter];
        CGFloat y = maxY - measurement / vScale;
        [path moveToPoint:CGPointMake(x, y)];
        while (x < imageSize.width){
            CGFloat age = x * hScale;
            y = maxY - [self valueForPercentile:p forAge:age forMeasure:self.parameter] / vScale;
            [path addLineToPoint:CGPointMake(x, y)];
            x += 1.0;
        }
        [path stroke];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.graphView setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    
    [self.graphView addSubview:[[UIImageView alloc] initWithImage:image]];
    self.scrollView.contentSize = image.size;
    [self.scrollView setZoomScale:1.0/GRAPH_RATIO];
    UIGraphicsEndImageContext();
    [self.graphView setNeedsDisplay];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    currentVRange = [self.growthDataSource dataMeasurementRange97PercentForParameter:self.parameter
                                                                           forGender:self.baby.gender] * VERTICAL_RANGE_ADJUSTMENT;
    currentHRange = [self.growthDataSource dataAgeRange];
    maxHRange = currentHRange;
    maxVRange = currentVRange;
    currentAgeRange.beginAge = 0.0;
    currentAgeRange.endAge = currentHRange;
    measureMin = 0.0;
    measureMax = maxVRange;
    
    [self.graphView setDataSource:self];
    [self.graphView setMeasure:self.parameter];
    
    for (UIGestureRecognizer *recog in self.scrollView.gestureRecognizers){
        if ([recog isKindOfClass:[UIPanGestureRecognizer class]]){
            [self.scrollView removeGestureRecognizer:recog];
            UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
            [pangr setDelegate:self];
            [self.scrollView addGestureRecognizer:pangr];
        }else if ([recog isKindOfClass:[UIPinchGestureRecognizer class]]){
            [self.scrollView removeGestureRecognizer:recog];
            UIPinchGestureRecognizer *pinchr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
            [pinchr setDelegate:self];
            [self.scrollView addGestureRecognizer:pinchr];
        }
    }

}

@end
