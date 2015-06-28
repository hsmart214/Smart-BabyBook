//
//  SBTGraphVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/13/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTGraphVC.h"
#import "SBTBaby.h"
#import "UIColor+SBTColors.h"
#import "SBTUnitsConvertor.h"
#import "SBTEncounter.h"
#import "SBTWHODataSource.h"

#define VERTICAL_RANGE_ADJUSTMENT 1.1f
#define GRAPH_RATIO 1.0

#define HEIGHT_TAB_POSITION 0
#define WEIGHT_TAB_POSITION 1
#define HEAD_CIRC_TAB_POSITION 3
#define BMI_TAB_POSITION 2

#define GROWTH_LINE_WIDTH 4.0f
#define AGE_LABEL_Y_ADJUSTMENT 5.0f


// to this we add in order - CDC/WHO infant/child 2yr/3yr/5yr boy/girl height/weight/headCirc/BMI portrait/landscape
// example "com.mySmartSoftware.graphCache.CDC.infant.2yr.boy.weight.landscape.png"
// TODO: fix this to use the frame instead of landscape/portrait
static NSString * const SBTGraphCacheFilePrefix = @"com.mySmartSoftware.graphCache";

@interface SBTGraphVC ()<UIScrollViewDelegate, UITabBarDelegate>

@property (strong, nonatomic) UIImageView *graphView;
@property (weak, nonatomic) IBOutlet UIImageView *overlayView;
@property (weak, nonatomic) IBOutlet UIImageView *labelsView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) CGFloat maxVRange;
@property (nonatomic) CGFloat maxHRange;
@property (nonatomic) CGFloat graphBaseline;
@property (nonatomic, getter = isChildChart) BOOL childChart;

@property (nonatomic, strong) NSMutableDictionary *measurementAxisLabels;
@property (nonatomic, strong) NSMutableDictionary *ageAxisLabels;
@property (weak, nonatomic) IBOutlet UISegmentedControl *parameterControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *infantChildControl;

@end

@implementation SBTGraphVC

#pragma mark - lazy instantiation

-(NSMutableDictionary *)measurementAxisLabels
{
    if (!_measurementAxisLabels){
        _measurementAxisLabels = [NSMutableDictionary dictionary];
    }
    return _measurementAxisLabels;
}

-(NSMutableDictionary *)ageAxisLabels
{
    if (!_ageAxisLabels){
        _ageAxisLabels = [NSMutableDictionary dictionary];
    }
    return _ageAxisLabels;
}

# pragma mark - moving targets

-(NSURL *)URLForPercentileGraph
{
    BOOL landscape = (self.view.frame.size.width > self.view.frame.size.height);
    BOOL child = [self isChildChart];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *cacheURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *age = child ? @"child" : @"infant";
    double ageCutoff = [defaults doubleForKey:SBTGrowthDataSourceInfantChildCutoffKey];
    NSString *ageBreak = @"2yr";
    if ((ageCutoff + 1) > FIVE_YEARS){
        ageBreak = @"5yr";
    }else if ((ageCutoff + 1) > THREE_YEARS){
        ageBreak = @"3yr";
    }
    NSString *orientation = landscape ? @"landscape" : @"portrait";
    NSString *parameter = nil;
    switch (self.parameter) {
        case SBTBMI:
            parameter = @"BMI";
            break;
        case SBTHeadCircumference:
            parameter = @"headCirc";
            break;
        case SBTLength:
        case SBTStature:
            parameter = @"stature";
            break;
        case SBTWeight:
            parameter = @"weight";
        default:
            break;
    }
    NSNumber *preferredGrowthDataSource = child? [defaults objectForKey:SBTGrowthDataSourceChildDataSourceKey] : [defaults objectForKey:SBTGrowthDataSourceInfantDataSourceKey];
    NSString *source = preferredGrowthDataSource == WHO_INFANT_CHART ? @"WHO" : @"CDC";
    NSString *gender = self.baby.gender == SBTMale ? @"boy" :@"girl";
    NSString *filename = [NSString stringWithFormat:@"%@.%@.%@.%@.%@.%@.%@.png", SBTGraphCacheFilePrefix, source, age, ageBreak, gender, parameter, orientation];
    return [cacheURL URLByAppendingPathComponent:filename];
}

-(CGFloat)maxVRange
{
    if (_maxVRange < 0.0){
        SBTGrowthDataSource *source = self.growthDataSource;
        if (self.parameter == SBTBMI && ![self isChildChart]) source = [SBTWHODataSource sharedDataSource];
        _maxVRange = [source dataMeasurementRange97PercentForParameter:self.parameter
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
        _graphBaseline = [self.growthDataSource baselineForParameter:self.parameter childChart:[self isChildChart]];
    }
    return _graphBaseline;
}

-(CGFloat)currentVMeasurePerPoint
{
    CGFloat ratio = ([self maxVRange] -[self graphBaseline]) / self.graphView.bounds.size.height;
    return ratio;
}

-(CGFloat)currentHMeasurePerPoint
{
    double range = [self isChildChart] ? [self maxHRange] - [SBTGrowthDataSource infantAgeMaximum] : [self maxHRange];
    CGFloat ratio = range / self.graphView.bounds.size.width;
    return ratio;
}

-(CGRect)currentMeasureVisibleExtents
{
    // The tricky part is that this is a rect in the screen oriented coordinates - x,y == TOP LEFT!!!
    // So... the y represents the max measure.  The min is given by (maxVRange - y - origin.y)
    // ptRect is in points, mRect is in metric measurement units for y, days for x
    double graphXStart = [self isChildChart] ? [SBTGrowthDataSource infantAgeMaximum] : 0;
    CGRect ptRect = [self.graphView convertRect:self.overlayView.bounds fromView:self.overlayView];
    CGFloat hRatio = [self currentHMeasurePerPoint];
    CGFloat vRatio = [self currentVMeasurePerPoint];
    CGRect mRect = CGRectMake(ptRect.origin.x * hRatio + graphXStart, ptRect.origin.y * vRatio, ptRect.size.width * hRatio, ptRect.size.height * vRatio);
    return mRect;
}

-(CGFloat)xPositionForAgeInDays:(double)days{
    double graphXStart = [self isChildChart] ? [SBTGrowthDataSource infantAgeMaximum] : 0;
    CGFloat hRatio = [self currentHMeasurePerPoint];
    return (days - graphXStart) / hRatio;
}

-(void)adjustAxesForContentOffset:(CGPoint)offset andScale:(CGFloat)scale
{
    // axes will be drawn for display units based on user preferences
    // draw these into an image context, then set the image as the UIImage of the overlayView
    UIGraphicsBeginImageContextWithOptions(self.labelsView.bounds.size, NO, 0.0);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path setLineWidth:1.0];
    [[UIColor SBTSuperLightGray] setStroke];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    NSDictionary *attrs = @{NSFontAttributeName: font};
    
    // use the [self currentMeasureVisibleExtents] to decide where to put labels
    //
    CGRect visibleMeasures = [self currentMeasureVisibleExtents];
    double maxAgeShown = visibleMeasures.origin.x + visibleMeasures.size.width;
    double maxMeasureShown = [self maxVRange] - visibleMeasures.origin.y;
    double minMeasureShown = maxMeasureShown - visibleMeasures.size.height;
    
    // add the percentile marks to the ends of the percentile lines (left edge)
    
    NSArray *percentiles = @[@(P5),@(P10),@(P25),@(P50),@(P75),@(P90),@(P95),];
    NSArray *pctStrings = @[@"5",@"10",@"25",@"50",@"75",@"90",@"95",];
    NSArray *pctMeasures = [self.growthDataSource measurementsAtPercentiles:percentiles
                                                                     forAge:maxAgeShown
                                                               forParameter:self.parameter
                                                                  forGender:self.baby.gender];
    
    for (int i = 0; i < [percentiles count]; i++){
        double measure = [pctMeasures[i] doubleValue];
        if (measure > minMeasureShown && measure < maxMeasureShown){
            NSAttributedString *label = [[NSAttributedString alloc] initWithString:pctStrings[i] attributes:attrs];
            CGSize box = label.size;
            // how far down the side of the image are we?
            double fraction = 1 - ((measure - minMeasureShown) / (maxMeasureShown - minMeasureShown));
            CGFloat yIntercept = self.overlayView.bounds.size.height * fraction;
            CGPoint boxOrigin = CGPointMake(self.overlayView.bounds.size.width - box.width, yIntercept - box.height);
            [label drawAtPoint:boxOrigin];
        }
    }
    
    // create a switchable flag for the infant cutoff age
    double m = [SBTGrowthDataSource infantAgeMaximum];
    NSInteger infantCutoff = 0;
    if (m < 2*366){// 2yrs
        infantCutoff = 2;
    }else if (m < 3*366){// 3 yrs
        infantCutoff = 3;
    }else{// 5 yrs
        infantCutoff = 5;
    }
    // TODO: add the ticks and labels for the data (y axis) remember the y axis is inverted
    
    // add the ticks and labels for the age (x axis)
    NSArray *ageLabels;
    NSInteger divisionCount = 0;
    CGFloat divisionSize = 0.0;
    CGFloat firstLabelAge = 0.0;
    if (self.isChildChart){
        // how many years on chart?
        switch (infantCutoff) {
            case 2:
                divisionCount = 8;
                divisionSize = 2 * 365.25;
                firstLabelAge = 4 * 365.25;
                ageLabels = @[@"4y", @"6y", @"8y", @"10y", @"12y", @"14y", @"16y", @"18y"];
                break;
            case 3:
                divisionCount = 8;
                divisionSize = 2 * 365.25;
                firstLabelAge = 4 * 365.25;
                ageLabels = @[@"4y", @"6y", @"8y", @"10y", @"12y", @"14y", @"16y", @"18y"];
                break;
            case 5:
                divisionCount = 7;
                divisionSize = 2 * 365.25;
                firstLabelAge = 6 * 365.25;
                ageLabels = @[@"6y", @"8y", @"10y", @"12y", @"14y", @"16y", @"18y"];
            default:
                break;
        }
    }else{
        // we have an infant chart
        switch (infantCutoff) {
            case 2:
                ageLabels = @[@"2m", @"4m", @"6m", @"8m", @"10m", @"12m", @"14m", @"16m", @"18m", @"20m", @"22m"];
                divisionSize = 2 * DAYS_PER_MONTH;
                firstLabelAge = 2 * DAYS_PER_MONTH;
                break;
            case 3:
                ageLabels = @[@"3m", @"6m", @"9m", @"12m", @"15m", @"18m", @"21m", @"24m", @"27m", @"30m", @"33m"];
                divisionSize = 3 * DAYS_PER_MONTH;
                firstLabelAge = 3 * DAYS_PER_MONTH;
                break;
            case 5:
                ageLabels = @[@"5m", @"10m", @"15m", @"20m", @"25m", @"30m", @"35m", @"40m", @"45m", @"50m", @"55m"];
                divisionSize = 5 * DAYS_PER_MONTH;
                firstLabelAge = 5 * DAYS_PER_MONTH;
            default:
                break;
        }
        divisionCount = 11;
    
    }
    for (int i = 0; i < divisionCount; i++){
        CGFloat xPos = [self xPositionForAgeInDays:firstLabelAge + i * divisionSize];
        NSAttributedString *label = [[NSAttributedString alloc] initWithString:ageLabels[i] attributes:attrs];
        CGSize box = label.size;
        // how far down the side of the image are we?
        CGFloat yPos = self.overlayView.bounds.size.height - AGE_LABEL_Y_ADJUSTMENT;
        CGPoint boxOrigin = CGPointMake(xPos - box.width/2, yPos - box.height);
        [label drawAtPoint:boxOrigin];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.labelsView.image = image;
    UIGraphicsEndImageContext();
}

#pragma mark - Target/Action

- (IBAction)infantChildGraphChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: //infant
            self.childChart = NO;
            [self.parameterControl setTitle:@"Head" forSegmentAtIndex:2];
            break;
        case 1: //child/adolescent
            self.childChart = YES;
            [self.parameterControl setTitle:@"BMI" forSegmentAtIndex:2];
            break;
        default:
            break;
    }
    // since we are switching age range, we cannot keep either BMI or HeadCirc, so force back to weight
    if (self.parameterControl.selectedSegmentIndex ==2){
        [self.parameterControl setSelectedSegmentIndex:0];
        self.parameter = SBTWeight;
    }
    [self resetDisplay];
}

- (IBAction)parameterChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.parameter = SBTWeight;
            break;
        case 1:
            self.parameter = SBTStature;
            break;
        case 2:
            if (self.isChildChart){
                self.parameter = SBTBMI;
            }else{
                self.parameter = SBTHeadCircumference;
            }
            break;
        default:
            break;
    }
    [self resetDisplay];
}

#pragma mark - View Life Cycle

-(void)drawPercentiles
{
    UIImage *image;
    SBTGrowthDataSource *oldDataSource = self.growthDataSource;
    // if the specific chart already exists, grab it from the cache directory, otherwise draw from scratch
    
    NSURL *url = [self URLForPercentileGraph];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        
        NSLog(@"Read image from %@", [url path]);
    }else{
        NSLog(@"Drawing image de novo.");
        // if it is an infant BMI chart, force the data source to WHO data, then set it back at the end
        if (![self isChildChart] && self.parameter == SBTBMI){
            self.growthDataSource = [SBTWHODataSource sharedDataSource];
        }
        // if it is a child (not infant) chart, start the graph at the age break point
        CGFloat xStart = 0.0;
        if ([self isChildChart]) xStart = [SBTGrowthDataSource infantAgeMaximum] + 1.0;
        
        // set the baseline of the chart based on which graph is being displayed
        // ask the growthDataSource
        CGFloat yStart = [self.growthDataSource baselineForParameter:self.parameter childChart:[self isChildChart]];
        
        // create an offscreen image and draw a 4x representation of the growth curve percentiles
        CGSize imageSize = CGSizeMake(self.view.bounds.size.width * GRAPH_RATIO, self.view.bounds.size.height * GRAPH_RATIO);
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
        CGRect rect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [[UIColor whiteColor] setFill];
        [path fill];
        
        // draw the background grid
        
        [[UIColor SBTSuperLightGray] setStroke];
        [path setLineWidth:2.0];
        
        // every year for child, 12 divisions for infant
        
        CGFloat spacing = 2 * DAYS_PER_MONTH;
        double infantMax = [SBTGrowthDataSource infantAgeMaximum];
        if (infantMax > 2*366){
            spacing = 3 * DAYS_PER_MONTH;
        }
        if (infantMax > 4 * 366){
            spacing = 5 * DAYS_PER_MONTH;
        }
        if ([self maxHRange] > (365.25 * 5.1)) spacing = 365.25;
        CGFloat age = xStart + spacing;
        while (age < [self maxHRange]) {
            
            CGFloat loc = ((age - xStart) / ([self maxHRange] - xStart)) * imageSize.width;
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
            BOOL limitedData = self.parameter == SBTWeight && [self isChildChart] && [self.growthDataSource hasLimitedWeightData];
            while (x < imageSize.width){
                age = xStart  + (x / imageSize.width) * ([self maxHRange] - xStart);
                if (limitedData && self.parameter == SBTWeight && age > WHO_CHILD_WEIGHT_MAX_AGE) break;
                measurement = [self.growthDataSource dataForPercentile:p forAge:age parameter:self.parameter andGender:self.baby.gender];
                y = ((measurement - yStart) / ([self maxVRange] - yStart)) * imageSize.height;
                y = imageSize.height - y;
                [path addLineToPoint:CGPointMake(x, y)];
                x += 1.0;
            }
            [path stroke];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile:[url path] atomically:YES];
        });
        // done with drawing from scratch
    }
    
    self.graphView = [[UIImageView alloc] initWithImage:image];
    for (UIView *view in self.contentView.subviews){
        [view removeFromSuperview];
    }
    [self.contentView addSubview:self.graphView];
    
    // if we had set the growth data source to WHO before, set it back now
    self.growthDataSource = oldDataSource;
} // drawPercentiles

-(void)drawDataForParameter:(SBTGrowthParameter)param
{
    NSArray *encounters = [self.baby encountersList];
    double first = [self isChildChart] ? self.growthDataSource.infantAgeMaximum + 1.0 : 0.0;
    double last = [self isChildChart] ? [self.growthDataSource dataAgeRangeForAge:([self.growthDataSource infantAgeMaximum] + 1.0)] : [self.growthDataSource infantAgeMaximum];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K BETWEEN %@", @"ageInDays", @[@(first), @(last)]];
    NSArray *encountersInRange = [encounters filteredArrayUsingPredicate:pred];
    UIGraphicsBeginImageContextWithOptions(self.overlayView.bounds.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.overlayView.bounds];
    [path addClip];
    [path removeAllPoints];
    [path setLineWidth:GROWTH_LINE_WIDTH];
    [path setLineJoinStyle:kCGLineJoinRound];
    if ([self.baby gender] == SBTMale){
        [[UIColor SBTBoyLineColor] setStroke];
    }else{
        [[UIColor SBTGirlLineColor] setStroke];
    }
    
    // now I have discovered that I need to spin through any points at the beginning of the range that have zero-value data
    NSInteger firstEncounterWithData = 0;
    for (NSInteger i = 0; i < [encountersInRange count]; i++){
        firstEncounterWithData = i;
        if ([encountersInRange[i] dataForParameter:param] > 0.0)  break;
    }
    if ([encountersInRange count] == 0){
        UIGraphicsEndImageContext();
        [self.overlayView setImage:nil];
        return;
    }
    CGFloat x = [(SBTEncounter *)encountersInRange[firstEncounterWithData] ageInDays];
    CGFloat y = [(SBTEncounter *)encountersInRange[firstEncounterWithData] dataForParameter:param];
    // if it is a child (not infant) chart, start the graph at the age break point
    CGFloat xStart = [self isChildChart] ? [SBTGrowthDataSource infantAgeMaximum] + 1.0 : 0.0;
    // set the baseline of the chart based on which graph is being displayed
    // ask the growthDataSource
    CGFloat yStart = [self.growthDataSource baselineForParameter:param childChart:[self isChildChart]];
    // x and y are now in measurement units
    CGFloat locx = ((x - xStart) / ([self maxHRange] - xStart)) * self.graphView.bounds.size.width;
    CGFloat locy = ((y - yStart) / ([self maxVRange] - yStart)) * self.graphView.bounds.size.height;
    locy = self.graphView.bounds.size.height - locy;
    // now that we have the ersatz location of the point in the graphView's coordinate system
    // we need to draw it in the overlayView's coordinate system
    CGPoint point = [self.overlayView convertPoint:CGPointMake(locx, locy) fromView:self.graphView];
    [path moveToPoint:point];
    for (NSInteger i = firstEncounterWithData; i < [encountersInRange count]; i++){
        SBTEncounter *enc = encountersInRange[i];
        x = [enc ageInDays];
        y = [enc dataForParameter:param];
        if (y < 0.001) continue;
        locx = ((x - xStart) / ([self maxHRange] - xStart)) * self.graphView.bounds.size.width;
        locy = ((y - yStart) / ([self maxVRange] - yStart)) * self.graphView.bounds.size.height;
        locy = self.graphView.bounds.size.height - locy;
        point = [self.overlayView convertPoint:CGPointMake(locx, locy) fromView:self.graphView];
        [path addLineToPoint:point];
    }
    if (firstEncounterWithData == [encountersInRange count]-1){
        // there is only one point so make a small circle there
        [path addArcWithCenter:point radius:GROWTH_LINE_WIDTH/2 startAngle:0.0 endAngle:2*M_PI clockwise:YES];
    }
    [path stroke];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.overlayView setImage:img];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Child Chart Segue"]){
        SBTGraphVC *gvc = segue.destinationViewController;
        NSInteger age = [SBTGrowthDataSource infantAgeMaximum] + 1;  // guarantee that we get the older child data set
        [gvc setGrowthDataSource:[SBTGrowthDataSource growthDataSourceForAge:age]];
        [gvc setBaby:self.baby];
        [gvc setParameter:self.parameter];
        [gvc setChildChart:YES];
    }
}

- (void) resetDisplay{
    // this flags these values as needing updates when they are accessed
    _maxVRange = -1.0;
    _maxHRange = -1.0;
    _graphBaseline = -1.0;
    [self drawPercentiles];
    [self drawDataForParameter:self.parameter];
    [self adjustAxesForContentOffset:CGPointZero andScale:1.0];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self resetDisplay];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // rename the segments of the age switcher control to match the user preferences
    double ageSwitch = [self.growthDataSource infantAgeMaximum];
    if (fabs(ageSwitch - TWO_YEARS) > 1.0){ // must not be the default two year break point.  Which one is it?
        if (fabs(ageSwitch - THREE_YEARS) < 1.0){ //it is three years
            [self.infantChildControl setTitle:@"0-36 mos" forSegmentAtIndex:0];
            [self.infantChildControl setTitle:@"3-20 yrs" forSegmentAtIndex:1];
        }else{// it is five years
            [self.infantChildControl setTitle:@"0-60 mos" forSegmentAtIndex:0];
            [self.infantChildControl setTitle:@"5-20 yrs" forSegmentAtIndex:1];
        }
    }
    [[self growthDataSource] infantAgeMaximum];
}

-(void)dealloc
{
    self.graphView = nil;
    self.measurementAxisLabels = nil;
    self.ageAxisLabels = nil;
}

@end