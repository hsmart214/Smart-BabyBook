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
        self.liveVaccine = NO;
        for (NSNumber *comp in comps){
            // no point in casting the NSNumber to an SBTComponent and back again
            if ([[[self class] liveVaccineComponents] containsObject:comp]){
                self.liveVaccine = YES;
                break;
            }
        }
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
    [aCoder encodeInteger:self.route forKey:@"route"];
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
        self.route = (SBTVaccineRoute)[aDecoder decodeIntegerForKey:@"route"];
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
    newVacc.route = self.route;
    
    return newVacc;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

// These vaccines will cause a 28 day lockout period for vaccines not given on the same day
+(NSSet *)liveVaccineComponents
{
    static NSSet *liveVaccines = nil;
    if (!liveVaccines){
        liveVaccines =[NSSet setWithObjects:@(SBTComponentLAIV), @(SBTComponentMeasles), @(SBTComponentMMR),
                       @(SBTComponentMumps), @(SBTComponentRota), @(SBTComponentRubella), @(SBTComponentTyphLive),
                       @(SBTComponentVZV), nil];
    }
    return liveVaccines;
}

+(NSDictionary *)vaccinesByTradeName
{
    static NSDictionary *allVaccs = nil;
    if (!allVaccs){
        allVaccs = @{
                     @"Adacel":[[SBTVaccine alloc] initWithName:@"Adacel" displayNames:@[@"Tdap"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTdap)]],
                     @"Boostrix":[[SBTVaccine alloc] initWithName:@"Boostrix" displayNames:@[@"Tdap"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTdap)]],
                     @"Daptacel":[[SBTVaccine alloc] initWithName:@"Daptacel" displayNames:@[@"DTaP"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTdap)]],
                     @"Tripedia":[[SBTVaccine alloc] initWithName:@"Tripedia" displayNames:@[@"DTaP"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentDTaP)]],
                     @"Infanrix":[[SBTVaccine alloc] initWithName:@"Infanrix" displayNames:@[@"DTaP"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentDTaP)]],
                     @"Kinrix":[[SBTVaccine alloc] initWithName:@"Kinrix" displayNames:@[@"DTaP", @"IPV"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentDTaP), @(SBTComponentIPV)]],
                     @"Pediarix":[[SBTVaccine alloc] initWithName:@"Pediarix" displayNames:@[@"DTaP", @"IPV", @"Hep B"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentDTaP), @(SBTComponentIPV), @(SBTComponentHepB)]],
                     @"Pentacel":[[SBTVaccine alloc] initWithName:@"Pentacel" displayNames:@[@"DTaP", @"HiB", @"IPV"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentDTaP), @(SBTComponentIPV), @(SBTComponentPRP_T)]],
                     @"MMR-II":[[SBTVaccine alloc] initWithName:@"MMR-II" displayNames:@[@"MMR"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentMMR)]],
                     @"ProQuad":[[SBTVaccine alloc] initWithName:@"ProQuad" displayNames:@[@"MMR", @"VZV"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentMMR), @(SBTComponentVZV)]],
                     @"PedvaxHiB":[[SBTVaccine alloc] initWithName:@"PedvaxHiB" displayNames:@[@"HiB"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPRP_OMP)]],
                     @"Comvax":[[SBTVaccine alloc] initWithName:@"Comvax" displayNames:@[@"Hep B", @"HiB"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPRP_OMP), @(SBTComponentHepB)]],
                     @"ActHiB":[[SBTVaccine alloc] initWithName:@"ActHiB" displayNames:@[@"HiB"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPRP_T)]],
                     @"Hiberix":[[SBTVaccine alloc] initWithName:@"Hiberix" displayNames:@[@"HiB"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPRP_T)]],
                     @"MenHibrix":[[SBTVaccine alloc] initWithName:@"MenHibrix" displayNames:@[@"HiB", @"Men-CY"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPRP_T), @(SBTComponentMenCY)]],
                     @"Havrix":[[SBTVaccine alloc] initWithName:@"Havrix" displayNames:@[@"Hep A"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentHepA)]],
                     @"Vaqta":[[SBTVaccine alloc] initWithName:@"Vaqta" displayNames:@[@"Hep A"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentHepA)]],
                     @"Twinrix":[[SBTVaccine alloc] initWithName:@"Twinrix" displayNames:@[@"Hep A", @"Hep B"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentHepA), @(SBTComponentHepB)]],
                     @"Recombivax HB":[[SBTVaccine alloc] initWithName:@"Recombivax HB" displayNames:@[@"Hep B"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentHepB)]],
                     @"Engerix-B":[[SBTVaccine alloc] initWithName:@"Engerix-B" displayNames:@[@"Hep B"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentHepB)]],
                     @"Gardasil":[[SBTVaccine alloc] initWithName:@"Gardasil" displayNames:@[@"HPV"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentHPV4)]],
                     @"Cervarix":[[SBTVaccine alloc] initWithName:@"Cervarix" displayNames:@[@"HPV"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentHPV2)]],
                     @"Menveo":[[SBTVaccine alloc] initWithName:@"Menveo" displayNames:@[@"MCV4"] manufacturer:Novartis andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentMCV4)]],
                     @"Menactra":[[SBTVaccine alloc] initWithName:@"Menactra" displayNames:@[@"MCV4"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentMCV4)]],
                     @"Menomune":[[SBTVaccine alloc] initWithName:@"Menomune" displayNames:@[@"MPV"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentMPV4)]],
                     @"Pneumovax":[[SBTVaccine alloc] initWithName:@"Pneumovax" displayNames:@[@"PPV23"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPPV23)]],
                     @"Prevnar7":[[SBTVaccine alloc] initWithName:@"Prevnar7" displayNames:@[@"PCV7"] manufacturer:Wyeth andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPCV7)]],
                     @"Prevnar13":[[SBTVaccine alloc] initWithName:@"Prevnar13" displayNames:@[@"PCV13"] manufacturer:Wyeth andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPCV13)]],
                     @"IPOL":[[SBTVaccine alloc] initWithName:@"IPOL" displayNames:@[@"Polio"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentIPV)]],
                     @"Rotarix":[[SBTVaccine alloc] initWithName:@"Rotarix" displayNames:@[@"Rota"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentRota)]],
                     @"Rotateq":[[SBTVaccine alloc] initWithName:@"Rotateq" displayNames:@[@"Rota"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentRota)]],
                     @"Decavac":[[SBTVaccine alloc] initWithName:@"Decavac" displayNames:@[@"Td"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTd)]],
                     @"Tenivac":[[SBTVaccine alloc] initWithName:@"Tenivac" displayNames:@[@"Td"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTd)]],
                     };
    }
    return allVaccs;
}
//TODO: put in the influenza vaccines, ?typhoid - only need for live lockout.
+(NSDictionary *)vaccinesByGenericName
{
    static NSDictionary *genericVaccines = nil;
    if (!genericVaccines){
        genericVaccines = @{
            @"DTaP":[[SBTVaccine alloc] initWithName:@"DTaP" displayNames:@[@"DTaP"] andComponents:@[@(SBTComponentDTaP)]],
            @"MMR":[[SBTVaccine alloc] initWithName:@"MMR" displayNames:@[@"MMR"] andComponents:@[@(SBTComponentMMR)]],
            @"Hep B":[[SBTVaccine alloc] initWithName:@"Hep B" displayNames:@[@"Hep B"] andComponents:@[@(SBTComponentHepB)]],
            @"Hep A":[[SBTVaccine alloc] initWithName:@"Hep A" displayNames:@[@"Hep A"] andComponents:@[@(SBTComponentHepA)]],
            @"Rota":[[SBTVaccine alloc] initWithName:@"Rota" displayNames:@[@"Rota"] andComponents:@[@(SBTComponentRota)]],
            @"Tdap":[[SBTVaccine alloc] initWithName:@"Tdap" displayNames:@[@"Tdap"] andComponents:@[@(SBTComponentTdap)]],
            @"HiB":[[SBTVaccine alloc] initWithName:@"HiB" displayNames:@[@"HiB"] andComponents:@[@(SBTComponentHiB)]],
            @"PCV13":[[SBTVaccine alloc] initWithName:@"PCV13" displayNames:@[@"PCV13"] andComponents:@[@(SBTComponentPCV13)]],
            @"PCV7":[[SBTVaccine alloc] initWithName:@"PCV7" displayNames:@[@"PCV7"] andComponents:@[@(SBTComponentPCV7)]],
            @"PPV23":[[SBTVaccine alloc] initWithName:@"PPV23" displayNames:@[@"PPV23"] andComponents:@[@(SBTComponentPPV23)]],
            @"Tdap":[[SBTVaccine alloc] initWithName:@"Tdap" displayNames:@[@"Tdap"] andComponents:@[@(SBTComponentTdap)]],
            @"IPV":[[SBTVaccine alloc] initWithName:@"IPV" displayNames:@[@"IPV"] andComponents:@[@(SBTComponentIPV)]],
            @"VZV":[[SBTVaccine alloc] initWithName:@"VZV" displayNames:@[@"VZV"] andComponents:@[@(SBTComponentVZV)]],
            @"HPV":[[SBTVaccine alloc] initWithName:@"HPV" displayNames:@[@"HPV"] andComponents:@[@(SBTComponentHPV4)]],
            @"MCV4":[[SBTVaccine alloc] initWithName:@"MCV4" displayNames:@[@"MCV4"] andComponents:@[@(SBTComponentMCV4)]],
                            };
    }
    return genericVaccines;
}

-(NSString *)description
{
    return self.name;
}

@end
