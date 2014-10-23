//
//  main.m
//  Maze
//
//  Created by christophe vichery on 27/09/2014.
//  Copyright (c) 2014 NutsNet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Maze.h"

// Definitions
Maze *maze;
char keyPress[1];
NSString *keyPressed;

void waitEnd();

// Generate maze file from string
NSUInteger generateFile(NSString *strFile)
{
    NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
    
    NSString *fileName = [[NSBundle mainBundle] bundlePath];
    fileName = [fileName stringByAppendingString:@"/"];
    fileName = [fileName stringByAppendingString:@"maze"];
    fileName = [fileName stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[directoryContent count]]];
    fileName = [fileName stringByAppendingString:@".txt"];
    
    if (![strFile writeToFile:fileName atomically:YES encoding:NSUnicodeStringEncoding error:nil])
        return 1;
    
    return 0;
}

// Generate string from maze file
NSString* generateString(NSString *file)
{
    NSStringEncoding *strEncoding = nil;
    
    NSString *fileName = [[NSBundle mainBundle] bundlePath];
    fileName = [fileName stringByAppendingString:@"/"];
    fileName = [fileName stringByAppendingString:file];
    NSString *strFile = [[[NSString alloc] initWithContentsOfFile:fileName usedEncoding:strEncoding error:nil] autorelease];
    
    return strFile;
}

// Start function
void start()
{
    char strNbXYZ[3], strPercentOfTransparentCubes[3], file[10];
    NSInteger nbX, nbY, nbZ, percentOfTransparentCubes;
    NSString *fileName, *strFile;
    
    do
    {
        system("clear");
        NSLog(@"MAZE BOT");
        NSLog(@"--------------------------\n");
        NSLog(@"[1] GENERATE A RANDOM MAZE");
        NSLog(@"[2] SELECT A FILE MAZE");
        NSLog(@"[Q] QUIT");
        
        scanf("%s", keyPress);
        keyPressed = [NSString stringWithFormat:@"%s", keyPress];
    }
    while(![keyPressed  isEqualToString: @"1"] && ![keyPressed  isEqualToString: @"2"] && ![keyPressed  isEqualToString: @"q"]);
    
    if ([keyPressed  isEqualToString: @"q"])
    {
        NSLog(@"BYE! TAKE CARE :)");
    }
    else if ([keyPressed  isEqualToString: @"1"])
    {
        do
        {
            NSLog(@"SIZE X OF ONE LAYER IN THE MAZE [2..N] : ");
            scanf("%s", strNbXYZ);
            nbX = [[NSString stringWithFormat:@"%s", strNbXYZ] integerValue];
        }
        while(nbX < 2);
        
        do
        {
            NSLog(@"SIZE Y OF ONE LAYER IN THE MAZE [1..N] : ");
            scanf("%s", strNbXYZ);
            nbY = [[NSString stringWithFormat:@"%s", strNbXYZ] integerValue];
        }
        while(nbY < 1);
        
        do
        {
            NSLog(@"SIZE Z OF THE MAZE [1..N] : ");
            scanf("%s", strNbXYZ);
            nbZ = [[NSString stringWithFormat:@"%s", strNbXYZ] integerValue];
        }
        while(nbZ < 1);
        
        do
        {
            NSLog(@"PERCENT OF TRANSPARENT CUBES [0..100] : ");
            scanf("%s", strPercentOfTransparentCubes);
            percentOfTransparentCubes = [[NSString stringWithFormat:@"%s", strPercentOfTransparentCubes] integerValue];
        }
        while(percentOfTransparentCubes < 0 || percentOfTransparentCubes > 100);
        
        NSLog(@"GENERATING NEW MAZE AND FILE ... PLEASE WAIT ...");
        maze = [[Maze alloc] initWithNbX:nbX withNbY:nbY withNbZ:nbZ andPercentOfTransparentCubes:percentOfTransparentCubes];
        [maze generateMazeFromFile:NO];
        NSLog(@"MAZE GENERATED");
        
        if(!generateFile([maze strFile]))
            NSLog(@"FILE GENERATED");
        else
            NSLog(@"FILE NOT GENERATED");
        
        waitEnd();
    }
    else if ([keyPressed  isEqualToString: @"2"])
    {
        do
        {
            NSLog(@"NAME OF THE FILE : ");
            
            scanf("%s", file);
            fileName = [NSString stringWithFormat:@"%s", file];
            strFile = generateString(fileName);
        }
        while(strFile == nil);
        
#if kTraces >= 2
        NSLog(@"DISPLAY MAZE FROM FILE :\n\n%@", strFile);
#endif
        NSLog(@"GENERATING MAZE FROM FILE ... PLEASE WAIT ...");
        maze = [[Maze alloc] initWithStrFile:strFile];
        [maze generateMazeFromFile:YES];
        NSLog(@"MAZE GENERATED");
        
        waitEnd();
    }
}

// End function
void waitEnd()
{
    NSDate *date = [NSDate date];
    
    NSLog(@" ");
    NSLog(@"THE NEXT STEP SHOULD TAKE AWHILE");
    NSLog(@"SOLVING MAZE ... PLEASE WAIT ...");
    [maze solveMaze];
    
    do
    {
    }
    while([maze isDisplayMenu] == NO);
    
    [maze release]; maze = nil;
    
    NSUInteger timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
    NSLog(@" ");
    NSLog(@"TIME TO TO SOLVE THE MAZE : %lu MS",(unsigned long)timePassed_ms);
    NSLog(@" ");
    
    do
    {
        NSLog(@"MAZE BOT");
        NSLog(@"-------------\n");
        NSLog(@"[M] MAIN MENU");
        NSLog(@"[Q] QUIT");
        
        scanf("%s", keyPress);
        keyPressed = [NSString stringWithFormat:@"%s", keyPress];
    }
    while(![keyPressed  isEqualToString: @"m"] && ![keyPressed  isEqualToString: @"q"]);
    
    if ([keyPressed  isEqualToString: @"m"])
        start();
    else if ([keyPressed  isEqualToString: @"q"])
        NSLog(@"BYE! TAKE CARE :)");
}

// Main function
int main(int argc, const char * argv[])
{
    @autoreleasepool { start(); }
    return 0;
}
