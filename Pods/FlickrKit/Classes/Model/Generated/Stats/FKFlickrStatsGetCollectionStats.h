//
//  FKFlickrStatsGetCollectionStats.h
//  FlickrKit
//
//  Generated by FKAPIBuilder on 19 Sep, 2014 at 10:49.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrAPIMethod.h"

typedef enum {
	FKFlickrStatsGetCollectionStatsError_UserDoesNotHaveStats = 1,		 /* The user you have requested stats has not enabled stats on their account. */
	FKFlickrStatsGetCollectionStatsError_NoStatsForThatDate = 2,		 /* No stats are available for the date requested. Flickr only keeps stats data for the last 28 days. */
	FKFlickrStatsGetCollectionStatsError_InvalidDate = 3,		 /* The date provided could not be parsed */
	FKFlickrStatsGetCollectionStatsError_CollectionNotFound = 4,		 /* The collection id was either invalid or was for a collection not owned by the calling user. */
	FKFlickrStatsGetCollectionStatsError_SSLIsRequired = 95,		 /* SSL is required to access the Flickr API. */
	FKFlickrStatsGetCollectionStatsError_InvalidSignature = 96,		 /* The passed signature was invalid. */
	FKFlickrStatsGetCollectionStatsError_MissingSignature = 97,		 /* The call required signing but no signature was sent. */
	FKFlickrStatsGetCollectionStatsError_LoginFailedOrInvalidAuthToken = 98,		 /* The login details or auth token passed were invalid. */
	FKFlickrStatsGetCollectionStatsError_UserNotLoggedInOrInsufficientPermissions = 99,		 /* The method requires user authentication but the user was not logged in, or the authenticated method call did not have the required permissions. */
	FKFlickrStatsGetCollectionStatsError_InvalidAPIKey = 100,		 /* The API key passed was not valid or has expired. */
	FKFlickrStatsGetCollectionStatsError_ServiceCurrentlyUnavailable = 105,		 /* The requested service is temporarily unavailable. */
	FKFlickrStatsGetCollectionStatsError_WriteOperationFailed = 106,		 /* The requested operation failed due to a temporary issue. */
	FKFlickrStatsGetCollectionStatsError_FormatXXXNotFound = 111,		 /* The requested response format was not found. */
	FKFlickrStatsGetCollectionStatsError_MethodXXXNotFound = 112,		 /* The requested method was not found. */
	FKFlickrStatsGetCollectionStatsError_InvalidSOAPEnvelope = 114,		 /* The SOAP envelope send in the request could not be parsed. */
	FKFlickrStatsGetCollectionStatsError_InvalidXMLRPCMethodCall = 115,		 /* The XML-RPC request document could not be parsed. */
	FKFlickrStatsGetCollectionStatsError_BadURLFound = 116,		 /* One or more arguments contained a URL that has been used for abuse on Flickr. */

} FKFlickrStatsGetCollectionStatsError;

/*

Get the number of views on a collection for a given date.


Response:

<stats views="24" />

*/
@interface FKFlickrStatsGetCollectionStats : NSObject <FKFlickrAPIMethod>

/* Stats will be returned for this date. This should be in either be in YYYY-MM-DD or unix timestamp format.

A day according to Flickr Stats starts at midnight GMT for all users, and timestamps will automatically be rounded down to the start of the day. */
@property (nonatomic, copy) NSString *date; /* (Required) */

/* The id of the collection to get stats for. */
@property (nonatomic, copy) NSString *collection_id; /* (Required) */


@end
