//
//  ViewController.m
//  FacebookApp
//
//  Created by Angie Chilmaza on 9/18/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import "ViewControllerFB.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ViewControllerFB () <FBSDKLoginButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKSharingDelegate>


@property (nonatomic, assign) FBSDKDefaultAudience defaultAudience;
@property (weak, nonatomic) IBOutlet UILabel *fbFullname;
@property (weak, nonatomic) IBOutlet UILabel *fbEmail;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *fbProfilePicture;
@property (weak, nonatomic) IBOutlet UIButton *fbPostPhoto;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;
@end

@implementation ViewControllerFB

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    FBSDKLoginButton * loginButton = [[FBSDKLoginButton alloc] init];
//    loginButton.readPermissions = @[@"public_profile", @"email"];
//    loginButton.delegate = self;
//    self.fbLoginButton = loginButton;
    
    self.fbLoginButton.readPermissions = @[@"public_profile", @"email"];
    self.fbLoginButton.delegate = self;
    
    [self getUserInfo];
}


#pragma FBSDKLoginButtonDelegate

-(void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    self.defaultAudience = FBSDKDefaultAudienceOnlyMe;
    
    if([result.grantedPermissions containsObject:@"email"]){
        [self getUserInfo];
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
    self.fbFullname.text = @"Username";
    self.fbEmail.text = @"user@mail.com";
    
    NSLog(@"Logged out \n");
}

-(void)getUserInfo{
    
    if([FBSDKAccessToken currentAccessToken]){
        
        NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
        [parameters setValue:@"id,name,email,picture" forKey:@"fields"];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if(!error){
                
                NSLog(@"result = %@ \n", result);
                self.fbEmail.text = [result objectForKey:@"email"];
                self.fbFullname.text = result[@"name"];
                
                //                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square",result[@"id"]]];
                //                NSData  *imageData = [NSData dataWithContentsOfURL:url];
                //                UIImage * image = [UIImage imageWithData:imageData];
                //                self.fbProfileImage.image = image;
                
                //                NSURL * url = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
                
                FBSDKProfilePictureView *pictureView=[[FBSDKProfilePictureView alloc]init];
                [pictureView setProfileID:result[@"id"]];
                [pictureView setPictureMode:FBSDKProfilePictureModeSquare];
                self.fbProfilePicture = pictureView;
                
            }
        }];
    }
    
}
- (IBAction)postToTimeline:(id)sender {
    
    if(![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]){
        [self publishPermissions];
    }
    
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(void)publishPermissions{
    
    FBSDKLoginManager *facebookLogin = [[FBSDKLoginManager alloc] init];
    [facebookLogin logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        if (error) {
            NSLog(@"Facebook login failed. Error: %@", error.description);
        } else if (result.isCancelled) {
            NSLog(@"Facebook login got cancelled.");
        } else {
            NSString *accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
            NSLog(@"accessToken = %@ \n", accessToken);
            NSLog(@"result = %@ \n", result);
        }
    }];
}

#pragma UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    UIImage * chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed" parameters:@{@"message" :@"Hello world"}
    //                                       HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
    //
    //        if(!error){
    //            NSLog(@"Post id = %@\n", result[@"id"]);
    //        }
    //    }];
    
    //Share photo on Facebook
    FBSDKSharePhotoContent * content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[[FBSDKSharePhoto photoWithImage:chosenImage userGenerated:YES]];
    [FBSDKShareAPI shareWithContent:content delegate:self];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    
    NSLog(@"sharer: results=%@ \n", results);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    
    NSLog(@"sharer:didFailWithError error=%@\n", error.description);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
    NSLog(@"sharerDidCancel \n");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickBasicShare:(id)sender {
    // [FBDialogs presentShareDialogWithParamams]
    
}

@end
