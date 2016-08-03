//
//  NSString+StringRegular.m
//  DHDemos
//
//  Created by xy2 on 16/7/5.
//  Copyright © 2016年 xy2. All rights reserved.
//

#import "NSString+StringRegular.h"

@implementation NSString (StringRegular)


-(NSMutableArray *)substringByRegular:(NSString *)regular{
    
    NSString * reg=regular;
    
    NSRange r= [self rangeOfString:reg options:NSRegularExpressionSearch];
    
    NSMutableArray *arr=[NSMutableArray array];
    
    if (r.length != NSNotFound &&r.length != 0) {
        
        while (r.length != NSNotFound &&r.length != 0) {
            
            NSString* substr = [self substringWithRange:r];
            
            [arr addObject:substr];
            
            NSRange startr=NSMakeRange(r.location+r.length, [self length]-r.location-r.length);
            
            r=[self rangeOfString:reg options:NSRegularExpressionSearch range:startr];
            
        }
        
    }
    
    return arr;
    
}

@end
