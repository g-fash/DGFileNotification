//
//  FileStoreTask.h
//  Example_MDS
//
//  Created by Дмитрий Голубев on 21/01/16.
//  Copyright © 2016 Golubev Dmitry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGFileNotificationTask : NSObject

typedef void (^DGFileNotificationHandler)(NSDictionary *userInfo);

- (void) runTasK:(BOOL)run handler:(DGFileNotificationHandler)handler;
- (void) removeFromCenter;

- (void) cancel;
- (void) resume;

@property (strong, nonatomic, readonly) DGFileNotificationHandler handler;
@property (assign, nonatomic, readonly) BOOL running;

@end
