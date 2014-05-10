// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCMap.h instead.

#import <CoreData/CoreData.h>
#import "PLCManagedObject.h"

extern const struct PLCMapAttributes {
	__unsafe_unretained NSString *name;
} PLCMapAttributes;

extern const struct PLCMapRelationships {
	__unsafe_unretained NSString *places;
} PLCMapRelationships;

extern const struct PLCMapFetchedProperties {
} PLCMapFetchedProperties;

@class PLCPlace;



@interface PLCMapID : NSManagedObjectID {}
@end

@interface _PLCMap : PLCManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PLCMapID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *places;

- (NSMutableSet*)placesSet;





@end

@interface _PLCMap (CoreDataGeneratedAccessors)

- (void)addPlaces:(NSSet*)value_;
- (void)removePlaces:(NSSet*)value_;
- (void)addPlacesObject:(PLCPlace*)value_;
- (void)removePlacesObject:(PLCPlace*)value_;

@end

@interface _PLCMap (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitivePlaces;
- (void)setPrimitivePlaces:(NSMutableSet*)value;


@end
