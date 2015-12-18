//
//  ViewController.m
//  Map View
//
//  Created by Nina Yang on 9/8/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () 

@end

@implementation ViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.searchBar.delegate = self;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.7413597 longitude: -73.98967470000002 zoom:16];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMinZoom:10 maxZoom:20];
    
    [self setupMarkerData];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 30, 0, self.bottomLayoutGuide.length + 5, 0);
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Control Segment

-(IBAction)setMap:(id)sender {
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.mapView.mapType = kGMSTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = kGMSTypeSatellite;
            break;
        default:
            break;
    }
}

#pragma mark - UI

- (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale {
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}

#pragma mark - Map Markers

-(void)setupMarkerData {
    CLLocationCoordinate2D turnToTechLocation = CLLocationCoordinate2DMake(40.7413597, -73.98967470000002);
    Place *place = [[Place alloc]initWithTitle:@"Turn to Tech" subtitle:@"Dev Bootcamp" location:turnToTechLocation andURL:@"http://turntotech.io/"];
    place.icon = [self compressForUpload:[UIImage imageNamed:@"map_pin"] scale:1];
    place.map = self.mapView;
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    UIView *infoWindow = [[UIView alloc]init];
    infoWindow.frame = CGRectMake(0, 0, 230, 70);
    infoWindow.clipsToBounds = NO;
    infoWindow.layer.masksToBounds = NO;
    infoWindow.backgroundColor = [UIColor whiteColor];
    infoWindow.layer.cornerRadius = 3;
    
    UIImage *image = [UIImage imageNamed:@"map_marker"];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 25, 35)];
    [iv setImage:image];
    [infoWindow addSubview:iv];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(52, 12, infoWindow.frame.size.width, 16);
    [infoWindow addSubview:titleLabel];
    titleLabel.text = marker.title;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 2;
    
    UILabel *snippetLabel = [[UILabel alloc]init];
    snippetLabel.frame = CGRectMake(52, 32, infoWindow.frame.size.width, 16);
    [infoWindow addSubview:snippetLabel];
    snippetLabel.text = marker.snippet;
    snippetLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    return infoWindow;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSLog(@"%@", marker);
    
    Place *place = (Place *)marker;
    
    if ([place.title isEqual: @"Turn to Tech"]) {
        self.webViewController = [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil];
        self.webViewController.url = [NSURL URLWithString:place.urlString];
        NSLog(@"%@", place.urlString);
        [self.navigationController pushViewController:self.webViewController animated:YES];
    }
    
    else {
        NSURLSession *detailsSearch = [NSURLSession sharedSession];
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyDovvsLgliaDDq1OaN-OpsFLL-VqxJS8y4", place.markerID];
        
        NSURLSessionDataTask *detailsSearchTask = [detailsSearch dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", [json objectForKey:@"result"]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *result = [json objectForKey:@"result"];
                Place *eachPlace = [[Place alloc]init];
                eachPlace.urlString = [result valueForKey:@"website"];
                
                self.webViewController = [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil];
                self.webViewController.url = [NSURL URLWithString:eachPlace.urlString];
                NSLog(@"%@", eachPlace.urlString);
                [self.navigationController pushViewController:self.webViewController animated:YES];
            });
        }];
        
        [detailsSearchTask resume];
    }
}

#pragma mark - Search Bar

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self googlePlacesSearchQuery];
    
    [self.mapView reloadInputViews];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

#pragma mark - Requests

-(void)googlePlacesSearchQuery {
    NSURLSession *nearbySearch = [NSURLSession sharedSession];
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=500&types=%@&key=AIzaSyDovvsLgliaDDq1OaN-OpsFLL-VqxJS8y4", self.mapView.camera.target.latitude, self.mapView.camera.target.longitude, self.searchBar.text];

    NSURLSessionDataTask *nearbySearchTask = [nearbySearch dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
//        for (id returnedPlace in [json objectForKey:@"results"]){
//            NSLog(@"placeid:%@", [returnedPlace objectForKey:@"placeID"]);
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *results = json[@"results"];
            
            Place *place = [[Place alloc]init];
            
            for (place in self.locations) {
                place.map = nil;
            }

            self.locations = [[NSMutableArray alloc]init];
            
            for (id place in results) {
                NSLog(@"%@", place);
                Place *eachPlace = [[Place alloc]init];

                eachPlace.title = [place valueForKey:@"name"];
                eachPlace.snippet = [place valueForKey:@"vicinity"];
                eachPlace.markerID = [place valueForKey:@"place_id"];
                NSLog(@"%@, %@, %@", eachPlace.title, eachPlace.snippet, eachPlace.markerID);
                
                NSDictionary *geometry = [place objectForKey:@"geometry"];
                CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([[geometry[@"location"] valueForKey:@"lat"] floatValue], [[geometry[@"location"] valueForKey:@"lng"] floatValue]);
                eachPlace.position = loc;
                NSLog(@"%f, %f", eachPlace.position.latitude, eachPlace.position.longitude);
                
                eachPlace.icon = [self compressForUpload:[UIImage imageNamed:@"map_pin"] scale:1];
                eachPlace.appearAnimation = YES;
                eachPlace.map = self.mapView;

                [self.locations addObject:eachPlace];
                NSLog(@"%@", self.locations);
            }

        });
    }];
    
    [nearbySearchTask resume];
}

@end
