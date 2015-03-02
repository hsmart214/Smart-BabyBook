//
//  SBTVaccine.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/25/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccine.h"
#import "BCRVaccineCodeLoader.h"


@interface SBTVaccine ()

@property (nonatomic, strong) NSSet *components;

@end

@implementation SBTVaccine

static NSString *const SBTVaccineNameKey = @"SBTVaccineName";

-(BOOL)includesEquivalentComponent:(SBTComponent)component
{
    NSArray *equivs = [[self class] componentsEquivalentToComponent:component];
    BOOL present = NO;
    for (NSNumber *n in equivs){
        if ([self.components containsObject:n]) present = YES;
    }
    return present;
}

-(BOOL)includesExactComponent:(SBTComponent)component
{
    return [self.components containsObject:@(component)];
}

-(NSString *)componentString{
    return [self.displayNames componentsJoinedByString:@", "];
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

-(instancetype)initWithBarcode:(NSString *)barcode{
    // get the NDC, lot# and expiration date out of the barcode
    // the barcode has a non-printing character x\1d at the beginning
    barcode = [barcode substringFromIndex:1];
    NSLog(@"%@", barcode);
    NSString *ndc = [self ndcFromBarcode:barcode];
    NSDate *expDate = [self expDateFromBarcode:barcode];
    NSString *lotNumber = [self lotNumberFromBarcode:barcode];
    NSLog(@"%@ %@ %@", ndc, expDate.description, lotNumber);
    // get the vaccine name from the NDC number
    NSDictionary *cdcVaccines = [BCRVaccineCodeLoader vaccines];
    NSDictionary *thisVaccineInfo = cdcVaccines[ndc];
    NSString *thisVaccineTradeName = thisVaccineInfo[SBTVaccineNameKey];
    // create an SBTVaccine from the vaccine name dictionary
    self = [SBTVaccine vaccinesByTradeName][thisVaccineTradeName];
    // fix up the new SBTVaccine before returning it
    self.expirationDate = expDate;
    self.lotNumber = lotNumber;
    self.barcodeScanned = YES;
    self.ndc = ndc;
    return self;
}

-(NSString *)ndcFromBarcode:(NSString *)code{
    NSString *prefix = [code substringWithRange:NSMakeRange(0, 2)];
    if ([prefix isEqualToString:@"01"]){
        // this is the GTIN, always starts "01003..."
        NSString *wholeNDC = [code substringWithRange:NSMakeRange(5, 11)];
        NSString *first = [wholeNDC substringWithRange:NSMakeRange(0, 5)];
        NSString *second = [wholeNDC substringWithRange:NSMakeRange(5, 3)];
        NSString *third = [wholeNDC substringWithRange:NSMakeRange(8, 2)];
        // note that we pad the middle portion with a 0 digit.  The database has NDC11, but the barcode has 10 digits only
        return [NSString stringWithFormat:@"%@-0%@-%@", first, second, third];
    }else if ([prefix isEqualToString:@"17"]){
        // this is the expiration date, "17YYMMDD"
        // skip over the exp date and recur
        return [self ndcFromBarcode:[code substringFromIndex:8]];
    }else{
        // we are in trouble because the lot number should not be first
        // since we have no way of knowing how long it is
        return nil;
    }
}

-(NSDate *)expDateFromBarcode:(NSString *)code{
    NSString *prefix = [code substringWithRange:NSMakeRange(0, 2)];
    if ([prefix isEqualToString:@"01"]){ // this is the most common arrangement
        // this is the GTIN, always starts "01003..."
        // skip over GTIN - should be 14 digits, but some are 15, perhaps erroneously
        // the 15 digit ones alway end in "10", so they go "1017"
        // the 14 digit ones are always followed by "17", so they go "x17"
        // so if the 15th digit is "0" it is a 15 digit GTIN
        // if it is "1" then that is the start of the exp date
        NSString *decider = [code substringWithRange:NSMakeRange(15, 1)];
        if ([decider isEqualToString:@"1"]){
            // this is the "1" in the "17" marker for the exp date
            return [self expDateFromBarcode:[code substringFromIndex:15]];
        }else if ([decider isEqualToString:@"0"]){
            // this is a padding digit
            return [self expDateFromBarcode:[code substringFromIndex:16]];
        }else{
            // we are in trouble because it does not make sense for this digit to be anything other than "0" or "1"
            return nil;
        }
    }else if ([prefix isEqualToString:@"17"]){
        // this is the expiration date, "17YYMMDD"
        NSString *year = [code substringWithRange:NSMakeRange(2, 2)];
        NSString *month = [code substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [code substringWithRange:NSMakeRange(6, 2)];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *ds = [NSString stringWithFormat:@"20%@/%@/%@", year, month, day];
        NSDate *exp = [df dateFromString:ds];
        return exp;
    }else{
        // we are in trouble because the lot number should not be first
        // since we have no way of knowing how long it is
        return nil;
    }

}

-(NSString *)lotNumberFromBarcode:(NSString *)code{
    NSString *prefix = [code substringWithRange:NSMakeRange(0, 2)];
    if ([prefix isEqualToString:@"01"]){
        NSString *decider = [code substringWithRange:NSMakeRange(15, 1)];
        if ([decider isEqualToString:@"1"]){
            // this is the "1" in the "17" marker for the exp date
            return [self lotNumberFromBarcode:[code substringFromIndex:15]];
        }else if ([decider isEqualToString:@"0"]){
            // this is a padding digit
            return [self lotNumberFromBarcode:[code substringFromIndex:16]];
        }else{
            // we are in trouble because it does not make sense for this digit to be anything other than "0" or "1"
            return nil;
        }
    }else if ([prefix isEqualToString:@"17"]){
        // this is the expiration date, "17YYMMDD"
        return [self lotNumberFromBarcode:[code substringFromIndex:8]];
    }else if ([prefix isEqualToString:@"10"]){
        return [code substringFromIndex:2];
    }else{
        // we have encountered an unknown prefix
        return nil;
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.displayNames forKey:@"displayName"];
    [aCoder encodeObject:self.manufacturer forKey:@"manufacturer"];
    [aCoder encodeObject:self.ndc forKey:@"ndc"];
    [aCoder encodeObject:self.lotNumber forKey:@"lotNumber"];
    [aCoder encodeObject:self.expirationDate forKey:@"expDate"];
    [aCoder encodeObject:self.components forKey:@"components"];
    [aCoder encodeInteger:self.route forKey:@"route"];
    [aCoder encodeBool:self.barcodeScanned forKey:@"scanned"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        self.name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.displayNames = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"displayName"];
        self.manufacturer = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"manufacturer"];
        self.ndc = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"ndc"];
        self.lotNumber = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lotNumber"];
        self.expirationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"expDate"];
        self.components = [aDecoder decodeObjectOfClass:[NSSet class] forKey:@"components"];
        self.route = (SBTVaccineRoute)[aDecoder decodeIntegerForKey:@"route"];
        self.barcodeScanned = [aDecoder decodeBoolForKey:@"scanned"];
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
    newVacc.ndc = self.ndc;
    newVacc.lotNumber = self.lotNumber;
    newVacc.expirationDate = self.expirationDate;
    newVacc.route = self.route;
    newVacc.barcodeScanned = self.barcodeScanned;
    return newVacc;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

// These vaccines will cause a mutual 28 day lockout period if not given on the same day
// Live oral vaccines do NOT cause this lockout period
+(NSSet *)liveVaccineComponents
{
    static NSSet *liveVaccines = nil;
    if (!liveVaccines){
        liveVaccines =[NSSet setWithObjects:@(SBTComponentLAIV), @(SBTComponentMeasles), @(SBTComponentMMR),
                       @(SBTComponentMumps), @(SBTComponentRubella), @(SBTComponentVZV), nil];
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
                     @"Daptacel":[[SBTVaccine alloc] initWithName:@"Daptacel" displayNames:@[@"DTaP"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentDTaP)]],
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
                     @"Trumenba":[[SBTVaccine alloc] initWithName:@"Trumenba" displayNames:@[@"MenB"] manufacturer:Pfizer andComponents:@[@(SBTComponentMenB), @(SBTComponentFDA_Approved)]],
                     @"Bexsero":[[SBTVaccine alloc] initWithName:@"Bexsero" displayNames:@[@"MenB"] manufacturer:Novartis andComponents:@[@(SBTComponentMenB), @(SBTComponentFDA_Approved)]],
                     @"Menomune":[[SBTVaccine alloc] initWithName:@"Menomune" displayNames:@[@"MPV"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentMPV4)]],
                     @"Pneumovax":[[SBTVaccine alloc] initWithName:@"Pneumovax" displayNames:@[@"PPV23"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPPV23)]],
                     @"Prevnar7":[[SBTVaccine alloc] initWithName:@"Prevnar7" displayNames:@[@"PCV7"] manufacturer:Wyeth andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPCV7)]],
                     @"Prevnar13":[[SBTVaccine alloc] initWithName:@"Prevnar13" displayNames:@[@"PCV13"] manufacturer:Wyeth andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentPCV13)]],
                     @"IPOL":[[SBTVaccine alloc] initWithName:@"IPOL" displayNames:@[@"Polio"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentIPV)]],
                     @"Rotarix":[[SBTVaccine alloc] initWithName:@"Rotarix" displayNames:@[@"Rota"] manufacturer:Glaxo andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentRota)]],
                     @"Rotateq":[[SBTVaccine alloc] initWithName:@"Rotateq" displayNames:@[@"Rota"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentRota)]],
                     @"Decavac":[[SBTVaccine alloc] initWithName:@"Decavac" displayNames:@[@"Td"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTd)]],
                     @"Tenivac":[[SBTVaccine alloc] initWithName:@"Tenivac" displayNames:@[@"Td"] manufacturer:Sanofi andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTd)]],
                     @"Varivax":[[SBTVaccine alloc] initWithName:@"Varivax" displayNames:@[@"VZV"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentVZV)]],
                     @"Tetanus MSD":[[SBTVaccine alloc] initWithName:@"Tetanus" displayNames:@[@"Td"] manufacturer:Merck andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTd)]],
                     @"Tetanus":[[SBTVaccine alloc] initWithName:@"Tetanus" displayNames:@[@"Td"] manufacturer:Rebel andComponents:@[@(SBTComponentFDA_Approved), @(SBTComponentTd)]],
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
            @"IPV":[[SBTVaccine alloc] initWithName:@"IPV" displayNames:@[@"IPV"] andComponents:@[@(SBTComponentIPV)]],
            @"OPV":[[SBTVaccine alloc] initWithName:@"OPV" displayNames:@[@"OPV"] andComponents:@[@(SBTComponentOPV)]],
            @"VZV":[[SBTVaccine alloc] initWithName:@"VZV" displayNames:@[@"VZV"] andComponents:@[@(SBTComponentVZV)]],
            @"HPV":[[SBTVaccine alloc] initWithName:@"HPV" displayNames:@[@"HPV"] andComponents:@[@(SBTComponentHPV4)]],
            @"MCV4":[[SBTVaccine alloc] initWithName:@"MCV4" displayNames:@[@"MCV4"] andComponents:@[@(SBTComponentMCV4)]],
                            };
    }
    return genericVaccines;
}

+(NSArray *)componentsEquivalentToComponent:(SBTComponent)component
{
    switch (component) {
        case SBTComponentDTaP:
        case SBTComponentDTP:
        case SBTComponentDTwP:
            return @[@(SBTComponentDTwP), @(SBTComponentDTP), @(SBTComponentDTaP)];
        case SBTComponentHiB:
        case SBTComponentPRP_T:
        case SBTComponentPRP_OMP:
            return @[@(SBTComponentHiB), @(SBTComponentPRP_T), @(SBTComponentPRP_OMP)];
        case SBTComponentIPV:
        case SBTComponentOPV:
            return @[@(SBTComponentIPV), @(SBTComponentOPV)];
        case SBTComponentHPV2:
        case SBTComponentHPV4:
            return @[@(SBTComponentHPV2), @(SBTComponentHPV4)];
        case SBTComponentPCV7:
        case SBTComponentPCV13:
            return @[@(SBTComponentPCV7), @(SBTComponentPCV13)];
        case SBTComponentFlu:
        case SBTComponentLAIV:
            return @[@(SBTComponentFlu), @(SBTComponentLAIV)];
        default:
            return @[@(component)];
            break;
    }
}

-(NSString *)description
{
    return self.name;
}

@end
