//
//  SBTVaccine.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import Foundation;

@interface SBTVaccine : NSObject <NSSecureCoding, NSCopying>

// Required
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *displayNames;
@property (nonatomic) BOOL liveVaccine;
// Optional
@property (nonatomic) SBTVaccineRoute route;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *lotNumber;
@property (nonatomic, copy) NSDate *expirationDate;

-(BOOL)includesEquivalentComponent:(SBTComponent)component;

-(instancetype)init;
-(instancetype)initWithName:(NSString *)name displayNames:(NSArray *)displayNames andComponents:(NSArray *)comps;    // Designated initializer
-(instancetype)initWithName:(NSString *)name displayNames:(NSArray *)displayNames manufacturer:(NSString *)man andComponents:(NSArray *)comps;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(instancetype)copy;

+(NSDictionary *)vaccinesByTradeName;
+(NSDictionary *)vaccinesByGenericName;
+(NSSet *)liveVaccineComponents;

@end
