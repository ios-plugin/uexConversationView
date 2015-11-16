//
//  uexCV_TextCell.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/15.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "uexCV_TextCell.h"




@implementation uexCV_TextCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/





-(void)modifiedCellWithMessageData:(uexCV_TableViewCellData *)data{
    [super modifiedCellWithMessageData:data];
    
    @weakify(self);
    self.msgText=[[UILabel alloc]init];
    NSString *msgContent=self.data.data;
    [_msgText setText:msgContent];
    [_msgText setFont:[UIFont systemFontOfSize:self.data.info.fontSize]];
    [_msgText setTextColor:self.data.info.fontColor];
    
    self.msgText.numberOfLines=0;

    
    CGSize labelsize = [msgContent boundingRectWithSize:CGSizeMake((self.data.maxTextWidth-10)*uexCV_inner_max_width_multipier, CGFLOAT_MAX)
                                             options:(NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:self.data.info.fontSize]}
                                             context:nil].size;
    
    NSLog(@"y%f",labelsize.height);
    [self.messageView addSubview:self.msgText];
    if(!uexCV_from_you){
        _msgText.transform=CGAffineTransformMakeScale(-1, 1);
    }
    [_msgText mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.width.lessThanOrEqualTo(uexCV_cell_container.mas_width).multipliedBy(uexCV_inner_max_width_multipier);
        make.height.greaterThanOrEqualTo(@(labelsize.height+5));
        
        make.edges.equalTo(ws.messageView).with.insets(uexCV_inner_padding);
    }];
    
    [self.messageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@(40));
    }];

}


-(void)layoutSubviews{
    [super layoutSubviews];

}

@end
