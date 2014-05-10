//
//  MKPlacemark+LocationSharing.m
//  Places
//
//  Created by Jack Flintermann on 5/9/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "MKPlacemark+LocationSharing.h"
#import "NSURLComponents+QueryDictionary.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation MKPlacemark (LocationSharing)

- (NSURL *)temporaryFileURLForLocationSharing:(NSError**)error {
    ABRecordRef people[1];
    ABRecordRef person = ABPersonCreate();
    CFErrorRef errorRef = NULL;
    
    NSString *address = ABCreateStringWithAddressDictionary(self.addressDictionary, NO);
    
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)address, &errorRef);
    
    ABMutableMultiValueRef multiHome = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    ABMultiValueAddValueAndLabel(multiHome, (__bridge CFTypeRef)(self.addressDictionary), kABHomeLabel, NULL);
    ABRecordSetValue(person, kABPersonAddressProperty, multiHome, &errorRef);
    
    ABMutableMultiValueRef multiURL = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    NSURL *mapsUrl = [self appleMapsURL];
    NSString *urlDesc = [mapsUrl description];
    ABMultiValueAddValueAndLabel(multiURL, (__bridge CFTypeRef)urlDesc, CFSTR("map url"), NULL);
    ABRecordSetValue(person, kABPersonURLProperty, multiURL, &errorRef);
    
    if (errorRef) {
        *error = CFBridgingRelease(errorRef);
        return nil;
    }
    
    people[0] = person;
    CFArrayRef peopleArray = CFArrayCreate(NULL, (void *)people, 1, &kCFTypeArrayCallBacks);
    CFDataRef dataRef = ABPersonCreateVCardRepresentationWithPeople(peopleArray);
    NSData *data = (__bridge_transfer NSData*)dataRef;
    NSURL *url = [self generateTemporaryURL];
    NSError *fileError;
    [data writeToURL:url options:NSDataWritingFileProtectionNone | NSDataWritingAtomic error:&fileError];
    
    CFRelease(peopleArray);
    CFRelease(person);
    
    if (fileError) {
        *error = fileError;
        return nil;
    }
    
    return url;
}

- (NSURL *)generateTemporaryURL {
    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByAppendingString:@".loc"];
    NSString *fileName = [uuid stringByAppendingPathExtension:@"vcf"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:filePath isDirectory:NO];
}

// https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
- (NSURL *)appleMapsURL {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"http://maps.apple.com/"];
    NSString *sll = [NSString stringWithFormat:@"%.06f,%.06f", self.coordinate.latitude, self.coordinate.longitude];
    NSString *address = ABCreateStringWithAddressDictionary(self.addressDictionary, YES);
    components.queryDictionary = @{
                                   @"sll": sll,
                                   @"q"  : address,
                                   };
    return [components URL];
}

@end
