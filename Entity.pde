static class Entity
{
  PVectorInt position;
  final EntityData data = null;

  void executeEffect(Effect effect, Card card)
  {
    EffectExecutor.execute(effect, new Context(this, card));
  }
}
