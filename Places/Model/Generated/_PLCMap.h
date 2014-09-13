// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCMap.h instead.

#import <CoreData/CoreData.h>
#import "PLCManagedObject.h"

extern const struct PLCMapAttributes {
	__unsafe_unretained NSString *deletedAt;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *selected;
	__unsafe_unretained NSString *uuid;
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





@property (nonatomic, strong) NSDate* deletedAt;



//- (BOOL)validateDeletedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* selected;



@property BOOL selectedValue;
- (BOOL)selectedValue;
- (void)setSelectedValue:(BOOL)value_;

//- (BOOL)validateSelected:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;





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


- (NSDate*)primitiveDeletedAt;
- (void)setPrimitiveDeletedAt:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveSelected;
- (void)setPrimitiveSelected:(NSNumber*)value;

- (BOOL)primitiveSelectedValue;
- (void)setPrimitiveSelectedValue:(BOOL)value_;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;





- (NSMutableSet*)primitivePlaces;
- (void)setPrimitivePlaces:(NSMutableSet*)value;


@end
