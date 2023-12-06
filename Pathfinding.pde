static class Pathfinding
{
}

static class Path
{
  Tile start;
  Tile target;
  Tile end; // May be different if a complete path could not be found
  Tile[] tiles;
  Direction[] steps;
}
