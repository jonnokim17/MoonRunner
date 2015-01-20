//
//  Badge.h
//  MoonRunner
//
//  Created by Jonathan Kim on 1/20/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Badge : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *information;
@property float distance;

@end
