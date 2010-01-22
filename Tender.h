//
//  Tender.h
//  Shopify
//
//  Created by Matt Newberry on 12/11/09.
//  Copyright 2009 Jaded Pixel Technologies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tender : NSObject {

	BOOL finished;
	int responseCode;
	NSMutableData *responseData;
	NSURLConnection *connection;
}

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) int responseCode;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *connection;

+ (Tender *) shared;

- (NSDictionary *) categories;
- (NSDictionary *) category:(NSInteger) categoryID;

- (NSDictionary *) discussions:(NSString *) state;
- (NSDictionary *) discussion:(NSInteger) discussion_id;
- (NSDictionary *) createDiscussion:(NSString *) title categoryID:(NSInteger)categoryID public:(BOOL)public authorEmail:(NSString *)authorEmail body:(NSString *)body skipSpam:(BOOL)skipSpam;
- (NSDictionary *) commentOnDiscussion:(NSInteger)discussionID authorEmail:(NSString *)authorEmail body:(NSString *)body skipSpam:(BOOL)skipSpam;
- (void) deleteDiscussion:(NSInteger) discussion_id;

- (NSDictionary *) sections;
- (NSDictionary *) section:(NSInteger) sectionID;

- (NSDictionary *) createFAQ:(NSString *) title sectionID:(NSInteger)sectionID keywords:(NSString *)keywords body:(NSString *)body;
- (NSDictionary *) updateFAQ:(NSString *) title faqID:(NSInteger)faqID keywords:(NSString *)keywords body:(NSString *)body;


@end
