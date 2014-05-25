//
//  SBTCDCDataSource.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/2/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTCDCDataSource.h"

#import "SBTDataPoint.h"

#define CDC_MAX_AGE 7305.0f
#define CDC_INFANT_MAX_AGE 1097.0
// these files define standards for 0-36 months
// length is a supine measurement
#define CDC_BOY_INFANT_WEIGHT_FILENAME @"cdcweightinfantboys"
#define CDC_GIRL_INFANT_WEIGHT_FILENAME @"cdcweightinfantgirls"
#define CDC_BOY_LENGTH_FILENAME @"cdclengthboys"
#define CDC_GIRL_LENGTH_FILENAME @"cdclengthgirls"
#define CDC_BOY_HC_FILENAME @"cdchcboys"
#define CDC_GIRL_HC_FILENAME @"cdchcgirls"
// these files define standards for 2-20 years
// stature is a standing measurement
#define CDC_BOY_WEIGHT_FILENAME @"cdcweightboys"
#define CDC_GIRL_WEIGHT_FILENAME @"cdcweightgirls"
#define CDC_BOY_STATURE_FILENAME @"cdcstatureboys"
#define CDC_GIRL_STATURE_FILENAME @"cdcstaturegirls"
#define CDC_BOY_BMI_FILENAME @"cdcbmiboys"
#define CDC_GIRL_BMI_FILENAME @"cdcbmigirls"
// there is no CDC data for infant BMI so we use WHO data for this
// no, this turned out to be awkward because of the difference in how the data is sliced
#define WHO_BOY_INFANT_BMI_FILENAME @"whobmiinfantboys"
#define WHO_GIRL_INFANT_BMI_FILENAME @"whobmiinfantgirls"


@interface SBTCDCDataSource();

@property (nonatomic, strong) NSArray *infantBoyWeightData;
@property (nonatomic, strong) NSArray *boyWeightData;
@property (nonatomic, strong) NSArray *boyLengthData;
@property (nonatomic, strong) NSArray *boyStatureData;
@property (nonatomic, strong) NSArray *boyHCData;
@property (nonatomic, strong) NSArray *boyBMIData;
@property (nonatomic, strong) NSArray *infantBoyBMIData;

@property (nonatomic, strong) NSArray *infantGirlWeightData;
@property (nonatomic, strong) NSArray *girlWeightData;
@property (nonatomic, strong) NSArray *girlLengthData;
@property (nonatomic, strong) NSArray *girlStatureData;
@property (nonatomic, strong) NSArray *girlHCData;
@property (nonatomic, strong) NSArray *girlBMIData;
@property (nonatomic, strong) NSArray *infantGirlBMIData;

@end

@implementation SBTCDCDataSource

-(NSArray *)infantBoyWeightData
{
    if (!_infantBoyWeightData){
        _infantBoyWeightData = [self filledDataArrayFromFile:CDC_BOY_INFANT_WEIGHT_FILENAME];
    }
    return _infantBoyWeightData;
}

-(NSArray *)infantBoyBMIData
{
    if (!_infantBoyBMIData){
        _infantBoyBMIData = [self filledDataArrayFromFile:WHO_BOY_INFANT_BMI_FILENAME];
    }
    return _infantBoyBMIData;
}

-(NSArray *)boyWeightData
{
    if (!_boyWeightData){
        _boyWeightData = [self filledDataArrayFromFile:CDC_BOY_WEIGHT_FILENAME];
    }
    return _boyWeightData;
}

-(NSArray *)boyStatureData
{
    if (!_boyStatureData){
        _boyStatureData = [self filledDataArrayFromFile:CDC_BOY_STATURE_FILENAME];
    }
    return _boyStatureData;
}

-(NSArray *)boyLengthData
{
    if (!_boyLengthData){
        _boyLengthData = [self filledDataArrayFromFile:CDC_BOY_LENGTH_FILENAME];
    }
    return _boyLengthData;
}

-(NSArray *)boyHCData
{
    if (!_boyHCData){
        _boyHCData = [self filledDataArrayFromFile:CDC_BOY_HC_FILENAME];
    }
    return _boyHCData;
}

-(NSArray *)boyBMIData
{
    if (!_boyBMIData){
        _boyBMIData = [self filledDataArrayFromFile:CDC_BOY_BMI_FILENAME];
    }
    return _boyBMIData;
}

-(NSArray *)infantGirlWeightData{
    if (!_infantGirlWeightData){
        _infantGirlWeightData = [self filledDataArrayFromFile:CDC_GIRL_INFANT_WEIGHT_FILENAME];
    }
    return _infantGirlWeightData;
}

-(NSArray *)infantGirlBMIData
{
    if (!_infantGirlBMIData){
        _infantGirlBMIData = [self filledDataArrayFromFile:WHO_GIRL_INFANT_BMI_FILENAME];
    }
    return _infantGirlBMIData;
}

-(NSArray *)girlWeightData
{
    if (!_girlWeightData){
        _girlWeightData = [self filledDataArrayFromFile:CDC_GIRL_WEIGHT_FILENAME];
    }
    return _girlWeightData;
}

-(NSArray *)girlStatureData
{
    if (!_girlStatureData){
        _girlStatureData = [self filledDataArrayFromFile:CDC_GIRL_STATURE_FILENAME];
    }
    return _girlStatureData;
}

-(NSArray *)girlLengthData
{
    if (!_girlLengthData){
        _girlLengthData = [self filledDataArrayFromFile:CDC_GIRL_LENGTH_FILENAME];
    }
    return _girlLengthData;
}

-(NSArray *)girlHCData
{
    if (!_girlHCData){
        _girlHCData = [self filledDataArrayFromFile:CDC_GIRL_HC_FILENAME];
    }
    return _girlHCData;
}

-(NSArray *)girlBMIData
{
    if (!_girlBMIData){
        _girlBMIData = [self filledDataArrayFromFile:CDC_GIRL_BMI_FILENAME];
    }
    return _girlBMIData;
}

-(double)dataAgeRangeForAge:(double)age
{
    double range;
    if (age > [self infantAgeMaximum]){
        range = CDC_MAX_AGE;
    }else{
        range = [self infantAgeMaximum];
    }
    return range;
}

-(double)dataForPercentile:(SBTPercentile)percentile
                    forAge:(double)age
                 parameter:(SBTGrowthParameter)parameter
                 andGender:(SBTGender)gender
{
    BOOL child = age > self.infantAgeMaximum;
    NSArray *dp;
    switch (gender) {
        case SBTFemale:
            switch (parameter) {
                case SBTLength:
                    dp = child ? self.girlStatureData : self.girlLengthData;
                    break;
                case SBTStature:
                    dp = child ? self.girlStatureData : self.girlLengthData;
                    break;
                case SBTWeight:
                    dp = child ? self.girlWeightData : self.infantGirlWeightData;
                    break;
                case SBTHeadCircumference:
                    dp = self.girlHCData;
                    break;
                case SBTBMI:
                    dp = self.girlBMIData;
            }
            break;
        case SBTMale:
            switch (parameter) {
                case SBTLength:
                    dp = child ? self.boyStatureData : self.boyLengthData;
                    break;
                case SBTStature:
                    dp = child ? self.boyStatureData : self.boyLengthData;
                    break;
                case SBTWeight:
                    dp = child ? self.boyWeightData : self.infantBoyWeightData;
                    break;
                case SBTHeadCircumference:
                    dp = self.boyHCData;
                    break;
                case SBTBMI:
                    dp = self.boyBMIData;
            }
    }
    SBTDataPoint *pt1, *pt2;
    NSInteger pivot = [dp count] / 2;
    NSInteger delta = pivot / 2;
    pt1 = dp[pivot];
    while (delta >= 1) {
        if ([pt1 ageInDays] < age) {
            pivot += delta;
        }else{
            pivot -= delta;
        }
        delta /= 2;
        pt1 = dp[pivot];
    }
    if ([pt1 ageInDays] < age){
        pt2 = (pivot < [dp count] - 1) ? dp[pivot +1] : pt1;
    }else{
        pt2 = pt1;
        pt1 = pivot > 0 ? dp[pivot - 1] : pt2;
    }
    if (pt1 == pt2) return [pt1 dataForPercentile:percentile];
    // figure out how far between the two points we are and get a proportional delta
    double d = [pt1 ageInDays];
    double diff = [pt2 ageInDays] - d;
    double frac = (age - d) / diff;
    d = [pt1 dataForPercentile:percentile];
    diff = [pt2 dataForPercentile:percentile] - d;
    return d + frac * diff;
}

-(double)dataMeasurementRange97PercentForParameter:(SBTGrowthParameter)parameter
                                         forGender:(SBTGender)gender
                                          forChild:(BOOL)child
{
    NSInteger infantMaxIndex = rint(self.infantAgeMaximum / DAYS_PER_MONTH) - 1;
    SBTDataPoint *dp;
    switch (gender) {
        case SBTFemale:
            switch (parameter) {
                case SBTLength:
                case SBTStature:
                    dp = child ? [self.girlStatureData lastObject] : self.girlLengthData[infantMaxIndex];
                    break;
                case SBTWeight:
                    dp = child ? [self.girlWeightData lastObject] : self.infantGirlWeightData[infantMaxIndex];
                    break;
                case SBTHeadCircumference:
                    dp = [self.girlHCData lastObject];
                    break;
                case SBTBMI:
                    dp = [self.girlBMIData lastObject];
            }
            break;
        case SBTMale:
            switch (parameter) {
                case SBTLength:
                case SBTStature:
                    dp = child ? [self.boyStatureData lastObject] : self.boyLengthData[infantMaxIndex];
                    break;
                case SBTWeight:
                    dp = child ? [self.boyWeightData lastObject] : self.infantBoyWeightData[infantMaxIndex];
                    break;
                case SBTHeadCircumference:
                    dp = [self.boyHCData lastObject];
                    break;
                case SBTBMI:
                    dp = [self.boyBMIData lastObject];
            }
    }
    NSInteger index97 = [dp translatePercentileToIndex:P97];
    return [dp->percentileData[index97] doubleValue];

    //  return dp->mean + 3*dp->stdev; // This is overly simplistic, but not critical
}

+(instancetype)sharedDataSource
{
    static SBTCDCDataSource *source = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        source = [[SBTCDCDataSource alloc] init];
    });
    return source;
}

-(instancetype)init
{
    if (self = [super init]){
        return self;
    }
    return nil;
}

-(double)percentileOfMeasurement:(double)measurement
                          forAge:(NSInteger)days
                       parameter:(SBTGrowthParameter)parameter
                       andGender:(SBTGender)gender
{
    //TODO: gracefully recover if someone asks for a CDC data value > 20 years age
    if (days > CDC_MAX_AGE) return 0.0;
    NSArray *data = nil;
    switch (gender) {
        case SBTFemale:
            switch (parameter) {
                case SBTWeight:
                    if (days <= AAP_CUTOFF){
                        data = self.infantGirlWeightData;
                    }else{
                        data = self.girlWeightData;
                    }
                    break;
                case SBTLength:
                    data = self.girlLengthData;
                    break;
                case SBTHeadCircumference:
                    data = self.girlHCData;
                    break;
                case SBTBMI:
                    data = self.girlBMIData;
                    break;
                case SBTStature:
                    data = self.girlStatureData;
                    break;
                default:
                    break;
            };
            break;
        case SBTMale:
            switch (parameter) {
                case SBTWeight:
                    if (days <= AAP_CUTOFF){
                        data = self.infantBoyWeightData;
                    }else{
                        data = self.boyWeightData;
                    }
                    break;
                case SBTLength:
                    data = self.boyLengthData;
                    break;
                case SBTHeadCircumference:
                    data = self.boyHCData;
                    break;
                case SBTBMI:
                    data = self.boyBMIData;
                    break;
                case SBTStature:
                    data = self.boyStatureData;
                    break;
                default:
                    break;
            };
            break;
        default:
            break;
    }
    // now find the data point in the array closest to the age requested. CDC data is given at half=months.
    // interpolation to the exact day must be done.  Linear interpolation should be close enough.
    
    // first find  the two dataPoints bracketing the exact age in days.
    
    SBTDataPoint *firstDataPoint, *secondDataPoint, *dataPoint;
    firstDataPoint = [data firstObject];
    secondDataPoint = [data firstObject];
    
    dataPoint = [[SBTDataPoint alloc] init];
    
    for (SBTDataPoint *dp in data){
        firstDataPoint = secondDataPoint;
        secondDataPoint = dp;
        if ([secondDataPoint ageInDays] > days) break;
    }
    // find out how far along the gap we are with our age 'days'
    
    if ([secondDataPoint ageInDays] > [firstDataPoint ageInDays]){  // guard against DIV_ZERO
        double mult = ((days - [firstDataPoint ageInDays]) / ([secondDataPoint ageInDays] - [firstDataPoint ageInDays]));
        
        dataPoint->mean = firstDataPoint->mean + mult * (secondDataPoint->mean - firstDataPoint->mean);
        dataPoint->skew = firstDataPoint->skew + mult * (secondDataPoint->skew - firstDataPoint->skew);
        dataPoint->stdev = firstDataPoint->stdev + mult * (secondDataPoint->stdev - firstDataPoint->stdev);
    }else{ // baby is a newborn
        dataPoint = firstDataPoint;
    }
    double percentile = [dataPoint percentileForMeasurement:measurement];
    return percentile;
}


@end
