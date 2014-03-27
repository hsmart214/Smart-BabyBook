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

#define VERTICAL_RANGE_ADJUSTMENT 1.1f

@interface SBTGraphViewController ()<SBTGraphViewDataSource, UIGestureRecognizerDelegate>
{
    CGFloat currentHRange, currentVRange, maxHRange, maxVRange;
    SBTAgeRange currentAgeRange;
}

@end

@implementation SBTGraphViewController

#pragma mark - Gestures

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (IBAction)pinch:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        CGFloat ageSpread = currentAgeRange.endAge - currentAgeRange.beginAge;
        ageSpread /= sender.scale;
        currentAgeRange.endAge = currentAgeRange.beginAge + ageSpread;
        [sender setScale:1.0];
        [self.view setNeedsDisplay];
    }
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        CGPoint trans = [sender translationInView:self.view];
        //        if (currentAgeRange.beginAge + trans.x >= 0.0 && currentAgeRange.endAge + trans.x <= maxHRange){
            currentAgeRange.beginAge += trans.x;
            currentAgeRange.endAge += trans.x;
        //        }
        [sender setTranslation:CGPointZero inView:self.view];
        [self.view setNeedsDisplay];
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
    return currentVRange;
}

#pragma mark - View Life Cycle

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
    SBTGraphView *view = (SBTGraphView *)self.view;
    [view setDataSource:self];
    [view setMeasure:self.parameter];
    [view setUpOnce];
}

@end
