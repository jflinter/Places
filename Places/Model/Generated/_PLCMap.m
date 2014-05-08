// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCMap.m instead.

#import "_PLCMap.h"

const struct PLCMapAttributes PLCMapAttributes = {
	.name = @"name",
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
	

	return keyPaths;
}




@dynamic name;






@dynamic places;

	
- (NSMutableSet*)placesSet {
	[self willAccessValueForKey:@"places"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"places"];
  
	[self didAccessValueForKey:@"places"];
	return result;
}
	






@end
