//
//  ViewController.h
//  audioMessages
//
//  Created by Ryan Nair on 12/8/24.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioViewController : NSViewController  <NSTableViewDelegate, NSTableViewDataSource, AVAudioPlayerDelegate>  {
    NSMutableArray<NSDictionary *> *_audioFiles;
    AVAudioPlayer *_player;
    NSInteger _selectedRow;
    NSTimer *_timer;
}
@property (strong) NSTableView *tableView;
@property (strong) NSScrollView *scrollView;
@property (strong) NSButton *playButton;
@property (strong) NSButton *pauseButton;
@property (strong) NSSlider *scrubber;
@property (strong) NSTextField *messageLabel;
@end
