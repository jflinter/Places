// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCMap.m instead.

#import "_PLCMap.h"

const struct PLCMapAttributes PLCMapAttributes = {
	.deletedAt = @"deletedAt",
	.name = @"name",
	.selected = @"selected",
	.uuid = @"uuid",
};

const struct PLCMapRelationships PLCMapRelationships = {
	.places = @"places",
};

const struct PLCMapFetchedProperties PLCMapFetchedProperties = {
};

@implementation PLCMapID
@end

@implementation _PLCMap

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Map" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Map";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Map" inManagedObjectContext:moc_];
}

- (PLCMapID*)objectID {
	return (PLCMapID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"selectedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"selected"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic deletedAt;






@dynamic name;






@dynamic selected;



- (BOOL)selectedValue {
	NSNumber *result = [self selected];
	return [result boolValue];
}

- (void)setSelectedValue:(BOOL)value_ {
	[self setSelected:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSelectedValue {
	NSNumber *result = [self primitiveSelected];
	return [result boolValue];
}

- (void)setPrimitiveSelectedValue:(BOOL)value_ {
	[self setPrimitiveSelected:[NSNumber numberWithBool:value_]];
}





@dynamic uuid;






@dynamic places;

	
- (NSMutableSet*)placesSet {
	[self willAccessValueForKey:@"places"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"places"];
  
	[self didAccessValueForKey:@"places"];
	return result;
}
	






@end
