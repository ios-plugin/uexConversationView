//
//  uexCV_Bubble.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/19.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#define uexCV_arrow_height 5

#import "uexCV_Bubble.h"

@implementation uexCV_Bubble

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


*/
- (void)drawRect:(CGRect)rect {
    [self drawInContext:UIGraphicsGetCurrentContext()];
    

    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 1.5;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    //self.layer.borderColor=[UIColor grayColor].CGColor;
    //self.layer.borderWidth=1;

}
- (void)drawInContext:(CGContextRef)context {
    
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    [self getDrawPath:context];
    
    CGContextFillPath(context);
}

- (void)getDrawPath:(CGContextRef)context {
    CGRect rrect = self.bounds;
    CGFloat radius = 5.0;
    CGFloat minx = CGRectGetMinX(rrect)+uexCV_arrow_height+2,
    midy=CGRectGetMidY(rrect),
    starty = MIN(25, midy),
    maxx = CGRectGetMaxX(rrect)-2;
    CGFloat miny = CGRectGetMinY(rrect)+2,
    maxy = CGRectGetMaxY(rrect)-2;
    CGContextMoveToPoint(context, minx, starty-uexCV_arrow_height);
    CGContextAddLineToPoint(context,minx-uexCV_arrow_height, starty);
    CGContextAddLineToPoint(context,minx, starty+uexCV_arrow_height);
    
    CGContextAddArcToPoint(context, minx, maxy, maxx, maxy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, maxx, miny, radius);
    
    CGContextAddArcToPoint(context, maxx, miny, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, miny, minx, maxy, radius);
    //CGContextAddLineToPoint(context, minx, starty-uexCV_arrow_height);


    CGContextClosePath(context);
}
@end
