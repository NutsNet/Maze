//
//  Cube.m
//  Maze
//
//  Created by christophe vichery on 27/09/2014.
//  Copyright (c) 2014 NutsNet. All rights reserved.
//

#import "Cube.h"

@implementation Cube

// Instances release
- (void)dealloc
{
    [super dealloc];
}

// Class initialization
- (id)initWithX:(NSUInteger)x withY:(NSUInteger)y withZ:(NSUInteger)z andWithNbOfKeyDigits:(NSUInteger)nbOfKeyDigits
{
    if(!(self = [super init]))
        return nil;
    
    _cubePos.x = x;
    _cubePos.y = y;
    _cubePos.z = z;
    _distanceToEnd = 0;
    
    _isNeighborCubesSorted = NO;
    
    NSString *strX = [NSString stringWithFormat:@"%lu", (unsigned long)_cubePos.x], *strNewX = [[strX copy] autorelease];
    NSString *strY = [NSString stringWithFormat:@"%lu", (unsigned long)_cubePos.y], *strNewY = [[strY copy] autorelease];
    NSString *strZ = [NSString stringWithFormat:@"%lu", (unsigned long)_cubePos.z], *strNewZ = [[strZ copy] autorelease];
    
    for(NSUInteger i=0; i<nbOfKeyDigits-[strX length]; i++)
        strNewX = [@"0" stringByAppendingString:strNewX];
    
    for(NSUInteger i=0; i<nbOfKeyDigits-[strY length]; i++)
        strNewY = [@"0" stringByAppendingString:strNewY];
    
    for(NSUInteger i=0; i<nbOfKeyDigits-[strZ length]; i++)
        strNewZ = [@"0" stringByAppendingString:strNewZ];
    
    _strCoordinates = strNewZ;
    _strCoordinates = [_strCoordinates stringByAppendingString:strNewY];
    _strCoordinates = [_strCoordinates stringByAppendingString:strNewX];
    
#if kTraces >= 2
    NSLog(@"COORDINATES : %@", _strCoordinates);
    NSLog(@"X : %lu", (unsigned long)_cubePos.x);
    NSLog(@"Y : %lu", (unsigned long)_cubePos.y);
    NSLog(@"Z : %lu", (unsigned long)_cubePos.z);
#endif
    
    return self;
}

// Add neighbor transparent cubes for one cube
- (void)addArrayOfNeighbors:(NSArray*)arrayOfNeighbours toCube:(Cube*)currentCube
{
#if kTraces >= 2
    NSLog(@"Key : %@", [currentCube strCoordinates]);
#endif
    
    currentCube->_arrayOfNeighborTransparentCubes = [[[NSMutableArray alloc] initWithArray:arrayOfNeighbours] autorelease];
}

@end
