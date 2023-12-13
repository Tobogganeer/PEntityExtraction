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

  Tile currentTile()
  {
    return Game.board().get(position);
  }

  void executeEffect(Effect effect, Card card)
  {
    EffectExecutor.execute(effect, new Context(this, card));
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
