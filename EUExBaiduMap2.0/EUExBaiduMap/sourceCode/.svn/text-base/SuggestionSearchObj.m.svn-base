//
//  SuggestionSearchObj.m
//  AppCan
//
//  Created by AppCan on 14-3-28.
//  Copyright (c) 2014年 AppCan. All rights reserved.
//

#import "SuggestionSearchObj.h"
#import "JSON.h"
#import "BMKTypes.h"
#import "EUExBaseDefine.h"
#import "EUExBase.h"

@implementation SuggestionSearchObj

+ (SuggestionSearchObj *)shareInstance {
    static SuggestionSearchObj * instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)suggestion_Search:(NSString *)searchStr withSearch:(BMKSearch *)_search withSelf:(EUExBase *)obj
{
    _search.delegate = self;
    baseObj = obj;
    BOOL flag = [_search suggestionSearch:searchStr];
    if (!flag) {
        //
    }
}

#pragma mark - BMKSearchDelegate

- (void)onGetSuggestionResult:(BMKSuggestionResult*)result errorCode:(int)error {
    
    if (error == BMKErrorOk) {
        NSMutableDictionary * resultDict = [NSMutableDictionary dictionaryWithCapacity:2];
        NSArray * cityList = result.cityList;
        NSArray * keyList = result.keyList;
        
        NSMutableArray * keyArray = [NSMutableArray arrayWithCapacity:2];
        for (int i = 0; i < [cityList count]; i ++) {
            NSMutableDictionary * mutableDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [mutableDict setObject:[cityList objectAtIndex:i] forKey:@"city"];
            [mutableDict setObject:[keyList objectAtIndex:i] forKey:@"key"];
            [keyArray addObject:mutableDict];
        }
        [resultDict setObject:keyArray forKey:@"list"];
        NSString * jsonStr = [NSString stringWithFormat:@"%@",[resultDict JSONFragment]];
        [baseObj jsSuccessWithName:@"uexBaiduMap.cbSuggestionSearch" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
    }else{
        [baseObj jsSuccessWithName:@"uexWidgetOne.cbError" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"result\":\"%d\"}",error]];
    }
}

@end
