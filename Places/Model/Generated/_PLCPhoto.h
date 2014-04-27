// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCPhoto.h instead.

#import <CoreData/CoreData.h>
#import "PLCManagedObject.h"

extern const struct PLCPhotoAttributes {
	__unsafe_unretained NSString *image;
} PLCPhotoAttributes;

extern const struct PLCPhotoRelationships {
	__unsafe_unretained NSString *place;
} PLCPhotoRelationships;

extern const struct PLCPhotoFetchedProperties {
} PLCPhotoFetchedProperties;

@class PLCPlace;

@class NSObject;

@interface PLCPhotoID : NSManagedObjectID {}
@end

@interface _PLCPhoto : PLCManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PLCPhotoID*)objectID;





@property (nonatomic, strong) id image;



//- (BOOL)validateImage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) PLCPlace *place;

//- (BOOL)validatePlace:(id*)value_ error:(NSError**)error_;





@end

@interface _PLCPhoto (CoreDataGeneratedAccessors)

@end

@interface _PLCPhoto (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveImage;
- (void)setPrimitiveImage:(id)value;





- (PLCPlace*)primitivePlace;
- (void)setPrimitivePlace:(PLCPlace*)value;


@end
