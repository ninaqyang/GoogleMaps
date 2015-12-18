//
//  ViewController.h
//  Map View
//
//  Created by Nina Yang on 9/8/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WebViewController.h"
#import "Place.h"
@import GoogleMaps;

@interface ViewController : UIViewController <GMSMapViewDelegate, NSURLSessionDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, retain) WebViewController *webViewController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) Place *place;
@property (nonatomic, strong) GMSCameraPosition *camera;
@property (nonatomic, strong) NSMutableArray *locations;

-(IBAction)setMap:(id)sender;

-(UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale;
-(void)setupMarkerData;
-(void)googlePlacesSearchQuery;

@end

