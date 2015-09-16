//
//  uexCV_TableView.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_TableView.h"

@implementation uexCV_TableView




- (void)setContentSize:(CGSize)contentSize
{
    //上拉刷新不滑动至顶端
    /*
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero))
    {
        if (contentSize.height > self.contentSize.height)
        {
            CGPoint offset = self.contentOffset;
            NSLog(@"yy:%f",offset.y);
            offset.y += (contentSize.height - self.contentSize.height);
            NSLog(@"yy+:%f",offset.y);
            self.contentOffset = offset;
        }
    }
    */
    //NSLog(@"yy:%f",self.contentOffset.y);
    [super setContentSize:contentSize];
}
@end
