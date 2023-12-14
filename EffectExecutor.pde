import java.util.Collection;

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
    if (effect.target == EffectTarget.SELF)
    {
      if (effect.what == CardDrawType.ITEM)
        for (int i = 0; i < effect.amount; i++)
          ctx.player.give(Game.drawItem());
      else
      {
        for (int i = 0; i < effect.amount; i++)
        {
          Card card = Game.drawEntity();
          if (card.data.type == CardType.ENTITY)
          {
            Player p = ctx.player;
            if (p == null)
              // Get a random player on the tile if we aren't there (DiscoverRandomRoom)
              if (ctx.tile.currentPlayers.size() > 0)
                p = ctx.tile.currentPlayers.get((int)Applet.get().random(ctx.tile.currentPlayers.size()));
            Entity.spawn(ctx.tile.position, (EntityData)card.data, p);
          } else
          {
            ctx.player.give(card);
          }
        }
      }
    }
  }

  // This place should really have { } instead of just top level if's... (idk what they are called)

  static void executeDiscard(DiscardEffect effect, Context ctx)
  {
    // FOR NOW: Only random and self cards (no getting to choose)
    if (effect.card == EffectTarget.SELF)
    {
      ctx.player.discard(ctx.card);
    } else if (effect.target == EffectTarget.SELF)
    {
      for (int i = 0; i < effect.amount; i++)
        ctx.player.discardRandomCard();
    } else if (effect.target == EffectTarget.ALL)
    {
      if (effect.where == EffectLocation.ONTILE)
      {
        for (Player p : Game.players())
          if (p.position.equals(ctx.tile.position))
            for (int i = 0; i < effect.amount; i++)
              p.discardRandomCard();
      } else if (effect.where == EffectLocation.ANY)
      {
        for (Player p : Game.players())
          for (int i = 0; i < effect.amount; i++)
            p.discardRandomCard();
      }
    }
  }

  static void executeAttack(AttackEffect effect, Context ctx)
  {
    // FOR NOW: Just give an action
    if (effect.target == EffectTarget.SELF)
    {
      if (ctx.type == ContextType.PLAYER)
        ctx.player.remainingActions++;
    }
  }

  static void executeDamage(DamageEffect effect, Context ctx)
  {
    // FOR NOW: Group player damage, single entity damage only

    if (effect.target == EffectTarget.SELF)
    {
      if (ctx.type == ContextType.PLAYER)
        ctx.player.damage(effect.amount);
      else if (ctx.type == ContextType.ENTITY)
        ctx.entity.damage(effect.amount);
    } else if (effect.target == EffectTarget.ALL)
    {
      if (effect.select == EffectSelector.ENTITY)
      {
        if (effect.where == EffectLocation.ONTILE)
        {
          for (Entity e : Game.entities())
            if (e.position.equals(ctx.tile.position))
              e.damage(effect.amount);
        } else if (effect.where == EffectLocation.ANY)
        {
          for (Entity e : Game.entities())
            e.damage(effect.amount);
        }
      } else if (effect.select == EffectSelector.PLAYER)
      {
        if (effect.where == EffectLocation.ONTILE)
        {
          for (Player p : Game.players())
            if (p.position.equals(ctx.tile.position))
              p.damage(effect.amount);
        } else if (effect.where == EffectLocation.ANY)
        {
          for (Player p : Game.players())
            p.damage(effect.amount);
        }
      }
    }
  }

  static void executeHeal(HealEffect effect, Context ctx)
  {
    // FOR NOW:
    if (effect.target == EffectTarget.SELF)
    {
      if (ctx.type == ContextType.PLAYER)
        ctx.player.heal(effect.amount);
      else if (ctx.type == ContextType.ENTITY)
        ctx.entity.heal(effect.amount);
    } else if (effect.target == EffectTarget.ALL)
    {
      if (effect.select == EffectSelector.ENTITY)
      {
        if (effect.where == EffectLocation.ONTILE)
        {
          for (Entity e : Game.entities())
            if (e.position.equals(ctx.tile.position))
              e.heal(effect.amount);
        } else if (effect.where == EffectLocation.ANY)
        {
          for (Entity e : Game.entities())
            e.heal(effect.amount);
        }
      } else if (effect.select == EffectSelector.PLAYER)
      {
        if (effect.where == EffectLocation.ONTILE)
        {
          for (Player p : Game.players())
            if (p.position.equals(ctx.tile.position))
              p.heal(effect.amount);
        } else if (effect.where == EffectLocation.ANY)
        {
          for (Player p : Game.players())
            p.heal(effect.amount);
        }
      }
    }
  }

  static void executeReload(ReloadEffect effect, Context ctx)
  {
    // FOR NOW: Single reloading only
    if (effect.target == EffectTarget.SELF)
    {
      if (ctx.type == ContextType.PLAYER)
        ctx.player.reload(effect.amount);
    } else if (effect.target == EffectTarget.ALL)
    {
      if (effect.select == EffectSelector.PLAYER)
      {
        if (effect.where == EffectLocation.ONTILE)
        {
          for (Player p : Game.players())
            if (p.position.equals(ctx.tile.position))
              p.reload(effect.amount);
        } else if (effect.where == EffectLocation.ANY)
        {
          for (Player p : Game.players())
            p.reload(effect.amount);
        }
      }
    }
  }

  static void executeAction(ActionEffect effect, Context ctx)
  {
    // FOR NOW: Single target only
    if (effect.target == EffectTarget.SELF)
    {
      if (ctx.type == ContextType.PLAYER)
        ctx.player.remainingActions++;
    }
  }

  static void executeOptional(OptionalEffect effect, Context ctx)
  {
    ModalMenu.prompt("Select an option:", (m, i) -> execute(effect.options[i], ctx), effect.labels);
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
    ArrayList<Tile> tiles = new ArrayList<Tile>(Game.board().tiles.values());
    Collections.shuffle(tiles);
    for (Tile t : tiles)
    {
      if (t.data.type == CardType.ROOM)
      {
        RoomTile room = (RoomTile)t;
        if (!room.discovered)
        {
          room.discover(null);
          break;
        }
      }
    }
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
    PVectorInt targetPosition = null;

    // TODO: Nearest won't work for multi-target
    if (effect.toSelect == EffectSelector.ENTITY)
    {
      Entity target = null;
      if (effect.toTarget == EffectTarget.SELF)
        target = ctx.entity;
      else if (effect.toTarget == EffectTarget.NEAREST)
        target = Game.getNearestEntity(ctx.tile.position);

      targetPosition = target.position;
    } else if (effect.toSelect == EffectSelector.PLAYER)
    {
      Player target = null;
      if (effect.toTarget == EffectTarget.SELF)
        target = ctx.player;
      else if (effect.toTarget == EffectTarget.NEAREST)
        target = Game.getNearestPlayer(ctx.tile.position);

      targetPosition = target.position;
    } else if (effect.toSelect == EffectSelector.PLAYERWITHLEASTITEMS)
    {
      Player target = null;
      int cards = Game.settings().maxItems;
      for (Player p : Game.players())
      {
        if (p.cards.size() < cards)
        {
          cards = p.cards.size();
          target = p;
        }
      }

      targetPosition = target.position;
    }

    if (effect.target == EffectTarget.SELF)
    {
      if (ctx.type == ContextType.ENTITY)
      {
        ctx.entity.moveTowards(targetPosition);
      } else if (ctx.type == ContextType.PLAYER)
      {
        ctx.player.moveTowards(targetPosition);
      }
    } else if (effect.target == EffectTarget.ALL)
    {
      if (ctx.type == ContextType.ENTITY)
      {
        for (Entity e : Game.entities())
          e.moveTowards(targetPosition);
      } else if (ctx.type == ContextType.PLAYER)
      {
        for (Player p : Game.players())
          p.moveTowards(targetPosition);
      }
    }

    /*
    if (move.toTarget == EffectTarget.NEAREST && move.toSelect == EffectSelector.PLAYER)
     {
     Entity e = ctx.entity;
     Path path = new Path(e.position, Game.players()[0].position, Game.board());
     if (path.steps.length > 0)
     e.position.add(path.steps[0].getOffset());
     Game.board().updateTiles();
     }
     */

    Game.board().updateTiles();
  }

  static void executeMove(MoveEffect effect, Context ctx)
  {
    // FOR NOW: No random targets, players XOR 1 entity, not both
    if (effect.select == EffectSelector.PLAYER)
    {
      if (effect.target == EffectTarget.SELF)
      {
        MoveMenu.getMovement(ctx.player.position, effect.amount, (pos) -> {
          ctx.player.position = pos;
        }
        );
      } else if (effect.target == EffectTarget.ALL)
      {
        for (Player p : Game.players())
        {
          MoveMenu.getMovement(p.position, effect.amount, (pos) -> {
            p.position = pos;
          }
          );
        }
      }
    } else if (effect.select == EffectSelector.ENTITY)
    {
      if (Game.entities().size() > 0)
      {
        EntitiesMenu.selectEntity((entity) ->
          MoveMenu.getMovement(entity.position, effect.amount, (pos) -> {
          entity.position = pos;
        }
        ));
      }
    }

    Game.board().updateTiles();
  }

  static void executeSetVariable(SetVariableEffect effect, Context ctx)
  {
    if (ctx.player != null)
    {
      if (effect.variable == CardVariableType.DAMAGEMULTIPLIER)
      {
        ctx.player.damageMultiplier = (int)effect.value;
      }
    }
  }

  static void executeChangeTurn(ChangeTurnEffect effect, Context ctx)
  {
    if (effect.turn == Turn.PLAYER)
      // A player could start a round with more than max items with this,
      // but who's gonna notice?
      Game.current.startPlayerTurns();
    else
      Game.current.startEntityTurn();
  }
}
