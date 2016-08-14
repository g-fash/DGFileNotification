//
//  NSString+NativePath.m
//  Example_MDS
//
//  Created by Дмитрий Голубев on 22/01/16.
//  Copyright © 2016 Golubev Dmitry. All rights reserved.
//

#import "NSString+NativePath.h"

@implementation NSString (NativePath)

-(NSString *)nativePath
{
    return [[NSURL fileURLWithPath:self] URLByResolvingSymlinksInPath].path.stringByRemovingPercentEncoding;;
}

@end
