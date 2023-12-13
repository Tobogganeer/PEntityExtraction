static class Entity
{
  static final float fullNameZoomThreshold = 1.0;

  PVectorInt position;
  final EntityData data;
  int health;

  boolean takenTurn;

  int colourIndex;

  Entity(PVectorInt position, EntityData data)
  {
    this.position = position.copy();
    this.data = data;
    health = data.health;
  }

  static Entity spawnNoDiscover(PVectorInt position, EntityData data)
  {
    Entity entity = new Entity(position, data);
    Game.current.entities.add(entity);
    return entity;
  }

  static void spawn(PVectorInt position, EntityData data, Player discoveringPlayer)
  {
    spawnNoDiscover(position, data).discover(discoveringPlayer);
  }

  void discover(Player player)
  {
    for (Effect effect : data.onDiscovery)
      // ContextType type, Card card, Tile tile, Player player, Entity entity
      EffectExecutor.execute(effect, new Context(ContextType.ENTITY, null, currentTile(), player, this));
  }



  void heal(int amount)
  {
    health = min(health + amount, data.health);
  }

  void damage(int amount)
  {
    health = max(health - amount, 0);
    if (health == 0)
      kill();
  }

  void kill()
  {
    // Not sure if this should be before or after removal?
    for (Effect e : data.onDeath)
      executeEffect(e);

    Game.current.entities.remove(this);
    Game.board().updateTiles();
  }

  void takeTurn()
  {
    for (Effect e : data.onTurn)
      executeEffect(e);
  }



  Tile currentTile()
  {
    return Game.board().get(position);
  }

  void executeEffect(Effect effect)
  {
    EffectExecutor.execute(effect, new Context(this));
  }

  void draw(PVector offset)
  {
    Draw.start();
    {
      Colours.fill(getColour());
      Colours.stroke(Colours.black);
      Colours.strokeWeight(3);
      float size = 65;
      Rect rect = new Rect(offset.x, offset.y, size, size);
      rect.draw(10);

      Text.align(TextAlign.CENTER);
      Text.colour = 0; // White

      // We are zoomed in close enough
      if (Game.board().zoom > fullNameZoomThreshold)
        Text.box(data.name, rect, 1.5);
      else
        Text.box("Ent.", rect, 3);
    }
    Draw.end();
  }

  int getColour()
  {
    // If the entities menu is open and we are selected
    return Menus.isInStack(Menus.entities) && Menus.entities.selectedIndex == colourIndex ? Colours.selectedEntity : Colours.entity;
  }
}
