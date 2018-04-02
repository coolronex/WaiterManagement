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
#import "StaffManagement-Swift.h"

@interface WaiterListViewController () <NSFetchedResultsControllerDelegate>

@property IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *waiters;
@property (nonatomic, strong) Restaurant *currentRestaurant;
@property (nonatomic, strong) Waiter *waiter;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation WaiterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentRestaurant = [[RestaurantManager sharedManager]currentRestaurant];
    [self setupFetchResultsController];
    [self setupViewController];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"waiterCell" forIndexPath:indexPath];
    
    Waiter *waiter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withWaiter:waiter];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell withWaiter:(Waiter *)waiter {
    cell.textLabel.text = waiter.name;
    [cell.textLabel setFont:[UIFont fontWithName:@"Futura" size: 18]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Fetched Results Controller

- (void)setupFetchResultsController {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Waiter"];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortByName]];
    
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showWaiterShifts"]) {
        
        WaiterShiftsTableVC *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.waiter = [self.fetchedResultsController objectAtIndexPath: indexPath];
        vc.waiter = self.waiter;
        vc.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark - Private Functions

- (void)setupViewController {
    
    UIImage *image = [UIImage imageNamed:@"TouchBistro-logo"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 170, 35);
    imageView.contentMode = UIViewContentModeCenter;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
}

@end
