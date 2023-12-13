static class EffectExecutor
{
  static void execute(Effect effect, Context context)
  {
    if (effect.type == EffectType.MOVETOWARDS)
    {
      MoveTowardsEffect move = (MoveTowardsEffect)effect;
      if (move.toTarget == EffectTarget.NEAREST && move.toSelect == EffectSelector.PLAYER)
      {
        Entity e = context.entity;
        Path path = new Path(e.position, Game.players()[0].position, Game.board());
        if (path.steps.length > 0)
          e.position.add(path.steps[0].getOffset());
        Game.board().updateTiles();
      }
    }
  }
}
