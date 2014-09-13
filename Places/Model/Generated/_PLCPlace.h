// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCPlace.h instead.

#import <CoreData/CoreData.h>
#import "PLCManagedObject.h"

extern const struct PLCPlaceAttributes {
	__unsafe_unretained NSString *caption;
	__unsafe_unretained NSString *deletedAt;
	__unsafe_unretained NSString *geocodedAddress;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *placeType;
	__unsafe_unretained NSString *uuid;
} PLCPlaceAttributes;

extern const struct PLCPlaceRelationships {
	__unsafe_unretained NSString *map;
	__unsafe_unretained NSString *photos;
} PLCPlaceRelationships;

extern const struct PLCPlaceFetchedProperties {
} PLCPlaceFetchedProperties;

@class PLCMap;
@class PLCPhoto;



@class NSMutableDictionary;





@interface PLCPlaceID : NSManagedObjectID {}
@end

@interface _PLCPlace : PLCManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PLCPlaceID*)objectID;





@property (nonatomic, strong) NSString* caption;



//- (BOOL)validateCaption:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* deletedAt;



//- (BOOL)validateDeletedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSMutableDictionary* geocodedAddress;



//- (BOOL)validateGeocodedAddress:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSNumber* placeType;



@property int16_t placeTypeValue;
- (int16_t)placeTypeValue;
- (void)setPlaceTypeValue:(int16_t)value_;

//- (BOOL)validatePlaceType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) PLCMap *map;

//- (BOOL)validateMap:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *photos;

- (NSMutableSet*)photosSet;





@end

@interface _PLCPlace (CoreDataGeneratedAccessors)

- (void)addPhotos:(NSSet*)value_;
- (void)removePhotos:(NSSet*)value_;
- (void)addPhotosObject:(PLCPhoto*)value_;
- (void)removePhotosObject:(PLCPhoto*)value_;

@end

@interface _PLCPlace (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCaption;
- (void)setPrimitiveCaption:(NSString*)value;




- (NSDate*)primitiveDeletedAt;
- (void)setPrimitiveDeletedAt:(NSDate*)value;




- (NSMutableDictionary*)primitiveGeocodedAddress;
- (void)setPrimitiveGeocodedAddress:(NSMutableDictionary*)value;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSNumber*)primitivePlaceType;
- (void)setPrimitivePlaceType:(NSNumber*)value;

- (int16_t)primitivePlaceTypeValue;
- (void)setPrimitivePlaceTypeValue:(int16_t)value_;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;





- (PLCMap*)primitiveMap;
- (void)setPrimitiveMap:(PLCMap*)value;



- (NSMutableSet*)primitivePhotos;
- (void)setPrimitivePhotos:(NSMutableSet*)value;


@end
