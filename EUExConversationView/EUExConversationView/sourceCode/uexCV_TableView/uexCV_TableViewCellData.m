/**
 *
 *	@file   	: uexCV_TableViewCellData.m  in EUExConversationView Project
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 15/11/16
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "uexCV_TableViewCellData.h"
#import "uexCV_ViewController.h"
#import "EUExConversationView.h"

@interface uexCV_TableViewCellData()
@property (nonatomic,strong)NSDictionary *dataDict;
@property (nonatomic,weak)uexCV_ViewController *vc;
@end

@implementation uexCV_TableViewCellData




- (instancetype)initWithDataDictionary:(NSDictionary *)data viewController:(uexCV_ViewController *)vc
{
    self = [super init];
    if (self) {

        self.dataDict=data;
        self.height=60;
        self.vc=vc;
        BOOL didFetchAllAttributes=[self fetchAttributes];
        self.dataDict=nil;
        if(!didFetchAllAttributes){
            return nil;
            
        }

    }
    return self;
}

-(BOOL)fetchAttributes{
    NSInteger attr=[_dataDict[@"from"] integerValue];
    switch (attr) {
        case 1:
            self.attribution=uexCV_MessageAttributionSentMessage;
            break;
        case 2:
            self.attribution=uexCV_MessageAttributionReceivedMessage;
            break;
            
        default:
            return NO;
            break;
    }
    NSInteger status=[_dataDict[@"status"] integerValue];
    switch (status) {
        case 0:
            self.status=uexCV_MessageStatusSending;
            break;
        case 1:
            self.status=uexCV_MessageStatusSent;
            break;
        case 2:
            self.status=uexCV_MessageStatusSendFailed;
            break;
            
        default:
            self.status=uexCV_MessageStatusSending;
            break;
    }
    self.timestamp=[_dataDict[@"timestamp"] longLongValue];

    NSInteger type=[_dataDict[@"type"] integerValue];
    switch (type) {
        case 1:
            self.type=uexCV_MessageTypeTextMessage;
            return [self fetchTextAttributes];
            break;
        case 2:
            self.type=uexCV_MessageTypeVoiceMessage;
            return [self fetchVoiceAttributes];
            break;
            
        default:
            return NO;
            break;
    }
    
    
}
-(BOOL)fetchTextAttributes{
    self.maxTextWidth=self.vc.frame.size.width;
    self.data=self.dataDict[@"data"];
    return YES;
}
-(BOOL)fetchVoiceAttributes{
    self.data=[self.vc.euexObj absPath:self.dataDict[@"data"]];
    self.isPlaying=NO;
    NSError *error=nil;
    AVAudioPlayer *tmpPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:self.data] error:&error];
    if(error){
        return NO;
    }
    [tmpPlayer prepareToPlay];
    self.duration = tmpPlayer.duration;
    return YES;
}
@end
