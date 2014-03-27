//
//  SBTWHODataSource.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/1/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTWHODataSource.h"
#import "SBTDataPoint.h"

#define WHO_MAX_AGE 1856.0f

#define WHO_BOY_WEIGHT_FILENAME @"whoweightboys"
#define WHO_GIRL_WEIGHT_FILENAME @"whoweightgirls"
#define WHO_BOY_LENGTH_FILENAME @"wholengthboys"
#define WHO_GIRL_LENGTH_FILENAME @"wholengthgirls"
#define WHO_BOY_HC_FILENAME @"whohcboys"
#define WHO_GIRL_HC_FILENAME @"whohcgirls"
#define WHO_BOY_BMI_FILENAME @"whobmiboys"
#define WHO_GIRL_BMI_FILENAME @"whobmigirls"


@interface SBTWHODataSource();

@property (nonatomic, strong) NSArray *boyWeightData;
@property (nonatomic, strong) NSArray *boyLengthData;
@property (nonatomic, strong) NSArray *boyHCData;
@property (nonatomic, strong) NSArray *boyBMIData;

@property (nonatomic, strong) NSArray *girlWeightData;
@property (nonatomic, strong) NSArray *girlLengthData;
@property (nonatomic, strong) NSArray *girlHCData;
@property (nonatomic, strong) NSArray *girlBMIData;

@end

@implementation SBTWHODataSource

-(NSArray *)boyWeightData
{
    if (!_boyWeightData){
        _boyWeightData = [self filledDataArrayFromFile:WHO_BOY_WEIGHT_FILENAME];
    }
    return _boyWeightData;
}

-(NSArray *)boyLengthData
{
    if (!_boyLengthData){
        _boyLengthData = [self filledDataArrayFromFile:WHO_BOY_LENGTH_FILENAME];
    }
    return _boyLengthData;
}

-(NSArray *)boyHCData
{
    if (!_boyHCData){
        _boyHCData = [self filledDataArrayFromFile:WHO_BOY_HC_FILENAME];
    }
    return _boyHCData;
}

-(NSArray *)boyBMIData
{
    if (!_boyBMIData){
        _boyBMIData = [self filledDataArrayFromFile:WHO_BOY_BMI_FILENAME];
    }
    return _boyBMIData;
}

-(NSArray *)girlWeightData
{
    if (!_girlWeightData){
        _girlWeightData = [self filledDataArrayFromFile:WHO_GIRL_WEIGHT_FILENAME];
    }
    return _girlWeightData;
}

-(NSArray *)girlLengthData
{
    if (!_girlLengthData){
        _girlLengthData = [self filledDataArrayFromFile:WHO_GIRL_LENGTH_FILENAME];
    }
    return _girlLengthData;
}

-(NSArray *)girlHCData
{
    if (!_girlHCData){
        _girlHCData = [self filledDataArrayFromFile:WHO_GIRL_HC_FILENAME];
    }
    return _girlHCData;
}

-(NSArray *)girlBMIData
{
    if (!_girlBMIData){
        _girlBMIData = [self filledDataArrayFromFile:WHO_GIRL_BMI_FILENAME];
    }
    return _girlBMIData;
}

-(double)dataAgeRange
{
    return WHO_MAX_AGE;
}

-(double)dataForPercentile:(SBTPercentile)percentile
                    forAge:(double)age
                 parameter:(SBTGrowthParameter)parameter
                 andGender:(SBTGender)gender
{
    NSArray *dp;
    switch (gender) {
        case SBTFemale:
            switch (parameter) {
                case SBTLength:
                    dp = self.girlLengthData;
                    break;
                case SBTStature:
                    dp = self.girlLengthData;
                    break;
                case SBTWeight:
                    dp = self.girlWeightData;
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
                    dp = self.boyLengthData;
                    break;
                case SBTStature:
                    dp = self.boyLengthData;
                    break;
                case SBTWeight:
                    dp = self.boyWeightData;
                    break;
                case SBTHeadCircumference:
                    dp = self.boyHCData;
                    break;
                case SBTBMI:
                    dp = self.boyBMIData;
            }
    }
    SBTDataPoint *pt1, *pt2;
    int pivot = [dp count] / 2;
    int delta = pivot / 2;
    pt1 = dp[pivot];
    pt2 = pt1;
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
-(double)dataMeasurementRange97PercentForParameter:(SBTGrowthParameter)parameter forGender:(SBTGender)gender
{
    SBTDataPoint *dp;
    switch (gender) {
        case SBTFemale:
            switch (parameter) {
                case SBTLength:
                case SBTStature:
                    dp = [self.girlLengthData lastObject];
                    break;
                case SBTWeight:
                    dp = [self.girlWeightData lastObject];
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
                    dp = [self.boyLengthData lastObject];
                    break;
                case SBTWeight:
                    dp = [self.boyWeightData lastObject];
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
    //    return dp->mean + 3*dp->stdev;
}

+(instancetype)sharedDataSource
{
    static SBTWHODataSource *source = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        source = [[SBTWHODataSource alloc] init];
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
    //TODO: gracefully recover if someone asks for a WHO data value > 61 months age
    if (days > WHO_MAX_AGE) return 0.0;
    NSArray *data = nil;
    switch (gender) {
        case SBTFemale:
            switch (parameter) {
                case SBTWeight:
                    data = self.girlWeightData;
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
                    data = self.girlLengthData;
                    break;
                default:
                    break;
            };
            break;
        case SBTMale:
            switch (parameter) {
                case SBTWeight:
                    data = self.boyWeightData;
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
                    data = self.boyLengthData;
                    break;
                default:
                    break;
            };
            break;
        default:
            break;
    }
    // now find the data point in the array closest to the age requested. All WHO data is in daily increments
    // so no interpolation will be necessary (not so with CDC data)
    // the array is ordered by age in days, so we should be able to index to the correct day directly, no searching
    SBTDataPoint *dataPoint = data[days];
    double percentile = [dataPoint percentileForMeasurement:measurement];
    return percentile;
}

@end
