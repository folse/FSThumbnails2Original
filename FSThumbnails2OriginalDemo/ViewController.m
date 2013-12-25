//
//  ViewController.m
//  FSThumbnails2OriginalDemo
//
//  Created by folse on 11/26/13.
//  Copyright (c) 2013 folse. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "F.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *imgUrl = @"http://ww4.sinaimg.cn/large/628547degw1ebvsapc66kj20hs0vkdn3.jpg";
    
    [_bgImageView setImage:[UIImage imageNamed:@"bg"]];
    
    NSString *downloadPath = [[F alloc] getMD5FilePathWithUrl:imgUrl];
    
    NSURLRequest *photoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imgUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:photoRequest];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:downloadPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        UIImage *shopImage = [UIImage imageWithContentsOfFile:downloadPath];
        
        int totalExpectedToRead = [[NSString stringWithFormat:@"%lld",totalBytesExpectedToRead] intValue];
        int totalRead = [[NSString stringWithFormat:@"%lld",totalBytesRead] intValue];
        
        float scaleProgress = (float)totalRead/(float)totalExpectedToRead;
        
        [_coverImageView setFrame:CGRectMake(0, 0, 320, 568*scaleProgress)];
        _coverImageView.image = [self cutImage:shopImage withScale:scaleProgress];
        
    }];
    
    [operation setCompletionBlock:^{
        UIImage *shopImage = [UIImage imageWithContentsOfFile:downloadPath];
        [_coverImageView setFrame:CGRectMake(0, 0, 320, 568)];
        _coverImageView.image = shopImage;
    }];
    
    [operation start];
}

-(UIImage *)cutImage:(UIImage *)superImage withScale:(float)scale{
    
    CGSize subImageSize = CGSizeMake(superImage.size.width,superImage.size.height);
    //定义裁剪的区域相对于原图片的位置
    CGRect subImageRect = CGRectMake(0, 0, superImage.size.width,superImage.size.height*scale);
    CGImageRef imageRef = superImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
    UIGraphicsBeginImageContext(subImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImageRect, subImageRef);
    UIImage* returnImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext(); //返回裁剪的部分图像
    return returnImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
