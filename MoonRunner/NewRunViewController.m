//
//  NewRunViewController.m
//  MoonRunner
//
//  Created by Jonathan Kim on 1/18/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import "NewRunViewController.h"
#import "Run.h"
#import <CoreLocation/CoreLocation.h>
#import "MathController.h"
#import "Location.h"

static NSString * const detailSegueName = @"RunDetails";

@interface NewRunViewController () <UIActionSheetDelegate, CLLocationManagerDelegate>

@property Run *run;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;

@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation NewRunViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // New in iOS8 - MANDATORY
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.startButton.hidden = NO;
    self.promptLabel.hidden = NO;

    self.timeLabel.text = @"";
    self.timeLabel.hidden = YES;
    self.distLabel.hidden = YES;
    self.paceLabel.hidden = YES;
    self.stopButton.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.timer invalidate]; // timer is stopped when the user navigates away from the view
}

-(IBAction)startPressed:(id)sender
{
    // Hide the start UI
    self.startButton.hidden = YES;
    self.promptLabel.hidden = YES;

    // Show the running UI
    self.timeLabel.hidden = NO;
    self.distLabel.hidden = NO;
    self.paceLabel.hidden = NO;
    self.stopButton.hidden = NO;

    // Reset when you start again
    self.seconds = 0;
    self.distance = 0;
    self.locations = [@[] mutableCopy];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(eachSecond)
                                                userInfo:nil
                                                 repeats:YES];
    [self startLocationUpdates];
}

-(IBAction)stopPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save", @"Discard", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.locationManager stopUpdatingLocation];

    // Save
    if (buttonIndex == 0)
    {
        [self saveRun];
        [self performSegueWithIdentifier:detailSegueName sender:nil];
    }
    // Discard
    else if (buttonIndex == 1)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Prepare for segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setRun:self.run];
}

#pragma mark - CLLocation Delegate Method
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // A CLLocation contains some great information.
    // Namely the latitude and longitude, along with the timestamp of the reading.

    // But before blindly accepting the reading, it’s worth a horizontalAccuracy check.
    // If the device isn’t confident it has a reading within 20 meters of the user’s actual location,
    // it’s best to keep it out of your dataset.
    for (CLLocation *newLocation in locations)
    {
        if (newLocation.horizontalAccuracy < 20)
        {
            // update distance
            if (self.locations.count > 0)
            {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject]; // A = A + B
            }
            [self.locations addObject:newLocation];
        }
    }
}


#pragma mark - Helper Methods

- (void)eachSecond
{
    self.seconds++;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@", [MathController stringifySecondCount:self.seconds
                                                                                      usingLongFormat:NO]];
    self.distLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@", [MathController stringifyAvgPaceFromDist:self.distance
                                                                                                  overTime:self.seconds]];
}

- (void)startLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
    }

    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;

    // Movement threshold for new events
    self.locationManager.distanceFilter = 10; // meters

    [self.locationManager startUpdatingLocation];
}

- (void)saveRun
{
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run"
                                                inManagedObjectContext:self.managedObjectContext];
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timeStamp = [NSDate date];

    NSMutableArray *locationArray = [@[] mutableCopy];
    for (CLLocation *location in self.locations)
    {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                 inManagedObjectContext:self.managedObjectContext];
        locationObject.timeStamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }

    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;

    // Save the context
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error:%@, %@", error, [error userInfo]);
        abort();
    }
}



@end
