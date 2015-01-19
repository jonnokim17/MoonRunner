//
//  DetailViewController.m
//  MoonRunner
//
//  Created by Jonathan Kim on 1/18/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "MathController.h"
#import "Run.h"
#import "Location.h"

@interface DetailViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

-(void)setRun:(Run *)run
{
    if (_run != run)
    {
        _run = run;
        [self configureView];
    }
}

- (void)configureView
{
    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [NSString stringWithFormat:@"Date: %@", [formatter stringFromDate:self.run.timeStamp]];

    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@", [MathController stringifySecondCount:self.run.distance.floatValue
                                                                                       usingLongFormat:YES]];
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@", [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue
                                                                                                  overTime:self.run.duration.intValue]];

    [self loadMap];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

#pragma mark - MKMapViewDelegate Method
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor blackColor];
        aRenderer.lineWidth = 3;

        return aRenderer;
    }
    return nil;
}

#pragma mark - Helper Methods
- (MKCoordinateRegion)mapRegion
{
    MKCoordinateRegion region;
    Location *initialLoc = self.run.locations.firstObject;

    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;

    for (Location *location in self.run.locations)
    {
        if (location.latitude.floatValue < minLat)
        {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng)
        {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat)
        {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng)
        {
            maxLng = location.longitude.floatValue;
        }
    }

    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;

    region.span.latitudeDelta = (maxLat - minLat) * 1.1f; // 10% padding
    region.span.longitudeDelta = (maxLng - minLng) * 1.1f; // 10% padding

    return region;
}

- (MKPolyline *)polyLine
{
    CLLocationCoordinate2D coords[self.run.locations.count];

    for (int i = 0; i < self.run.locations.count; i++)
    {
        Location *location = [self.run.locations objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
    }

    return [MKPolyline polylineWithCoordinates:coords count:self.run.locations.count];
}

- (void)loadMap
{
    if (self.run.locations.count > 0)
    {
        self.mapView.hidden = NO;

        // Set the map bounds
        [self.mapView setRegion:[self mapRegion]];

        // make the line(s!) on the map
        [self.mapView addOverlay:[self polyLine]];
    }
    else
    {
        self.mapView.hidden = YES;

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Sorry, this run has no locations saved."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}



@end
