// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PLCPhoto.m instead.

#import "_PLCPhoto.h"

const struct PLCPhotoAttributes PLCPhotoAttributes = {
	.image = @"image",
	.uuid = @"uuid",
};

const struct PLCPhotoRelationships PLCPhotoRelationships = {
	.place = @"place",
};

const struct PLCPhotoFetchedProperties PLCPhotoFetchedProperties = {
};

@implementation PLCPhotoID
@end

@implementation _PLCPhoto

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Photo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:moc_];
}

- (PLCPhotoID*)objectID {
	return (PLCPhotoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic image;






@dynamic uuid;






@dynamic place;

	






@end
