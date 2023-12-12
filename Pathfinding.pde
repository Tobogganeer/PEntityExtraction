/*

 Here's the plan for my pathfinding.
 Due to the small number of tiles, I plan to generate Dijkstra maps for each tile.
 https://www.roguebasin.com/index.php?title=The_Incredible_Power_of_Dijkstra_Maps
 These will be rebuilt whenever the blocking objects change (doors open/close, statue entity spawns)
 The memory cost shouldn't be too high - with 15 floor tiles, there should be less than ~30 tiles at any time
 30 tiles with and integer for all 30 tiles = 900 ints
 There will probably be some other data but that's hopefully less than a MB of ram?
 Not the end of the world if it's a few MB though lol
 
 */

static class PathMapCache
{
}

static class PathMap
{
  PVectorInt goal;
  HashMap<PVectorInt, Integer> distances;

  PathMap(PVectorInt goal)
  {
    this.goal = goal;
    this.distances = new HashMap<PVectorInt, Integer>();
  }
}

static class Pathfinding
{
  static final int HighTileValue = 10000; // Couldn't tell ya why I'm storing this

  static PathMap getPathMap(PVectorInt goal, Board board)
  {
    PathMap pathMap = new PathMap(goal);
    HashMap<PVectorInt, Integer> map = pathMap.distances; // Easier access

    for (Tile t : board.tiles.values())
      map.put(t.position, HighTileValue); // Initialize costs to a high value

    map.put(goal, 0); // Set goal distance to zero

    int walkLimit = 100; // Should not take more than a few iterations
    int tilesUpdated = walkDistanceMap(map, goal, board);

    while (tilesUpdated > 0 && walkLimit > 0)
    {
      // Walk the board until all tiles are set correctly
      tilesUpdated = walkDistanceMap(map, goal, board);
      walkLimit--;
    }

    // Uh oh
    if (walkLimit == 0)
      Popup.show("Pathfinding reached max walkLimit!", 5);

    return pathMap;
  }

  // Recursively walks through all tiles setting neighbour distances, starting at position. Returns the number of changes.
  private static int walkDistanceMap(HashMap<PVectorInt, Integer> map, PVectorInt position, Board board)
  {
    int changes = 0;

    // Get the current tile and distance
    Tile current = board.get(position);
    int distance = map.get(position);

    int lowestDistance = HighTileValue;
    // Check if any neighbour is closer to the goal
    for (Tile neighbour : current.neighbours)
    {
      // Only include them if they are accessible
      if (current.isPathClearToNeighbour(neighbour))
        lowestDistance = min(lowestDistance, map.get(neighbour.position));
    }

    // If we are more than 1 distance greater than our closest neighbour
    // Eg 5 - 3 = 2
    if (distance - lowestDistance > 1)
    {
      distance = lowestDistance + 1;
      map.put(position, distance);
      changes++;
    }

    // Walk through neighbours
    for (Tile neighbour : current.neighbours)
    {
      // Don't walk neighbours we can't reach
      if (!current.isPathClearToNeighbour(neighbour))
        continue;
        
      int neighbourDistance = map.get(neighbour.position);
      // If this neighbour is more than 1 tile further than us
      if (neighbourDistance - distance > 1)
      {
        // Walk the neighbour
        changes += walkDistanceMap(map, neighbour.position, board);
      }
    }

    return changes;
  }

  /*
  static Path calculatePath(Board board, PVectorInt start, PVectorInt target)
   {
   }
   */
}

/*
static class Path
 {
 final Tile start;
 final Tile target;
 Tile end; // May be different if a complete path could not be found
 Tile[] tiles;
 Direction[] steps;
 boolean reachedTarget;
 }
 */
