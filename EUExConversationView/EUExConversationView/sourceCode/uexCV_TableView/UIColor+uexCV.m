//
//  UIColor+uexCV.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/19.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "UIColor+uexCV.h"

#define END return [self clearColor]

@implementation UIColor (uexCV)



+(UIColor *)uexCV_colorFromHtmlString:(NSString *)colorString{
    colorString=[[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    
    if ([colorString hasPrefix:@"#"]){
        
        
        unsigned int r,g,b,a;
        
        NSRange range;
        NSMutableArray *colorArray=[NSMutableArray arrayWithCapacity:4];
        switch ([colorString length]) {
            case 4://"#123"型字符串
                [colorArray addObject:@"ff"];
                for(int k=0;k<3;k++){
                    range.location=k+1;
                    range.length=1;
                    NSMutableString *tmp=[[colorString substringWithRange:range] mutableCopy];
                    [tmp  appendString:tmp];
                    [colorArray addObject:tmp];
                    
                }
                break;
            case 7://"#112233"型字符串
                [colorArray addObject:@"ff"];
                for(int k=0;k<3;k++){
                    range.location=2*k+1;
                    range.length=2;
                    [colorArray addObject:[colorString substringWithRange:range]];
                    
                }
                break;
            case 9://"#11223344"型字符串
                for(int k=0;k<4;k++){
                    range.location=2*k+1;
                    range.length=2;
                    [colorArray addObject:[colorString substringWithRange:range]];
                }
                break;
                
            default:
                END;
                break;
        }
        
        [[NSScanner scannerWithString:colorArray[0]] scanHexInt:&a];
        [[NSScanner scannerWithString:colorArray[1]] scanHexInt:&r];
        [[NSScanner scannerWithString:colorArray[2]] scanHexInt:&g];
        [[NSScanner scannerWithString:colorArray[3]] scanHexInt:&b];
        
        return [self colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:(float)a/255.0];
        
        
    }
    
    if ([colorString hasPrefix:@"rgb("]&&[colorString hasSuffix:@")"]){
        colorString=[colorString substringWithRange:NSMakeRange(4, [colorString length] -5)];
        return [self uexCV_ColorWithRGBAArray:[colorString componentsSeparatedByString:@","]];
    }
    
    if ([colorString hasPrefix:@"rgba("]&&[colorString hasSuffix:@")"]){
        colorString=[colorString substringWithRange:NSMakeRange(5, [colorString length] -6)];
        return [self uexCV_ColorWithRGBAArray:[colorString componentsSeparatedByString:@","]];
    }
    
    
    END;
    
    
    
    
}

+(UIColor*)uexCV_ColorWithRGBAArray:(NSArray *)rgbaStr{
    if([rgbaStr count]<3) END;
    NSMutableArray *rgb=[NSMutableArray array];
    NSString *alpha=@"1";
    if([rgbaStr count]>3 && [rgbaStr[3] isKindOfClass:[NSString class]]){
        alpha=[rgbaStr[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    for(int i=0;i<3;i++) {
        if(![rgbaStr[i] isKindOfClass:[NSString class]]) END;
        NSString *str=rgbaStr[i];
        str=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([str hasSuffix:@"%"]){
            str=[str substringWithRange:NSMakeRange(0, [str length] - 1)];
            [rgb addObject:[NSNumber numberWithFloat:([str floatValue]*255.0f)]];
        }else{
            [rgb addObject:[NSNumber numberWithFloat:[str floatValue]]];
        }
    }
    return [self colorWithRed:[rgb[0] floatValue]/255.0f green:[rgb[1] floatValue]/255.0f blue:[rgb[2] floatValue]/255.0f alpha:[alpha floatValue]];
    
    
}

@end
