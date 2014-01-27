//
//  SBTVaccine.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccine.h"

@interface SBTVaccine ()

@property (nonatomic, strong) NSSet *components;

@end

@implementation SBTVaccine


//TODO: add logic for different but equivalent components
-(BOOL)includesEquivalentComponent:(SBTComponent)component
{
    return [self.components containsObject:@(component)];
}

-(instancetype)init{
    NSLog(@"Problem: Wrong initializer used for SBTVaccine instance");
    return [self initWithName:nil displayNames:nil andComponents:nil];
}

-(instancetype)initWithName:(NSString *)name displayNames:(NSArray *)displayNames andComponents:(NSArray *)comps
{
    if (self = [super init]){
        self.name = name;
        self.displayNames = displayNames;
        self.components = [NSSet setWithArray:comps];
    }
    return self;
}

-(instancetype)initWithName:(NSString *)name displayNames:(NSArray *)displayNames manufacturer:(NSString *)man andComponents:(NSArray *)comps
{
    self = [self initWithName:name displayNames:displayNames andComponents:comps];
    self.manufacturer = man;
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.displayNames forKey:@"displayName"];
    [aCoder encodeObject:self.manufacturer forKey:@"manufacturer"];
    [aCoder encodeObject:self.lotNumber forKey:@"lotNumber"];
    [aCoder encodeObject:self.expirationDate forKey:@"expDate"];
    [aCoder encodeObject:self.components forKey:@"components"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        self.name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.displayNames = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"displayName"];
        self.manufacturer = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"manufacturer"];
        self.lotNumber = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lotNumber"];
        self.expirationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"expDate"];
        self.components = [aDecoder decodeObjectOfClass:[NSSet class] forKey:@"components"];
    }
    return self;
}

-(instancetype)copy{
    return [self copyWithZone:nil];
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    SBTVaccine *newVacc = [[SBTVaccine alloc] initWithName:self.name displayNames:self.displayNames andComponents:[self.components allObjects]];
    newVacc.manufacturer = self.manufacturer;
    newVacc.lotNumber = self.lotNumber;
    newVacc.expirationDate = self.expirationDate;
    
    return newVacc;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

+(NSDictionary *)vaccinesByTradeName
{
    static NSDictionary *allVaccs = nil;
    if (!allVaccs){
        allVaccs = @{
                     @"Adacel":[[SBTVaccine alloc] initWithName:@"Adacel" displayNames:@[@"Tdap"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTdap), @(SBTComponentTet), @(SBTComponentDiph), @(SBTComponentAcelPert)]]
                     };
    }
    return allVaccs;
}

+(NSDictionary *)vaccinesByGenericName
{
    static NSDictionary *genericVaccines = nil;
    if (!genericVaccines){
        genericVaccines = @{@"DTaP":[[SBTVaccine alloc] initWithName:@"DTaP" displayNames:@[@"DTaP"] andComponents:@[@(SBTComponentFDA_Approved),@(SBTComponentTet), @(SBTComponentDiph), @(SBTComponentAcelPert)]]
                            };
    }
    return genericVaccines;
}

@end
