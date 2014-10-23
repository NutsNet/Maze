//
//  Cube.h
//  Maze
//
//  Created by christophe vichery on 27/09/2014.
//  Copyright (c) 2014 NutsNet. All rights reserved.
//

#import <Foundation/Foundation.h>

// Position for one cube
typedef struct CubePositon
{
    NSInteger x, y, z;
} CubePositon;

#define kTraces 0 // 0: without traces - 1..2: with traces level[1..2]

@interface Cube : NSObject

@property (assign) CubePositon cubePos;
@property (assign) NSUInteger distanceToEnd; // Distance between the cube and the End cube
@property (assign) NSString *cubeChar; // Type of the cube according to character (B,E,#,.)
@property (assign) NSString *strCoordinates; // Key for dictionaryOfCubes
@property (assign) BOOL isNeighborCubesSorted; // YES when sorted from the closest to the furthest from the end cube
@property (assign) NSMutableArray *arrayOfNeighborTransparentCubes; // Neighbor transparent cubes

- (id)initWithX:(NSUInteger)x withY:(NSUInteger)y withZ:(NSUInteger)z andWithNbOfKeyDigits:(NSUInteger)nbOfKeyDigits;
- (void)addArrayOfNeighbors:(NSArray*)arrayOfNeighbours toCube:(Cube*)currentCube;

@end
