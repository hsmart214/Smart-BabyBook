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
@property (nonatomic, copy) NSString *displayName;
// Optional
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *lotNumber;
@property (nonatomic, copy) NSDate *expirationDate;

-(instancetype)init;
-(instancetype)initWithName:(NSString *)name displayName:(NSString *)displayName andComponents:(NSArray *)comps;    // Designated initializer
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(instancetype)copy;

+(BOOL)supportsSecureCoding;

@end
