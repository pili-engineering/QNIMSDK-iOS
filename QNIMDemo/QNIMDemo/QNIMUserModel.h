//
//  QNIMUserModel.h
//  QNIMDemo
//
//  Created by 郭茜 on 2021/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMUserModel : NSObject

@property (nonatomic, copy) NSString *im_uid;
@property (nonatomic, copy) NSString *im_username;
@property (nonatomic, copy) NSString *im_password;

@end

NS_ASSUME_NONNULL_END
