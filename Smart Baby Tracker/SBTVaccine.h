//
//  SBTVaccine.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import Foundation;

// Other parts of this application depend on the fact that there are NO DUPLICATE VACCINE NAMES in the dictionaries
// Specifically, no common names between the generic and trade name dictionaries.

@interface SBTVaccine : NSObject <NSSecureCoding, NSCopying>

// Required
@property (nonatomic, strong, readonly) NSSet* components;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *displayNames;
@property (nonatomic) BOOL liveVaccine;
// Optional
@property (nonatomic, assign) BOOL barcodeScanned;
@property (nonatomic) SBTVaccineRoute route;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *ndc;
@property (nonatomic, copy) NSString *lotNumber;
@property (nonatomic, copy) NSDate *expirationDate;

-(NSString *)componentString;

-(BOOL)includesEquivalentComponent:(SBTComponent)component;
-(BOOL)includesExactComponent:(SBTComponent)component;

-(instancetype)init;
// Designated initializer
-(instancetype)initWithName:(NSString *)name displayNames:(NSArray *)displayNames andComponents:(NSArray *)comps;
-(instancetype)initWithName:(NSString *)name displayNames:(NSArray *)displayNames manufacturer:(NSString *)man andComponents:(NSArray *)comps;
-(instancetype)initWithBarcode:(NSString *)barcode;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(instancetype)copy;

+(NSString *)ndcFromBarcode:(NSString *)code;
+(NSDictionary *)vaccinesByTradeName;
+(NSDictionary *)vaccinesByGenericName;
+(NSSet *)liveVaccineComponents;
+(NSArray *)componentsEquivalentToComponent:(SBTComponent)component;

@end
