//
//  Tender.m
//  Shopify
//
//  Created by Matt Newberry on 12/11/09.
//  Copyright 2009 Jaded Pixel Technologies Inc. All rights reserved.
//

#import "Tender.h"
#import "JSON.h"

static Tender *_sharedInstance;
#define AUTH @""
#define ACCOUNT_NAME @""
#define API_URL @"api.tenderapp.com"


@implementation Tender

@synthesize finished;
@synthesize responseCode;
@synthesize responseData;
@synthesize connection;


+ (Tender *) shared{
	
	if(!_sharedInstance){
	
		_sharedInstance = [[Tender alloc] init];
	}
	
	return _sharedInstance;
}

- (NSDictionary *) send:(NSString *) resource payload:(NSString *)payload method:(NSString *)method{
		
	finished = NO;
	
	NSString *urlString	= [NSString stringWithFormat:@"http://%@/%@/%@?auth=%@", API_URL, ACCOUNT_NAME, resource, AUTH];
	
	NSURL* url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:4]];
	
	NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	[urlRequest setHTTPMethod:method];
	
	NSString *contentType = @"application/json";
	
	if([method isEqualToString:@"GET"] && payload)
		[urlRequest setURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@?%@", urlString, payload] stringByAddingPercentEscapesUsingEncoding:4]]];
	else{
		[urlRequest setHTTPBody:[payload dataUsingEncoding:NSASCIIStringEncoding]];
	}
		
			
	[urlRequest setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"application/vnd.tender-v1+json", @"Accept", contentType, @"Content-Type", nil]];
	
	connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[connection start];
	
	NSString *response;
	
	if(connection){
		
		responseData = [[NSMutableData data] retain];
		
		while (!finished) {			
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:60.0]];
		}
		
		response = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] autorelease];
	}
	
	[urlRequest release];
	
	return [response length] > 0 ? [response JSONValue] : nil;
}



/*	Categories		*/

- (NSDictionary *) categories{
		
	return [self send:@"categories" payload:nil method:@"GET"];
}

- (NSDictionary *) category:(NSInteger) categoryID{
	
	return [self send:[NSString stringWithFormat:@"categories/%i", categoryID] payload:nil method:@"GET"];
}


/*	Discussions		*/

- (NSDictionary *) discussions:(NSString *) state{
	
	NSString *resource = state ? [NSString stringWithFormat:@"discussions/%@", state] : @"discussions";
	
	return [self send:resource payload:nil method:@"GET"];
}

- (NSDictionary *) discussion:(NSInteger) discussionID{
		
	return [self send:[NSString stringWithFormat:@"discussions/%i", discussionID] payload:nil method:@"GET"];
}

- (NSDictionary *) createDiscussion:(NSString *) title categoryID:(NSInteger)categoryID public:(BOOL)public authorEmail:(NSString *)authorEmail body:(NSString *)body skipSpam:(BOOL)skipSpam{
	
	NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", [NSNumber numberWithBool:public] , @"public", authorEmail, @"author_email", body, @"body", [NSNumber numberWithBool:skipSpam], @"skip_spam", [NSNumber numberWithInt:categoryID] , @"category_id", nil];
		
	return [self send:[NSString stringWithFormat:@"categories/%i/discussions", categoryID] payload:[payload JSONRepresentation] method:@"POST"];
}

- (NSDictionary *) commentOnDiscussion:(NSInteger)discussionID authorEmail:(NSString *)authorEmail body:(NSString *)body skipSpam:(BOOL)skipSpam{
	
	NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:authorEmail, @"author_email", body, @"body", [NSNumber numberWithBool:skipSpam], @"skip_spam", nil];
	
	return [self send:[NSString stringWithFormat:@"discussions/%i/comments", discussionID] payload:[payload JSONRepresentation] method:@"POST"];
}

- (void) deleteDiscussion:(NSInteger) discussion_id{
	
	[self send:[NSString stringWithFormat:@"discussions/%i", discussion_id] payload:nil method:@"DELETE"];
}




/*	Sections		*/

- (NSDictionary *) sections{
	
	return [self send:@"sections" payload:nil method:@"GET"];
}

- (NSDictionary *) section:(NSInteger) sectionID{
	
	return [self send:[NSString stringWithFormat:@"sections/%i", sectionID] payload:nil method:@"GET"];
}


/*	FAQS		*/

- (NSDictionary *) faqs{
		
	return [self send:@"faqs" payload:nil method:@"GET"];
}

- (NSDictionary *) faq:(NSInteger) faqID{
	
	return [self send:[NSString stringWithFormat:@"faqs/%i", faqID] payload:nil method:@"GET"];
}

- (NSDictionary *) createFAQ:(NSString *) title sectionID:(NSInteger)sectionID keywords:(NSString *)keywords body:(NSString *)body{
	
	NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", body, @"body", keywords, @"keywords", nil];
	
	return [self send:[NSString stringWithFormat:@"sections/%i/faqs", sectionID] payload:[payload JSONRepresentation] method:@"POST"];
}

- (NSDictionary *) updateFAQ:(NSString *) title faqID:(NSInteger)faqID keywords:(NSString *)keywords body:(NSString *)body{
	
	NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", body, @"body", keywords, @"keywords", nil];
	
	return [self send:[NSString stringWithFormat:@"faqs/%i", faqID] payload:[payload JSONRepresentation] method:@"PUT"];
}










/*	Utilities	*/


- (NSString *) requestString:(NSDictionary *) payload{
	
	NSMutableArray *request	= [NSMutableArray array];
	
	for(NSString *field in payload){
		
		[request addObject:[NSString stringWithFormat:@"%@=%@", field, [payload objectForKey:field]]];
	}
	
	return [[request componentsJoinedByString:@"&"] stringByAddingPercentEscapesUsingEncoding:4];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	[responseData setLength:0];
	
	responseCode = [response statusCode];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	finished = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	finished = YES;
}

- (void)dealloc{
	
	[responseData release];
	[connection release];
	
	[super dealloc];
}


@end
