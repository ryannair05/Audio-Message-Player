//
//  ViewController.m
//  audioMessages
//
//  Created by Ryan Nair on 12/8/24.
//

// AudioViewController.m

#import "AudioViewController.h"

@implementation AudioViewController

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
    self.view.wantsLayer = YES;
}

- (void)viewDidLoad {
    [self setupUI];
    [self loadAudioFiles];
}

- (void)setupUI {
    self.messageLabel = [[NSTextField alloc] init];
    self.messageLabel.bezeled = NO;
    self.messageLabel.drawsBackground = NO;
    self.messageLabel.editable = NO;
    self.messageLabel.selectable = NO;
    self.messageLabel.alignment = NSTextAlignmentCenter;
    self.messageLabel.hidden = YES;
    [self.view addSubview:self.messageLabel];
    
    NSStackView *audioControlsStack = [[NSStackView alloc] init];
    audioControlsStack.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    audioControlsStack.spacing = 10;
    audioControlsStack.alignment = NSLayoutAttributeCenterY;
    [self.view addSubview:audioControlsStack];
    
    self.playButton = [[NSButton alloc] init];
    self.playButton.bezelStyle = NSBezelStyleCircular;
    NSImage *playImage = [NSImage imageWithSystemSymbolName:@"play.circle.fill"
                                   accessibilityDescription:@"Play"];
    NSImage *largePlayImage = [playImage imageWithSymbolConfiguration:
                               [NSImageSymbolConfiguration configurationWithPointSize:24
                                                                               weight:NSFontWeightRegular]];
    [self.playButton setImage:largePlayImage];
    [self.playButton setTarget:self];
    [self.playButton setAction:@selector(playButtonClicked:)];
    
    self.pauseButton = [[NSButton alloc] init];
    self.pauseButton.bezelStyle = NSBezelStyleCircular;
    NSImage *pauseImage = [NSImage imageWithSystemSymbolName:@"pause.circle.fill"
                                    accessibilityDescription:@"Pause"];
    NSImage *largePauseImage = [pauseImage imageWithSymbolConfiguration:
                                [NSImageSymbolConfiguration configurationWithPointSize:24
                                                                                weight:NSFontWeightRegular]];
    [self.pauseButton setImage:largePauseImage];
    [self.pauseButton setTarget:self];
    [self.pauseButton setAction:@selector(pauseButtonClicked:)];
    self.pauseButton.hidden = YES;
    
    self.scrubber = [[NSSlider alloc] init];
    self.scrubber.minValue = 0;
    self.scrubber.maxValue = 1;
    [self.scrubber setTarget:self];
    [self.scrubber setAction:@selector(scrubberValueChanged:)];
    
    [self.scrubber setControlSize:NSControlSizeLarge];
    
    [audioControlsStack addArrangedSubview:self.playButton];
    [audioControlsStack addArrangedSubview:self.pauseButton];
    [audioControlsStack addArrangedSubview:self.scrubber];
    
    self.scrollView = [[NSScrollView alloc] init];
    self.scrollView.hasVerticalScroller = YES;
    self.scrollView.hasHorizontalScroller = YES;
    [self.view addSubview:self.scrollView];
    
    self.tableView = [[NSTableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSMenu *contextMenu = [[NSMenu alloc] init];
    NSMenuItem *openInFinder = [[NSMenuItem alloc] initWithTitle:@"Open in Finder"
                                                         action:@selector(openInFinder:)
                                                  keyEquivalent:@""];
    [openInFinder setTarget:self];
    [contextMenu addItem:openInFinder];
    self.tableView.menu = contextMenu;
    
    NSTableColumn *dateColumn = [[NSTableColumn alloc] initWithIdentifier:@"dateColumn"];
    [dateColumn setTitle: @"Date & Time"];
    [dateColumn setMinWidth:90];
    [self.tableView addTableColumn:dateColumn];
    
    NSTableColumn *titleColumn = [[NSTableColumn alloc] initWithIdentifier:@"titleColumn"];
    [dateColumn setTitle:@"File Name"];
    [self.tableView addTableColumn:titleColumn];
    
    self.scrollView.documentView = self.tableView;
    
    [audioControlsStack setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrubber setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10],
        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [audioControlsStack.topAnchor constraintEqualToAnchor:self.messageLabel.bottomAnchor constant:10],
        [audioControlsStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [audioControlsStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.scrubber.widthAnchor constraintEqualToAnchor:audioControlsStack.widthAnchor multiplier:0.8],
        
        [self.scrollView.topAnchor constraintEqualToAnchor:audioControlsStack.bottomAnchor constant:20],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20]
    ]];
}

- (void)stopTimer {
    self.playButton.hidden = NO;
    self.pauseButton.hidden = YES;
    [_timer invalidate];
    _timer = nil;
}

- (void)scrubberValueChanged:(NSSlider *)sender {
    if (_player) {
        _player.currentTime = sender.doubleValue * _player.duration;
    }
}

- (void)openInFinder:(id)sender {
    if (_selectedRow >= 0 && _selectedRow < _audioFiles.count) {
        NSDictionary *fileInfo = _audioFiles[_selectedRow];
        NSString *path = fileInfo[@"path"];
        [[NSWorkspace sharedWorkspace] selectFile:path
                         inFileViewerRootedAtPath:@""];
    }
}

- (void)loadAudioFiles {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        self->_audioFiles = [NSMutableArray array];
        NSString *attachmentsPath = [@"~/Library/Messages/Attachments/" stringByExpandingTildeInPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:attachmentsPath];
        NSString *file;
        while (file = [enumerator nextObject]) {
            if ([[file pathExtension] isEqualToString:@"caf"]) {
                NSString *fullPath = [attachmentsPath stringByAppendingPathComponent:file];
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
                NSDate *modificationDate = [attributes fileModificationDate];
                
                [self->_audioFiles addObject:@{
                    @"path": fullPath,
                    @"date": modificationDate,
                    @"name": file.lastPathComponent
                }];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_audioFiles.count == 0) {
                if ([fileManager isReadableFileAtPath:attachmentsPath]) {
                    self.messageLabel.stringValue = @"No audio files stored";
                }
                else {
                    self.messageLabel.stringValue = @"Please go to Settings -> Privacy and Security -> Full Disk Access and turn on Audio Message Player for this app to work";
                }
                
                self.messageLabel.hidden = NO;
                self.scrollView.hidden = YES;
                self.playButton.enabled = NO;
            }
            else {
                [self->_audioFiles sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [obj2[@"date"] compare:obj1[@"date"]];
                }];
                
                self.messageLabel.hidden = YES;
                self.scrollView.hidden = NO;
                self.playButton.enabled = YES;
                [self.tableView reloadData];
            }
        });
    });
}

- (void)playButtonClicked:(id)sender {
    if (!_player || !_player.isPlaying) {
        [self startPlayback];
    }
}

- (void)pauseButtonClicked:(id)sender {
    if (_player && _player.isPlaying) {
        [_player pause];
        [self stopTimer];
    }
}

- (void)startPlayback {
    if (_selectedRow < 0 || _selectedRow >= _audioFiles.count) return;
    
    NSDictionary *fileInfo = _audioFiles[_selectedRow];
    NSURL *fileURL = [NSURL fileURLWithPath:fileInfo[@"path"]];

    if (!(_player && [_player.url isEqualTo:fileURL])) {
        NSError *error;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        if (error) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Error Playing File";
            alert.informativeText = error.localizedDescription;
            [alert runModal];
            return;
        }
        
        [_player setDelegate:self];
        
        self.scrubber.doubleValue = 0;
    }

    [_player play];
    if (!_timer)
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.20 target:self selector:@selector(updateScrubber) userInfo:nil repeats:YES];
    
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (void)updateScrubber {
    self.scrubber.doubleValue = _player.currentTime / _player.duration;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _audioFiles.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *fileInfo = _audioFiles[row];
    
    if ([tableColumn.identifier isEqualToString:@"dateColumn"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
        return [formatter stringFromDate:fileInfo[@"date"]];
    } else {
        return fileInfo[@"name"];
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger newSelectedRow = self.tableView.selectedRow;
    if (newSelectedRow != _selectedRow) {
        _selectedRow = newSelectedRow;
        if (_player) {
            [_player stop];
        }
        [self startPlayback];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopTimer];
    self.scrubber.doubleValue = flag;
}

@end
