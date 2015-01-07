//
//  EUExBaiduMap.h
//  AppCan
//
//  Created by AppCan on 12-5-30.
//  Copyright (c) 2012年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExBase.h"
#import "BMapKit.h"
#import "MyAnnotationPoint.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "makeNextDelegate.h"
#import <QuartzCore/QuartzCore.h>
enum  search {
    busLineItem,
    otherItems,
};
enum  TypeBMKOverLayerView{
    line,
    other,
};
@class KYBubbleView;
@interface EUExBaiduMap : EUExBase <BMKMapViewDelegate,BMKSearchDelegate,BMKGeneralDelegate,makeNextDelegate> {
    BMKMapManager *mapManager;
    BMKMapView *bMapView;
    BOOL mapDidDisplay;
    BOOL userSetCenter;
    BMKSearch* _search;
    NSMutableDictionary *dataDict;
    CLLocationCoordinate2D currentLocationcc2d;
    KYBubbleView *bubbleView;
    BMKAnnotationView *selectedAV;
    BOOL isSystemBubble;
    NSString *poiId; //routeId;
    search searchType;//标识点击的是哪一类型
    NSString *bushLineCity;
    NSInteger geoOrReverse;
    
    //云图
    UIImageView *airplaneImageView;
    NSMutableDictionary *markDictionary;
    TypeBMKOverLayerView typeOverLayerView;
    NSTimer *updateMark; //更新mark的定时器
    NSTimer *updateCloudy; //更新云图
}
@property(nonatomic,retain)    BMKMapView *bMapView;
@property(nonatomic,retain)    NSMutableDictionary *dataDict;
@property(nonatomic,retain)    NSMutableArray *dataArray;//气泡悬浮窗口的地址，名称
@property(nonatomic,retain)  NSString *poiId;
@property(nonatomic,retain)  NSString *bushLineCity;
@property(nonatomic,retain)   NSMutableDictionary *markDictionary;
@end
