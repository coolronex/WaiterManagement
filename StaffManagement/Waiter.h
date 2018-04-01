//
//  Waiter.h
//  StaffManagement
//
//  Created by Derek Harasen on 2015-03-14.
//  Copyright (c) 2015 Derek Harasen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Restaurant;
@class Shift;

@interface Waiter : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Restaurant *restaurant;
@property (nonatomic, retain) NSSet <Shift *> *shifts;

@end

@interface Waiter (CoreDataGeneratedAccessors)

- (void) addShiftObject:(Shift *)value;

@end
