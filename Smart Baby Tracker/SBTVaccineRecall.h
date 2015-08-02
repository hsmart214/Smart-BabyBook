//
//  SBTVaccineRecall.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/5/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccine.h"

#define RECALL_DATE_KEY @"com.mysmartsoftware.SmartBabyBook.recallDateKey"
#define RECALL_REASON_KEY @"com.mysmartsoftware.SmartBabyBook.recallReasonKey"
#define RECALL_ADVICE_KEY @"com.mysmartsoftware.SmartBabyBook.recallAdviceKey"
#define RECALL_VACCINE_NAME_KEY @"com.mysmartsoftware.SmartBabyBook.recallVaccineTradeNameKey"
#define RECALL_VACCINE_LOT_KEY @"com.mysmartsoftware.SmartBabyBook.recallLotKey"


@interface SBTVaccineRecall : SBTVaccine

@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, strong, readonly) NSString *reason;
@property (nonatomic, strong, readonly) NSString *advice;

-(instancetype)initWithVaccine:(SBTVaccine *)vac recallDate:(NSDate *)date reason:(NSString *)reason advice:(NSString *)advice;

@end
