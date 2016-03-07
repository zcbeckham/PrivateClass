//
//  AppDelegate.h
//  createxml
//
//  Created by zhongchen on 16-1-14.
//  Copyright (c) 2016年 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSTableView *_messageTableView;
    
    IBOutlet NSButton *_createNewMessageButton;
    IBOutlet NSButton *_deleteMessageButton;
    IBOutlet NSButton *_saveMessageSettingButton;
    
    IBOutlet NSDatePicker *_startDatePicker;
    IBOutlet NSDatePicker *_endDatePicker;
    
    IBOutlet NSTextField *_titleTxtField;
    IBOutlet NSTextField *_describeTxtField;
    IBOutlet NSTextField *_urlTxtField;
    IBOutlet NSImageView *_messageIconView;
    
    IBOutlet NSImageView *_finalImageView;
    
    
    IBOutlet NSButton *_openLocalImageButton;
    
    IBOutlet NSButton *_enButton;
    IBOutlet NSButton *_esButton;
    IBOutlet NSButton *_frButton;
    IBOutlet NSButton *_jpButton;
    IBOutlet NSButton *_itButton;
    IBOutlet NSButton *_nlButton;
    IBOutlet NSButton *_ptButton;
    IBOutlet NSButton *_ruButton;
    IBOutlet NSButton *_deButton;
    
    IBOutlet NSButton *_messagePopupButton;
    
    
    NSString *_imageDataBase64String;
    
    NSXMLDocument  *_xmlDocument;
    
    NSMutableArray *_messageList;
    
    NSDateFormatter *_messageDateFormatter;
    
    BOOL _isNeedUpdateDate;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (readwrite, copy)NSString *imageDataBase64String;

- (IBAction)createNewMessage:(id)sender;
- (IBAction)deleteMessage:(id)sender;
- (IBAction)saveMessageSetting:(id)sender;

- (IBAction)openLocalImageFile:(id)sender;

- (IBAction)forcePopMessageAction:(id)sender;

@end
