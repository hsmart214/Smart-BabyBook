//
//  SBTImageStore.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/15/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTImageStore.h"

@interface SBTImageStore()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation SBTImageStore

+(SBTImageStore *)sharedStore
{
    static SBTImageStore *sharedStore = nil;
    if (!sharedStore){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedStore = [[super allocWithZone:NULL] init];
        });
    }
    return sharedStore;
}

-(instancetype)init
{
    if (self = [super init]){
        self.dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedStore];
}

-(void)setImage:(UIImage *)i forKey:(NSString *)s
{
    self.dictionary[s] = i;
    NSString *imagePath = [self imagePathForKey:s];
    NSData *data = UIImageJPEGRepresentation(i, 0.5);
    [data writeToFile:imagePath atomically:YES];
}

-(UIImage *)imageForKey:(NSString *)s
{
    UIImage *result = self.dictionary[s];
    if (!result){
        result = [UIImage imageWithContentsOfFile:[self imagePathForKey:s]];
        if (result){
            self.dictionary[s] = result;
        }else{
            NSLog(@"Error: unable to find %@", [self imagePathForKey:s]);
        }
    }
    return result;
}

-(void)deleteImageForKey:(NSString *)s
{
    if (s) {
        [self.dictionary removeObjectForKey:s];
        NSString *path = [self imagePathForKey:s];
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
}

#pragma mark - Archiving

-(NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = (NSString *)[documentDirectories firstObject];
    return [documentPath stringByAppendingPathComponent:key];
}


@end
