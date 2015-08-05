//
//  WebViewController.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/15/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "WebViewController.h"
#import "User.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) User *user;
@end

@implementation WebViewController

- (instancetype) initWithUser:(User *)user {
    self = [super init];
    if (self) {
        self.webView.delegate = self;
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad {
    NSString *path = [NSString stringWithFormat:@"https://www.facebook.com/app_scoped_user_id/%@", self.user.FBID];
    NSURL *toRedirect = [NSURL URLWithString:path];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:toRedirect];
    //webView loads profile based on app_scoped_user_id
    [self.webView loadRequest:urlRequest];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //called when the button is tapped, since a request was loaded
    NSURL *redirect = self.webView.request.URL;
    //obtains username based on the redirected url
    NSString *payload =  [redirect.absoluteString componentsSeparatedByString:@"/"][3];
    //creates payload and calls last method
    NSString *check=[payload substringToIndex:3];
    NSString *otherCheck = [payload substringToIndex:10];
    if(![check isEqualToString:@"log"] && ![otherCheck isEqualToString:@"checkpoint"]){
        [self payloadIsReady: payload];
    }
}

- (void) payloadIsReady:(NSString *) payload{
    //forms internal FB Messenger link and then launches
    NSString *messenger = [NSString stringWithFormat:@"fb-messenger://user-thread/%@", payload];
    NSURL *toOpen = [NSURL URLWithString:messenger];
    self.user.url = toOpen.absoluteString;
    [self.user saveInBackground];
    [self dismissViewControllerAnimated:YES completion:^{
        self.block(self.user);
    }];
}
@end
