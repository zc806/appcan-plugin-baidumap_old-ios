//
//  SuggestionSearchObj.h
//  AppCan
//
//  Created by AppCan on 14-3-28.
//  Copyright (c) 2014年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMKSearch.h"
@class EUExBase;
@interface SuggestionSearchObj : NSObject<BMKSearchDelegate> {
    EUExBase * baseObj;
}

+ (SuggestionSearchObj *)shareInstance;
- (void)suggestion_Search:(NSString *)searchStr withSearch:(BMKSearch *)_search withSelf:(EUExBase *)obj;

@end
