//
//  SBTUnitsConvertor.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#define MASS_UNIT_KEY @"kMassUnitKey"
#define LENGTH_UNIT_KEY @"kLengthUnitKey"
#define HC_UNIT_KEY @"kHeadCircUnitKey"

@import Foundation;

@interface SBTUnitsConvertor : NSObject

+(NSString *)preferredUnitForKey:(NSString *)key;

+(void)setPreferredUnit:(NSString *)unit forKey:(NSString *)key;

+(double)metricStandardOf:(double)dimension forKey:(NSString *)dimKey;

+(double)displayUnitsOf:(double)dimension forKey:(NSString *)dimKey;

+(NSString *)displayStringForKey:(NSString *)dimKey;

+(NSString *)formattedStringForMeasurement:(double)measurement forKey:(NSString *)dimKey;

// this will assume measure is in imperial units - either decimal pounds or decimal inches (no feet, no ounces)
+(double)convertMeasure:(double)measure toMetricForKey:(NSString *)key;

+(NSDictionary *)standardUnitPrefs;

+(SBTImperialWeight)imperialWeightForMass:(double)mass;

+(BOOL)displayPounds;

+(BOOL)unitPreferencesSynchronizedMetric;
+(BOOL)unitPreferencesSynchronizedStandard;

+(void)chooseAllMetricUnits;
+(void)chooseAllStandardUnits;

@end
