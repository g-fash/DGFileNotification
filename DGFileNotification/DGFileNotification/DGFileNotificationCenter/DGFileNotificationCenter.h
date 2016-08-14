//
//  GDFileSystemNotificationCenter.h
//  Example_MDS
//
//  Created by Golubev Dmitry on 17.01.16.
//  Copyright © 2016 Golubev Dmitry. All rights reserved.
//

@class DGFileNotificationTask;

#import <Foundation/Foundation.h>

@interface DGFileNotificationCenter : NSObject

FOUNDATION_EXPORT NSString * const DGFilePath;

FOUNDATION_EXPORT NSString * const DGNotification;

FOUNDATION_EXPORT NSString * const DGNotificationRename;
FOUNDATION_EXPORT NSString * const DGNotificationDelete;
FOUNDATION_EXPORT NSString * const DGNotificationAdd;
FOUNDATION_EXPORT NSString * const DGNotificationWrite;
FOUNDATION_EXPORT NSString * const DGNotificationChangeSize;
FOUNDATION_EXPORT NSString * const DGNotificationChangeAttribute;

+ (DGFileNotificationCenter *) defaultCenter;
- (DGFileNotificationTask   *) newTask;



@end
