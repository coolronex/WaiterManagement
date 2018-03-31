//
//  ViewController.m
//  StaffManagement
//
//  Created by Derek Harasen on 2015-03-14.
//  Copyright (c) 2015 Derek Harasen. All rights reserved.
//

#import "WaiterListViewController.h"
#import "Restaurant.h"
#import "RestaurantManager.h"
#import "Waiter.h"
#import "AppDelegate.h"

static NSString * const kCellIdentifier = @"waiterCell";

@interface WaiterListViewController () <NSFetchedResultsControllerDelegate>

@property IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *waiters;
@property (nonatomic, strong) Restaurant *currentRestaurant;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation WaiterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentRestaurant = [[RestaurantManager sharedManager]currentRestaurant];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self setupFetchResultsController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

- (IBAction)addWaiterTapped:(UIBarButtonItem *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Waiter"
                                                                   message:@"Add new waiter to list"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     
                                                     UITextField *waiterTextField = alert.textFields.firstObject;
                                                     
                                                     NSEntityDescription *waiterEntity = [NSEntityDescription entityForName:@"Waiter" inManagedObjectContext:self.managedObjectContext];
                                                     Waiter *newWaiter = [[Waiter alloc]initWithEntity:waiterEntity insertIntoManagedObjectContext:self.managedObjectContext];
                                                     
                                                     newWaiter.name = waiterTextField.text;
                                                     newWaiter.restaurant = self.currentRestaurant;
                                                     
                                                     [self.currentRestaurant addStaffObject:newWaiter];
                                                     
                                                     NSError *error = nil;
                                                     if ([self.managedObjectContext save:&error] == NO) {
                                                         NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                                                     }
                                                 }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       nil;
                                                   }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Waiter Name";
    }];
    
    [alert addAction:save];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        nil;
    }];
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Waiter *waiter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withWaiter:waiter];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell withWaiter:(Waiter *)waiter {
    cell.textLabel.text = waiter.name;
}

#pragma mark - Fetched Results Controller

- (void)setupFetchResultsController {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Waiter"];
    NSSortDescriptor *nameSortByAscending = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[nameSortByAscending]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] withWaiter:anObject];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}






@end
