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
    double percentile = [dataPoint percentileForMeasurment:measurement];
    return percentile;
}

@end
