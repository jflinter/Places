// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCPhoto.h instead.

#import <CoreData/CoreData.h>
#import "PLCManagedObject.h"

extern const struct PLCPhotoAttributes {
	__unsafe_unretained NSString *imageData;
	__unsafe_unretained NSString *uuid;
} PLCPhotoAttributes;

extern const struct PLCPhotoRelationships {
	__unsafe_unretained NSString *place;
} PLCPhotoRelationships;

extern const struct PLCPhotoFetchedProperties {
} PLCPhotoFetchedProperties;

@class PLCPlace;




@interface PLCPhotoID : NSManagedObjectID {}
@end

@interface _PLCPhoto : PLCManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PLCPhotoID*)objectID;





@property (nonatomic, strong) NSData* imageData;



//- (BOOL)validateImageData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) PLCPlace *place;

//- (BOOL)validatePlace:(id*)value_ error:(NSError**)error_;





@end

@interface _PLCPhoto (CoreDataGeneratedAccessors)

@end

@interface _PLCPhoto (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveImageData;
- (void)setPrimitiveImageData:(NSData*)value;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;





- (PLCPlace*)primitivePlace;
- (void)setPrimitivePlace:(PLCPlace*)value;


@end
