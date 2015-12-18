//
//  Place.m
//  Map View
//
//  Created by Nina Yang on 9/15/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import "Place.h"

@implementation Place

-(id)initWithTitle:(NSString *)newTitle subtitle:(NSString *)newSubtitle location:(CLLocationCoordinate2D)location andURL:(NSString *)urlString {
    self = [super init];
    
    if (self) {
        self.title = newTitle;
        self.snippet = newSubtitle;
        self.position = location;
        self.urlString = urlString;
    }
    
    return self;
}

@end
