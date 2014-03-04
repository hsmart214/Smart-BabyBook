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
#define AAP_CUTOFF 731.0
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


@interface SBTCDCDataSource();

@property (nonatomic, strong) NSArray *infantBoyWeightData;
@property (nonatomic, strong) NSArray *boyWeightData;
@property (nonatomic, strong) NSArray *boyLengthData;
@property (nonatomic, strong) NSArray *boyStatureData;
@property (nonatomic, strong) NSArray *boyHCData;
@property (nonatomic, strong) NSArray *boyBMIData;

@property (nonatomic, strong) NSArray *infantGirlWeightData;
@property (nonatomic, strong) NSArray *girlWeightData;
@property (nonatomic, strong) NSArray *girlLengthData;
@property (nonatomic, strong) NSArray *girlStatureData;
@property (nonatomic, strong) NSArray *girlHCData;
@property (nonatomic, strong) NSArray *girlBMIData;

@end

@implementation SBTCDCDataSource

-(NSArray *)infantBoyWeightData{
    if (!_infantBoyWeightData){
        _infantBoyWeightData = [self filledDataArrayFromFile:CDC_BOY_INFANT_WEIGHT_FILENAME];
    }
    return _infantBoyWeightData;
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
    double percentile = [dataPoint percentileForMeasurment:measurement];
    return percentile;
}


@end
