//
//  EUExBaiduMap.m
//  AppCan
//
//  Created by AppCan on 12-5-30.
//  Copyright (c) 2012年 AppCan. All rights reserved.
//

#import "EUExBaiduMap.h"
#import "EUExBaseDefine.h"
#import "EUtility.h"
#import "JSON.h"
#import "SDWebImageManager.h"
#import "BMKAnnotationView+WebCache.h"
#import "NBMKPolylineView.h"
#import "NBMKPolygonView.h"
#import "NBMKCircleView.h"
#import "KYBubbleView.h"
#import "RouteAnnotation.h"
#import "UIImage+InternalMethod.h"
#import "NKBMKOverlayView.h"
#import "GTMBase64.h"
#import "SuggestionSearchObj.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

static CGFloat kTransitionDuration = 0.45f;
@implementation EUExBaiduMap
@synthesize  bMapView;
@synthesize dataDict;
@synthesize dataArray;
@synthesize poiId;
@synthesize bushLineCity;
@synthesize markDictionary;

- (id)initWithBrwView:(EBrowserView *) eInBrwView {
	if (self = [super initWithBrwView:eInBrwView]) {
        mapDidDisplay = NO;
    }
	return self;
}

-(void)transformScreen {
	//强制转屏
	UIInterfaceOrientation cOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if (cOrientation == UIInterfaceOrientationLandscapeLeft || (cOrientation == UIInterfaceOrientationLandscapeRight)) {
		if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
			[[UIDevice currentDevice] performSelector:@selector(setOrientation:)
										   withObject:(id)UIInterfaceOrientationPortrait];
		}
	}
}
- (void)open:(NSMutableArray *)inArguments {
    NSString * baiduKey = [inArguments objectAtIndex:0];
    if (baiduKey) {
        mapManager  = [[BMKMapManager alloc] init];
        BOOL ret = [mapManager start:baiduKey generalDelegate:self];
        if (!ret) {
            return;
        }
    } else {
        return;
    }
    if (mapDidDisplay) {
        return;
    }
    int inX = [[inArguments objectAtIndex:1] intValue];
    int inY = [[inArguments objectAtIndex:2] intValue];
    int inWidth = [[inArguments objectAtIndex:3] intValue];
    int inHeight  = [[inArguments objectAtIndex:4] intValue];
    BMKMapView *mView = [[BMKMapView alloc] initWithFrame:CGRectMake(inX, inY, inWidth, inHeight)];
    [mView setDelegate:self];
    [mView setZoomLevel:15];
    [mView setShowsUserLocation:YES];
    _search = [[BMKSearch alloc]init];
    _search.delegate = self;
    if ([inArguments count] == 7) {
        userSetCenter = YES;
        float  longit = [[inArguments objectAtIndex:5] floatValue];
        float  lat =  [[inArguments objectAtIndex:6] floatValue];
        CLLocationCoordinate2D cc2d;
        cc2d.longitude = longit;
        cc2d.latitude = lat;
        [mView setCenterCoordinate:cc2d animated:YES];
    } else {
        userSetCenter = NO;
    }
    self.bMapView = mView;
    [mView release];
    
    [EUtility brwView:meBrwView addSubview:bMapView];
    mapDidDisplay = YES;
    UIInterfaceOrientation cOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if ((cOrientation == UIInterfaceOrientationLandscapeLeft) || (cOrientation == UIInterfaceOrientationLandscapeRight)) {
        [self transformScreen];
	}
    [EUtility brwView:meBrwView forbidRotate:YES];
}
-(void)addMark:(NSMutableArray *)inArguments {
    NSString * inJson = [inArguments objectAtIndex:0];
    NSDictionary * markDict = [inJson JSONValue];
    if (markDict) {
        NSArray * marks = [markDict valueForKey:@"markInfo"];
        NSString * isCallShowOut = [markDict valueForKey:@"canShowCallout"];
        if ([isCallShowOut isEqualToString:@"0"] || isCallShowOut == nil) {
            isSystemBubble = YES;
        }else{
            isSystemBubble = NO;
        }
        if (marks) {
            for (NSDictionary * dict in marks) {
                float longit = [[dict objectForKey:@"longitude"]  floatValue];
                float lat = [[dict objectForKey:@"latitude"] floatValue];
                MyAnnotationPoint *aPoint = [[MyAnnotationPoint alloc] init];
                [aPoint setTitle:[dict objectForKey:@"title"]];
                [aPoint setSubtitle:[dict objectForKey:@"message"]];
                CLLocationCoordinate2D cc2d;
                cc2d.longitude = longit;
                cc2d.latitude = lat;
                aPoint.coordinate = cc2d;
                aPoint.pointId = [[dict objectForKey:@"id"] intValue];
                aPoint.annotationImageUrl = [dict objectForKey:@"imageUrl"];
                //imagesize
                float imgW = [[dict objectForKey:@"imageWidth"] floatValue];
                float imgH = [[dict objectForKey:@"imageHeight"] floatValue];
                aPoint.imgSize = CGSizeMake(imgW, imgH);
                [bMapView addAnnotation:aPoint];
                [aPoint release];
            }
            if (!dataArray) {
                self.dataArray =[NSMutableArray arrayWithCapacity:2];
            }
            [self.dataArray addObjectsFromArray:marks];
        }
    }
}

int j = 0;

-(void)updateMarkMethd:(NSTimer *)t {
    NSDictionary * updateDict = t.userInfo;
    NSString * stringId = [NSString stringWithFormat:@"%@",[updateDict objectForKey:@"id"]];
    NSString * imageUrl = [NSString stringWithFormat:@"%@",[updateDict objectForKey:@"imageUrl"]];
    NSString * imageWidth = [NSString stringWithFormat:@"%@",[updateDict objectForKey:@"imageWidth"]];
    NSString * imageHeight = [NSString stringWithFormat:@"%@",[updateDict objectForKey:@"imageHeight"]];
    NSString * title = [NSString stringWithFormat:@"%@",[updateDict objectForKey:@"title"]];
    NSArray * propertyArray = [NSArray arrayWithArray:[updateDict objectForKey:@"property"]];
    NSDictionary * lalonDict = [propertyArray objectAtIndex:0];
    int len = (int)[propertyArray count];
    int ind = j % len;
    j ++;
    if (bMapView) {
        NSArray * annotations = [NSArray arrayWithArray:bMapView.annotations];
        if (annotations && [annotations count] > 0) {
            for (MyAnnotationPoint * mark in annotations) {
                if (mark.pointId == [stringId intValue]) {
                    NSMutableArray * array = [NSMutableArray arrayWithCapacity:1];
                    [array addObject:stringId];
                    [self clearMarks:array];
                    NSMutableArray * markArray = [NSMutableArray arrayWithCapacity:1];
                    
                    NSMutableDictionary * markDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    NSMutableArray * markPropertyArray = [NSMutableArray arrayWithCapacity:1];
                    NSMutableDictionary * markPropertyDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    
                    [markPropertyDict setObject:stringId forKey:@"id"];
                    [markPropertyDict setObject:imageUrl forKey:@"imageUrl"];
                    [markPropertyDict setObject:imageWidth forKey:@"imageWidth"];
                    [markPropertyDict setObject:imageHeight forKey:@"imageHeight"];
                    [markPropertyDict setObject:title forKey:@"title"];
                    NSString * longitude = [NSString stringWithFormat:@"%@",[[propertyArray objectAtIndex:ind] objectForKey:@"longitude"]];
                    NSString * latitude = [NSString stringWithFormat:@"%@",[[propertyArray objectAtIndex:ind] objectForKey:@"latitude"]];
                    NSString * connectStr =[NSString stringWithFormat:@"经度:%@纬度:%@",longitude,latitude];
                    [markPropertyDict setObject:connectStr forKey:@"message"];
                    [markPropertyDict setObject:longitude forKey:@"longitude"];
                    [markPropertyDict setObject:latitude forKey:@"latitude"];
                    [markPropertyArray addObject:markPropertyDict];
                    [markDict setObject:markPropertyArray forKey:@"markInfo"];
                    NSString * jsonStr = [markDict JSONRepresentation];
                    [markArray addObject:jsonStr];
                    [self addMark:markArray];
                }
            }
        } else {
            [bMapView removeAnnotations:annotations];
        }
    }
    if (j == len + 1) {
        j = 0;
    }
}
- (void)updateMark:(NSMutableArray *)array {
    NSString *inJson = [array objectAtIndex:0];
    NSDictionary *updateMarkDict = [inJson JSONValue];
    NSInteger seconds = [[updateMarkDict objectForKey:@"timer"] integerValue];
    updateMark = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(updateMarkMethd:) userInfo:updateMarkDict repeats:YES];
}

- (void)getCurrentLocation:(NSMutableArray *)inArguments {
    if (bMapView.userLocation) {
        float longit = bMapView.userLocation.coordinate.longitude;
        float lat = bMapView.userLocation.coordinate.latitude;
        [super jsSuccessWithName:@"uexBaiduMap.cbGetCurrentLocation" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"longitude\":\"%f\",\"latitude\":\"%f\"}",longit,lat]];
    }
}
#pragma mark-
#pragma BMKSearchDelegate
/**
 *返回POI搜索结果
 *@param poiResultList 搜索结果列表，成员类型为BMKPoiResult
 *@param type 返回结果类型： BMKTypePoiList,BMKTypeAreaPoiList,BMKAreaMultiPoiList
 *@param error 错误号，@see BMKErrorCode
 */
- (void)onGetPoiResult:(NSArray*)poiResultList searchType:(int)type errorCode:(int)error {
    if (error == BMKErrorOk) {
		BMKPoiResult * result = [poiResultList objectAtIndex:0];
        if (searchType == busLineItem) {
            BMKPoiInfo* poi;
            for (int i = 0; i < result.poiInfoList.count; i ++) {
                poi = [result.poiInfoList objectAtIndex:i];
                if (poi.epoitype == 2) {
                    break;
                }
            }
            //开始bueline详情搜索
            if(poi != nil && poi.epoitype == 2 ) {
                BOOL flag = [_search busLineSearch:self.bushLineCity withKey:poi.uid];
                if (!flag) {
                }
            }
        } else {
            NSString *totalPoiNum = [NSString stringWithFormat:@"%d",result.totalPoiNum];///本次POI搜索的总结果数
            NSString *currPoiNum = [NSString stringWithFormat:@"%d",result.currPoiNum];///当前页的POI结果数
            NSString *pageNum = [NSString stringWithFormat:@"%d",result.pageNum];///本次POI搜索的总页数
            NSString *pageIndex = [NSString stringWithFormat:@"%d",result.pageIndex];///当前页的索引
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:1];
            NSMutableArray *dictArray = [NSMutableArray arrayWithCapacity:2];
            for (int i = 0; i < result.poiInfoList.count; i++) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
                BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
                NSString *longitude = [NSString stringWithFormat:@"%lf",poi.pt.longitude];
                NSString *latitude = [NSString stringWithFormat:@"%lf",poi.pt.latitude];
                NSString *name = [NSString stringWithFormat:@"%@",poi.name];
                NSString *uid = [NSString stringWithFormat:@"%@",poi.uid];
                NSString *address = [NSString stringWithFormat:@"%@",poi.address];
                NSString *city = [NSString stringWithFormat:@"%@",poi.city];
                NSString *phone = [NSString stringWithFormat:@"%@",poi.phone];
                NSString *postcode = [NSString stringWithFormat:@"%@",poi.postcode];
                [dict setObject:longitude forKey:@"longitude"];
                [dict setObject:latitude forKey:@"latitude"];
                [dict setObject:name forKey:@"name"];
                [dict setObject:uid forKey:@"uid"];
                [dict setObject:address forKey:@"address"];
                [dict setObject:city forKey:@"city"];
                [dict setObject:phone forKey:@"phone"];
                [dict setObject:postcode forKey:@"postCode"];
                NSString *strType = [NSString stringWithFormat:@"%d",poi.epoitype];
                [dict setObject:strType forKey:@"ePoiType"];
                
                [dictArray addObject:dict];
            }
            [resultDict setObject:totalPoiNum forKey:@"totalPoiNum"];
            [resultDict setObject:currPoiNum forKey:@"currPoiNum"];
            [resultDict setObject:pageNum forKey:@"pageNum"];
            [resultDict setObject:pageIndex forKey:@"pageIndex"];
            [resultDict setObject:dictArray forKey:@"list"];
            NSString * jsonStr = [NSString stringWithFormat:@"%@",[resultDict JSONFragment]];
            if (type == BMKTypePoiList) {
                [super jsSuccessWithName:@"uexBaiduMap.cbPoiSearchInCity" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
            } else if (type == BMKTypeAreaPoiList) {
                [super jsSuccessWithName:@"uexBaiduMap.cbPoiSearchArea" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
            } else if (type == BMKTypeAreaMultiPoiList) {
                [super jsSuccessWithName:@"uexBaiduMap.cbPoiMultiSearchArea" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
            }
        }
	} else {//搜索结果未找到
        NSString *strError = [NSString stringWithFormat:@"{\"error\":\"%d\"}",error];
        [super jsSuccessWithName:@"uexWidgetOne.cbError" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:strError];
    }
}

/**
 *返回公交搜索结果
 *@param result 搜索结果
 *@param error 错误号，@see BMKErrorCode
 */
- (void)onGetTransitRouteResult:(BMKPlanResult*)result errorCode:(int)error
{
	if (error == BMKErrorOk) {
		BMKTransitRoutePlan * plan = (BMKTransitRoutePlan *)[result.plans objectAtIndex:0];
		RouteAnnotation * item = [[RouteAnnotation alloc]init];
		item.coordinate = plan.startPt;
		item.title = @"起点";
		item.type = 0;
        item.poiId = self.poiId;
		[bMapView addAnnotation:item];
		[item release];
		item = [[RouteAnnotation alloc]init];
		item.coordinate = plan.endPt;
		item.type = 1;
		item.title = @"终点";
        item.poiId = self.poiId;
		[bMapView addAnnotation:item];
		[item release];
		
		int size = (int)[plan.lines count];
		int index = 0;
		for (int i = 0; i < size; i++) {
			BMKRoute* route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j ++) {
				int len = [route getPointsNum:j];
				index += len;
			}
			BMKLine * line = [plan.lines objectAtIndex:i];
			index += line.pointsCount;
			if (i == size - 1) {
				i ++;
				route = [plan.routes objectAtIndex:i];
				for (int j = 0; j < route.pointsCount; j ++) {
					int len = [route getPointsNum:j];
					index += len;
				}
				break;
			}
		}
		
		BMKMapPoint* points = new BMKMapPoint[index];
		index = 0;
		
		for (int i = 0; i < size; i ++) {
			BMKRoute * route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j ++) {
				int len = [route getPointsNum:j];
				BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
				memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
				index += len;
			}
			BMKLine * line = [plan.lines objectAtIndex:i];
			memcpy(points + index, line.points, line.pointsCount * sizeof(BMKMapPoint));
			index += line.pointsCount;
			
			item = [[RouteAnnotation alloc]init];
			item.coordinate = line.getOnStopPoiInfo.pt;
			item.title = line.tip;
			if (line.type == 0) {
				item.type = 2;
			} else {
				item.type = 3;
			}
			[bMapView addAnnotation:item];
			[item release];
			route = [plan.routes objectAtIndex:i+1];
			item = [[RouteAnnotation alloc]init];
			item.coordinate = line.getOffStopPoiInfo.pt;
			item.title = route.tip;
			if (line.type == 0) {
				item.type = 2;
			} else {
				item.type = 3;
			}
			[bMapView addAnnotation:item];
			[item release];
			if (i == size - 1) {
				i ++;
				route = [plan.routes objectAtIndex:i];
				for (int j = 0; j < route.pointsCount; j ++) {
					int len = [route getPointsNum:j];
					BMKMapPoint * pointArray = (BMKMapPoint *)[route getPoints:j];
					memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
					index += len;
				}
				break;
			}
		}
		
		BMKPolyline * polyLine = [BMKPolyline polylineWithPoints:points count:index];
		[bMapView addOverlay:polyLine];
		delete []points;
        [super jsSuccessWithName:@"uexBaiduMap.cbShowRoutePlan" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"id\":\"%@\"}",item.poiId]];
	} else {
        [super jsSuccessWithName:@"uexWidgetOne.cbError" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"result\":\"%d\"}",error]];
    }
}
/**
 *返回驾乘搜索结果
 *@param result 搜索结果
 *@param error 错误号，@see BMKErrorCode
 */
- (void)onGetDrivingRouteResult:(BMKPlanResult*)result errorCode:(int)error {
	if (error == BMKErrorOk) {
		BMKRoutePlan* plan = (BMKRoutePlan*)[result.plans objectAtIndex:0];
		RouteAnnotation* item = [[RouteAnnotation alloc]init];
		item.coordinate = result.startNode.pt;
		item.title = @"起点";
		item.type = 0;
		[bMapView addAnnotation:item];
		[item release];
		
		int index = 0;
		int size = (int)[plan.routes count];
		for (int i = 0; i < 1; i++) {
			BMKRoute * route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j ++) {
				int len = [route getPointsNum:j];
				index += len;
			}
		}
		
		BMKMapPoint * points = new BMKMapPoint[index];
		index = 0;
		
		for (int i = 0; i < 1; i ++) {
			BMKRoute * route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j ++) {
				int len = [route getPointsNum:j];
				BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
				memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
				index += len;
			}
			size = (int)route.steps.count;
			for (int j = 0; j < size; j ++) {
				BMKStep * step = [route.steps objectAtIndex:j];
				item = [[RouteAnnotation alloc]init];
				item.coordinate = step.pt;
				item.title = step.content;
				item.degree = step.degree * 30;
				item.type = 4;
				[bMapView addAnnotation:item];
				[item release];
			}
			
		}
		
		item = [[RouteAnnotation alloc]init];
		item.coordinate = result.endNode.pt;
		item.type = 1;
		item.title = @"终点";
		[bMapView addAnnotation:item];
		[item release];
		BMKPolyline * polyLine = [BMKPolyline polylineWithPoints:points count:index];
		[bMapView addOverlay:polyLine];
		delete []points;
        [super jsSuccessWithName:@"uexBaiduMap.cbShowRoutePlan" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"id\":\"%@\"}",item.poiId]];
	}else{
        [super jsSuccessWithName:@"uexWidgetOne.cbError" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"result\":\"%d\"}",error]];
    }
}

/**
 *返回步行搜索结果
 *@param result 搜索结果
 *@param error 错误号，@see BMKErrorCode
 */
- (void)onGetWalkingRouteResult:(BMKPlanResult*)result errorCode:(int)error{
	if (error == BMKErrorOk) {
		BMKRoutePlan* plan = (BMKRoutePlan*)[result.plans objectAtIndex:0];
        
		RouteAnnotation* item = [[RouteAnnotation alloc]init];
		item.coordinate = result.startNode.pt;
		item.title = @"起点";
		item.type = 0;
		[bMapView addAnnotation:item];
		[item release];
		
		int index = 0;
		int size = (int)[plan.routes count];
		for (int i = 0; i < 1; i ++) {
			BMKRoute* route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j ++) {
				int len = [route getPointsNum:j];
				index += len;
			}
		}
		
		BMKMapPoint * points = new BMKMapPoint[index];
		index = 0;
		
		for (int i = 0; i < 1; i ++) {
			BMKRoute * route = [plan.routes objectAtIndex:i];
			for (int j = 0; j < route.pointsCount; j ++) {
				int len = [route getPointsNum:j];
				BMKMapPoint * pointArray = (BMKMapPoint*)[route getPoints:j];
				memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
				index += len;
			}
			size = (int)route.steps.count;
			for (int j = 0; j < size; j ++) {
				BMKStep * step = [route.steps objectAtIndex:j];
				item = [[RouteAnnotation alloc]init];
				item.coordinate = step.pt;
				item.title = step.content;
				item.degree = step.degree * 30;
				item.type = 4;
				[bMapView addAnnotation:item];
				[item release];
			}
		}
		
		item = [[RouteAnnotation alloc]init];
		item.coordinate = result.endNode.pt;
		item.type = 1;
		item.title = @"终点";
		[bMapView addAnnotation:item];
		[item release];
		BMKPolyline * polyLine = [BMKPolyline polylineWithPoints:points count:index];
		[bMapView addOverlay:polyLine];
		delete []points;
        [super jsSuccessWithName:@"uexBaiduMap.cbShowRoutePlan" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"id\":\"%@\"}",self.poiId]];
	}else{
        [super jsSuccessWithName:@"uexWidgetOne.cbError" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"result\":\"%d\"}",error]];
    }
}

/**
 *返回地址信息搜索结果
 *@param result 搜索结果
 *@param error 错误号，@see BMKErrorCode
 */
- (void)onGetAddrResult:(BMKAddrInfo*)result errorCode:(int)error{
    if (error == BMKErrorOk) {
        if (geoOrReverse == 0) {
            NSString * longitude = [NSString stringWithFormat:@"%f",result.geoPt.longitude];
            NSString * latitude = [NSString stringWithFormat:@"%f",result.geoPt.latitude];
            NSMutableDictionary * resultDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [resultDict setObject:longitude forKey:@"longitude"];
            [resultDict setObject:latitude forKey:@"latitude"];
            NSString * jsonStr = [NSString stringWithFormat:@"%@",[resultDict JSONFragment]];
            [super jsSuccessWithName:@"uexBaiduMap.cbGeocode" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
        }else{
            BMKGeocoderAddressComponent *addressCompent = result.addressComponent;
            
            NSString *longitude = [NSString stringWithFormat:@"%f",result.geoPt.longitude];
            NSString *latitude = [NSString stringWithFormat:@"%f",result.geoPt.latitude];
            NSString *province = [NSString stringWithFormat:@"%@",addressCompent.province];
            NSString *city = [NSString stringWithFormat:@"%@",addressCompent.city];
            NSString *district = [NSString stringWithFormat:@"%@",addressCompent.district];
            NSString *streetName = [NSString stringWithFormat:@"%@",addressCompent.streetName];
            NSString *streetNumber = [NSString stringWithFormat:@"%@",addressCompent.streetNumber];
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [resultDict setObject:result.strAddr forKey:@"Address"];
            [resultDict setObject:longitude forKey:@"longitude"];
            [resultDict setObject:latitude forKey:@"latitude"];
            [resultDict setObject:province forKey:@"province"];
            [resultDict setObject:city forKey:@"city"];
            [resultDict setObject:district forKey:@"district"];
            [resultDict setObject:streetName forKey:@"streetName"];
            [resultDict setObject:streetNumber forKey:@"streetNumber"];
            NSString *jsonStr = [NSString stringWithFormat:@"%@",[resultDict JSONFragment]];
            [super jsSuccessWithName:@"uexBaiduMap.cbReverseGeocode" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
        }
    }else{
        [super jsSuccessWithName:@"uexWidgetOne.cbError" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"result\":\"%d\"}",error]];
    }
}

/**2
 *返回suggestion搜索结果
 *@param result 搜索结果
 *@param error 错误号，@see BMKErrorCode
 */

/*
 - (void)onGetSuggestionResult:(BMKSuggestionResult*)result errorCode:(int)error
 {
 NSLog(@"onGetSuggestionResult------->error:%d",error);
 if (error == BMKErrorOk) {
 NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:2];
 NSArray *cityList = result.cityList;
 NSArray *keyList = result.keyList;
 //    if (result) {
 //        cityList =result.cityList;
 //        keyList =result.keyList;
 //        [resultDict setObject:cityList forKey:@"cityList"];
 //        [resultDict setObject:keyList forKey:@"keyList"];
 //    }else{
 //        cityList = [NSArray array];
 //        keyList = [NSArray array];
 //        [resultDict setObject:cityList forKey:@"cityList"];
 //        [resultDict setObject:keyList forKey:@"keyList"];
 //    }
 NSMutableArray *keyArray = [NSMutableArray arrayWithCapacity:2];
 for (int i=0; i<[cityList count]; i++) {
 NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithCapacity:2];
 [mutableDict setObject:[cityList objectAtIndex:i] forKey:@"city"];
 [mutableDict setObject:[keyList objectAtIndex:i] forKey:@"key"];
 [keyArray addObject:mutableDict];
 }
 [resultDict setObject:keyArray forKey:@"list"];
 NSString *jsonStr = [NSString stringWithFormat:@"%@",[resultDict JSONFragment]];
 NSLog(@"onGetSuggestionResult------>jsonStr:%@",jsonStr);
 [super jsSuccessWithName:@"uexBaiduMap.cbSuggestionSearch" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
 }else{
 [super jsSuccessWithName:@"uexWidgetOne.cbError" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"result\":\"%d\"}",error]];
 }
 }
 */

/**
 *返回busdetail搜索结果
 *@param busLineResult 搜索结果
 *@param error 错误号，@see BMKErrorCode
 */
- (void)onGetBusDetailResult:(BMKBusLineResult*)busLineResult errorCode:(int)error
{
    if (error == BMKErrorOk) {
        //起点
        RouteAnnotation* item = [[RouteAnnotation alloc]init];
        
        item.coordinate = busLineResult.mBusRoute.startPt;
        BMKStep * tempstep = [busLineResult.mBusRoute.steps objectAtIndex:0];
        
        item.title = tempstep.content;
        
        item.type = 0;
        [bMapView addAnnotation:item];
        [item release];
        
        //终点
        item = [[RouteAnnotation alloc]init];
        item.coordinate = busLineResult.mBusRoute.endPt;
        item.type = 1;
        item.poiId = self.poiId;
        tempstep = [busLineResult.mBusRoute.steps objectAtIndex:busLineResult.mBusRoute.steps.count-1];
        item.title = tempstep.content;
        [bMapView addAnnotation:item];
        [item release];
        
        NSMutableArray *stepArray = [NSMutableArray arrayWithCapacity:2];
        NSMutableDictionary *stepDict = [NSMutableDictionary dictionaryWithCapacity:2];
        //站点信息
        int size = 0;
        size = (int)busLineResult.mBusRoute.steps.count;
        for (int j = 0; j < size; j ++) {
            BMKStep * step = [busLineResult.mBusRoute.steps objectAtIndex:j];
            item = [[RouteAnnotation alloc]init];
            item.coordinate = step.pt;
            item.title = step.content;
            item.poiId =self.poiId;
            item.degree = step.degree * 30;
            item.type = 2;
            [bMapView addAnnotation:item];
            [item release];
            NSString * longitude = [NSString stringWithFormat:@"%f",step.pt.longitude];
            NSString * latitude = [NSString stringWithFormat:@"%f",step.pt.latitude];
            [stepDict setObject:longitude forKey:@"longitude"];
            [stepDict setObject:latitude forKey:@"latitude"];
            [stepDict setObject:step.content forKey:@"title"];
            [stepArray addObject:stepDict];
        }
        //路段信息
        int index = 0;
		
		for (int i = 0; i < 1; i++) {
			for (int j = 0; j < busLineResult.mBusRoute.pointsCount; j++) {
				int len = [busLineResult.mBusRoute getPointsNum:j];
				index += len;
			}
		}
		//BMKMapPoint* points = new BMKMapPoint[index];
        
		index = 0;
		for (int i = 0; i < 1; i++) {
			for (int j = 0; j < busLineResult.mBusRoute.pointsCount; j++) {
				int len = [busLineResult.mBusRoute getPointsNum:j];
				index += len;
			}
        }
        //直角坐标划线
        BMKMapPoint * temppoints = new BMKMapPoint[index];
        index = 0;
		for (int i = 0; i < 1; i++) {
			for (int j = 0; j < busLineResult.mBusRoute.pointsCount; j++) {
				int len = [busLineResult.mBusRoute getPointsNum:j];
                for(int k=0;k<len;k++)
                {
                    BMKMapPoint pointarray;
                    pointarray.x = [busLineResult.mBusRoute getPoints:j][k].x;
                    pointarray.y = [busLineResult.mBusRoute getPoints:j][k].y;
                    temppoints[k] = pointarray;
                }
                //memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
				index += len;
			}
        }
        
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:index];
		[bMapView addOverlay:polyLine];
		delete []temppoints;
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [resultDict setObject:[busLineResult mBusName] forKey:@"busName"];
        [resultDict setObject:busLineResult.mCompany forKey:@"company"];
        [resultDict setObject:busLineResult.mStartTime forKey:@"startTime"];
        [resultDict setObject:busLineResult.mEndTime forKey:@"endTime"];
        [resultDict setObject:stepArray forKey:@"stepInfo"];
        
        NSString *errorCode = [NSString stringWithFormat:@"%d",error];
        [resultDict setObject:errorCode forKey:@"result"];
        NSString *jsonStr = [NSString stringWithFormat:@"%@",[resultDict JSONFragment]];
        [super jsSuccessWithName:@"uexBaiduMap.cbBusLineSearch" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
    }else{
        [super jsSuccessWithName:@"uexWidgetOne.cbError" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"result\":\"%d\"}",error]];
    }
}

#pragma mark-
#pragma BMKGeneralDelegate
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError{
    NSString *jsstr = [NSString stringWithFormat:@"if(uexBaiduMap.onNetworkError!=null){uexBaiduMap.onNetworkError();}"];
    [meBrwView stringByEvaluatingJavaScriptFromString:jsstr];
}
/**
 *返回授权验证错误
 *@param iError 错误号 : BMKErrorPermissionCheckFailure 验证失败
 */
- (void)onGetPermissionState:(int)iError{
    NSString *jsstr2 = [NSString stringWithFormat:@"if(uexBaiduMap.onPermissionDenied!=null){uexBaiduMap.onPermissionDenied();}"];
    [meBrwView stringByEvaluatingJavaScriptFromString:jsstr2];
}
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    NSString *jsstr = [NSString stringWithFormat:@"if(uexBaiduMap.onMapMove!=null){uexBaiduMap.onMapMove(0);}"];
    [meBrwView stringByEvaluatingJavaScriptFromString:jsstr];
    NSString *jsstr2 = [NSString stringWithFormat:@"if(uexBaiduMap.onMapDrag!=null){uexBaiduMap.onMapDrag(0);}"];
    [meBrwView stringByEvaluatingJavaScriptFromString:jsstr2];
    //显示气泡
    if (selectedAV) {
        //        [self showBubble:YES];
        [self changeBubblePosition];
    }else{
        selectedAV = nil;
        //        [self showBubble:NO];
    }
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSString *jsstr = [NSString stringWithFormat:@"if(uexBaiduMap.onMapMoveEnd!=null){uexBaiduMap.onMapMoveEnd(2);}"];
    [meBrwView stringByEvaluatingJavaScriptFromString:jsstr];
    NSString *jsstr2 = [NSString stringWithFormat:@"if(uexBaiduMap.onMapDrag!=null){uexBaiduMap.onMapDrag(2);}"];
    [meBrwView stringByEvaluatingJavaScriptFromString:jsstr2];
    //显示气泡
    if (selectedAV) {
        [self changeBubblePosition];
    }else{
        selectedAV = nil;
    }
}
- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation{
    if (!userSetCenter) {
        float  longit =userLocation.location.coordinate.longitude;
        float  lat = userLocation.location.coordinate.latitude;
        currentLocationcc2d.longitude = longit;
        currentLocationcc2d.latitude = lat;
        [mapView setCenterCoordinate:currentLocationcc2d animated:YES];
        userSetCenter = YES;
    }else{
        float  longit =userLocation.location.coordinate.longitude;
        float  lat = userLocation.location.coordinate.latitude;
        currentLocationcc2d.longitude = longit;
        currentLocationcc2d.latitude = lat;
    }
    
}
-(void)mapViewDidStopLocatingUser:(BMKMapView *)mapView{
    
}

-(void)showBubbleView1:(NSMutableArray *)array{
    NSString *stringId = [array objectAtIndex:0];
    NSString *stringUrl =[self absPath:[array objectAtIndex:1]];
    NSString *stringTitle = [array objectAtIndex:2];
    NSString *stringContent = [array objectAtIndex:3];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [resultDict setObject:stringId forKey:@"id"];
    [resultDict setObject:stringUrl forKey:@"ImageUrl"];
    [resultDict setObject:stringTitle forKey:@"title"];
    [resultDict setObject:stringContent forKey:@"conctent"];
    //气泡
    if (!bubbleView) {
        bubbleView = [[KYBubbleView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        [bubbleView setStyle1];
    }
    [bubbleView setDelgate:self];
    bubbleView.hidden = YES;
    [self setMapAnimationProperty:resultDict];
}
-(void)showBubbleView2:(NSMutableArray *)array{
    //    [self canShowCallout];
    NSString *stringId = [array objectAtIndex:0];
    NSString *stringTitle = [array objectAtIndex:1];
    NSString *stringContent = [array objectAtIndex:2];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [resultDict setObject:stringId forKey:@"id"];
    [resultDict setObject:stringTitle forKey:@"title"];
    [resultDict setObject:stringContent forKey:@"conctent"];
    //气泡
    if (!bubbleView) {
        bubbleView = [[KYBubbleView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        [bubbleView setStyle2];
    }
    [bubbleView setDelgate:self];
    bubbleView.hidden = YES;
    [self setMapAnimationProperty:resultDict];
}
-(void)showBubbleView3:(NSMutableArray *)array{
    //    [self canShowCallout];
    NSString *stringId = [array objectAtIndex:0];
    NSString *stringTitle = [array objectAtIndex:1];
    NSString *stringContent = [array objectAtIndex:2];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [resultDict setObject:stringId forKey:@"id"];
    [resultDict setObject:stringTitle forKey:@"title"];
    [resultDict setObject:stringContent forKey:@"conctent"];
    //气泡
    if (!bubbleView) {
        bubbleView = [[KYBubbleView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        [bubbleView setStyle3];
    }
    [bubbleView setDelgate:self];
    bubbleView.hidden = YES;
    [self setMapAnimationProperty:resultDict];
}
- (NSString*)getMyBundlePath1:(NSString *)filename
{
	
	NSBundle * libBundle = MYBUNDLE ;
	if ( libBundle && filename ){
		NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
		return s;
	}
	return nil ;
}
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
	BMKAnnotationView* view = nil;
	switch (routeAnnotation.type) {
		case 0:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 1:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 2:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 3:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 4:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
			
		}
			break;
		default:
			break;
	}
	return view;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MyAnnotationPoint class]]) {
        int pointId = (int)[(MyAnnotationPoint *)annotation pointId];
        NSString *imageUrl = [(MyAnnotationPoint *)annotation annotationImageUrl];
        NSString *absUrl = nil;
        if (imageUrl==nil||[imageUrl isEqualToString:@""]) {
            
        }else{
            absUrl = [self absPath:imageUrl];
        }
		BMKPinAnnotationView *newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%d",pointId]] autorelease];
		newAnnotation.draggable = NO;
        [newAnnotation setBackgroundColor:[UIColor clearColor]];
        if (isSystemBubble) {
            newAnnotation.canShowCallout = YES;
        }else{
            newAnnotation.canShowCallout = NO;
        }
        newAnnotation.calloutOffset = CGPointMake(0, 25);
        if ([absUrl hasPrefix:@"http"]) {
            [newAnnotation setImageWithURL:[NSURL URLWithString:absUrl]];
        }else {
            if (imageUrl==nil||[imageUrl isEqualToString:@""]) {
                newAnnotation.image = nil;
            }else{
                UIImage   *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:absUrl]];
                CGSize size = ((MyAnnotationPoint *)annotation).imgSize;
                UIGraphicsBeginImageContext(size);
                CGRect thumbnailRect = CGRectMake(0, 0, size.width, size.height);
                [image drawInRect:thumbnailRect];
                UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                newAnnotation.image = newImage;
            }
        }
        if (bubbleView.superview == nil) {
            selectedAV = newAnnotation;
            //bubbleView加在BMKAnnotationView的superview(UIScrollView)上,且令zPosition为1
            [newAnnotation.superview addSubview:bubbleView];
            bubbleView.layer.zPosition = 1;
            bubbleView.infoDict = [self.dataArray objectAtIndex:0];
        }
		return newAnnotation;
	}
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
		return [self getRouteAnnotationView:mapView viewForAnnotation:(RouteAnnotation*)annotation];
	}
	return nil;
}

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;{
    //
}
-(void)setMapAnimationProperty:(NSDictionary *)dict{
    [self showBubble:NO];
    //    selectedAV = annotationView;
    if (bubbleView.superview == nil) {
        //bubbleView加在BMKAnnotationView的superview(UIScrollView)上,且令zPosition为1
        [selectedAV.superview addSubview:bubbleView];
        bubbleView.layer.zPosition = 1;
    }
    bubbleView.infoDict = dict;
    if (selectedAV) {
        MyAnnotationPoint *kYPointAnnotation = selectedAV.annotation;
        [bMapView setCenterCoordinate:kYPointAnnotation.coordinate animated:YES];
        [self changeBubblePosition];
        [self showBubble:YES];
    }
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    if ([EUtility brwViewIsFront:meBrwView]) {
        if (isSystemBubble) {
            
        }else{
            [mapView deselectAnnotation:view.annotation animated:NO];
        }
        NSString * uid = view.reuseIdentifier;
        NSString * longut =[NSString stringWithFormat:@"%f",( (BMKPointAnnotation *)view.annotation).coordinate.longitude];
        NSString * lati=[NSString stringWithFormat:@"%f",( (BMKPointAnnotation *)view.annotation).coordinate.latitude];
        NSString * jsstr = [NSString stringWithFormat:@"if(uexBaiduMap.onTouchMark!=null){uexBaiduMap.onTouchMark('%@','%@','%@');}",uid,longut,lati];
        [EUtility brwView:meBrwView evaluateScript:jsstr];
        if (selectedAV) {
            selectedAV = view;
            //            [self showBubble:YES];
        }else{
            selectedAV = nil;
            [self showBubble:NO];
        }
    }
}
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    [self showBubble:NO];
}
-(UIColor *) getColor:(NSString *)hexColor
{
    unsigned int red, green, blue;
    NSRange range;
    range.length =2;
    range.location =0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    range.location =2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    range.location =4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green/255.0f)blue:(float)(blue/255.0f)alpha:1.0f];
}
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKCircle class]])
    {
        NBMKCircleView* circleView = [[[NBMKCircleView alloc] initWithOverlay:overlay] autorelease];
        if (self.dataDict == nil) {
            return nil;
        }else{
            circleView.stringId = [self.dataDict objectForKey:@"id"];
            circleView.fillColor =  [[self getColor:[self.dataDict objectForKey:@"fillColor"]] colorWithAlphaComponent:0.5];
            ;
            circleView.strokeColor =  [[self getColor:[self.dataDict objectForKey:@"strokeColor"]] colorWithAlphaComponent:0.5];
            circleView.lineWidth =[[self.dataDict objectForKey:@"lineWidth"] floatValue];
        }
		return circleView;
    }
    if ([overlay isKindOfClass:[BMKPolygon class]]) {
        NBMKPolygonView* polygonView = [[[NBMKPolygonView alloc] initWithOverlay:overlay] autorelease];
        if (self.dataDict == nil) {
            return nil;
        }else{
            polygonView.stringId = [self.dataDict objectForKey:@"id"];
            polygonView.fillColor = [[self getColor:[self.dataDict objectForKey:@"fillColor"]] colorWithAlphaComponent:0.5];
            ;
            polygonView.strokeColor =  [[self getColor:[self.dataDict objectForKey:@"strokeColor"]] colorWithAlphaComponent:0.5];
            polygonView.lineWidth =[[self.dataDict objectForKey:@"lineWidth"] floatValue];
        }
		return polygonView;
    }
    if ([overlay isKindOfClass:[BMKPolyline class]]&&typeOverLayerView == line){
		NBMKPolylineView* polylineView = [[[NBMKPolylineView alloc] initWithOverlay:overlay] autorelease];
        if (self.dataDict == nil) {
            polylineView.stringId = self.poiId;
            polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
            polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
            polylineView.lineWidth = 3.0;
        }else{
            polylineView.stringId = [self.dataDict objectForKey:@"id"];
            polylineView.fillColor = [[self getColor:[self.dataDict objectForKey:@"fillColor"]] colorWithAlphaComponent:0.5];
            ;
            polylineView.strokeColor =  [[self getColor:[self.dataDict objectForKey:@"strokeColor"]] colorWithAlphaComponent:0.5];
            polylineView.lineWidth =[[self.dataDict objectForKey:@"lineWidth"] floatValue];
        }
		return polylineView;
	}
    if ([overlay isKindOfClass:[BMKPolyline class]]&&typeOverLayerView == other) {
        
        NKBMKOverlayView * polylineView = [[[NKBMKOverlayView alloc] initWithOverlay:overlay] autorelease];
        NSString *url = [self absPath:[self.markDictionary objectForKey:@"imageUrl"]];
        [NKBMKOverlayView setUrlString:url];
        [NKBMKOverlayView setStrId:[NSString stringWithFormat:@"%@",[self.markDictionary objectForKey:@"id"]]];
        return polylineView;
    }
	return nil;
}

-(void)clearMarks:(NSMutableArray *)inArguments{
    NSString * idString = nil;
    if ([inArguments count]>0) {
        idString = [inArguments objectAtIndex:0];
    }
    NSArray *annotations = [NSArray arrayWithArray:bMapView.annotations];
    if (annotations && [annotations count] > 0) {
        if (idString) {
            NSArray * idArray = [idString componentsSeparatedByString:@","];
            for (MyAnnotationPoint * mark in annotations) {
                for (NSString * idStr in idArray) {
                    if (mark.pointId == [idStr intValue]) {
                        [bMapView removeAnnotation:mark];
                    }
                    
                }
            }
        } else {
            [bMapView removeAnnotations:annotations];
        }
    }
}
-(void)setCenter:(NSMutableArray *)inArguments{
    float longit = [[inArguments objectAtIndex:0] floatValue];
    float latit = [[inArguments objectAtIndex:1] floatValue];
    if (longit > 180 || longit < -180) {
        return;
    }
    if (latit > 90 || latit < -90) {
        return;
    }
    CLLocationCoordinate2D cc2d;
    cc2d.longitude = longit;
    cc2d.latitude = latit;
    
    [bMapView setCenterCoordinate:cc2d animated:YES];
    
}
-(void)setZoomLevel:(NSMutableArray *)inArguments{
    int zoomLevel = [[inArguments objectAtIndex:0] intValue];
    if (zoomLevel>18) {
        zoomLevel = 18;
    }
    if (zoomLevel<3) {
        zoomLevel = 3;
    }
    [bMapView setZoomLevel:zoomLevel];
}
-(void)hide:(NSMutableArray *)inArguments{
    [bMapView setHidden:YES];
}
-(void)show:(NSMutableArray *)inArguments{
    [bMapView setHidden:NO];
}

-(void)clean:(NSMutableArray *)inArguments{
    if ([updateMark isValid]) {
        [updateMark invalidate];
    }
    if ([updateCloudy isValid]) {
        [updateCloudy invalidate];
    }
    if (bMapView) {
        [bMapView setShowsUserLocation:NO];
        [EUtility brwView:meBrwView forbidRotate: NO];
        [bMapView removeFromSuperview];
//        [bMapView release];
        bMapView = nil;
        mapDidDisplay = NO;
    }
}
-(void)clean{
    if ([updateMark isValid]) {
        [updateMark invalidate];
    }
    if ([updateCloudy isValid]) {
        [updateCloudy invalidate];
    }
    if (bMapView) {
        [bMapView setShowsUserLocation:NO];
        [EUtility brwView:meBrwView forbidRotate: NO];
        [bMapView removeFromSuperview];
//        [bMapView release];
        bMapView = nil;
        mapDidDisplay = NO;
    }
}


-(void)setType:(NSMutableArray *)array{
    NSString *typeString = [array objectAtIndex:0];
    int type=0;
    BMKMapType mapType = 0;
    type = [typeString intValue];
    switch (type) {
        case 0:
        {
            mapType = BMKMapTypeStandard;///< 标准地图
        }
            break;
        case 1:
        {
            mapType = BMKMapTypeSatellite;///< 卫星地图
        }
            break;
        case 2:
        {
            mapType = BMKMapTypeTrafficOn;///< 打开实时路况
        }
            break;
        case 3:
        {
            mapType = BMKMapTypeTrafficOff;///< 关闭实时路况
        }
            break;
        default:
            break;
    }
    [bMapView setMapType:mapType];
}
-(void)setZoomEnable:(NSMutableArray *)array{
    NSString * str= [array objectAtIndex:0];
    if ([str isEqualToString:@"0"]) {
        [bMapView setZoomEnabled:NO];
    }else if([str isEqualToString:@"1"]){
        [bMapView setZoomEnabled:YES];
    }
}
-(void)setScrollEnable:(NSMutableArray *)array{
    NSString * str= [array objectAtIndex:0];
    if ([str isEqualToString:@"0"]) {
        [bMapView setScrollEnabled:NO];
    }else if([str isEqualToString:@"1"]){
        [bMapView setScrollEnabled:YES];
    }
}
-(void)zoomToSpan:(NSMutableArray *)array{
    NSString * longitudeSpan = [array objectAtIndex:0];
    NSString * latitudeSpan = [array objectAtIndex:0];
    BMKCoordinateRegion region;
    region.center= bMapView.centerCoordinate;
    region.span.longitudeDelta = [longitudeSpan doubleValue];
    region.span.latitudeDelta = [latitudeSpan doubleValue];
    [bMapView setRegion:region animated:YES];
}
-(void)showUserLocation:(NSMutableArray *)array{
    float  longit =currentLocationcc2d.longitude;
    float  lat = currentLocationcc2d.latitude;
    if (longit == 0.0 && lat == 0.0){
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"定位尚未成功，稍后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    [bMapView setShowsUserLocation:YES];
    [super jsSuccessWithName:@"uexBaiduMap.cbShowUserLocation" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[NSString stringWithFormat:@"{\"longitude\":\"%f\",\"latitude\":\"%f\"}",longit,lat]];
}
-(void)hideUserLocation:(NSMutableArray *)array{
    [bMapView setShowsUserLocation:NO];
}
-(void)zoomIn:(NSMutableArray *)array{
    if (bMapView) {
        [bMapView zoomIn];
    }
}
-(void)zoomOut:(NSMutableArray *)array{
    if (bMapView) {
        [bMapView zoomOut];
    }
}
//在指定的城市搜索兴趣点
-(void)poiSearchInCity:(NSMutableArray *)array{
    NSString * city = [array objectAtIndex:0];
    NSString * poi = [array objectAtIndex:1];
    NSString * pageIndex = [array objectAtIndex:2];
    searchType = otherItems;
    BOOL flag = [_search poiSearchInCity:city withKey:poi pageIndex:[pageIndex intValue]];
    if (!flag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"search failed!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}
//根据单个关键字在指定的中心点和半径范围内搜索兴趣点
-(void)poiSearchNearBy:(NSMutableArray *)array{
    NSString * key = [array objectAtIndex:0];
    float longitude = [[array objectAtIndex:1] doubleValue];
    float latitude = [[array objectAtIndex:2] doubleValue];
    int radicus = [[array objectAtIndex:3] intValue];
    int pageIndex = [[array objectAtIndex:4] intValue];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    searchType = otherItems;
    BOOL flag = [_search poiSearchNearBy:key center:coordinate radius:radicus pageIndex:pageIndex];
    if (!flag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"search failed!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}
///根据多个关键字在指定的中心点和半径范围内搜索兴趣点
-(void)poiMultiSearchNearBy:(NSMutableArray *)array{
    NSString *arrayString = [array objectAtIndex:0];
    NSDictionary *dict = [arrayString JSONValue];
    NSArray *arrayKey = [dict objectForKey:@"list"];
    float longitude = [[dict objectForKey:@"longitude"] floatValue];
    float latitude = [[dict objectForKey:@"latitude"] floatValue];
    int radius = [[dict objectForKey:@"radius"] intValue];
    int pageIndex = [[dict objectForKey:@"pageIndex"] intValue];
    searchType = otherItems;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    BOOL flag = [_search poiMultiSearchNearBy:arrayKey center:coordinate radius:radius pageIndex:pageIndex];
    if (!flag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"search failed!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}
//根据单个关键字在指定的范围内搜索兴趣点
-(void)poiSearchInBounds:(NSMutableArray *)array{
    NSString * arrayString = [array objectAtIndex:0];
    NSDictionary * dict = [arrayString JSONValue];
    NSString * stringKey = [dict objectForKey:@"key"];
    float ltLongitude = [[dict objectForKey:@"ltLongitude"] doubleValue];
    float ltLatitude = [[dict objectForKey:@"ltLatitude"] doubleValue];
    float rbLongitude = [[dict objectForKey:@"rbLongitude"] doubleValue];
    float rbLatitude = [[dict objectForKey:@"rbLatitude"] doubleValue];
    int pageIndex = [[dict objectForKey:@"pageIndex"] intValue];
    searchType = otherItems;
    CLLocationCoordinate2D ltCoordinate;
    ltCoordinate.longitude = ltLongitude;
    ltCoordinate.latitude = ltLatitude;
    
    CLLocationCoordinate2D rbCoordinate;
    rbCoordinate.longitude = rbLongitude;
    rbCoordinate.latitude = rbLatitude;
    
    BOOL flag = [_search poiSearchInbounds:stringKey leftBottom:ltCoordinate rightTop:rbCoordinate pageIndex:pageIndex];
    if (!flag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"search failed!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}
//根据多个关键字在指定的范围内搜索兴趣点
-(void)poiMultiSearchInBounds:(NSMutableArray *)array{
    NSString *arrayString = [array objectAtIndex:0];
    
    NSDictionary *dict = [arrayString JSONValue];
    NSArray *stringList = [dict objectForKey:@"list"];
    float ltLongitude = [[dict objectForKey:@"ltLongitude"] floatValue];
    float ltLatitude = [[dict objectForKey:@"ltLatitude"] floatValue];
    float rbLongitude = [[dict objectForKey:@"rbLongitude"] floatValue];
    float rbLatitude = [[dict objectForKey:@"rbLatitude"] floatValue];
    int pageIndex = [[dict objectForKey:@"pageIndex"] intValue];
    searchType = otherItems;
    CLLocationCoordinate2D ltCoordinate;
    ltCoordinate.longitude = ltLongitude;
    ltCoordinate.latitude = ltLatitude;
    
    CLLocationCoordinate2D rbCoordinate;
    rbCoordinate.longitude = rbLongitude;
    rbCoordinate.latitude = rbLatitude;
    
    BOOL flag = [_search poiMultiSearchInbounds:stringList leftBottom:ltCoordinate rightTop:rbCoordinate pageIndex:pageIndex];
    if (!flag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"search failed!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

#pragma mark -

-(void)suggestionSearch:(NSMutableArray *)array
{
    NSString * key = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
    //    BOOL flag = [_search suggestionSearch:key];
    searchType = otherItems;
    
    
    //-asge-
    //解决联想词搜索崩溃的问题：两个函数不能共存，百度地图sdk的bug
    //代理函数：onGetSuggestionResult和onGetBusDetailResult有冲突
    SuggestionSearchObj * suggestion = [SuggestionSearchObj shareInstance];
    [suggestion suggestion_Search:key withSearch:_search withSelf:self];
}
-(void)busLineSearch:(NSMutableArray *)array
{
    NSString * city =[array objectAtIndex:0];
    self.bushLineCity =[NSString stringWithFormat:@"%@",city];
    NSString * line =[array objectAtIndex:1];
    NSString * lineId =[array objectAtIndex:2];
    self.poiId = [NSString stringWithFormat:@"%@",lineId];
    searchType = busLineItem;
    //-asge-代理来回传递
    _search.delegate = self;
    //    BOOL flag = [_search busLineSearch:city withKey:line];
    BOOL flag = [_search poiSearchInCity:city withKey:line pageIndex:0];
	if (!flag) {
		//
	}
}
-(void)geocode:(NSMutableArray *)array{
    NSString *city = [array objectAtIndex:0];
    NSString *address =[array objectAtIndex:1];
    geoOrReverse = 0;
    BOOL flag = [_search geocode:address withCity:city];
	if (!flag) {
		//
	}
}
-(void)reverseGeocode:(NSMutableArray *)array{
    float longitude = [[array objectAtIndex:0] floatValue];
    float latitude = [[array objectAtIndex:1] floatValue];
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    pt.longitude = longitude;
    pt.latitude = latitude;
    geoOrReverse = 1;
	BOOL flag = [_search reverseGeocode:pt];
	if (!flag) {
		//
	}
}
- (void)getBaiduFromGoogle:(NSMutableArray *)array
{
    CLLocationCoordinate2D locationCoord;
    if ([array count]== 2) {
        locationCoord.longitude = [[array objectAtIndex:0] floatValue];
        locationCoord.latitude = [[array objectAtIndex:1] floatValue];
    }
    NSDictionary * baidudict =BMKBaiduCoorForGcj(CLLocationCoordinate2DMake(locationCoord.latitude, locationCoord.longitude));
    NSString * xbase64 = [baidudict objectForKey:@"x"];
    NSString * ybase64 = [baidudict objectForKey:@"y"];
    NSData * xdata = [GTMBase64 decodeString:xbase64];
    NSData * ydata = [GTMBase64 decodeString:ybase64];
    NSString  * xstr = [[NSString alloc] initWithData:xdata encoding:NSUTF8StringEncoding];
    NSString * ystr = [[NSString alloc] initWithData:ydata encoding:NSUTF8StringEncoding];
    CLLocationCoordinate2D result;
    result.latitude = [ystr floatValue];
    result.longitude = [xstr floatValue];
    NSString * jsstr = [NSString stringWithFormat:@"if(uexBaiduMap.cbBaiduFromGoogle!=null){uexBaiduMap.cbBaiduFromGoogle('%f','%f');}",[ystr floatValue],[xstr floatValue]];
    [EUtility brwView:meBrwView evaluateScript:jsstr];
}
-(void)showRoutePlan:(NSMutableArray *)array {
    typeOverLayerView = line;
    NSString * str = [array objectAtIndex:0];
    NSDictionary * dict = [str JSONValue];
    int type = [[dict objectForKey:@"type"] intValue];
    NSString * _poiId = [dict objectForKey:@"id"];
    self.poiId = [NSString stringWithFormat:@"%@",_poiId];
    NSDictionary * startDict = [dict objectForKey:@"start"];
    NSString * startCity = [startDict objectForKey:@"city"];
    NSString * startName = [startDict objectForKey:@"name"];
    NSString * startLongitude = [startDict objectForKey:@"longitude"];
    NSString * startLatitude= [startDict objectForKey:@"latitude"];
    
    NSDictionary * endDict = [dict objectForKey:@"end"];
    NSString * endCity = [endDict objectForKey:@"city"];
    NSString * endName = [endDict objectForKey:@"name"];
    NSString * endLongitude = [endDict objectForKey:@"longitude"];
    NSString * endLatitude= [endDict objectForKey:@"latitude"];
    
    CLLocationCoordinate2D startPt = (CLLocationCoordinate2D){0, 0};
    startPt.longitude = [startLongitude floatValue];
    startPt.latitude = [startLatitude floatValue];
    
    CLLocationCoordinate2D endPt = (CLLocationCoordinate2D){0, 0};
    endPt.longitude = [endLongitude floatValue];
    endPt.latitude = [endLatitude floatValue];
    
    BMKPlanNode * start = [[BMKPlanNode alloc]init];
    start.pt = startPt;
    start.name = startName;
    
    BMKPlanNode * end = [[BMKPlanNode alloc]init];
    end.pt = endPt;
    end.name = endName;
    BOOL flag=NO;
    switch (type) {
        case 0://驾车
        {
            flag =[_search drivingSearch:startCity startNode:start endCity:endCity endNode:end];
        }
            break;
        case 1://公交
        {
            flag = [_search transitSearch:startCity startNode:start endNode:end];
        }
            break;
        case 2://步行
        {
            [_search walkingSearch:startCity startNode:start endCity:endCity endNode:end];
        }
            break;
        default:
            break;
    }
    [start release];
    [end release];
    if(selectedAV){
        //隐藏自定义的Bubble,否则出现点击路线的animation弹出自定义的Bubble
        selectedAV = nil;
        [self showBubble:NO];
    }
    
	if (!flag) {
		//
	}
}
-(void)clearRoutePlan:(NSMutableArray *)array{
    NSString *idString = nil;
    if ([array count]>0) {
        idString = [array objectAtIndex:0];
    }else{
        if (bMapView) {
            NSArray *overlaysArray = [NSArray arrayWithArray:bMapView.overlays];
            [bMapView removeOverlays:overlaysArray];
        }
        return;
    }
    NSArray *idArray = [idString componentsSeparatedByString:@","];
    NSArray *overlaysArray = [NSArray arrayWithArray:bMapView.overlays];
    for (NSString *stringId in idArray) {
        for (id<BMKOverlay>overlay in  overlaysArray) {
            NBMKPolylineView *overlayPolylineView = (NBMKPolylineView *)[bMapView viewForOverlay:overlay];
            if (overlayPolylineView&&[overlayPolylineView isKindOfClass:[NBMKPolylineView class]]) {
                NSString *Id = overlayPolylineView.stringId;
                if([Id isEqualToString:stringId]){
                    [bMapView removeOverlay:overlayPolylineView.overlay];
                    NSArray *array = [NSArray arrayWithArray:bMapView.annotations];
                    [bMapView removeAnnotations:array];
                }
            }
        }
    }
    if (!selectedAV) {
        selectedAV = [[BMKAnnotationView alloc] init];
    }
    
}
//添加线型覆盖物
-(void)addLineOverLayer:(NSMutableArray *)array{
    typeOverLayerView = line;
    NSDictionary *dict = [[array objectAtIndex:0] JSONValue];
    if (!self.dataDict) {
        self.dataDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [self.dataDict setDictionary:dict];
    NSArray *propertyArray = [dict objectForKey:@"property"];
    int caplity = (int)[propertyArray count];
    CLLocationCoordinate2D coords[999] = {0};//默认分配999空间数组，不常用
    // 添加多边形覆盖物
    for (int i=0; i<[propertyArray count]; i++) {
        coords[i].latitude = [[[propertyArray objectAtIndex:i] objectForKey:@"latitude"] floatValue];
        coords[i].longitude =  [[[propertyArray objectAtIndex:i] objectForKey:@"longitude"] floatValue];
    }
    //    if ([bMapView.overlays count]>0) {
    //        [bMapView removeOverlays:bMapView.overlays];
    //    }
    BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:coords count:caplity];
    //    [BMKPolyline setStringId:[dict objectForKey:@"id"]];
	[bMapView addOverlay:polyline];
}
//添加圆型覆盖物
-(void)addCircleOverLayer:(NSMutableArray *)array{
    NSDictionary *dict = [[array objectAtIndex:0] JSONValue];
    if (!self.dataDict) {
        self.dataDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [self.dataDict setDictionary:dict];
    
    CLLocationCoordinate2D coor;
    coor.latitude = [[dict objectForKey:@"latitude"] floatValue];
    coor.longitude = [[dict objectForKey:@"longitude"] floatValue];
    float radius = [[dict objectForKey:@"radius"] floatValue];
    //    if ([bMapView.overlays count]>0) {
    //        [bMapView removeOverlays:bMapView.overlays];
    //    }
    BMKCircle* circle = [BMKCircle circleWithCenterCoordinate:coor radius:radius];
    //    [NBMKCircle setStringId:[dict objectForKey:@"id"]];
    [bMapView addOverlay:circle];
}
//添加多边型覆盖物
-(void)addPolygonOverLayer:(NSMutableArray *)array{
    NSDictionary *dict = [[array objectAtIndex:0] JSONValue];
    if (!self.dataDict) {
        self.dataDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [self.dataDict setDictionary:dict];
    NSArray *propertyArray = [dict objectForKey:@"property"];
    int caplity = (int)[propertyArray count];
    CLLocationCoordinate2D coords[100] = {0};//默认分配十几空间数组，不常用
    // 添加多边形覆盖物
    for (int i=0; i<[propertyArray count]; i++) {
        coords[i].latitude = [[[propertyArray objectAtIndex:i] objectForKey:@"latitude"] floatValue];
        coords[i].longitude =  [[[propertyArray objectAtIndex:i] objectForKey:@"longitude"] floatValue];
    }
    BMKPolygon* polygon = [BMKPolygon polygonWithCoordinates:coords count:caplity];
    //    [NBMKPolygon setStringId:[dict objectForKey:@"id"]];
    [bMapView addOverlay:polygon];
}
//清除覆盖物
-(void)clearOverLayers:(NSMutableArray *)array{
    typeOverLayerView = line;//自定义试图
    NSString *idString = nil;
    if ([array count]>0) {//传参删除指定的Id对应的overlays
        idString = [array objectAtIndex:0];
    }else{//不传参数，删除全部的overlays
        if (bMapView) {
            NSArray *overlaysArray = [NSArray arrayWithArray:bMapView.overlays];
            [bMapView removeOverlays:overlaysArray];
        }
        return;
    }
    NSArray *idArray = [idString componentsSeparatedByString:@","];
    NSArray *overlaysArray = [NSArray arrayWithArray:bMapView.overlays];
    for (NSString *stringId in idArray) {
        for (id<BMKOverlay> overlay in  overlaysArray) {
            //线型
            if ([[bMapView viewForOverlay:overlay] isKindOfClass:[NBMKPolylineView class]]) {
                NBMKPolylineView *overlayView = (NBMKPolylineView *)[bMapView viewForOverlay:overlay];
                if([overlayView.stringId isEqualToString:stringId]){
                    [bMapView removeOverlay:overlayView.overlay];
                }
            }
            //圆型
            else if ([[bMapView viewForOverlay:overlay] isKindOfClass:[NBMKCircleView class]]) {
                NBMKCircleView *overlayView = (NBMKCircleView *)[bMapView viewForOverlay:overlay];
                if([overlayView.stringId isEqualToString:stringId]){
                    [bMapView removeOverlay:overlayView.overlay];
                }
            }
            //多边型
            else if ([[bMapView viewForOverlay:overlay] isKindOfClass:[NBMKPolygonView class]])
            {
                NBMKPolygonView *overlayView = (NBMKPolygonView *)[bMapView viewForOverlay:overlay];
                if([overlayView.stringId isEqualToString:stringId]){
                    [bMapView removeOverlay:overlayView.overlay];
                }
            }
            else {
                //
            }
            
        }
    }
    
}
/*
 -(void)animationOfUIViewFrame:(UIView*)aview Center:(CGPoint)point Time:(NSTimeInterval)duration{
 if (aview) {
 CGContextRef context=UIGraphicsGetCurrentContext();
 [UIView beginAnimations:nil context:context];
 [UIView setAnimationBeginsFromCurrentState:YES];
 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
 [UIView setAnimationDuration:duration];
 [aview setCenter:point];
 [UIView commitAnimations];
 }
 }
 -(void)timerMethod{
 if (onView) {
 onView.imageView.image = [UIImage imageNamed:@"uexBaiduMap/backGroud.png"];
 }
 [onView setNeedsDisplay];
 UIImageView *endImageView = (UIImageView *)[onView viewWithTag:1000];
 [self animationOfUIViewFrame:airplaneImageView Center:endImageView.center Time:3];
 }
 -(void)updateMark:(NSMutableArray *)array{
 if (!onView) {
 CloudyView *tempOnView = [[CloudyView alloc] initWithFrame:CGRectMake(0, 0, bMapView.frame.size.width, bMapView.frame.size.height)];
 self.onView = tempOnView;
 [tempOnView release];
 [bMapView addSubview:onView];
 }
 float locations[] = {116.4990234375,39.740986355883564,
 106.611328125,29.305561325527698};
 NSMutableArray *pointsArray = [NSMutableArray arrayWithCapacity:2];
 CGPoint points[2];
 for (int i = 0; i < 2; i++) {
 CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(locations[2*i+1], locations[2*i]);
 points[i] = [bMapView convertCoordinate:coord toPointToView:onView];
 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
 [dict setObject:[NSString stringWithFormat:@"%f",points[i].x] forKey:@"xPoint"];
 [dict setObject:[NSString stringWithFormat:@"%f",points[i].y] forKey:@"yPoint"];
 [pointsArray addObject:dict];
 }
 UIImage *green_Image = [UIImage imageNamed:@"uexBaiduMap/circle_green.png"];
 UIImageView *startImageView = [[UIImageView alloc] init];
 CGRect green_Rect = CGRectMake(points[0].x, points[0].y, green_Image.size.width, green_Image.size.height);
 [startImageView setFrame:green_Rect];
 [startImageView setImage:green_Image];
 startImageView.center = points[0];
 [startImageView setTag:1000];
 [onView addSubview:startImageView];
 [startImageView release];
 
 UIImage *blue_Image = [UIImage imageNamed:@"uexBaiduMap/circle_blue.png"];
 UIImageView *endImageView = [[UIImageView alloc] init];
 CGRect blue_Rect = CGRectMake(points[1].x, points[1].y, blue_Image.size.width, blue_Image.size.height);
 [endImageView setFrame:blue_Rect];
 [endImageView setImage:blue_Image];
 endImageView.center = points[1];
 [endImageView setTag:1001];
 [onView addSubview:endImageView];
 
 UIImage *air_Image = [UIImage imageNamed:@"uexBaiduMap/cat.png"];
 if (!airplaneImageView) {
 airplaneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(points[1].x, points[1].x, air_Image.size.width, air_Image.size.height)];
 [airplaneImageView setImage:air_Image];
 airplaneImageView.center = points[1];
 [onView addSubview:airplaneImageView];
 }
 onView.pointArray = pointsArray;
 NSTimer   *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:NO];
 }*/
-(void)addAreaMark:(NSMutableArray *)array{
    if (bMapView) {
        typeOverLayerView = other;
        NSString * str = [array objectAtIndex:0];
        NSDictionary *dict = [str JSONValue];
        NSArray * infoArray = [dict objectForKey:@"markInfo"];
        NSDictionary * resultDict = [infoArray objectAtIndex:0];
        if (!markDictionary) {
            self.markDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        [self.markDictionary setDictionary:resultDict];
        float  ltLongitude =[[resultDict objectForKey:@"ltLongitude"] floatValue];
        float  ltLatitude =[[resultDict objectForKey:@"ltLatitude"] floatValue];
        float  rbLongitude =[[resultDict objectForKey:@"rbLongitude"] floatValue];
        float  rbLatitude =[[resultDict objectForKey:@"rbLatitude"] floatValue];
        float locations[] = {ltLongitude,ltLatitude,
            rbLongitude, rbLatitude};
        BMKMapPoint * points = (BMKMapPoint *)malloc(sizeof(CLLocationCoordinate2D) *2);
        for (int i = 0; i < 2; i++) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(locations[2 * i + 1], locations[2 * i]);
            points[i] = BMKMapPointForCoordinate(coord);
        }
        BMKPolyline * line = [BMKPolyline polylineWithPoints:points count:2];
        [bMapView addOverlay:line];
    }
}
-(void)updateAreaMark0:(NSMutableArray *)array{
    typeOverLayerView = other;//自定义试图
    NSString * jsonStr = [array objectAtIndex:0];
    NSDictionary * dict = [jsonStr JSONValue];
    if (dict == nil) {
        return;
    }
    NSString * strId = [dict objectForKey:@"id"];
    if (bMapView) {
        NSArray * overlaysArray = [NSArray arrayWithArray:bMapView.overlays];
        for (id<BMKOverlay>overlay in  overlaysArray) {
            NKBMKOverlayView * overlayView = (NKBMKOverlayView *)[bMapView viewForOverlay:overlay];
            
            if (overlayView && [overlayView isKindOfClass:[BMKOverlayPathView class]]) {
                if ([strId isEqualToString:[NKBMKOverlayView getStrId]]) {
                    NSString * url = [self absPath:[dict objectForKey:@"imageUrl"]];
                    [NKBMKOverlayView setUrlString:url];
                    [overlayView setNeedsDisplay];
                    break;
                }
            }
        }
    }
}
int i=0;
-(void)updateCloudyMethd:(NSTimer *)t{
    int index = i % 9;
    i ++;
    NSDictionary * updateDict = t.userInfo;
    NSArray * cloudyImageUrlArray = [updateDict objectForKey:@"property"];
    NSDictionary * dict = [cloudyImageUrlArray objectAtIndex:index];
    NSMutableDictionary * cloudyDict = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString * cloudyId = [updateDict objectForKey:@"id"];
    NSString * ltLongitude = [dict objectForKey:@"ltLongitude"];
    NSString * ltLatitude = [dict objectForKey:@"ltLatitude"];
    NSString * rbLongitude = [dict objectForKey:@"rbLongitude"];
    NSString * rbLatitude = [dict objectForKey:@"rbLatitude"];
    NSString * imageUrl = [dict objectForKey:@"imageUrl"];
    [cloudyDict setObject:cloudyId forKey:@"id"];
    [cloudyDict setObject:ltLongitude forKey:@"ltLongitude"];
    [cloudyDict setObject:ltLatitude forKey:@"ltLatitude"];
    [cloudyDict setObject:rbLongitude forKey:@"rbLongitude"];
    [cloudyDict setObject:rbLatitude forKey:@"rbLatitude"];
    [cloudyDict setObject:imageUrl forKey:@"imageUrl"];
    
    NSMutableArray * jsonArray = [NSMutableArray arrayWithCapacity:1];
    NSString * jsonStr = [cloudyDict JSONRepresentation];
    [jsonArray addObject:jsonStr];
    [self updateAreaMark0:jsonArray];
    if (i == 10) {
        i = 0;
    }
}
-(void)updateAreaMark:(NSMutableArray *)array{
    NSString * inJson = [array objectAtIndex:0];
    NSDictionary * updateMarkDict = [inJson JSONValue];
    NSInteger seconds = [[updateMarkDict objectForKey:@"timer"] integerValue];
    updateCloudy = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(updateCloudyMethd:) userInfo:updateMarkDict repeats:YES];
}
-(void)clearAreaMarks:(NSMutableArray *)array{
    typeOverLayerView = other;//自定义试图
    NSString * idString = nil;
    if ([array count]>0) {//传参删除指定的Id对应的overlays
        idString = [array objectAtIndex:0];
    } else {//不传参数，删除全部的overlays
        if (bMapView) {
            NSArray * overlaysArray = [NSArray arrayWithArray:bMapView.overlays];
            [bMapView removeOverlays:overlaysArray];
        }
        return;
    }
    NSArray * idArray = [idString componentsSeparatedByString:@","];
    NSArray * overlaysArray = [NSArray arrayWithArray:bMapView.overlays];
    for (NSString * stringId in idArray) {
        for (id<BMKOverlay>overlay in  overlaysArray) {
            NKBMKOverlayView * overlayView = (NKBMKOverlayView *)[bMapView viewForOverlay:overlay];
            if (overlayView&&[overlayView isKindOfClass:[NKBMKOverlayView class]]) {
                NSString * Id = [NKBMKOverlayView getStrId];
                if([Id isEqualToString:stringId]){
                    [bMapView removeOverlay:overlayView.overlay];
                }
            }
        }
    }
}
#pragma mark show bubble animation
- (void)changeBubblePosition {
    if (selectedAV) {
        if (bubbleView) {
            CGRect rect = selectedAV.frame;
            CGPoint center;
            center.x = rect.origin.x + rect.size.width/2 - 10;
            center.y = rect.origin.y - bubbleView.frame.size.height/20 - 15;
            bubbleView.center = center;
        }
    }
}
- (void)bounce4AnimationStopped{
    if (bubbleView) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/6];
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
        [UIView commitAnimations];
    }
}

- (void)bounce3AnimationStopped{
    if (bubbleView) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/6];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounce4AnimationStopped)];
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        [UIView commitAnimations];
    }
}

- (void)bounce2AnimationStopped{
    if (bubbleView) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/6];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounce3AnimationStopped)];
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
        [UIView commitAnimations];
    }
}

- (void)bounce1AnimationStopped{
    if (bubbleView) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/6];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        [UIView commitAnimations];
    }
}

- (void)showBubble:(BOOL)show {
    if (show) {
        if (bubbleView) {
            [bubbleView showFromRect:selectedAV.frame];
            
            bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:kTransitionDuration/3];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
            bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            bubbleView.hidden = NO;
            //bubbleView.center = center;
            [UIView commitAnimations];
        }
    } else {
        if (bubbleView) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:kTransitionDuration/3];
            bubbleView.hidden = YES;
            [UIView commitAnimations];
        }
    }
}
-(void)makeNextBtnClicked:(NSString *)strId {
    NSString *jsstr = [NSString stringWithFormat:@"if(uexBaiduMap.onTouchBubbleView!=null){uexBaiduMap.onTouchBubbleView('%@');}",strId];
    [EUtility brwView:meBrwView evaluateScript:jsstr];
}
-(void)dealloc{
    if (bMapView) {
        [bMapView setShowsUserLocation:NO];
    }
    if (markDictionary) {
        self.markDictionary = nil;
    }
    if (airplaneImageView) {
        [airplaneImageView release];
    }
    if (bushLineCity) {
        self.bushLineCity = nil;
    }
    if (poiId) {
        self.poiId=nil;
    }
    if (dataArray) {
        self.dataArray = nil;
    }
    if (selectedAV){
        [selectedAV release];
        selectedAV = nil;
    }
    if (bubbleView) {
        [bubbleView release];
        bubbleView = nil;
    }
    if (bMapView) {
        [bMapView release];
        bMapView = nil;
    }
    if (dataDict) {
        self.dataDict = nil;
    }
    [super dealloc];
}
@end
