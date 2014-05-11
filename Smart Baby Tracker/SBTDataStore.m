//
//  SBTDataStore.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/17/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTDataStore.h"
#import "SBTBaby.h"

//#define BABY_DICTIONARY_KEY @"com.mySmartSoftware.smartBabyTrackerBabyDictionary"

@interface SBTDataStore()

@property (nonatomic, strong) NSMutableDictionary *babyDict;

@end

@implementation SBTDataStore

-(void)storeBaby:(SBTBaby *)baby
{
    self.babyDict[baby.name] = baby;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saveChanges];
    });
}

-(BOOL)removeBaby:(SBTBaby *)baby
{
    BOOL found = self.babyDict[baby.name] != nil;
    if (found) {
        [self.babyDict removeObjectsForKeys:@[baby.name]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveChanges];
        });
    }
    return found;
}

-(NSArray *)storedBabies
{
    NSArray *babies = [[self.babyDict allValues] sortedArrayUsingSelector:@selector(name)];
    return babies;
}

+(instancetype)sharedStore
{
    static SBTDataStore *ds = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ds = [[SBTDataStore alloc] init];
    });
    return ds;
}

-(instancetype)init
{
    if (self = [super init]){
        NSString *path = [self babyArchivePath];
        self.babyDict = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] mutableCopy];
        if (!self.babyDict){
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"babies" withExtension:@"data"];
            self.babyDict = [[NSKeyedUnarchiver unarchiveObjectWithFile:[url path]] mutableCopy];
        }
        if (!self.babyDict){
            self.babyDict = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

#pragma mark - Archiving

-(NSString *)babyArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = (NSString *)[documentDirectories firstObject];
    return [documentPath stringByAppendingPathComponent:@"babies.data"];
}

-(BOOL)saveChanges
{
    NSString *path = [self babyArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.babyDict
                                       toFile:path];
}


@end
