//
//  SBTUnitsConvertor.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTUnitsConvertor.h"

@implementation SBTUnitsConvertor

+(NSString *)preferredUnitForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitDefaults = [defaults objectForKey:UNIT_PREFS_KEY];
    return unitDefaults[key];
}

+(void)setPreferredUnit:(NSString *)unit forKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *unitDefaults = [[defaults objectForKey:UNIT_PREFS_KEY] mutableCopy];
    unitDefaults[key] = unit;
    [defaults setObject:unitDefaults forKey:UNIT_PREFS_KEY];
    [defaults synchronize];
}

#pragma mark - Class Methods
// measurements of the child will always be stored in the metric units used for calculations
// but the user can ask to see them in US or non-standard units if desired
// This class method can be called to convert a dimension from the displayed units back to the metric for storage

+(double)metricStandardOf:(double)dimension forKey:(NSString *)dimKey{
    NSDictionary *standards = @{LENGTH_UNIT_KEY: K_CENTIMETERS,
                                HC_UNIT_KEY: K_CENTIMETERS,
                                MASS_UNIT_KEY: K_KILOGRAMS,
                                };
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitPrefs = [defaults objectForKey:UNIT_PREFS_KEY];
    
    if ([unitPrefs[dimKey] isEqualToString: standards[dimKey]]) return dimension;
    
    if ([dimKey isEqualToString:LENGTH_UNIT_KEY]){      // standard is CENTIMETERS
        if ([unitPrefs[dimKey] isEqualToString:K_INCHES]){
            return dimension / INCHES_PER_CENTIMETER;
        }
    }
    if ([dimKey isEqualToString:HC_UNIT_KEY]){    // standard is CENTIMETERS
        if ([unitPrefs[dimKey] isEqualToString:K_INCHES]){
            return dimension / (INCHES_PER_CENTIMETER);
        }
    }
    if ([dimKey isEqualToString:MASS_UNIT_KEY]){         // standard is KILOGRAMS
        if ([unitPrefs[dimKey] isEqualToString:K_POUNDS]){
            return dimension/ POUNDS_PER_KILOGRAM;
        }
    }
    return dimension;
}

// and here is the inverse function to turn the measurement back into display units

+(double)displayUnitsOf:(double)dimension forKey:(NSString *)dimKey{
    NSDictionary *standards = @{LENGTH_UNIT_KEY: K_CENTIMETERS,
                                HC_UNIT_KEY: K_CENTIMETERS,
                                MASS_UNIT_KEY: K_KILOGRAMS,
                                };
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitPrefs = [defaults objectForKey:UNIT_PREFS_KEY];
    
    if ([unitPrefs[dimKey] isEqualToString: standards[dimKey]]) return dimension;
    
    if ([dimKey isEqualToString:LENGTH_UNIT_KEY]){      // standard is CENTIMETERS
        if ([unitPrefs[dimKey] isEqualToString:K_INCHES]){
            return dimension * INCHES_PER_CENTIMETER;
        }
    }
    if ([dimKey isEqualToString:HC_UNIT_KEY]){    // standard is CENTIMETERS
        if ([unitPrefs[dimKey] isEqualToString:K_INCHES]){
            return dimension * INCHES_PER_CENTIMETER;
        }
    }
    if ([dimKey isEqualToString:MASS_UNIT_KEY]){         // standard is KILOGRAMS
        if ([unitPrefs[dimKey] isEqualToString:K_POUNDS]){
            return dimension * POUNDS_PER_KILOGRAM;
        }
    }
    return dimension;
}

+(double)convertMeasure:(double)measure toMetricForKey:(NSString *)key{
    double retVal = 0.0;
    if ([key isEqualToString:MASS_UNIT_KEY]){
        retVal = measure/POUNDS_PER_KILOGRAM;
    }else if([key isEqualToString:LENGTH_UNIT_KEY] || [key isEqualToString:HC_UNIT_KEY]){
        retVal = measure/INCHES_PER_CENTIMETER;
    }
    return retVal;
}

+(SBTImperialWeight)imperialWeightForMass:(double)mass
{
    SBTImperialWeight result;
    result.mass = mass;
    double realPounds = mass * POUNDS_PER_KILOGRAM;
    result.pounds = (int)realPounds;
    result.ounces = (realPounds - result.pounds) * 16;
    return result;
}

+(BOOL)displayPounds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitPrefs = [defaults objectForKey:UNIT_PREFS_KEY];
    return [unitPrefs[MASS_UNIT_KEY] isEqualToString:K_POUNDS];
}

+ (NSString *)displayStringForKey:(NSString *)dimKey{
    NSDictionary *displayStrings = @{
                                     K_CENTIMETERS: @"cm",
                                     K_INCHES: @"in",
                                     K_KILOGRAMS: @"kg",
                                     K_POUNDS: @"lbs",
                                     };
    NSString *preferredUnit = [SBTUnitsConvertor preferredUnitForKey:dimKey];
    return displayStrings[preferredUnit];
}

+(NSString *)formattedStringForMeasurement:(double)measurement forKey:(NSString *)dimKey{
    double num = [[self class] displayUnitsOf:measurement forKey:dimKey];
    NSString *unit = [[self class] displayStringForKey:dimKey];
    return [NSString stringWithFormat:@"%1.2f %@", num, unit];
}

+(NSDictionary *)standardUnitPrefs
{
    return @{MASS_UNIT_KEY: K_POUNDS,
             HC_UNIT_KEY: K_INCHES,
             LENGTH_UNIT_KEY: K_INCHES,
             };
}

+(NSDictionary *)metricUnitPrefs
{
    return @{MASS_UNIT_KEY: K_KILOGRAMS,
             HC_UNIT_KEY: K_CENTIMETERS,
             LENGTH_UNIT_KEY: K_CENTIMETERS,
             };
}

+(BOOL)unitPreferencesSynchronizedMetric
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitPrefs = [defaults objectForKey:UNIT_PREFS_KEY];
    NSDictionary *metricPrefs = [[self class] metricUnitPrefs];
    BOOL result = YES;
    for (NSString *key in [unitPrefs allKeys]){
        result = result && [unitPrefs[key] isEqualToString:metricPrefs[key]];
    }
    return result;
}

+(BOOL)unitPreferencesSynchronizedStandard
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *unitPrefs = [defaults objectForKey:UNIT_PREFS_KEY];
    NSDictionary *defaultPrefs = [[self class] standardUnitPrefs];
    BOOL result = YES;
    for (NSString *key in [unitPrefs allKeys]){
        result = result && [unitPrefs[key] isEqualToString:defaultPrefs[key]];
    }
    return result;
}

+(void)chooseAllMetricUnits
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[self class] metricUnitPrefs] forKey:UNIT_PREFS_KEY];
}

+(void)chooseAllStandardUnits
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[self class] standardUnitPrefs] forKey:UNIT_PREFS_KEY];

}

@end
