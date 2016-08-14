//
//  GDFileSystemNotificationCenter.m
//  Example_MDS
//
//  Created by Golubev Dmitry on 17.01.16.
//  Copyright © 2016 Golubev Dmitry. All rights reserved.
//

#import "DGFileNotificationCenter.h"
#import "DGFileNotificationTask.h"
#import "NSString+NativePath.h"
#import <sys/stat.h>
#import <pthread.h>

NSString * const DGFilePath = @"kFilePath";

NSString * const DGNotification = @"kNotification";

NSString * const DGNotificationRename = @"kNotificationRename";
NSString * const DGNotificationDelete = @"kNotificationDelete";
NSString * const DGNotificationAdd = @"kNotificationlAdd";
NSString * const DGNotificationChangeSize = @"kNotificationChangeSize";
NSString * const DGNotificationWrite = @"kNotificationWrite";
NSString * const DGNotificationChangeAttribute = @"kNotificationChangeAttribute";

@interface DGFileNotificationCenter ()

@property (strong, nonatomic) NSMutableArray <DGFileNotificationTask *> *tasks;
@property (strong, nonatomic) NSMutableArray <dispatch_source_t> *source;
@property (strong, nonatomic) NSString *appDocument;

@end

static DGFileNotificationCenter *fileNotificatonCenter;

@implementation DGFileNotificationCenter

+ (instancetype) defaultCenter
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        fileNotificatonCenter = [[self alloc] init];
        fileNotificatonCenter.source = [NSMutableArray array];
        fileNotificatonCenter.tasks = [NSMutableArray array];
        fileNotificatonCenter.appDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    });
    return fileNotificatonCenter;
}

- (DGFileNotificationTask *) newTask
{
    DGFileNotificationTask *task = [DGFileNotificationTask new];
    
    pthread_mutex_t lock;
    pthread_mutex_lock(&lock);
    
    if (!fileNotificatonCenter.tasks.count) {
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSArray <NSString *> *files = [defaultManager subpathsOfDirectoryAtPath:fileNotificatonCenter.appDocument
                                                                          error:nil];
        files = [files arrayByAddingObject:@""];
        [fileNotificatonCenter addEventForPaths:files];
    }
    
    [fileNotificatonCenter.tasks addObject:task];
    pthread_mutex_unlock(&lock);
    
    return task;
}

-(void)sendNotification:(NSDictionary *)userInfo
{
    pthread_mutex_t lock;
    pthread_mutex_lock(&lock);
    
    for (DGFileNotificationTask *task in fileNotificatonCenter.tasks) {
        if (task.handler && task.running) {
            task.handler(userInfo);
        }
    }
    pthread_mutex_unlock(&lock);
}

-(dispatch_source_t)sourceFromPath:(NSString *)relativePath
{
    unsigned long mask  = DISPATCH_VNODE_DELETE
                        | DISPATCH_VNODE_WRITE
                        | DISPATCH_VNODE_EXTEND
                        | DISPATCH_VNODE_ATTRIB
                        | DISPATCH_VNODE_RENAME;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    NSString *pathAppDocument = [NSString stringWithFormat:@"%@/%@", fileNotificatonCenter.appDocument, relativePath];
    const char *cPathAppDocument = [pathAppDocument UTF8String];
    int fdes = open(cPathAppDocument , O_EVTONLY);
    return dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fdes, mask, queue);
}

-(void)addEventForPaths:(NSArray <NSString *> *)paths
{
    for (NSString *file in paths) {
        dispatch_source_t source = [fileNotificatonCenter sourceFromPath:file];
        
        dispatch_source_set_event_handler(source, ^{
            int fdes = (int)dispatch_source_get_handle(source);
            char filePath[PATH_MAX];
            
            if (fcntl(fdes, F_GETPATH, filePath) != -1){
                NSString *unixFilePath = [NSString stringWithUTF8String:filePath];
                unsigned long mask = dispatch_source_get_data(source);
                
                if (mask & DISPATCH_VNODE_RENAME) {
                    [fileNotificatonCenter sendNotification:(@{DGNotification : DGNotificationRename,
                                                    DGFilePath : unixFilePath.nativePath})];
                    
                } else if (mask & DISPATCH_VNODE_DELETE) {
                    dispatch_source_cancel(source);
                    close(fdes);
                    [fileNotificatonCenter sendNotification:@{DGNotification : DGNotificationDelete,
                                                   DGFilePath : unixFilePath.nativePath}];
                    [fileNotificatonCenter.source removeObject:source];
                    
                } else if(mask & DISPATCH_VNODE_WRITE) {
                    [fileNotificatonCenter updateSources];
                    [fileNotificatonCenter sendNotification:@{DGNotification : DGNotificationWrite,
                                                   DGFilePath : unixFilePath.nativePath}];
                    
                } else if(mask & DISPATCH_VNODE_EXTEND) {
                    [fileNotificatonCenter sendNotification:@{DGNotification : DGNotificationChangeSize,
                                                   DGFilePath : unixFilePath.nativePath}];
                    
                } else if (mask & DISPATCH_VNODE_ATTRIB){
                    [fileNotificatonCenter sendNotification:@{DGNotification : DGNotificationChangeAttribute,
                                                   DGFilePath : unixFilePath.nativePath}];
                }
            }
        });
        
        dispatch_resume(source);
        pthread_mutex_t lock;
        pthread_mutex_lock(&lock);
        
        [fileNotificatonCenter.source addObject:source];
        
        pthread_mutex_unlock(&lock);
    }
}

-(void)updateSources
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray <NSString *> *files = [fileManager subpathsOfDirectoryAtPath:fileNotificatonCenter.appDocument error:nil];
    
    for(NSString *file in files) {
        NSString *pathOfLocalFile = [NSString stringWithFormat:@"%@/%@", fileNotificatonCenter.appDocument, file];
        BOOL folderExists = NO;
        
        for (dispatch_source_t source in fileNotificatonCenter.source) {
            int fdes = (int)dispatch_source_get_handle(source);
            char cUnixFilePath[PATH_MAX];

            if (fcntl(fdes, F_GETPATH, cUnixFilePath) != -1){
                NSString *unixPath = [NSString stringWithUTF8String:cUnixFilePath];
                if ([unixPath.nativePath isEqualToString:pathOfLocalFile]){
                    folderExists = YES;
                    break;
                }

            }
        }
        if(!folderExists) {
            [fileNotificatonCenter addEventForPaths:@[file]];
            [fileNotificatonCenter sendNotification:@{DGNotification : DGNotificationAdd,
                                           DGFilePath:file}];
        }
    }
}

@end
