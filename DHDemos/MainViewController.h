//
//  MainViewController.h
//  DHDemos
//
//  Created by xy2 on 16/8/3.
//  Copyright © 2016年 xy2. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@interface MainViewController : UIViewController

@end
