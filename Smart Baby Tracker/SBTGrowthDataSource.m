//
//  SBTGrowthChart.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTGrowthDataSource.h"
#import "SBTDataPoint.h"

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
        // the columns are 'Age	L	M	S	P01	P1	P3	P5	P10	P15	P25	P50	P75	P85	P90	P95	P97	P99	P999'
        SBTDataPoint *dp = [[SBTDataPoint alloc] init];
        if (days) {
            dp->ageDays = [chunks[0] doubleValue];
        }else{
            dp->ageMonths = [chunks[0] doubleValue];
        }
        dp->skew = [chunks[1] doubleValue];
        dp->mean = [chunks[2] doubleValue];
        dp->stdev = [chunks[3] doubleValue];
        
        [data addObject:dp];
        [plist addObject:[dp propertyList]];
    }
    dataFileURL = [cacheURL URLByAppendingPathComponent:fileString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [plist writeToURL:dataFileURL atomically:YES];
        NSLog(@"Wrote data file?: %d", success);
    });
    return data;
}

-(double)percentileOfMeasurement:(double)measurement
                          forAge:(NSInteger)days
                       parameter:(SBTGrowthParameter)parameter
                       andGender:(SBTGender)gender
{
    NSAssert(NO, @"Should not be calling the superclass method for SBTGrowthDataSource");
    return 0.0;
}

+(instancetype)sharedDataSource
{
    NSAssert(NO, @"Should not be calling the superclass method for SBTGrowthDataSource");
    return nil;
}

@end
