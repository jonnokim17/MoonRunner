//
//  Location.h
//  MoonRunner
//
//  Created by Jonathan Kim on 1/18/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSManagedObject *run;

@end
