//
//  Maze.m
//  Maze
//
//  Created by christophe vichery on 27/09/2014.
//  Copyright (c) 2014 NutsNet. All rights reserved.
//

#import "Maze.h"

@implementation Maze

// Instances release
- (void)dealloc
{
    [queue release]; queue = nil;
    
    [dictionaryOfCubes release]; dictionaryOfCubes = nil;
    [dictionaryOfPaths release]; dictionaryOfPaths = nil;
    
    [arrayOfAllIndexesInAllPaths release]; arrayOfAllIndexesInAllPaths = nil;
    [arrayOfOperations release]; arrayOfOperations = nil;
    
    [super dealloc];
}

// Class initialization
- (id)initWithNbX:(NSUInteger)numX withNbY:(NSUInteger)numY withNbZ:(NSUInteger)numZ andPercentOfTransparentCubes:(NSUInteger)percent
{
    if(!(self = [super init]))
        return nil;
    
    _isDisplayMenu = NO;
    isDisplaySolution = YES;
    
    buildIndex = 0; // We don't need that value
    threadId = 0;
    
    queue = [[NSOperationQueue alloc] init];
    
    dictionaryOfCubes = [[NSMutableDictionary alloc] init];
    dictionaryOfPaths = [[NSMutableDictionary alloc] init];
    
    arrayOfAllIndexesInAllPaths = [[NSMutableArray alloc] init];
    
    arrayOfOperations = [[NSMutableArray alloc] init];
    
    percentOfTransparentCubes = percent;
    
    nbX = numX;
    nbY = numY;
    nbZ = numZ;
    
    NSString *strX = [NSString stringWithFormat:@"%lu", (unsigned long)nbX];
    NSString *strY = [NSString stringWithFormat:@"%lu", (unsigned long)nbY];
    NSString *strZ = [NSString stringWithFormat:@"%lu", (unsigned long)nbZ];
    
    nbOfKeyDigit = MAX([strX length], MAX([strY length], [strZ length]));
    
#if kTraces >= 1
    NSLog(@"[.] : %lu%%", (unsigned long)percentOfTransparentCubes);
    NSLog(@"nbX : %lu", (unsigned long)nbX);
    NSLog(@"nbY : %lu", (unsigned long)nbY);
    NSLog(@"nbZ : %lu", (unsigned long)nbZ);
#endif
    
    _strFile = [NSMutableString stringWithFormat:@"%lu", (unsigned long)nbZ];
    [_strFile appendString:@"\n"];
    
    return self;
}

// Class initialization with a file
- (id)initWithStrFile:(NSString*)file
{
    if(!(self = [super init]))
        return nil;
    
    BOOL isNbX = NO, isNbY = NO;
    
    nbX = 0; nbY = 0; nbZ = 0;
    
    _isDisplayMenu = NO;
    isDisplaySolution = YES;
    
    buildIndex = 0;
    threadId = 0;
    
    queue = [[NSOperationQueue alloc] init];
    
    dictionaryOfCubes = [[NSMutableDictionary alloc] init];
    dictionaryOfPaths = [[NSMutableDictionary alloc] init];
    
    arrayOfAllIndexesInAllPaths = [[NSMutableArray alloc] init];
    
    arrayOfOperations = [[NSMutableArray alloc] init];
    
    percentOfTransparentCubes = 111; // We don't need that value
    
    _strFile = [NSMutableString stringWithString:file];
    
    NSMutableString *currentString = [[NSMutableString alloc] init];
    NSString *characterCtx = nil;
    
    for(NSUInteger i=0; i<[_strFile length]; i++)
    {
        NSString *character = [_strFile substringWithRange:NSMakeRange(i, 1)];
        
        for(NSUInteger j=0; j<10; j++)
        {
            if([character isEqualToString:[NSString stringWithFormat:@"%lu", (unsigned long)j]])
                [currentString appendString:character];
        }
        
        if(currentString != nil && [character isEqualToString:@"\n"])
            nbZ = [currentString integerValue];
        
        if(!isNbX && nbX > 0 && [character isEqualToString:@"\n"])
            isNbX = YES;
        
        if(!isNbX &&
           ([character isEqualToString:@"B"] || [character isEqualToString:@"E"] ||
            [character isEqualToString:@"#"] || [character isEqualToString:@"."] ))
        { nbX++; }
        
        if(!isNbY && nbX > 0 &&[character isEqualToString:@"\n"])
        {
            if([characterCtx isEqualToString:@"\n"])
                isNbY = YES;
            else
                nbY++;
        }
        
        characterCtx = character;
    }
    
    [currentString release]; currentString = nil;
    
    NSString *strX = [NSString stringWithFormat:@"%lu", (unsigned long)nbX];
    NSString *strY = [NSString stringWithFormat:@"%lu", (unsigned long)nbY];
    NSString *strZ = [NSString stringWithFormat:@"%lu", (unsigned long)nbZ];
    
    nbOfKeyDigit = MAX([strX length], MAX([strY length], [strZ length]));
    
#if kTraces >= 1
    NSLog(@"nbX : %lu", (unsigned long)nbX);
    NSLog(@"nbY : %lu", (unsigned long)nbY);
    NSLog(@"nbZ : %lu", (unsigned long)nbZ);
#endif
    
    return self;
}

// Generate a maze
- (void)generateMazeFromFile:(BOOL)isFromFile
{
    BOOL isQuartOne = NO;
    NSUInteger currentIndex = 0;
    NSString *character = nil;
    
    for(NSUInteger z=0; z<nbZ; z++)
    {
        for(NSUInteger y=0; y<nbY; y++)
        {
            for(NSUInteger x=0; x<nbX; x++)
            {
                // Building job progress step one
                if(!isQuartOne && (currentIndex*100)/(nbX*nbY*nbZ) >= 25)
                {
                    isQuartOne = YES;
                    NSLog(@"25%% DONE");
                }
                
                cube = [[Cube alloc] initWithX:x withY:y withZ:z andWithNbOfKeyDigits:nbOfKeyDigit];
                
                if(!isFromFile)
                {
                    if(arc4random()%100 < 100-percentOfTransparentCubes)
                        [cube setCubeChar:@"#"];
                    else
                        [cube setCubeChar:@"."];
                }
                else
                {
                    do
                    {
                        character = [_strFile substringWithRange:NSMakeRange(buildIndex, 1)];
                        buildIndex++;
                    }
                    while(buildIndex < [_strFile length]-1 &&
                          (![character isEqualToString:@"B"] && ![character isEqualToString:@"E"] &&
                           ![character isEqualToString:@"#"] && ![character isEqualToString:@"."] ));
                    
                    [cube setCubeChar:character];
                }
                
                [dictionaryOfCubes setObject:cube forKey:[cube strCoordinates]];
                [cube release]; cube = nil;
                
                currentIndex++;
            }
        }
    }
    
    // Building job progress step two
    NSLog(@"50%% DONE");
    
    [self addNeighborTransparentCubes:isFromFile];
}

// Add neighbor transparent cubes for all the cubes in the maze
- (void)addNeighborTransparentCubes:(BOOL)isFromFile;
{
    BOOL isQuartThree = NO;
    NSUInteger indexBegin, indexEnd, currentIndex = 0;
    NSArray *arrayOfKeys = [[dictionaryOfCubes allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    if(!isFromFile)
    {
        // Create the begin cube
        indexBegin = arc4random()%(nbX*nbY*nbZ);
        cube = [dictionaryOfCubes objectForKey:[arrayOfKeys objectAtIndex:indexBegin]];
        [cube setCubeChar:@"B"];
        
        // Create the end cube
        do { indexEnd = arc4random()%(nbX*nbY*nbZ); } while(indexEnd == indexBegin);
        cube = [dictionaryOfCubes objectForKey:[arrayOfKeys objectAtIndex:indexEnd]];
        [cube setCubeChar:@"E"];
    }
    
    for(NSUInteger z=0; z<nbZ; z++)
    {
        for(NSUInteger y=0; y<nbY; y++)
        {
            for(NSUInteger x=0; x<nbX; x++)
            {
#if kTraces >= 2
                NSLog(@"currentIndex : %lu", currentIndex);
#endif
                
                cube = [dictionaryOfCubes objectForKey:[arrayOfKeys objectAtIndex:currentIndex]];
                
                // Building job progress step three
                if(!isQuartThree && (currentIndex*100)/((nbX*nbY*nbZ)) >= 25)
                {
                    isQuartThree = YES;
                    NSLog(@"75%% DONE");
                }
                
                // Build the _strFile string to build the file maze
                if(!isFromFile)
                {
                    [_strFile appendString:[cube cubeChar]];
                    
                    if(x == nbX-1)
                    {
                        [_strFile appendString:@"\n"];
                        
                        if(y == nbY-1)
                            [_strFile appendString:@"\n"];
                    }
                }
                
                // Store index of the Begin and End cube
                if([[cube cubeChar] isEqualToString:@"B"])
                {
                    indexOfBeginCube = [arrayOfKeys objectAtIndex:currentIndex];
#if kTraces >= 1
                    NSLog(@"indexOfBeginCube : %@", indexOfBeginCube);
#endif
                }
                else if([[cube cubeChar] isEqualToString:@"E"])
                {
                    cubeEndPos = [cube cubePos];
                    indexOfEndCube = [arrayOfKeys objectAtIndex:currentIndex];
#if kTraces >= 1
                    NSLog(@"cubeEndPos.x   : %lu", (unsigned long)cubeEndPos.x);
                    NSLog(@"cubeEndPos.y   : %lu", (unsigned long)cubeEndPos.y);
                    NSLog(@"cubeEndPos.z   : %lu", (unsigned long)cubeEndPos.z);
                    NSLog(@"indexOfEndCube   : %@", indexOfEndCube);
#endif
                }
                
                // Index of the six neighbor cubes
                NSInteger neighborIndex[6];
                neighborIndex[0] = currentIndex-1; // Est
                neighborIndex[1] = currentIndex+1; // West
                neighborIndex[2] = currentIndex-nbX; // North
                neighborIndex[3] = currentIndex+nbX; // South
                neighborIndex[4] = currentIndex-(nbX*nbY); // Down
                neighborIndex[5] = currentIndex+(nbX*nbY); // Up
                
                NSMutableArray *arrayOfNeighbors = [[NSMutableArray alloc] init];
                
                for(NSUInteger i=0; i<6; i++)
                {
                    if(neighborIndex[i] >= 0 && neighborIndex[i] < (nbX*nbY*nbZ))
                    {
                        cube = [dictionaryOfCubes objectForKey:[arrayOfKeys objectAtIndex:currentIndex]];
                        
                        if(((i!=0)||(i==0 && [cube cubePos].x!=0)) &&
                           ((i!=1)||(i==1 && [cube cubePos].x!=nbX-1)) &&
                           ((i!=2)||(i==2 && [cube cubePos].y!=0)) &&
                           ((i!=3)||(i==3 && [cube cubePos].y!=nbY-1)))
                        {
                            cube = [dictionaryOfCubes objectForKey:[arrayOfKeys objectAtIndex:neighborIndex[i]]];
                            
                            if(cube &&
                               ([[cube cubeChar] isEqualToString:@"."] ||
                                [[cube cubeChar] isEqualToString:@"B"] ||
                                [[cube cubeChar] isEqualToString:@"E"] ))
                            {
#if kTraces >= 2
                                NSLog(@"neighborIndex[%lu] : %lu",(unsigned long)i, neighborIndex[i]);
#endif
                                [arrayOfNeighbors addObject:cube];
                            }
                        }
                    }
                }
                
                cube = [dictionaryOfCubes objectForKey:[arrayOfKeys objectAtIndex:currentIndex]];
                [cube addArrayOfNeighbors:arrayOfNeighbors toCube:cube];
                
                [arrayOfNeighbors release]; arrayOfNeighbors = nil;
                
                currentIndex++;
            }
        }
    }
}

// Solve a maze
- (void)solveMaze
{
    NSMutableArray *arrayOfCubesInPath = [[NSMutableArray alloc] init];
    
    cube = [dictionaryOfCubes objectForKey:indexOfBeginCube];
    
    [arrayOfCubesInPath addObject:cube];
    [arrayOfAllIndexesInAllPaths addObject:indexOfBeginCube];
    
    [dictionaryOfPaths setObject:arrayOfCubesInPath forKey:[NSString stringWithFormat:@"%lu", (unsigned long)threadId]];
    
    [arrayOfCubesInPath release]; arrayOfCubesInPath = nil;
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(solveMazeWithParameters:)
                                                                              object:[NSArray arrayWithObjects:cube, [NSString stringWithFormat:@"%lu", (unsigned long)threadId], nil]];
    [arrayOfOperations addObject:operation];
    [queue addOperation:operation];
    [operation release];
}

// Solve a maze at cube in the right thread
- (void)solveMazeWithParameters:(NSArray*) parameters
{
    Cube *mainCube = [parameters objectAtIndex:0];
    NSString *threadIndex = [parameters objectAtIndex:1];
    
#if kTraces >= 1
    NSLog(@"THREADID START : %@", threadIndex);
#endif
    
    // First step : Sort the neighbor cubes from the closest to the furthest from the end cube
    if(![mainCube isNeighborCubesSorted])
    {
        NSMutableArray *arrayOfSortedNeighborDistance = [[NSMutableArray alloc] init];
        NSMutableArray *arrayOfSortedNeighborTransparentCubes = [[NSMutableArray alloc] init];
        
        for(NSUInteger i=0; i<[[mainCube arrayOfNeighborTransparentCubes] count]; i++)
        {
            cube = [[mainCube arrayOfNeighborTransparentCubes] objectAtIndex:i];
            [cube setDistanceToEnd:ABS(cubeEndPos.x-[cube cubePos].x)+ABS(cubeEndPos.y-[cube cubePos].y)+ABS(cubeEndPos.z-[cube cubePos].z)];
            
            [arrayOfSortedNeighborDistance addObject:[NSNumber numberWithUnsignedInteger:[cube distanceToEnd]]];
        }
        
        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        [arrayOfSortedNeighborDistance sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
        
        do
        {
        for(NSUInteger i=0; i<[[mainCube arrayOfNeighborTransparentCubes] count]; i++)
        {
            cube = [[mainCube arrayOfNeighborTransparentCubes] objectAtIndex:i];
            
            if([cube distanceToEnd] == [[arrayOfSortedNeighborDistance objectAtIndex:0] unsignedIntegerValue])
            {
                [arrayOfSortedNeighborTransparentCubes addObject:cube];
                [arrayOfSortedNeighborDistance removeObjectAtIndex:0];
                
                if([arrayOfSortedNeighborDistance count] == 0)
                    break;
            }
        }
        }
        while([arrayOfSortedNeighborDistance count] != 0);
        
#if kTraces >= 2
        NSLog(@" ");
        NSLog(@"-------------");
        NSLog(@"MAIN CUBE %@ [%lu]", [mainCube strCoordinates], (unsigned long)[mainCube distanceToEnd]);
        
        for(NSUInteger i=0; i<[[mainCube arrayOfNeighborTransparentCubes] count]; i++)
        {
            cube = [[mainCube arrayOfNeighborTransparentCubes] objectAtIndex:i];
            NSLog(@"- CUBE[%lu] %@ [%lu]", (unsigned long)i, [cube strCoordinates], (unsigned long)[cube distanceToEnd]);
        }
        
        NSLog(@" ");
#endif
        
        [mainCube setArrayOfNeighborTransparentCubes:[arrayOfSortedNeighborTransparentCubes mutableCopy]];
        
        [arrayOfSortedNeighborDistance release]; arrayOfSortedNeighborDistance = nil;
        [arrayOfSortedNeighborTransparentCubes release]; arrayOfSortedNeighborTransparentCubes = nil;
        
        [mainCube setIsNeighborCubesSorted:YES];
        
#if kTraces >= 2
        NSLog(@"SORTING CUBE");
        NSLog(@" ");
        NSLog(@"MAIN CUBE %@ [%lu]", [mainCube strCoordinates], (unsigned long)[mainCube distanceToEnd]);
        
        for(NSUInteger i=0; i<[[mainCube arrayOfNeighborTransparentCubes] count]; i++)
        {
            cube = [[mainCube arrayOfNeighborTransparentCubes] objectAtIndex:i];
            NSLog(@"- CUBE[%lu] %@ [%lu]", (unsigned long)i, [cube strCoordinates], (unsigned long)[cube distanceToEnd]);
        }
        
        NSLog(@" ");
        NSLog(@"-------------");
#endif
    }
    
    // Second step : Solve the maze
    NSInvocationOperation *operation;
    
    for(NSUInteger i=0; i<[[mainCube arrayOfNeighborTransparentCubes] count]; i++)
    {
        cube = [[mainCube arrayOfNeighborTransparentCubes] objectAtIndex:i];
        
        NSMutableArray *arrayOfCubesInPath = [dictionaryOfPaths objectForKey:threadIndex];
        
        if(![arrayOfAllIndexesInAllPaths containsObject:[cube strCoordinates]])
        {
            if(isDisplaySolution && [[cube cubeChar] isEqualTo:@"E"])
            {
                isDisplaySolution = NO;
                [arrayOfCubesInPath addObject:cube];
                [queue cancelAllOperations];
                [self displaySolution];
                break;
            }
            
            if([[cube cubeChar] isEqualTo:@"."])
            {
                if(![arrayOfAllIndexesInAllPaths containsObject:[cube strCoordinates]])
                    [arrayOfAllIndexesInAllPaths addObject:[cube strCoordinates]];
                
                if(i == 0)
                {
                    [arrayOfCubesInPath addObject:cube];
                    
                    operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(solveMazeWithParameters:)
                                                                       object:[NSArray arrayWithObjects:cube, threadIndex, nil]];
                }
                else
                {
                    
                    NSMutableArray *arrayOfCubesInPath = [[NSMutableArray alloc] initWithArray:[dictionaryOfPaths objectForKey:threadIndex]];
                    
                    if([arrayOfCubesInPath lastObject] == [[mainCube arrayOfNeighborTransparentCubes] objectAtIndex:0])
                        [arrayOfCubesInPath removeLastObject];
                    
                    [arrayOfCubesInPath addObject:cube];

                    threadId++;
                    
                    [dictionaryOfPaths setObject:arrayOfCubesInPath forKey:[NSString stringWithFormat:@"%lu", (unsigned long)threadId]];
                    
                    [arrayOfCubesInPath release]; arrayOfCubesInPath = nil;
                    
                    operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(solveMazeWithParameters:)
                                                                       object:[NSArray arrayWithObjects:cube, [NSString stringWithFormat:@"%lu", (unsigned long)threadId], nil]];
                    
                }
                
                [arrayOfOperations addObject:operation];
                
                if([arrayOfOperations count] > 1)
                    [[arrayOfOperations objectAtIndex:[arrayOfOperations count]-1] addDependency:[arrayOfOperations objectAtIndex:[arrayOfOperations count]-2]];
                
                [queue addOperation:operation];
                [operation release];
            }
        }
    }
    
    if(isDisplaySolution && [queue operationCount] <= 1)
    {
        isDisplaySolution = NO;
        
        operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displaySolution) object:nil];
        [arrayOfOperations addObject:operation];
        
        if([arrayOfOperations count] > 1)
            [[arrayOfOperations objectAtIndex:[arrayOfOperations count]-1] addDependency:[arrayOfOperations objectAtIndex:[arrayOfOperations count]-2]];
        
        [queue addOperation:operation];
        [operation release];
    }

#if kTraces >= 1
    NSLog(@"THREADID END  : %@", threadIndex);
#endif
}

// Display the solution
- (void)displaySolution
{
    NSString *indexBestSolution = @"none";
    NSUInteger sizeBestSolution = UINT_MAX;
    
    for(NSUInteger i=0; i<[dictionaryOfPaths count]; i++)
    {
        NSMutableArray *arrayOfCubesInPath = [[NSMutableArray alloc] initWithArray:
                                              [dictionaryOfPaths objectForKey:[NSString stringWithFormat:@"%lu", i]]];
        
        if([[[arrayOfCubesInPath lastObject] cubeChar] isEqualToString:@"E"] && [arrayOfCubesInPath count] < sizeBestSolution)
        {
            sizeBestSolution = [arrayOfCubesInPath count];
            indexBestSolution = [NSString stringWithFormat:@"%lu", i];
        }
        
        [arrayOfCubesInPath release]; arrayOfCubesInPath = nil;
    }
    
    NSLog(@" ");
    
    if([indexBestSolution isEqualToString:@"none"])
    {
        NSLog(@"THE MAZE IS NOT ESCAPABLE!");
        
#if kTraces == 0
        _isDisplayMenu = YES;
#endif
        
#if kTraces >= 1
        [NSThread detachNewThreadSelector:@selector(displaySolutions) toTarget:self withObject:nil];
#endif
    }
    else
    {
        NSMutableString *pathBegintoEnd = [[NSMutableString alloc] init];
        NSMutableArray *arrayOfCubesInPath = [[NSMutableArray alloc] initWithArray: [dictionaryOfPaths objectForKey:indexBestSolution]];
        
#if kTraces >= 1
        NSLog(@"SOLUTION :");
        
        for(NSUInteger i=0; i<[arrayOfCubesInPath count]; i++)
        {
            cube = [arrayOfCubesInPath objectAtIndex:i];
            NSLog(@"%@ %@", [cube cubeChar], [cube strCoordinates]);
        }
        
        NSLog(@" ");
#endif
        
        for(NSUInteger i=0; i<[arrayOfCubesInPath count]-1; i++)
        {
            cube = [arrayOfCubesInPath objectAtIndex:i+1];
            
            NSInteger diffX = [cube cubePos].x;
            NSInteger diffY = [cube cubePos].y;
            NSInteger diffZ = [cube cubePos].z;
            
            cube = [arrayOfCubesInPath objectAtIndex:i];
            
            diffX = diffX - [cube cubePos].x;
            diffY = diffY - [cube cubePos].y;
            diffZ = diffZ - [cube cubePos].z;
            
                 if(diffX == -1) { [pathBegintoEnd appendString:@"W "]; }
            else if(diffX == +1) { [pathBegintoEnd appendString:@"E "]; }
            else if(diffY == -1) { [pathBegintoEnd appendString:@"N "]; }
            else if(diffY == +1) { [pathBegintoEnd appendString:@"S "]; }
            else if(diffZ == -1) { [pathBegintoEnd appendString:@"D "]; }
            else if(diffZ == +1) { [pathBegintoEnd appendString:@"U "]; }
        }
        
        NSLog(@"THE MAZE IS ESCAPABLE : %@", pathBegintoEnd);
        
        [arrayOfCubesInPath release]; arrayOfCubesInPath = nil;
        [pathBegintoEnd release]; pathBegintoEnd = nil;
        
        _isDisplayMenu = YES;
    }
}

// Display all the solutions when traces activated
#if kTraces >= 1
- (void)displaySolutions
{
    NSArray *arrayOfKeys = [[dictionaryOfPaths allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSLog(@" ");
    
    for(NSUInteger j=0; j<[dictionaryOfPaths count]; j++)
    {
        NSMutableString *pathBegintoEnd = [[NSMutableString alloc] init];
        NSMutableArray *arrayOfCubesInPath = [[NSMutableArray alloc] initWithArray: [dictionaryOfPaths objectForKey:[arrayOfKeys objectAtIndex:j]]];
        
        for(NSUInteger i=0; i<[arrayOfCubesInPath count]-1; i++)
        {
            cube = [arrayOfCubesInPath objectAtIndex:i+1];
            
            NSInteger diffX = [cube cubePos].x;
            NSInteger diffY = [cube cubePos].y;
            NSInteger diffZ = [cube cubePos].z;
            
            cube = [arrayOfCubesInPath objectAtIndex:i];
            
            diffX = diffX - [cube cubePos].x;
            diffY = diffY - [cube cubePos].y;
            diffZ = diffZ - [cube cubePos].z;
            
            if(diffX == -1) { [pathBegintoEnd appendString:@"W "]; }
            else if(diffX == +1) { [pathBegintoEnd appendString:@"E "]; }
            else if(diffY == -1) { [pathBegintoEnd appendString:@"N "]; }
            else if(diffY == +1) { [pathBegintoEnd appendString:@"S "]; }
            else if(diffZ == -1) { [pathBegintoEnd appendString:@"D "]; }
            else if(diffZ == +1) { [pathBegintoEnd appendString:@"U "]; }
            
        }
        
        NSLog(@"SOLUTION [%lu] : %@", (unsigned long)j, pathBegintoEnd);
        
        [arrayOfCubesInPath release]; arrayOfCubesInPath = nil;
        [pathBegintoEnd release]; pathBegintoEnd = nil;
    }
    
    _isDisplayMenu = YES;
}
#endif

@end
