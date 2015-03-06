//
//  SBTVaccineRecall.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/5/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccineRecall.h"

@implementation SBTVaccineRecall

-(instancetype)initWithVaccine:(SBTVaccine *)vac recallDate:(NSDate *)date andReason:(NSString *)reason {
    if (self = [super initWithName:vac.name displayNames:vac.displayNames manufacturer:vac.manufacturer andComponents:[vac.components allObjects]]){
        self.ndc = vac.ndc;
        self.expirationDate = vac.expirationDate;
        self.lotNumber = vac.lotNumber;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.date forKey:@"recallDate"];
    [aCoder encodeObject:self.reason forKey:@"recallReason"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        _date = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"recallDate"];
        _reason = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"recallReason"];
    }
    return self;
}

@end
