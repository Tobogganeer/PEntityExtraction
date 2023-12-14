static class EffectExecutor
{
  static void execute(Effect effect, Context context)
  {
    if (effect == null || effect.type == null)
    {
      println("Tried to execute null effect.");
      return;
    }

    if (context == null)
    {
      println("Tried to execute effect with no context.");
      return;
    }

    switch(effect.type) {
    case DRAW:
      executeDraw((DrawEffect)effect, context);
      break;
    case DISCARD:
      executeDiscard((DiscardEffect)effect, context);
      break;
    case ATTACK:
      executeAttack((AttackEffect)effect, context);
      break;
    case DAMAGE:
      executeDamage((DamageEffect)effect, context);
      break;
    case HEAL:
      executeHeal((HealEffect)effect, context);
      break;
    case RELOAD:
      executeReload((ReloadEffect)effect, context);
      break;
    case ACTION:
      executeAction((ActionEffect)effect, context);
      break;
    case OPTIONAL:
      executeOptional((OptionalEffect)effect, context);
      break;
    case MULTI:
      executeMulti((MultiEffect)effect, context);
      break;
    case DOOR:
      executeDoor((DoorEffect)effect, context);
      break;
    case DISCOVERRANDOMROOM:
      executeDiscoverRandomRoom((DiscoverRandomRoomEffect)effect, context);
      break;
    case TELEPORT:
      executeTeleport((TeleportEffect)effect, context);
      break;
    case MOVETOWARDS:
      executeMoveTowards((MoveTowardsEffect)effect, context);
      break;
    case MOVE:
      executeMove((MoveEffect)effect, context);
      break;
    case SETVARIABLE:
      executeSetVariable((SetVariableEffect)effect, context);
      break;
    case CHANGETURN:
      executeChangeTurn((ChangeTurnEffect)effect, context);
      break;
    default:
      Popup.show("Unknown effect type tried to execute: " + effect.type.name(), 5);
    }
  }

  /*
    DRAW, // Item, Weapon, Entity
   DISCARD,
   ATTACK,
   DAMAGE, HEAL, RELOAD, ACTION,
   OPTIONAL, MULTI,
   DOOR, // Lock, unlock, lockOrUnlock
   DISCOVERRANDOMROOM,
   TELEPORT, // Player, entity, playerOrEntity
   MOVETOWARDS, // Player, entity
   MOVE,
   SETVARIABLE, // Damage multiplier
   CHANGETURN;
   */

  // Should these be a method in the Effect subclasses? Maybe...

  static void executeDraw(DrawEffect effect, Context ctx)
  {
    // FOR NOW: Only single target drawing (one player, self)
  }

  static void executeDiscard(DiscardEffect effect, Context ctx)
  {
    // FOR NOW: Only random and self cards (no getting to choose)
  }

  static void executeAttack(AttackEffect effect, Context ctx)
  {
    // FOR NOW: Just give an action
  }

  static void executeDamage(DamageEffect effect, Context ctx)
  {
    // FOR NOW: Group player damage, single entity damage only
  }

  static void executeHeal(HealEffect effect, Context ctx)
  {
    // FOR NOW: No healing entities
  }

  static void executeReload(ReloadEffect effect, Context ctx)
  {
    // FOR NOW: Single reloading only
  }

  static void executeAction(ActionEffect effect, Context ctx)
  {
    // FOR NOW: Single target only
  }

  static void executeOptional(OptionalEffect effect, Context ctx)
  {
    // FOR NOW:
  }

  static void executeMulti(MultiEffect effect, Context ctx)
  {
    for (Effect sub : effect.effects)
      execute(sub, ctx);
  }

  static void executeDoor(DoorEffect effect, Context ctx)
  {
    // FOR NOW: do nothing lol
    Game.board().updateTiles();
  }

  static void executeDiscoverRandomRoom(DiscoverRandomRoomEffect effect, Context ctx)
  {
    Game.board().updateTiles();
  }

  static void executeTeleport(TeleportEffect effect, Context ctx)
  {
    // FOR NOW: No random targets
    Game.board().updateTiles();
  }

  static void executeMoveTowards(MoveTowardsEffect effect, Context ctx)
  {
    // FOR NOW: No random targets
    if (effect.type == EffectType.MOVETOWARDS)
    {
      MoveTowardsEffect move = (MoveTowardsEffect)effect;
      if (move.toTarget == EffectTarget.NEAREST && move.toSelect == EffectSelector.PLAYER)
      {
        Entity e = ctx.entity;
        Path path = new Path(e.position, Game.players()[0].position, Game.board());
        if (path.steps.length > 0)
          e.position.add(path.steps[0].getOffset());
        Game.board().updateTiles();
      }
    }

    Game.board().updateTiles();
  }

  static void executeMove(MoveEffect effect, Context ctx)
  {
    // FOR NOW: No random targets
    Game.board().updateTiles();
  }

  static void executeSetVariable(SetVariableEffect effect, Context ctx)
  {
    // FOR NOW: do nothing
  }

  static void executeChangeTurn(ChangeTurnEffect effect, Context ctx)
  {
  }
}
