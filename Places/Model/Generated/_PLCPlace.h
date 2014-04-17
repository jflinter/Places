// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCPlace.h instead.

#import <CoreData/CoreData.h>
#import "PLCManagedObject.h"

extern const struct PLCPlaceAttributes {
	__unsafe_unretained NSString *caption;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
} PLCPlaceAttributes;

extern const struct PLCPlaceRelationships {
} PLCPlaceRelationships;

extern const struct PLCPlaceFetchedProperties {
} PLCPlaceFetchedProperties;






@interface PLCPlaceID : NSManagedObjectID {}
@end

@interface _PLCPlace : PLCManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PLCPlaceID*)objectID;





@property (nonatomic, strong) NSString* caption;



//- (BOOL)validateCaption:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;






@end

@interface _PLCPlace (CoreDataGeneratedAccessors)

@end

@interface _PLCPlace (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCaption;
- (void)setPrimitiveCaption:(NSString*)value;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




@end
