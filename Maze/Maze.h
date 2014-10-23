//
//  Maze.h
//  Maze
//
//  Created by christophe vichery on 27/09/2014.
//  Copyright (c) 2014 NutsNet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cube.h"

@interface Maze : NSObject
{
    Cube *cube; // Cube from maze
    CubePositon cubeEndPos; // End cube position
    
    NSMutableDictionary *dictionaryOfCubes; // Cubes in the maze
    NSMutableDictionary *dictionaryOfPaths; // Best pathfinding solutions
    
    NSMutableArray *arrayOfAllIndexesInAllPaths; // All cube indexes used to create all different paths
    NSMutableArray *arrayOfOperations; //Array to synchronise all the operations
    
    NSUInteger nbX, nbY, nbZ; // Size of the maze
    NSUInteger percentOfTransparentCubes; // Percent of transparent cubes in the maze (0..100)
    NSUInteger buildIndex; // Index to build dictionaryOfCubes from a file
    NSUInteger threadId; // Thread Id used as index in dictionaryOfPaths
    NSUInteger nbOfKeyDigit; // How the key of the dictionaryOfCubes is formatted
    
    NSString *indexOfBeginCube, *indexOfEndCube; // Index of the Begin and End cubes
    
    NSOperationQueue *queue; // Queue of operations
    
    BOOL isDisplaySolution; // To display the solution
}

@property (assign) NSMutableString *strFile; // String used to create the file maze.txt
@property (assign) BOOL isDisplayMenu; // To display the end menu at the right time

- (id)initWithNbX:(NSUInteger)numX withNbY:(NSUInteger)numY withNbZ:(NSUInteger)numZ andPercentOfTransparentCubes:(NSUInteger)percent;
- (id)initWithStrFile:(NSString*)file;
- (void)generateMazeFromFile:(BOOL)isFromFile;
- (void)solveMaze;
- (void)displaySolution;

@end
