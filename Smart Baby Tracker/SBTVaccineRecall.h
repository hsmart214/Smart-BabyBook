//
//  SBTVaccineRecall.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/5/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccine.h"

@interface SBTVaccineRecall : SBTVaccine

@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, strong, readonly) NSString *reason;

-(instancetype)initWithVaccine:(SBTVaccine *)vac recallDate:(NSDate *)date andReason:(NSString *)reason;

@end
