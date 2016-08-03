//
//  iOSHardwareInfoDataBase.h
//  DHDemos
//
//  Created by xy2 on 16/7/5.
//  Copyright © 2016年 xy2. All rights reserved.
//

#import <Foundation/Foundation.h>
/*********************************
 
 Device,
 
 Model ID,
 
 Year,
 
 SoC,
 
 RAM (MB),
 
 Mem Speed (MHz),
 
 Mem Type,
 
 CPU,
 
 CPU Arch,
 
 Data Width,
 
 CPU Cores,
 
 CPU Clock (MHz),
 
 Geekbench Score,
 
 GPU,
 
 GPU Cores,
 
 GPU Clock (MHz),
 
 Screen Res,
 
 PPI,
 
 Screen Size (inches)
 
 *********************************/
@interface iOSHardwareInfoDataBase : NSObject

@property(nonatomic, readonly) BOOL isReady;

+ (iOSHardwareInfoDataBase *) sharedInstance;

-(NSDictionary *)currentDeviceInfo;
@end
