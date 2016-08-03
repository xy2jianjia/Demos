//
//  ViewController.m
//  DHDemos
//
//  Created by xy2 on 16/6/15.
//  Copyright © 2016年 xy2. All rights reserved.
//

#import "ViewController.h"
#include <objc/runtime.h>
#import "iOSHardwareInfoDataBase.h"
#import <mach/task_info.h>
#import <mach/task.h>
#import <mach/vm_map.h>
#import <mach/thread_act.h>
#import <mach/mach.h>
#import <mach/port.h>
#import <mach/exception.h>
#import <mach/exception_types.h>
#import <mach/task.h>
#import <stdio.h>
#import <pthread/pthread.h>


#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "MainViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc]init];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn setTitle:@"点击" forState:(UIControlStateNormal)];
    btn.backgroundColor = [UIColor yellowColor];
    [btn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(demoTest:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
}
- (IBAction)demoTest:(id)sender {

    MainViewController *vc = [[MainViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
//    NSString *cpu = [self getCPUType];
//    NSLog(@"cpu:%@",cpu);
//    
//    cpu_subtype_t cupt = [self getCPUSubType];
//    
//    NSLog(@"%d",cupt);
//    
//    NSInteger memory =[self getTotalMemoryBytes];
//    NSLog(@"memory:%ld",memory);
//    
//    double hasUseMemory = [self getCurrentApplicationUseMemory];
//    NSLog(@"useMemory:%f",hasUseMemory);
//    
//    
//    NSDictionary *mccDict = [self getMCCAndMNCInfo];
//    NSLog(@"mcc:%@",mccDict);
//    
//    NSString *netW = [self getNetworkType];
//    NSLog(@"network:%@",netW);
    
}
// Declaration
//BOOL APCheckIfAppInstalled(NSString *bundleIdentifier); // Bundle identifier (eg. com.apple.mobilesafari) used to track apps

// Implementation


/**
 *  cpu已使用情况
 *
 *  @return
 */
-(float) cpu_usage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}
/**
 *  获取cpu型号
 *
 *  @return
 */
- (NSString *) getCPUType
{
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    
    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
    
    // values for cputype and cpusubtype defined in mach/machine.h
    if (type == CPU_TYPE_X86)
    {
        [cpu appendString:@"x86 "];
        // check for subtype ...
        
    } else if (type == CPU_TYPE_ARM)
    {
        [cpu appendString:@"ARM"];
        [cpu appendFormat:@",Type:%d",subtype];
    }
    return cpu;
    
}

- (cpu_subtype_t )getCPUSubType{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
    kern_return_t ret = host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t )&hostInfo, &infoCount);
    if (ret == KERN_SUCCESS) {
        NSLog(@"the cpuSubType is :%d",hostInfo.cpu_subtype);
    }
    return hostInfo.cpu_subtype;
}


/**
 *  获取设备总内存
 *
 *  @return
 */
- (NSUInteger)getTotalMemoryBytes
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, HW_PHYSMEM};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results/1024/1024;
}
/**
 *  获取当前应用所占内存
 *
 *  @return
 */
- (double)getCurrentApplicationUseMemory{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}
/**
 *  获取运营商
 *
 *  @return
 */
- (NSDictionary*)getMCCAndMNCInfo
{
    CTTelephonyNetworkInfo* ctt=[[CTTelephonyNetworkInfo alloc] init];
    return [NSDictionary dictionaryWithObjectsAndKeys:ctt.subscriberCellularProvider.mobileNetworkCode,@"MNC",
            ctt.subscriberCellularProvider.mobileCountryCode,@"MCC", nil ,nil];
}
/**
 *  获取运行中的进程
 *
 *  @return
 */
- (NSArray *)getRunningProcesses {
    
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess){
            
            if (process){
                free(process);
            }
            
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            
            if (nprocess){
                
                NSMutableArray * array = [[NSMutableArray alloc] init];
                
                for (int i = nprocess - 1; i >= 0; i--){
                    
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil ,nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil ,nil]];
//                    [processID release];
//                    [processName release];
//                    [array addObject:dict];
//                    [dict release];
                }
                
                free(process);
                return array;
            }
        }
    }
    
    
    return nil;
}
/**
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyGPRS          __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyEdge          __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyWCDMA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyHSDPA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyHSUPA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMA1x        __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORev0  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORevA  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORevB  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyeHRPD         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyLTE           __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 **/
/**
 *  获取网络类型(需要IOS7以后的版本)
 *
 *  @return
 */
- (NSString *)getNetworkType
{
    CTTelephonyNetworkInfo* info=[[CTTelephonyNetworkInfo alloc]init];
    return info.currentRadioAccessTechnology;
    
}



/**
 *  异常收集处理(可以发送网络请求,这里就直接写调用EMAIL了)
 *
 *  @param exception
 */
void UncaughtExceptionHandler(NSException *exception) {
    NSString *_email = @"xy2jianjia@163.com";
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *urlStr = [NSString stringWithFormat:@"mailto://%@?subject=bug报告&body=感谢您的配合!<br><br><br>"
                        "错误详情:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",
                        _email,name,reason,[arr componentsJoinedByString:@"<br>"]];
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}
/**
 *  调用
 */
-(void)writeACrashMessage
{
    // 括号内是c的函数名地址
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}


-(void) APCheckIfAppInstalled:(NSString *)bundleIdentifier
{
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSLog(@"apps: %@", [workspace performSelector:@selector(allApplications)]);
    
    // 是否已经启动过，yes已经启动过了，不再执行；NO，未启动，执行代码
    BOOL hasLauchApp = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasLauchApp"];
    if (!hasLauchApp) {
        
        NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
        [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSInteger timeInterval = 24*60*60;
        NSString *today = [[fmt stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0, 10)];
        NSString *tomorrow = [[fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]] substringWithRange:NSMakeRange(0, 10)];
        NSString *afterTomorrow = [[fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval*2]] substringWithRange:NSMakeRange(0, 10)];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@",today]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@",tomorrow]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@",afterTomorrow]];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLauchApp"];
        
    }
}

- (BOOL)isNeedToShowAd{
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSInteger timeInterval = 24*60*60;
    NSString *today = [[fmt stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0, 10)];
    NSString *tomorrow = [[fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]] substringWithRange:NSMakeRange(0, 10)];
    NSString *afterTomorrow = [[fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval*2]] substringWithRange:NSMakeRange(0, 10)];
    
    BOOL istoday = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",today]];
    BOOL istomorrow = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",tomorrow]];
    BOOL isafterTomorrow = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",afterTomorrow]];
    
    return istoday || istomorrow || isafterTomorrow;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
