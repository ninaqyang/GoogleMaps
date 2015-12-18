//
//  Place.h
//  Map View
//
//  Created by Nina Yang on 9/15/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

@interface Place : GMSMarker <GMSMapViewDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *markerID;

-(id)initWithTitle:(NSString *)newTitle subtitle:(NSString *)newSubtitle location:(CLLocationCoordinate2D)location andURL:(NSString *)urlString;

@end
