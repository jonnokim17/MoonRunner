//
//  MasterViewController.h
//  MoonRunner
//
//  Created by Jonathan Kim on 1/18/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

