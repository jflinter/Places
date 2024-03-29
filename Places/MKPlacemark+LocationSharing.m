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

NSString * const MKPlaceMarkPLCMapFieldNameKey = @"MKPlaceMarkPLCMapFieldNameKey";
NSString * const MKPlaceMarkPLCMapFieldValueKey = @"MKPlaceMarkPLCMapFieldValueKey";
NSString * const MKPlaceMarkPLCMapPreviewKey = @"MKPlaceMarkPLCMapPreviewKey";

@implementation MKPlacemark (LocationSharing)

- (NSURL *)jrf_temporaryFileURLForLocationSharingWithOptions:(NSDictionary *)options
                                                   error:(NSError *__autoreleasing *)error {
    ABRecordRef person = ABPersonCreate();
    ABRecordRef people[1] = { person };
    CFErrorRef errorRef = NULL;
    
    NSString *address = options[MKPlaceMarkPLCMapPreviewKey];
    if (!address) {
        address = ABCreateStringWithAddressDictionary(self.addressDictionary, NO);
    }
    
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)address, &errorRef);
    
    ABMutableMultiValueRef multiHome = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    
    NSMutableDictionary *mutableAddressDictionary = [self.addressDictionary mutableCopy];
    if (options[MKPlaceMarkPLCMapFieldNameKey] && options[MKPlaceMarkPLCMapFieldValueKey]) {
        NSString *mapUrlDesc = [options[MKPlaceMarkPLCMapFieldValueKey] description];
        mutableAddressDictionary[@"Url"] = mapUrlDesc;
    }
    
    ABMultiValueAddValueAndLabel(multiHome, (__bridge CFTypeRef)(mutableAddressDictionary), kABHomeLabel, NULL);
    ABRecordSetValue(person, kABPersonAddressProperty, multiHome, &errorRef);
    CFRelease(multiHome), multiHome = NULL;
    
    ABMutableMultiValueRef multiURL = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    NSString *urlDesc = [[self jrf_appleMapsURL] description];
    ABMultiValueAddValueAndLabel(multiURL, (__bridge CFTypeRef)urlDesc, CFSTR("Open in Maps"), NULL);
    
    ABRecordSetValue(person, kABPersonURLProperty, multiURL, &errorRef);
    CFRelease(multiURL), multiURL = NULL;
    
    if (errorRef) {
        if (error) {
            *error = CFBridgingRelease(errorRef);
        }
        CFRelease(person), person = NULL;
        return nil;
    }

    CFArrayRef peopleArray = CFArrayCreate(NULL, (void *)people, 1, &kCFTypeArrayCallBacks);
    NSData *data = (__bridge_transfer NSData *)ABPersonCreateVCardRepresentationWithPeople(peopleArray);

    NSURL *url = [self jrf_generateTemporaryURL];
    if (![data writeToURL:url options:NSDataWritingFileProtectionNone | NSDataWritingAtomic error:error]) {
        url = nil;
    }
    
    CFRelease(peopleArray), peopleArray = NULL;
    CFRelease(person), person = NULL;

    return url;
}

- (NSURL *)jrf_generateTemporaryURL {
    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByAppendingString:@".loc"];
    NSString *fileName = [uuid stringByAppendingPathExtension:@"vcf"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:filePath isDirectory:NO];
}

// https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
- (NSURL *)jrf_appleMapsURL {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"http://maps.apple.com/"];
    NSString *sll = [NSString stringWithFormat:@"%.06f,%.06f", self.coordinate.latitude, self.coordinate.longitude];
    NSString *address = ABCreateStringWithAddressDictionary(self.addressDictionary, YES);
    components.jrf_queryDictionary = @{
                                   @"sll": sll,
                                   @"q"  : address,
                                   };
    return [components URL];
}

@end
