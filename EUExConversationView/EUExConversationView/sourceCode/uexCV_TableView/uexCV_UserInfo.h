//
//  uexCV_UserInfo.h
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor(uexConversationView)

+(instancetype)uexCV_colorFromHtmlString:(NSString *)colorString;


@end






@interface uexCV_UserInfo : NSObject
@property(nonatomic,strong)UIImage * photo;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,strong)UIColor * fontColor;
@property(nonatomic,copy)NSString * nickname;

-(instancetype)initWithPhoto:(UIImage *)photo
                    fontSize:(CGFloat)size
                   fontColor:(UIColor*)color
                    nickname:(NSString *)nick;

@end
