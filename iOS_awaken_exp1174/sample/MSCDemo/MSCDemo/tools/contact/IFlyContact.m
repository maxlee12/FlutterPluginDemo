//
//  IFlyContact.m
//  msc
//
//  Created by ypzhao on 13-3-1.
//  Copyright (c) 2013年 IFLYTEK. All rights reserved.
//

#import "IFlyContact.h"

#import <AddressBook/AddressBook.h> /*AddressBook.framework*/
#import <Contacts/Contacts.h>
#import <UIKit/UIKit.h>

@interface IFlyContact(private)
- (NSString *) toString:(NSMutableArray *) array;
@end

@implementation IFlyContact

-(NSString *) contact{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    if ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending){
        
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);

            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                
                dispatch_semaphore_signal(sema);
                
            }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//            dispatch_release(sema);
        }
        
        NSMutableArray *addreBookArray = [self fetchContactWithContactStore:contactStore];
        
//        [contactStore release];
        
        if (addreBookArray == nil || [addreBookArray count] == 0) {
            return nil;
        }
        else {
            return [self toString: addreBookArray];
        }
    }else
#endif
    {
     
    
        ABAddressBookRef addressBook = nil;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
        if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) {
            
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            //等待同意后向下执行
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         dispatch_semaphore_signal(sema);
                                                     });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//            dispatch_release(sema);
        }
        else 
#endif
        {
            addressBook = ABAddressBookCreate();
        }
        NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
        
        if(allPeople == nil){
//            [IFlyDebugLog showLog:@"contact count :0"];
            NSLog(@"contact count :0");
            if(addressBook){
                CFRelease(addressBook);
            }
            return nil;
        }
        else{
//            [IFlyDebugLog showLog:@"contact count :%d",[allPeople count]];
            NSLog(@"contact count :%d",[allPeople count]);
        }
        
        NSMutableArray *addreBookArray = [NSMutableArray arrayWithCapacity:[allPeople count]];

        for (id person in (NSArray *)allPeople) {
            NSString *personName = (NSString*)CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(person), kABPersonFirstNameProperty));
            NSString *lastName = (NSString *) CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(person), kABPersonLastNameProperty));

            if ([personName length] ==0 && [lastName length] == 0) {
                
            }
            else if ([personName length] == 0) {
                NSString *name = [NSString stringWithFormat:@"%@", lastName];
                [addreBookArray addObject:name];
            }
            else if ([lastName length] == 0) {
                NSString *name = [NSString stringWithFormat:@"%@",personName];
                [addreBookArray addObject:name];
            }
            else {
                NSString *name = [NSString stringWithFormat:@"%@%@",lastName,personName];
                [addreBookArray addObject:name];
            }
        }
        if (addressBook) {
            CFRelease(addressBook);
        }
        return [self toString: addreBookArray];
    
    
    }
}

#pragma mark owner

- (NSString *) toString:(NSMutableArray *) array
{
    NSArray *addressArray = [[NSArray alloc] initWithArray: array];
    if (!addressArray) {
        return nil;
    }
    NSMutableString *address = [NSMutableString stringWithCapacity: [addressArray count]];
    for (int i = 0; i < [addressArray count]; i++) {
        [address appendFormat:@"%@\n",[addressArray objectAtIndex: i]];
    }
    return address;
}

- (NSMutableArray *)fetchContactWithContactStore:(CNContactStore *)contactStore{
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactFamilyNameKey, CNContactGivenNameKey]];
        
        NSError *error = nil;
        NSMutableArray *addreBookArray = [NSMutableArray array];
        
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            if (!error){
                
                if ([contact.familyName length] != 0 && [contact.givenName length] !=0) {
                    NSString *name = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
                    [addreBookArray addObject:name];
                }else if ([contact.familyName length] != 0) {
                    NSString *name = [NSString stringWithFormat:@"%@",contact.familyName];
                    [addreBookArray addObject:name];
                }else {
                    NSString *name = [NSString stringWithFormat:@"%@",contact.givenName];
                    [addreBookArray addObject:name];
                }
                
            }
        }];
        
        
        return addreBookArray;
    }
    
    return nil;
}


@end
