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
  Board board;
  HashMap<PVectorInt, PathMap> directPaths; // If every door was unlocked
  HashMap<PVectorInt, PathMap> actualPaths; // Includes blocked doors etc

  PathMapCache(Board board)
  {
    this.board = board;

    directPaths = new HashMap<PVectorInt, PathMap>();
    actualPaths = new HashMap<PVectorInt, PathMap>();
  }

  void calculatePaths()
  {
    calculateDirectPaths();
    calculateActualPaths();
  }

  void calculateDirectPaths()
  {
    calculatePaths(directPaths, false);
  }

  // Called when a door is locked/unlocked, etc
  void calculateActualPaths()
  {
    calculatePaths(actualPaths, true);
  }

  private void calculatePaths(HashMap<PVectorInt, PathMap> paths, boolean acknowledgeBlockedTiles)
  {
    paths.clear();
    for (Tile t : board.tiles.values())
    {
      paths.put(t.position, Pathfinding.getPathMap(t.position, board, acknowledgeBlockedTiles));
    }
  }


  int getDirectDistance(PVectorInt from, PVectorInt to)
  {
    return directPaths.get(to).distances.get(from);
  }

  int getActualDistance(PVectorInt from, PVectorInt to)
  {
    return actualPaths.get(to).distances.get(from);
  }
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

  static PathMap getPathMap(PVectorInt goal, Board board, boolean acknowledgeBlockedTiles)
  {
    PathMap pathMap = new PathMap(goal);
    HashMap<PVectorInt, Integer> map = pathMap.distances; // Easier access

    for (Tile t : board.tiles.values())
      map.put(t.position, HighTileValue); // Initialize costs to a high value

    map.put(goal, 0); // Set goal distance to zero

    int walkLimit = 100; // Should not take more than a few iterations
    int tilesUpdated = walkDistanceMap(map, goal, board, acknowledgeBlockedTiles);

    while (tilesUpdated > 0 && walkLimit > 0)
    {
      // Walk the board until all tiles are set correctly
      tilesUpdated = walkDistanceMap(map, goal, board, acknowledgeBlockedTiles);
      walkLimit--;
    }

    // Uh oh
    if (walkLimit == 0)
      Popup.show("Pathfinding reached max walkLimit!", 5);

    return pathMap;
  }

  // Recursively walks through all tiles setting neighbour distances, starting at position. Returns the number of changes.
  private static int walkDistanceMap(HashMap<PVectorInt, Integer> map, PVectorInt position, Board board, boolean acknowledgeBlockedTiles)
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
      if (!acknowledgeBlockedTiles || current.isPathClearToNeighbour(neighbour))
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
      if (acknowledgeBlockedTiles && !current.isPathClearToNeighbour(neighbour))
        continue;

      int neighbourDistance = map.get(neighbour.position);
      // If this neighbour is more than 1 tile further than us
      if (neighbourDistance - distance > 1)
      {
        // Walk the neighbour
        changes += walkDistanceMap(map, neighbour.position, board, acknowledgeBlockedTiles);
      }
    }

    return changes;
  }

  // Used for finding the closest player/entity to a point
  static int getClosest(PVectorInt to, ArrayList<PVectorInt> from)
  {
    if (from.size() == 0)
      return 0;

    ArrayList<Path> paths = new ArrayList<Path>();
    for (PVectorInt start : from)
      paths.add(new Path(start, to, Game.board()));

    int closestDistance = HighTileValue;
    int closestIndex = -1;
    for (int i = 0; i < paths.size(); i++)
    {
      if (paths.get(i).distance < closestDistance)
      {
        closestDistance = paths.get(i).distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }
}


static class Path
{
  final Tile start;
  final Tile target;
  Tile end; // May be different if a complete path could not be found
  Tile[] tiles; // Includes the start and end
  Direction[] steps;
  int distance;
  final boolean canReachTarget;

  Path(PVectorInt start, PVectorInt target, Board board)
  {
    this.start = board.get(start);
    this.target = board.get(target);

    // Bruh
    if (start.equals(target))
    {
      end = this.target;
      tiles = new Tile[] { this.start, this.end };
      steps = new Direction[0];
      canReachTarget = true;
      return;
    }

    PathMap actualPath = board.pathMapCache.actualPaths.get(target);
    PathMap directPath = board.pathMapCache.directPaths.get(target);

    // Is the end reachable?
    if (actualPath.distances.get(start) == Pathfinding.HighTileValue)
      canReachTarget = false;
    else
      canReachTarget = true;

    // Make sure the passed start is valid
    if (directPath.distances.get(start) == Pathfinding.HighTileValue)
    {
      Popup.show("No path found (tile is disconnected from map?)", 5);
      Game.end();
    }

    if (canReachTarget)
      fillPath(actualPath, start, board, false);
    else
      fillPath(directPath, start, board, true);

    distance = steps.length;
  }

  // Walk until we get to the target
  void fillPath(PathMap map, PVectorInt start, Board board, boolean checkImpassableConnections)
  {
    ArrayList<Tile> walkedTiles = new ArrayList<Tile>();
    ArrayList<Direction> directions = new ArrayList<Direction>();

    Tile current = board.get(start);
    walkedTiles.add(current); // The first tile!!1!1!1
    int distance = map.distances.get(current.position);

    while (distance > 0)
    {
      Tile closestNeighbour = null;
      int closestDistance = distance;
      // Find our neighbour closest to the goal (travel downhill)
      for (Tile neighbour : current.neighbours)
      {
        // Make sure we can reach this neighbour (if we are checking for it)
        if (checkImpassableConnections && !current.isPathClearToNeighbour(neighbour))
          continue;

        int neighbourDistance = map.distances.get(neighbour.position);
        if (neighbourDistance < closestDistance)
        {
          closestDistance = neighbourDistance;
          closestNeighbour = neighbour;
        }
      }

      // If we didn't find any closer neighbours
      if (closestDistance == distance || closestNeighbour == null)
        break;

      // Add this step to our lists
      walkedTiles.add(closestNeighbour);
      directions.add(current.dir(closestNeighbour));
      // Get ready to loop starting at this neighbour
      current = closestNeighbour;
      distance = closestDistance;
    }

    // Set the member variables
    tiles = walkedTiles.toArray(new Tile[0]);
    steps = directions.toArray(new Direction[0]);
    end = walkedTiles.get(walkedTiles.size() - 1);
  }
}
