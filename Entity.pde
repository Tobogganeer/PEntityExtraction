static class Entity
{
  PVectorInt position;
  final EntityData data;
  int health;
  
  boolean takenTurn;

  Entity(PVectorInt position, EntityData data)
  {
    this.position = position.copy();
    this.data = data;
    health = data.health;
  }

  Tile currentTile()
  {
    return Game.board().get(position);
  }

  void executeEffect(Effect effect, Card card)
  {
    EffectExecutor.execute(effect, new Context(this, card));
  }
}
