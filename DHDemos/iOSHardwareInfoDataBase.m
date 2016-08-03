//
//  iOSHardwareInfoDataBase.m
//  DHDemos
//
//  Created by xy2 on 16/7/5.
//  Copyright © 2016年 xy2. All rights reserved.
//

#import "iOSHardwareInfoDataBase.h"
#import "JSONKit.h"
#import "NSString+StringRegular.h"

#include <sys/socket.h>

#include <sys/sysctl.h>

#include <net/if.h>

#include <net/if_dl.h>

#define IOS_DEVICE_SPECIFICATIONS_GRID_URL @"http://www.blakespot.com/ios_device_specifications_grid.html"
@interface iOSHardwareInfoDataBase()

{
    
    BOOL _isReady;
    
}

@property(nonatomic, strong) NSMutableDictionary* db;

@end
@implementation iOSHardwareInfoDataBase


@synthesize isReady = _isReady;

+ (iOSHardwareInfoDataBase *) sharedInstance

{
    
    static iOSHardwareInfoDataBase* _sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        if (!_sharedInstance) {
            
            if (!_sharedInstance) _sharedInstance=[[iOSHardwareInfoDataBase alloc] init];
            
        }
        
    });
    
    return _sharedInstance;
    
}
-(id)init

{
    
    if (self =[super init]) {
        
        _isReady = FALSE;
        
        self.db = [NSMutableDictionary dictionary];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
            
            [self TryParse];
            
        });
        
    }
    
    return self;
    
}
-(NSString *)getMetaData

{
    
    NSURL *url = [NSURL URLWithString:IOS_DEVICE_SPECIFICATIONS_GRID_URL];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}
-(void) TryParse

{
    
    NSFileManager*fileManager =[NSFileManager defaultManager];
    
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString*path =[documentsDirectory stringByAppendingPathComponent:@"hardware"];
    
    if([fileManager fileExistsAtPath:path])
        
    {
        
        NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:path];
        
        NSDictionary * db= [jsonData objectFromJSONData];
        
        [self.db addEntriesFromDictionary:db];
        
    }
    
    NSString *metaData = [self getMetaData];
    
    if (!metaData)
        
    {
        
        _isReady = TRUE;
        
        return;
        
    }
    
    NSRange rangeTable= [metaData rangeOfString:@"<table border=0 cellpadding=0 cellspacing=2>[\\s\\S]*</table>" options:NSRegularExpressionSearch];
    
    if (rangeTable.length <=0)
        
    {
        
        _isReady = TRUE;
        
        return;
        
    }
    
    [self.db removeAllObjects];
    
    NSString* tableStr = [[metaData substringWithRange:rangeTable] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    tableStr = [tableStr stringByReplacingOccurrencesOfString:@"<br>" withString:@" "];
    
    tableStr = [tableStr stringByReplacingOccurrencesOfString:@"# " withString:@""];
    
    NSMutableArray *infoArray=[tableStr substringByRegular:@"<tr[\\s\\S]*?>[\\s\\S]*?</tr>"];
    
    NSString *titleStr = [infoArray firstObject];
    
    NSMutableArray *titleArr = [titleStr substringByRegular:@"<td[\\s\\S]*?>[\\s\\S]*?</td>"];
    
    for (NSUInteger i = 0; i < [titleArr count]; i++)
        
    {
        
        NSString *title = [titleArr objectAtIndex:i];
        
        NSRange rangetd = [title rangeOfString:@"<td[\\s\\S]*?>" options:NSRegularExpressionSearch];
        
        title = [title stringByReplacingCharactersInRange:rangetd withString:@""];
        
        title = [title stringByReplacingOccurrencesOfString:@"</td>" withString:@" "];
        
        [titleArr replaceObjectAtIndex:i withObject:title];
        
    }
    
    [infoArray removeObjectAtIndex:0];
    
    [infoArray removeLastObject];
    
    for (NSString *deviceInfo in infoArray)
        
    {
        
        NSMutableArray *devices = [deviceInfo substringByRegular:@"<td[\\s\\S]*?>[\\s\\S]*?</td>"];
        
        for (NSUInteger i = 0; i < [devices count]; i++)
            
        {
            
            NSString *val = [devices objectAtIndex:i];
            
            NSRange rangetd = [val rangeOfString:@"<td[\\s\\S]*?>" options:NSRegularExpressionSearch];
            
            val = [val stringByReplacingCharactersInRange:rangetd withString:@""];
            
            val = [val stringByReplacingOccurrencesOfString:@"</td>" withString:@" "];
            
            [devices replaceObjectAtIndex:i withObject:val];
            
        }
        
        NSString *deviceKey = [devices objectAtIndex:1];
        
        NSArray* keyArr = [[deviceKey stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@"•"];
        
        NSRange chRange = [[keyArr firstObject] rangeOfString:@"[\\D]*" options:NSRegularExpressionSearch];
        
        NSString* chs = [[keyArr firstObject] substringWithRange:chRange];
        
        for (NSString* _key in keyArr)
            
        {
            
            if (_key && [_key length] > 0)
                
            {
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                
                for (NSUInteger j = 0; j < [titleArr count]; j++)
                    
                {
                    
                    if (j != 1)
                        
                    {
                        
                        NSString *titleKey = [[titleArr objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        
                        NSString *deviceVal = [[devices objectAtIndex:j]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
                        
                        [dict setObject:deviceVal forKey:titleKey];
                        
                    }
                    
                }
                
                NSString* dKey = _key;
                
                if ([dKey rangeOfString:chs].length == 0) dKey = [chs stringByAppendingString:dKey];
                
                [self.db setObject:dict forKey:dKey];
                
            }
            
        }
        
    }
    
    _isReady = TRUE;
    
    NSData *newJsonData = [self.db JSONData];
    
    [newJsonData writeToFile:path atomically:YES];
    
}

- (NSString *) platform{
    
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);
    
    return platform;
    
}

-(NSDictionary *)currentDeviceInfo

{
    
//    if (_isReady)
//        
//    {
    
    NSFileManager*fileManager =[NSFileManager defaultManager];
    
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString*path =[documentsDirectory stringByAppendingPathComponent:@"hardware"];
    
    if([fileManager fileExistsAtPath:path])
        
    {
        
        NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:path];
        
        NSDictionary * db= [jsonData objectFromJSONData];
        
        [self.db addEntriesFromDictionary:db];
        
    }
    NSString *key = [self platform];
    NSDictionary *temp = [self.db objectForKey:key];
    return temp;
    
//    }
//    
//    return nil;
    
}

@end
