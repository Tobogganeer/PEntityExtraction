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

static class PathCache
{
  
}

static class Pathfinding
{
  
  
  static Path calculatePath(Board board, PVectorInt start, PVectorInt target)
  {
    
  }
}

static class Path
{
  final Tile start;
  final Tile target;
  Tile end; // May be different if a complete path could not be found
  Tile[] tiles;
  Direction[] steps;
  boolean reachedTarget;
}
