//
//  AppDelegate.m
//  createxml
//
//  Created by zhongchen on 16-1-14.
//  Copyright (c) 2016年 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "NSDataAdditions.h"

#define MessageName @"MessageName"
#define MessageID   @"MessageID"
#define MessageDescription @"Description"
#define MessageStartTime @"MessageStartTime"
#define MessageEndTime @"MessageEndTime"
#define MessageCreateTime @"MessageCreateTime"
#define MessageUrl    @"MessageUrl"
#define MessageIcon   @"MessageIcon"
#define MessageLanguage @"MessageLanguage"
#define MessageForcePop @"MessageForcePop"


@implementation AppDelegate

@synthesize imageDataBase64String = _imageDataBase64String;

- (void)initLanguageButton
{
    [_enButton setTarget:self];
    [_enButton setAction:@selector(languageButtonClick:)];
    [_esButton setTarget:self];
    [_esButton setAction:@selector(languageButtonClick:)];
    [_frButton setTarget:self];
    [_frButton setAction:@selector(languageButtonClick:)];
    [_jpButton setTarget:self];
    [_jpButton setAction:@selector(languageButtonClick:)];
    [_itButton setTarget:self];
    [_itButton setAction:@selector(languageButtonClick:)];
    [_nlButton setTarget:self];
    [_nlButton setAction:@selector(languageButtonClick:)];
    [_ptButton setTarget:self];
    [_ptButton setAction:@selector(languageButtonClick:)];
    [_ruButton setTarget:self];
    [_ruButton setAction:@selector(languageButtonClick:)];
    [_deButton setTarget:self];
    [_deButton setAction:@selector(languageButtonClick:)];
    
}

- (void)languageButtonClick:(id)sender
{
    if (sender == _enButton) {
    }else if(sender == _esButton){
    }else if(sender == _frButton){
    }else if(sender == _jpButton){
    }else if(sender == _itButton){
    }else if(sender == _nlButton){
    }else if(sender == _ptButton){
    }else if(sender == _ruButton){
    }else if(sender == _deButton){
    }
    
    if ([_messageTableView selectedRow] >= 0) {
        NSMutableDictionary *dic = [_messageList objectAtIndex:[_messageTableView selectedRow]];
        [dic setObject:[self getLanguageString] forKey:MessageLanguage];
    }
}

- (void)awakeFromNib
{
    //先初始化一个xml对象
    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"Messages"];
    _xmlDocument = [[NSXMLDocument alloc] initWithRootElement:root];
    [_xmlDocument setVersion:@"1.0"];
    [_xmlDocument setCharacterEncoding:@"UTF-8"];
    [root addChild:[NSXMLNode commentWithStringValue:@"Message"]];
    
    _messageDateFormatter =[[NSDateFormatter alloc] init];
    [_messageDateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //初始化其他
    _messageList = [[NSMutableArray alloc] init];
    
    [_messageTableView setDataSource:(id<NSTableViewDataSource>)self];
    [_messageTableView setDelegate:(id<NSTableViewDelegate>)self];
    
    [self initLanguageButton];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval: secondsPerDay];
    [_startDatePicker setDateValue:[NSDate date]];
    [_endDatePicker setDateValue:tomorrow];
    [[_startDatePicker cell] setDelegate:self];
    [[_endDatePicker cell] setDelegate:self];
    
    [_titleTxtField setDelegate:(id<NSTextFieldDelegate>)self];
    [_describeTxtField setDelegate:(id<NSTextFieldDelegate>) self];
    [_urlTxtField setDelegate:(id<NSTextFieldDelegate>) self];
    
    //先把已经存在的xml中的消息读取出来
    [self readMessageFromXMLPath:nil];
    if (_messageList && [_messageList count] > 0) {
        NSMutableDictionary *dic = [_messageList objectAtIndex:0];
        [self updateUI:dic];
        
    }
    
    _isNeedUpdateDate = YES;
    
    //刷新一下消息显示
    [_messageTableView reloadData];
    
    if ([_messageTableView numberOfRows] > 0) {
        [_deleteMessageButton setEnabled:YES];
    }else{
        [_deleteMessageButton setEnabled:NO];
    }

}

- (BOOL)windowShouldClose:(id)sender {
    exit(0);
    return YES;
}


- (void)dealloc
{
    [_messageDateFormatter release], _messageDateFormatter = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)createXMLDocument:(NSMutableDictionary *)dic
{
    //创建普通节点
    NSXMLElement *titleElement = [[NSXMLElement alloc] initWithName:@"Title" stringValue:[dic valueForKey:MessageName]];
    NSXMLElement *descriptionElement = [[NSXMLElement alloc] initWithName:@"Description" stringValue:[dic valueForKey:MessageDescription]];
   
    NSString *currentDateString = [_messageDateFormatter stringFromDate:[NSDate date]];
    NSXMLElement *dateElement = [[NSXMLElement alloc] initWithName:@"Date" stringValue:currentDateString];
    NSXMLElement *urlElement = [[NSXMLElement alloc] initWithName:@"Url" stringValue:[dic valueForKey:MessageUrl]];
    NSXMLElement *iconElement = [[NSXMLElement alloc] initWithName:@"Icon" stringValue:[dic valueForKey:MessageIcon]];
    NSArray *elementArray = [NSArray arrayWithObjects:titleElement, descriptionElement, urlElement, dateElement, iconElement, nil];
    
    //创建属性节点
    //1. Message ID
    NSXMLNode *idNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    [idNode setName:@"ID"];
    CFUUIDRef udid = CFUUIDCreate(NULL);
    NSString *udidString = (NSString *) CFUUIDCreateString(NULL, udid);
    [idNode setObjectValue:[dic valueForKey:MessageID]];
    //Message Language
    NSXMLNode *langNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    [langNode setName:@"Language"];
    
    //2. 保存语言
    [langNode setObjectValue:[dic valueForKey:MessageLanguage]];
    
    //3. 是否强制推送
    NSXMLNode *forceNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    [forceNode setName:@"Force"];
    int force = [_messagePopupButton state] == NSOnState ? 1 : 0;
    [forceNode setObjectValue:[dic valueForKey:MessageForcePop]];
    
    //4. 消息有效期限
    NSXMLNode *startDateNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    [startDateNode setName:@"StartDate"];
    NSString *startdateString = [_messageDateFormatter stringFromDate:[_startDatePicker dateValue]];
    [startDateNode setObjectValue:[dic valueForKey:MessageStartTime]];
    NSXMLNode *endDateNode = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
    [endDateNode setName:@"EndDate"];
    NSString *endDateString = [_messageDateFormatter stringFromDate:[_endDatePicker dateValue]];
    [endDateNode setObjectValue:[dic valueForKey:MessageEndTime]];
    
    
    NSArray *attributeArray = [NSArray arrayWithObjects:idNode, langNode, startDateNode, endDateNode, forceNode, nil];
    
    
    NSXMLNode *node = [NSXMLNode elementWithName:@"Message" children:elementArray attributes:attributeArray];
    [[_xmlDocument rootElement] addChild:node];
}

//保存xml
- (BOOL)xmlDocument:(NSXMLDocument *)XMLDoc writeToFile:(NSString *)filePath{
    
    NSData *xmlData = [XMLDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    if (![xmlData writeToFile:filePath atomically:YES]) {
        NSBeep();
        NSLog(@"Could not write document out...");
        return NO;
    }
    return YES;
}

- (NSString *)getLanguageString
{
    NSString *languageString = @"";
    //2. 保存语言
    if (NSOnState == [_enButton state]) {
        languageString = [languageString stringByAppendingString:@"en;"];
    }
    if(NSOnState == [_esButton state]){
        languageString = [languageString stringByAppendingString:@"es;"];
    }
    if(NSOnState == [_frButton state]){
        languageString = [languageString stringByAppendingString:@"fr;"];
    }
    if(NSOnState == [_jpButton state]){
        languageString = [languageString stringByAppendingString:@"jp;"];
    }
    if(NSOnState == [_itButton state]){
        languageString = [languageString stringByAppendingString:@"it;"];
    }
    if(NSOnState == [_nlButton state]){
        languageString = [languageString stringByAppendingString:@"nl;"];
    }
    if(NSOnState == [_ptButton state]){
        languageString = [languageString stringByAppendingString:@"pt;"];
    }
    if(NSOnState == [_ruButton state]){
        languageString = [languageString stringByAppendingString:@"ru;"];
    }
    if(NSOnState == [_deButton state]){
        languageString = [languageString stringByAppendingString:@"de;"];
    }
    
    return languageString;
}

- (void)resetUI
{
    [self initLanguageButton];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval: secondsPerDay];
    [_startDatePicker setDateValue:[NSDate date]];
    [_endDatePicker setDateValue:tomorrow];
    
    [_titleTxtField setStringValue:@""];
    [_describeTxtField setStringValue:@""];
    [_urlTxtField setStringValue:@""];
    
    [_messageIconView setImage:nil];
    
    [_messagePopupButton setState:NSOffState];
    

}

#pragma mark -------------- 读取已经存在的xml文件 --------------------
- (void)readMessageFromXMLPath:(NSString *)xmlFilePath
{
    NSString *localPath = [NSString stringWithFormat:@"file://%@/Desktop/mac-message-center.xml", NSHomeDirectory()];
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:localPath] options:NSXMLDocumentTidyXML error:NULL];
    if (doc && [doc rootElement]) {
        for (NSXMLElement *nodeProduct in  [[doc rootElement] elementsForName:@"Message"]) {
            
            NSString *messageID = [[nodeProduct attributeForName:@"ID"] objectValue];
            
            NSString *messageName = nil;
            NSString *messageURL = nil;
            NSString *description = nil;
            NSString *dateString = nil;
            NSString *messageBase64String = nil;
            
            NSArray *titleNode = [nodeProduct elementsForName:@"Title"];
            if (titleNode && [titleNode count] > 0) {
                messageName =  [[titleNode objectAtIndex:0] objectValue];
            }
            NSArray *descriptionNode = [nodeProduct elementsForName:@"Description"];
            if (descriptionNode && [descriptionNode count] > 0) {
                description =  [[descriptionNode objectAtIndex:0] objectValue];
            }
            NSArray *urlNode = [nodeProduct elementsForName:@"Url"];
            if (urlNode && [urlNode count] > 0) {
                messageURL = [[urlNode objectAtIndex:0] objectValue];
            }
            
            NSArray *dateNode = [nodeProduct elementsForName:@"Date"];
            if (dateNode && [dateNode count] > 0) {
                dateString = [[dateNode objectAtIndex:0] objectValue];
            }
            
            NSArray *iconNode = [nodeProduct elementsForName:@"Icon"];
            if (iconNode && [iconNode count] > 0) {
                messageBase64String = [[iconNode objectAtIndex:0] objectValue];
            }
            
            NSString *languageString = [[nodeProduct attributeForName:@"Language"] objectValue];
            NSString *startTime = [[nodeProduct attributeForName:@"StartDate"] objectValue];
            NSString *endTime = [[nodeProduct attributeForName:@"EndDate"] objectValue];
            NSString *forcePop = [[nodeProduct attributeForName:@"Force"] objectValue];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        messageName,MessageName,
                                        messageID, MessageID,
                                        description, MessageDescription,
                                        startTime, MessageStartTime,
                                        endTime, MessageEndTime,
                                        messageURL, MessageUrl,
                                        messageBase64String, MessageIcon,
                                        dateString, MessageCreateTime,
                                        languageString, MessageLanguage,
                                        forcePop, MessageForcePop,
                                        nil];
            [_messageList addObject:dic];
        }
        
    }
    [doc release], doc = nil;

}


#pragma mark ------------------ Action ---------------------

- (IBAction)createNewMessage:(id)sender
{
    CFUUIDRef udid = CFUUIDCreate(NULL);
    NSString *udidString = (NSString *) CFUUIDCreateString(NULL, udid);
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval: secondsPerDay];
    [_startDatePicker setDateValue:[NSDate date]];
    [_endDatePicker setDateValue:tomorrow];
    NSString *startdateString = [_messageDateFormatter stringFromDate:[_startDatePicker dateValue]];
    NSString *enddateString = [_messageDateFormatter stringFromDate:[_endDatePicker dateValue]];
    
    NSString *messagelanguage = @"en;es;fr;jp;it;nl;pt;ru;de;";

    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                @"New Message",MessageName,
                                udidString, MessageID,
                                @"", MessageDescription,
                                startdateString, MessageStartTime,
                                enddateString, MessageEndTime,
                                @"", MessageUrl,
                                @"", MessageIcon,
                                messagelanguage, MessageLanguage,
                                @"0", MessageForcePop,
                                nil];
    
    [_messageList addObject:dic];
    [_messageTableView reloadData];
    [_messageTableView  selectRowIndexes:[NSIndexSet indexSetWithIndex:[_messageTableView numberOfRows] - 1] byExtendingSelection:NO];
    
    //设置一下删除消息按钮的状态
    if ([_messageTableView numberOfRows] > 0) {
        [_deleteMessageButton setEnabled:YES];
    }else{
        [_deleteMessageButton setEnabled:NO];
    }
}

- (IBAction)deleteMessage:(id)sender
{
    if ([_messageList count] > 0) {
        BOOL isNeedSetSelect = NO;
        if ([_messageTableView selectedRow] == [_messageTableView numberOfRows] - 1) {
            isNeedSetSelect = YES;
        }
        [_messageList removeObjectAtIndex:[_messageTableView selectedRow]];
        [_messageTableView reloadData];
        if (isNeedSetSelect) {
            [_messageTableView  selectRowIndexes:[NSIndexSet indexSetWithIndex:[_messageTableView numberOfRows] - 1] byExtendingSelection:NO];
        }
        //如果列表里面的消息删除完了，要重置一下界面
        if ([_messageList count] <= 0) {
            [self resetUI];
            //设置一下删除消息按钮的状态
            if ([_messageTableView numberOfRows] > 0) {
                [_deleteMessageButton setEnabled:YES];
            }else{
                [_deleteMessageButton setEnabled:NO];
            }
        }
    }
}

- (IBAction)saveMessageSetting:(id)sender
{
    //先移除xml中所有节点
    while ([[_xmlDocument rootElement] childCount] > 0) {
        [[_xmlDocument rootElement] removeChildAtIndex:0];
    }
    
    for (NSMutableDictionary *dic in _messageList) {
        [self createXMLDocument:dic];
    }
    [self xmlDocument:_xmlDocument writeToFile:[@"~/Desktop/mac-message-center.xml" stringByExpandingTildeInPath]];
    
}

- (IBAction)openLocalImageFile:(id)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    
    [panel setCanSelectHiddenExtension:NO];
    [panel setAllowsMultipleSelection:NO];

    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg", @"png", @"jpeg", nil]];
    
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            NSArray* arrFiles = [panel URLs];
            if ([arrFiles count] == 1) {
                NSURL* fileURL = [arrFiles objectAtIndex:0];
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:fileURL];
                [_messageIconView setImage:image];
                
                //
                NSString* filePath = [fileURL path];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                NSString *base64String = [data base64Encoding];
                //NSLog(@"加密后的字符串是:%@", base64String);
                self.imageDataBase64String = base64String;
                
                if ([_messageTableView selectedRow] >= 0) {
                    NSMutableDictionary *dic = [_messageList objectAtIndex:[_messageTableView selectedRow]];
                    [dic setObject:base64String forKey:MessageIcon];
                }
                
                //解密
//                NSData *finaldata = [NSData dataWithBase64EncodedString:base64String];
//                NSImage *finalImage = [[NSImage alloc] initWithData:finaldata];
//                [_finalImageView setImage:finalImage];
                
                //检查一下选择的目的路径是否有可写权限
                if (![[NSFileManager defaultManager] isWritableFileAtPath:filePath]) {
                    NSRunAlertPanel(@"No write privilege for the target directory, please specify a new directory.", @"", @"OK", nil, nil);
                }else{
                }
                
            }
            
        }else if(result == NSCancelButton){
        }
    }];
}

- (IBAction)forcePopMessageAction:(id)sender
{
    if ([_messageTableView selectedRow] >= 0) {
        NSMutableDictionary *dic = [_messageList objectAtIndex:[_messageTableView selectedRow]];
        [dic setObject:[NSString stringWithFormat:@"%ld", [_messagePopupButton state]] forKey:MessageForcePop];
    }
}

- (void)updateUI:(NSMutableDictionary *)dic
{
    [_titleTxtField setStringValue:[dic valueForKey:MessageName]];
    [_describeTxtField setStringValue:[dic valueForKey:MessageDescription]];
    
    NSDate *startDate = [_messageDateFormatter dateFromString:[dic valueForKey:MessageStartTime]];
    NSDate *endDate = [_messageDateFormatter dateFromString:[dic valueForKey:MessageEndTime]];
    [_startDatePicker setDateValue:startDate];
    [_endDatePicker setDateValue:endDate];
    [_urlTxtField setStringValue:[dic valueForKey:MessageUrl]];
    
    NSString *iconBase64String = [dic valueForKey:MessageIcon];
    NSData *finaldata = (NSData *)[NSData dataWithBase64EncodedString:iconBase64String];
    NSImage *image = [[NSImage alloc] initWithData:finaldata];
    [_messageIconView setImage:image];
    
    NSArray *languageArray = [[dic valueForKey:MessageLanguage] componentsSeparatedByString:@";"];
    if ([languageArray containsObject:@"en"]) {
        [_enButton setState:NSOnState];
    }else{
        [_enButton setState:NSOffState];
    }
    if ([languageArray containsObject:@"es"]) {
        [_esButton setState:NSOnState];
    }else{
        [_esButton setState:NSOffState];
    }
    if ([languageArray containsObject:@"fr"]) {
        [_frButton setState:NSOnState];
    }else{
        [_frButton setState:NSOffState];
    }
    if ([languageArray containsObject:@"jp"]) {
        [_jpButton setState:NSOnState];
    }else{
        [_jpButton setState:NSOffState];
    }
    if ([languageArray containsObject:@"it"]) {
        [_itButton setState:NSOnState];
    }else{
        [_itButton setState:NSOffState];
    }
    if ([languageArray containsObject:@"nl"]) {
        [_nlButton setState:NSOnState];
    }else{
        [_nlButton setState:NSOffState];
    }
    if ([languageArray containsObject:@"pt"]) {
        [_ptButton setState:NSOnState];
    }else{
        [_ptButton setState:NSOffState];
    }
    if ([languageArray containsObject:@"ru"]) {
        [_ruButton setState:NSOnState];
    }else{
        [_ruButton setState:NSOffState];
    }
    if ([languageArray containsObject:@"de"]) {
        [_deButton setState:NSOnState];
    }else{
        [_deButton setState:NSOffState];
    }
    
    [_messagePopupButton setState:[[dic valueForKey:MessageForcePop] boolValue]];
    
}


#pragma mark --------------- NSTextField Delegate -------------------

- (void)controlTextDidChange:(NSNotification *)obj
{
    if ([obj object] == _titleTxtField) {
        NSInteger index = [_messageTableView selectedRow];
        if (index >= 0) {
            NSMutableDictionary *dic = [_messageList objectAtIndex:index];
            [dic setObject:[_titleTxtField stringValue] forKey:MessageName];
        }
    }else if([obj object] == _describeTxtField){
        NSInteger index = [_messageTableView selectedRow];
        if (index >= 0) {
            NSMutableDictionary *dic = [_messageList objectAtIndex:index];
            [dic setObject:[_describeTxtField stringValue] forKey:MessageDescription];
        }
    }else if([obj object] == _urlTxtField){
        NSInteger index = [_messageTableView selectedRow];
        if (index >= 0) {
            NSMutableDictionary *dic = [_messageList objectAtIndex:index];
            [dic setObject:[_urlTxtField stringValue] forKey:MessageUrl];
        }
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSLog(@"我去");
}

#pragma mark ---------------- DatePicker Delegate ---------------------------
- (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell validateProposedDateValue:(NSDate **)proposedDateValue timeInterval:(NSTimeInterval *)proposedTimeInterval
{
    
    if (!_isNeedUpdateDate) {
        return;
    }
    
    if ([aDatePickerCell isEqual:[_startDatePicker cell]]) {
        NSString *startdateString = [_messageDateFormatter stringFromDate:*proposedDateValue];
        if ([_messageTableView selectedRow] >= 0) {
            NSMutableDictionary *dic = [_messageList objectAtIndex:[_messageTableView selectedRow]];
            [dic setObject:startdateString forKey:MessageStartTime];
        }
        
    }
    if ([aDatePickerCell isEqual:[_endDatePicker cell]]) {
        NSString *enddataString = [_messageDateFormatter stringFromDate:*proposedDateValue];
        if ([_messageTableView selectedRow] >= 0) {
            NSMutableDictionary *dic = [_messageList objectAtIndex:[_messageTableView selectedRow]];
            [dic setObject:enddataString forKey:MessageEndTime];
        }
    }
}


#pragma mark ---------------- TableView DataSource & Delegate ----------------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_messageList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[_messageList objectAtIndex:row] objectForKey:MessageName];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    _isNeedUpdateDate = NO;
    if ([_messageTableView selectedRow] >= 0 ) {
        if ([_messageList count] > 0) {
            NSMutableDictionary *dic = [_messageList objectAtIndex:[_messageTableView selectedRow]];
            [self updateUI:dic];
        }
    }
    
    _isNeedUpdateDate = YES;
}


@end
