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

-(instancetype)init{
    NSLog(@"Problem: Wrong initializer used for SBTVaccine instance");
    return [self initWithName:nil displayName:nil andComponents:nil];
}

-(instancetype)initWithName:(NSString *)name displayName:(NSString *)displayName andComponents:(NSArray *)comps
{
    if (self = [super init]){
        self.name = name;
        self.displayName = displayName;
        self.components = [NSSet setWithArray:comps];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.displayName forKey:@"displayName"];
    [aCoder encodeObject:self.manufacturer forKey:@"manufacturer"];
    [aCoder encodeObject:self.lotNumber forKey:@"lotNumber"];
    [aCoder encodeObject:self.expirationDate forKey:@"expDate"];
    [aCoder encodeObject:self.components forKey:@"components"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        self.name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.displayName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"displayName"];
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
    SBTVaccine *newVacc = [[SBTVaccine alloc] initWithName:self.name displayName:self.displayName andComponents:[self.components allObjects]];
    newVacc.manufacturer = self.manufacturer;
    newVacc.lotNumber = self.lotNumber;
    newVacc.expirationDate = self.expirationDate;
    
    return newVacc;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end
