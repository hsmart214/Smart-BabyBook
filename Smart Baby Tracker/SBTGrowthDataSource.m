//
//  SBTGrowthChart.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTGrowthDataSource.h"
#import "SBTDataPoint.h"
#import "SBTWHODataSource.h"
#import "SBTCDCDataSource.h"

@interface SBTGrowthDataSource()

@property (nonatomic) double infantChildCutoff;

@end

@implementation SBTGrowthDataSource

-(NSArray *)filledDataArrayFromFile:(NSString *)fileString
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *plist = [[NSMutableArray alloc] init];
    
    NSURL *cacheURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *dataFileURL = [cacheURL URLByAppendingPathComponent:fileString];
    //TODO: time this to make sure it is faster when cached
    if ([[NSFileManager defaultManager]fileExistsAtPath:[dataFileURL path]]){
        NSArray *cachedData = [[NSArray alloc] initWithContentsOfURL:dataFileURL];
        
        for (NSDictionary *dict in cachedData){
            [data addObject:[[SBTDataPoint alloc] initWithPlist:dict]];
        }
        NSLog(@"Read from plist file.");
        return data;
    }
    
    // from here on we are regenerating the data file from the text file on disk
    dataFileURL = [[NSBundle mainBundle] URLForResource:fileString withExtension:@"txt"];
    
    NSError *err;
    NSString *dataBlob = [NSString stringWithContentsOfURL:dataFileURL encoding:NSUTF8StringEncoding error:&err];
    if (err){
        NSLog(@"Error reading data: %@",[err debugDescription]);
    }
    NSMutableArray *textLines = [NSMutableArray arrayWithArray:[dataBlob componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]]];
    // the first line is always a header with description of each column
    NSString *header = textLines[0];
    NSArray *chunks = [header componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL days = ([(NSString *)chunks[0] isEqualToString:@"Age"]); // the other possibility is "Agemos"
    
    [textLines removeObjectAtIndex:0];
    for (NSString *line in textLines){
        chunks = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // WHO columns are 'Age	L	M	S	P01	P1	P3	P5	P10	P15	P25	P50	P75	P85	P90	P95	P97	P99	P999' (15 percentile data items)
        // CDC columns are 'Age L	M	S	P3	P5	P10	P25	P50	P75 P90	P95	P97' (9 percentile data items)
        // except CDC BMI which adds P85 (10 percentile data items)
        SBTDataPoint *dp = [[SBTDataPoint alloc] init];
        if (days) {
            dp->ageDays = [chunks[0] doubleValue];
        }else{
            dp->ageMonths = [chunks[0] doubleValue];
        }
        dp->skew = [chunks[1] doubleValue];
        dp->mean = [chunks[2] doubleValue];
        dp->stdev = [chunks[3] doubleValue];
        NSMutableArray *pd = [NSMutableArray array];
        for (int i = 4; i < [chunks count]; i++){
            [pd addObject:@([chunks[i] doubleValue])];
        }
        dp->percentileData = [pd copy];
        
        [data addObject:dp];
        [plist addObject:[dp propertyList]];
    }
    dataFileURL = [cacheURL URLByAppendingPathComponent:fileString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [plist writeToURL:dataFileURL atomically:YES];
        NSLog(@"Wrote data file?: %@", success ? @"YES" : @"NO");
    });
    return data;
}

-(double)dataAgeRangeForAge:(double)age
{
    NSAssert(NO, @"Should not be calling the superclass method for SBTGrowthDataSource");
    return 0.0;
}

-(double)baselineForParameter:(SBTGrowthParameter)parameter childChart:(BOOL)child
{
    switch (parameter) {
        case SBTWeight:
            return 0.0;
            break;
        case SBTStature:
        case SBTLength:
            return child ? CHILD_HEIGHT_BASELINE : INFANT_LENGTH_BASELINE;
            break;
        case SBTHeadCircumference:
            return INFANT_HC_BASELINE;
            break;
        case SBTBMI:
            return child ? CHILD_BMI_BASELINE : INFANT_BMI_BASELINE;
        default:
            return 0.0;
            break;
    }
}

-(double)dataFloorForParameter:(SBTGrowthParameter)parameter
{
    NSAssert(NO, @"Should not be calling the superclass method for SBTGrowthDataSource");
    return 0.0;
}

-(double)dataForPercentile:(SBTPercentile)percentile
                    forAge:(double)age
                 parameter:(SBTGrowthParameter)parameter
                 andGender:(SBTGender)gender
{
    return 0.0;
}

-(double)dataMeasurementRange97PercentForParameter:(SBTGrowthParameter)parameter
                                         forGender:(SBTGender)gender
                                          forChild:(BOOL)child
{
    return 0.0;
}

-(double)percentileOfMeasurement:(double)measurement
                          forAge:(NSInteger)days
                       parameter:(SBTGrowthParameter)parameter
                       andGender:(SBTGender)gender
{
    NSAssert(NO, @"Should not be calling the superclass method for SBTGrowthDataSource");
    return 0.0;
}

+(SBTGrowthDataSource *)growthDataSourceForAge:(NSInteger)ageInDays
{
    SBTGrowthDataSource *gds;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (ageInDays < [SBTGrowthDataSource infantAgeMaximum]){
        // is considered an infant age
        if ([defaults integerForKey:SBTGrowthDataSourceInfantDataSourceKey] == WHO_INFANT_CHART){
            gds = [SBTWHODataSource sharedDataSource];
        }else{
            gds = [SBTCDCDataSource sharedDataSource];
        }
    }else{
        // is considered a child age
        if ([defaults integerForKey:SBTGrowthDataSourceChildDataSourceKey] == WHO_CHILD_CHART){
            gds = [SBTWHODataSource sharedDataSource];
        }else{
            gds = [SBTCDCDataSource sharedDataSource];
        }
    }
    return gds;
}

+(double)infantAgeMaximum
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger max = [defaults doubleForKey:SBTGrowthDataSourceInfantChildCutoffKey];
    if (max == 0.0) {
        max = AAP_CUTOFF;
        [defaults setDouble:max forKey:SBTGrowthDataSourceInfantChildCutoffKey];
    }
    return max;
}

-(double)infantAgeMaximum
{
    if (_infantChildCutoff == 0.0) {
        _infantChildCutoff = [SBTGrowthDataSource infantAgeMaximum];
    }
    return _infantChildCutoff;
}

+(instancetype)sharedDataSource
{
    NSAssert(NO, @"Should not be calling the superclass method for SBTGrowthDataSource");
    return nil;
}

@end
