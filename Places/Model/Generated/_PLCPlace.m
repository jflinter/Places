// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCPlace.m instead.

#import "_PLCPlace.h"

const struct PLCPlaceAttributes PLCPlaceAttributes = {
	.caption = @"caption",
	.deletedAt = @"deletedAt",
	.geocodedAddress = @"geocodedAddress",
	.imageIds = @"imageIds",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.placeType = @"placeType",
	.uuid = @"uuid",
};

const struct PLCPlaceRelationships PLCPlaceRelationships = {
	.map = @"map",
};

const struct PLCPlaceFetchedProperties PLCPlaceFetchedProperties = {
};

@implementation PLCPlaceID
@end

@implementation _PLCPlace

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Place";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Place" inManagedObjectContext:moc_];
}

- (PLCPlaceID*)objectID {
	return (PLCPlaceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"placeTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"placeType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic caption;






@dynamic deletedAt;






@dynamic geocodedAddress;






@dynamic imageIds;






@dynamic latitude;



- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic placeType;



- (int16_t)placeTypeValue {
	NSNumber *result = [self placeType];
	return [result shortValue];
}

- (void)setPlaceTypeValue:(int16_t)value_ {
	[self setPlaceType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePlaceTypeValue {
	NSNumber *result = [self primitivePlaceType];
	return [result shortValue];
}

- (void)setPrimitivePlaceTypeValue:(int16_t)value_ {
	[self setPrimitivePlaceType:[NSNumber numberWithShort:value_]];
}





@dynamic uuid;






@dynamic map;

	






@end
