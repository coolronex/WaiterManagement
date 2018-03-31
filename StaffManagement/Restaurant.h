//
//  Restaurant.h
//  StaffManagement
//
//  Created by Derek Harasen on 2015-03-14.
//  Copyright (c) 2015 Derek Harasen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Restaurant : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *staff;
@end

@interface Restaurant (CoreDataGeneratedAccessors)

- (void)addStaffObject:(NSManagedObject *)value;
- (void)removeStaffObject:(NSManagedObject *)value;
- (void)addStaff:(NSSet *)values;
- (void)removeStaff:(NSSet *)values;

@end
