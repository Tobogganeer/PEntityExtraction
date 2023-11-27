static class Tile
{
  PVectorInt position;

  // TODO: Impl
}

// TODO: Probably move this class into another file
static class Connection
{
  Direction direction;
  ConnectionType type;

  Connection(Direction direction, ConnectionType type)
  {
    this.direction = direction;
    this.type = type;
  }

  boolean canConnectTyo(Connection connection)
  {
    return this.direction.oppositeTo(connection.direction);
  }
}

// TODO: This too for sure, does not belong here lol
// Have way too many classes though, a million tabs is so tricky
// Want to use VSCode but the support and autofill is icky
static class CardEffect
{
  
}
