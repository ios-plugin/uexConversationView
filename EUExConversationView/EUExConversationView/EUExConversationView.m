//
//  EUExConversationView.m
//  EUExConversationView
//
//  Created by Cerino on 15/9/14.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExConversationView.h"
#import "uexCV_ViewController.h"
#import "uexCV_TableView.h"


@interface EUExConversationView()
@property(nonatomic,strong)uexCV_ViewController *vc;
@end




@implementation EUExConversationView

#pragma mark - Required Method

-(id)initWithBrwView:(EBrowserView *)eInBrwView{
    self=[super initWithBrwView:eInBrwView];
    if(self){
        
    }
    return self;
}

-(void)clean{
    if(self.vc){
        [self.vc.view removeFromSuperview];
        self.vc=nil;
    }
}

-(void)dealloc{
    [self clean];
}


#pragma mark - Main API

-(void)open:(NSMutableArray *)inArguments{
    if([inArguments count]==0){
        return;
    }
    id info =[inArguments[0] JSONValue];
    if(!info||![info isKindOfClass:[NSDictionary class]]){
        return;
    }

    uexCV_ViewController *vc = [[uexCV_ViewController alloc]initWithFrame:CGRectMake([info[@"x"] floatValue], [info[@"y"] floatValue], [info[@"w"] floatValue], [info[@"h"] floatValue])
                                                                    bgImg:[UIImage imageWithContentsOfFile:[self absPath:info[@"bgImage"]]]
                                                                   meInfo:[self defineUserInfo:@"me" inDataDict:info]
                                                                  youInfo:[self defineUserInfo:@"you" inDataDict:info]
                                                                   extras:nil
                                                                  euexObj:self];
    self.vc=vc;
    //[EUtility brwView:meBrwView addSubview:vc.view];
    [EUtility brwView:meBrwView addSubviewToScrollView:vc.view];
    [self callbackJsonWithName:@"cbOpen" Object:nil];
    
}


-(void)close:(NSMutableArray *)inArguments{
    [self.vc.view removeFromSuperview];
    self.vc=nil;
}


-(void)addMessages:(NSMutableArray *)inArguments{
    if([inArguments count]==0){
        return;
    }
    id info =[inArguments[0] JSONValue];
    if(!self.vc||!info||![info isKindOfClass:[NSDictionary class]]||!info[@"type"]){
        return;
    }
   
    uexConversationViewAddDataType type=uexConversationViewAddDataNewMessage;
    if([info[@"type"] integerValue]==2){
        type = uexConversationViewAddDataMessageHistory;
    }
    NSArray *msgs=nil;
    if([info objectForKey:@"messages"]&&[info[@"messages"] isKindOfClass:[NSArray class]]){
        msgs=info[@"messages"];
    }
    [self.vc addData:msgs type:type];
}


-(void)reload:(NSMutableArray *)inArguments{
    NSLog(@"reload");
    [self.vc.tableView reloadData];
}

#pragma mark - Private Methods

-(uexCV_UserInfo *)defineUserInfo:(NSString *)user inDataDict:(NSDictionary *)dict{
    id info =[dict objectForKey:user];
    if(!info||![info isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    
    return [[uexCV_UserInfo alloc]initWithPhoto:[UIImage imageWithContentsOfFile:[self absPath:info[@"photo"]]]
                                       fontSize:[info[@"fontSize"] floatValue]
                                      fontColor:[UIColor uexCV_colorFromHtmlString:info[@"fontColor"]]
                                       nickname:info[@"nickname"]
            ];
    
    
    
    
}


#pragma mark - JS Callback

-(void)callbackJsonWithName:(NSString *)name Object:(id)obj{
    
    NSString *result=[obj JSONFragment];
    NSString *jsStr = [NSString stringWithFormat:@"if(uexConversationView.%@ != null){uexConversationView.%@('%@');}",name,name,result];
    
    [EUtility brwView:meBrwView evaluateScript:jsStr];
    
}
@end
