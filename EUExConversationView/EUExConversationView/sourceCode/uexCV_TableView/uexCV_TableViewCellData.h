/**
 *
 *	@file   	: uexCV_TableViewCellData.h  in EUExConversationView Project
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


#import <Foundation/Foundation.h>
@class uexCV_UserInfo;
@class uexCV_ViewController;

typedef BOOL (^clickBlock)();

typedef NS_ENUM(NSInteger,uexCV_MessageStatus) {
    uexCV_MessageStatusSending,
    uexCV_MessageStatusSent,
    uexCV_MessageStatusSendFailed,
};
typedef NS_ENUM(NSInteger,uexCV_MessageAttribution) {
    uexCV_MessageAttributionSentMessage,
    uexCV_MessageAttributionReceivedMessage
};
typedef NS_ENUM(NSInteger,uexCV_MessageType){
    uexCV_MessageTypeTextMessage,
    uexCV_MessageTypeVoiceMessage
};
@interface uexCV_TableViewCellData : NSObject
@property (nonatomic,strong)uexCV_UserInfo *info;
@property (nonatomic,assign)uexCV_MessageType type;
@property (nonatomic,assign)uexCV_MessageAttribution attribution;
@property (nonatomic,assign)uexCV_MessageStatus status;
@property (nonatomic,assign)long long timestamp;
@property (nonatomic,strong)NSString *data;

@property (nonatomic,assign)CGFloat height;

//textCell
@property (nonatomic,assign)CGFloat maxTextWidth;


//voiceCell
@property (nonatomic,assign)BOOL isPlaying;
@property (nonatomic,assign)NSTimeInterval duration;
@property (nonatomic,strong)clickBlock onClickAction;


-(instancetype)initWithDataDictionary:(NSDictionary *)data viewController:(uexCV_ViewController *)vc;

@end

