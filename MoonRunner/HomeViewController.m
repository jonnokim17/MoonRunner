//
//  HomeViewController.m
//  MoonRunner
//
//  Created by Jonathan Kim on 1/18/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import "HomeViewController.h"
#import "NewRunViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NewRunViewController *newRunVC = segue.destinationViewController;
//    newRunVC.managedObjectContext = self.managedObjectContext;
    UIViewController *nextController = segue.destinationViewController;
    if ([nextController isKindOfClass:[NewRunViewController class]])
    {
        ((NewRunViewController *)nextController).managedObjectContext = self.managedObjectContext;
    }
}



@end
