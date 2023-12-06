
static class Effect
{
  final static String ID_type = "type";
  final static String ID_amount = "amount";
  final static String ID_target = "target";
  final static String ID_targetCount = "targetCount";
  final static String ID_where = "where";
  final static String ID_select = "select";
  final static int INVALID_NUMBER = -1;

  // Not making everything final like CardData because I feel like it
  // (don't want to make million-argument constructors)
  final EffectType type;
  int amount = INVALID_NUMBER;
  EffectTarget target;
  int targetCount = INVALID_NUMBER;
  EffectLocation where;
  EffectSelector select;

  Effect(EffectType type)
  {
    this.type = type;
  }

  Effect(JSONObject obj) throws InvalidEffectException
  {
    if (obj == null)
      throw new InvalidEffectException("Tried to create an effect from a null JSONObject.");

    if (!obj.hasKey(ID_type))
      throw new InvalidEffectException("Tried to create an effect with no type.");

    EffectType jsonType = JSON.getEnum(EffectType.class, obj, ID_type);
    if (jsonType == null)
      throw new InvalidEffectException("Tried to create an effect with an invalid type.");

    this.type = jsonType;

    // These might all have no value VVV
    amount = obj.getInt(ID_amount, INVALID_NUMBER);
    target = JSON.getEnum(EffectTarget.class, obj, ID_target);
    targetCount = obj.getInt(ID_targetCount, INVALID_NUMBER);
    where = JSON.getEnum(EffectLocation.class, obj, ID_where);
    select = JSON.getEnum(EffectSelector.class, obj, ID_select);
  }

  // Overriden by subclasses
  void apply(Context context) {
  }

  JSONObject toJSON()
  {
    // TODO: impl
    return null;
  }

  // Returns the correct subclass
  static Effect fromJSON(JSONObject obj) throws InvalidEffectException
  {
    if (obj == null)
      throw new InvalidEffectException("Tried to parse an effect from a null JSONObject.");

    if (!obj.hasKey(ID_type))
      throw new InvalidEffectException("Tried to parse an effect with no type.");

    EffectType jsonType = JSON.getEnum(EffectType.class, obj.getString(ID_type));
    if (jsonType == null)
      throw new InvalidEffectException("Tried to parse an effect with an invalid type.");

    switch (jsonType)
    {
    case DRAW:
      return new DrawEffect(obj);
    case DISCARD:
      return new DiscardEffect(obj);
    case ATTACK:
      return new AttackEffect(obj);
    case DAMAGE:
      return new DamageEffect(obj);
    case HEAL:
      return new HealEffect(obj);
    case RELOAD:
      return new ReloadEffect(obj);
    case ACTION:
      return new ActionEffect(obj);
    case OPTIONAL:
      return new OptionalEffect(obj);
    case MULTI:
      return new MultiEffect(obj);
    case DOOR:
      return new DoorEffect(obj);
    case DISCOVERRANDOMROOM:
      return new DiscoverRandomRoomEffect(obj);
    case TELEPORT:
      return new TeleportEffect(obj);
    case MOVETOWARDS:
      return new MoveTowardsEffect(obj);
    case MOVE:
      return new MoveEffect(obj);
    case SETVARIABLE:
      return new SetVariableEffect(obj);
    case CHANGETURN:
      return new ChangeTurnEffect(obj);
    default:
      throw new InvalidEffectException("Tried to parse an effect with an unknown type.");
    }
  }

  static Effect[] fromJSONArray(JSONArray jsonEffects)
  {
    /*
    Effect[] effects = new Effect[jsonEffects.size()];
     for (int i = 0; i < effects.length; i++)
     effects[i] = Effect.fromJSON(jsonEffects.getJSONObject(i));
     return effects;
     */
    ArrayList<Effect> effects = new ArrayList<Effect>();
    for (int i = 0; i < jsonEffects.size(); i++)
    {
      // Check if the effect can actually be properly parsed
      try
      {
        Effect e = Effect.fromJSON(jsonEffects.getJSONObject(i));
        if (e != null)
          effects.add(e);
      }
      catch(InvalidEffectException ex)
      {
        Popup.show("Error creating effect: " + ex.getMessage(), 3);
      }
    }

    // https://stackoverflow.com/questions/5374311/convert-arrayliststring-to-string-array
    return effects.toArray(new Effect[0]);
  }

  static JSONArray toJSONArray(Effect[] effects)
  {
    JSONArray jsonEffects = new JSONArray();
    if (effects == null || effects.length == 0)
      return jsonEffects;

    for (Effect e : effects)
      jsonEffects.append(e.toJSON());
    return jsonEffects;
  }
}



static class InvalidEffectException extends Exception
{
  public InvalidEffectException() {
  }

  public InvalidEffectException(String message)
  {
    super(message);
  }
}

static class Context
{
  final ContextType type;
  final Card card;
  final Player player;
  final Entity entity;

  Context(ContextType type, Card card, Player player, Entity entity)
  {
    this.type = type;
    this.player = player;
    this.entity = entity;
    this.card = card;
  }

  Context(Player player, Card card)
  {
    this(ContextType.PLAYER, card, player, null);
  }

  Context(Entity entity, Card card)
  {
    this(ContextType.ENTITY, card, null, entity);
  }
}






// ============================================== Subclasses =====================================================


// throw new InvalidEffectException("JSONObject for ____Effect had no '____' value!");

// ========================== Draw ========================== //
static class DrawEffect extends Effect
{
  static final String ID_what = "what";

  CardDrawType what;

  DrawEffect(CardDrawType what, int amount, EffectTarget target, int targetCount, EffectLocation where)
  {
    super(EffectType.DRAW);
    this.what = what;
    this.amount = amount == INVALID_NUMBER ? 1 : amount;
    this.target = target == null ? EffectTarget.SELF : target;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    this.where = where == null ? EffectLocation.ANY : where;
  }

  DrawEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    what = JSON.getEnum(CardDrawType.class, obj, ID_what);
    if (what == null)
      throw new InvalidEffectException("JSONObject for DrawEffect had no 'what' value!");

    // Optional
    amount = amount == INVALID_NUMBER ? 1 : amount;
    target = target == null ? EffectTarget.SELF : target;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    where = where == null ? EffectLocation.ANY : where;
    // TODO: Player with least cards can draw?
    //select = select == null ? EffectSelector.PLAYER : select;
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setString(ID_what, what.name());
    obj.setInt(ID_amount, amount);
    obj.setString(ID_target, target.name());
    obj.setInt(ID_targetCount, targetCount);
    obj.setString(ID_where, where.name());

    return obj;
  }
}

// ========================== Discard ========================== //
static class DiscardEffect extends Effect
{
  DiscardEffect(int amount, EffectTarget target, int targetCount, EffectLocation where)
  {
    super(EffectType.DISCARD);
    this.amount = amount == INVALID_NUMBER ? 1 : amount;
    this.target = target == null ? EffectTarget.SELF : target;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    this.where = where == null ? EffectLocation.ANY : where;
  }

  DiscardEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Optional
    amount = amount == INVALID_NUMBER ? 1 : amount;
    target = target == null ? EffectTarget.SELF : target;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    where = where == null ? EffectLocation.ANY : where;
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setInt(ID_amount, amount);
    obj.setString(ID_target, target.name());
    obj.setInt(ID_targetCount, targetCount);
    obj.setString(ID_where, where.name());

    return obj;
  }
}

// ========================== Attack ========================== //
static class AttackEffect extends Effect
{
  AttackEffect(int amount, EffectTarget target, int targetCount, EffectLocation where, EffectSelector select)
  {
    super(EffectType.ATTACK);
    this.amount = amount == INVALID_NUMBER ? 1 : amount;
    this.target = target == null ? EffectTarget.SELF : target;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    this.where = where == null ? EffectLocation.ANY : where;
    this.select = select == null ? EffectSelector.PLAYER : select;
  }

  AttackEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Optional
    amount = amount == INVALID_NUMBER ? 1 : amount;
    target = target == null ? EffectTarget.SELF : target;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    where = where == null ? EffectLocation.ANY : where;
    select = select == null ? EffectSelector.PLAYER : select;
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setInt(ID_amount, amount);
    obj.setString(ID_target, target.name());
    obj.setInt(ID_targetCount, targetCount);
    obj.setString(ID_where, where.name());
    obj.setString(ID_select, select.name());

    return obj;
  }
}

// ========================== Damage ========================== //
static class DamageEffect extends Effect
{
  DamageEffect(int amount, EffectTarget target, EffectLocation where, EffectSelector select, int targetCount)
  {
    super(EffectType.DAMAGE);
    this.amount = amount;
    this.target = target == null ? EffectTarget.SELF : target;
    this.where = where == null ? EffectLocation.ANY : where;
    this.select = select == null ? EffectSelector.PLAYERORENTITY : select;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
  }

  DamageEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    if (amount == INVALID_NUMBER)
      throw new InvalidEffectException("JSONObject for DamageEffect had no 'amount' value!");

    // Optional
    target = target == null ? EffectTarget.SELF : target;
    where = where == null ? EffectLocation.ANY : where;
    select = select == null ? EffectSelector.PLAYERORENTITY : select;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setInt(ID_amount, amount);
    obj.setString(ID_target, target.name());
    obj.setString(ID_where, where.name());
    obj.setString(ID_select, select.name());
    obj.setInt(ID_targetCount, targetCount);

    return obj;
  }
}

// ========================== Heal ========================== //
static class HealEffect extends Effect
{
  HealEffect(int amount, EffectTarget target, EffectLocation where, EffectSelector select, int targetCount)
  {
    super(EffectType.HEAL);
    this.amount = amount;
    this.target = target == null ? EffectTarget.SELF : target;
    this.where = where == null ? EffectLocation.ANY : where;
    this.select = select == null ? EffectSelector.PLAYERORENTITY : select;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
  }

  HealEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    if (amount == INVALID_NUMBER)
      throw new InvalidEffectException("JSONObject for HealEffect had no 'amount' value!");

    // Optional
    target = target == null ? EffectTarget.SELF : target;
    where = where == null ? EffectLocation.ANY : where;
    select = select == null ? EffectSelector.PLAYERORENTITY : select;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setInt(ID_amount, amount);
    obj.setString(ID_target, target.name());
    obj.setString(ID_where, where.name());
    obj.setString(ID_select, select.name());
    obj.setInt(ID_targetCount, targetCount);

    return obj;
  }
}

// ========================== Reload ========================== //
static class ReloadEffect extends Effect
{
  ReloadEffect(int amount, EffectTarget target, EffectLocation where, int targetCount)
  {
    super(EffectType.RELOAD);
    this.amount = amount;
    this.target = target == null ? EffectTarget.SELF : target;
    this.where = where == null ? EffectLocation.ANY : where;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
  }

  ReloadEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    if (amount == INVALID_NUMBER)
      throw new InvalidEffectException("JSONObject for ReloadEffect had no 'amount' value!");

    // Optional
    target = target == null ? EffectTarget.SELF : target;
    where = where == null ? EffectLocation.ANY : where;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setInt(ID_amount, amount);
    obj.setString(ID_target, target.name());
    obj.setString(ID_where, where.name());
    obj.setInt(ID_targetCount, targetCount);

    return obj;
  }
}

// ========================== Action ========================== //
// This is deprecated (replaced by MoveEffect and AttackEffect)
/*
static class ActionEffect extends Effect
 {
 ActionEffect()
 {
 super(EffectType.ACTION);
 }
 
 ActionEffect(JSONObject obj) throws InvalidEffectException
 {
 super(obj);
 
 // Required Values
 
 // Optional
 }
 
 void apply(Context context)
 {
 }
 
 JSONObject toJSON()
 {
 JSONObject obj = super.toJSON();
 
 return obj;
 }
 }
 */

// ========================== Optional ========================== //
static class OptionalEffect extends Effect
{
  static final String ID_labels = "labels";
  static final String ID_options = "options";

  String[] labels;
  Effect[] options;

  OptionalEffect(String[] labels, Effect... options)
  {
    super(EffectType.OPTIONAL);
    this.labels = labels;
    this.options = options;
  }

  OptionalEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    if (!obj.hasKey(ID_labels))
      throw new InvalidEffectException("JSONObject for MultiEffect had no 'labels' value!");
    labels = obj.getStringList(ID_labels).toArray();
    if (!obj.hasKey(ID_options))
      throw new InvalidEffectException("JSONObject for MultiEffect had no 'options' value!");
    options = Effect.fromJSONArray(obj.getJSONArray(ID_options));
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setJSONArray(ID_options, Effect.toJSONArray(options));
    JSONArray jsonLabels = new JSONArray();
    for (String l : labels)
      jsonLabels.append(l);
    obj.setJSONArray(ID_labels, jsonLabels);

    return obj;
  }
}

// ========================== Multi ========================== //
static class MultiEffect extends Effect
{
  static final String ID_effects = "effects";

  Effect[] effects;

  MultiEffect(Effect... effects)
  {
    super(EffectType.MULTI);

    this.effects = effects;
  }

  MultiEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    if (!obj.hasKey(ID_effects))
      throw new InvalidEffectException("JSONObject for MultiEffect had no 'effects' value!");
    effects = Effect.fromJSONArray(obj.getJSONArray(ID_effects));
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setJSONArray(ID_effects, Effect.toJSONArray(effects));

    return obj;
  }
}

// ========================== Door ========================== //
static class DoorEffect extends Effect
{
  static final String ID_action = "action";

  DoorActionType action;

  DoorEffect(int targetCount, DoorActionType action, EffectTarget target, EffectLocation where)
  {
    super(EffectType.DOOR);
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    this.action = action;
    this.target = target;
    this.where = where == null ? EffectLocation.ANY : where;
  }

  DoorEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    action = JSON.getEnum(DoorActionType.class, obj, ID_action);
    if (action == null)
      throw new InvalidEffectException("JSONObject for DoorEffect had no 'action' value!");
    target = JSON.getEnum(EffectTarget.class, obj, ID_target);
    if (target == null)
      throw new InvalidEffectException("JSONObject for DoorEffect had no 'target' value!");

    // Optional
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    where = where == null ? EffectLocation.ANY : where;
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setInt(ID_targetCount, targetCount);
    obj.setString(ID_action, action.name());
    obj.setString(ID_target, target.name());
    obj.setString(ID_where, where.name());

    return obj;
  }
}

// ========================== Discover Random Room ========================== //
static class DiscoverRandomRoomEffect extends Effect
{
  static final String ID_amount = "amount";

  int amount;

  DiscoverRandomRoomEffect(int amount)
  {
    super(EffectType.DISCOVERRANDOMROOM);
    this.amount = amount == INVALID_NUMBER ? 1 : amount;
  }

  DiscoverRandomRoomEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Optional
    amount = obj.getInt(ID_amount, 1);
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setInt(ID_amount, amount);

    return obj;
  }
}

// ========================== Teleport ========================= //
static class TeleportEffect extends Effect
{
  static final String ID_toTarget = "toTarget";
  static final String ID_toWhere = "toWhere";
  static final String ID_toSelect = "toSelect";

  EffectTarget toTarget;
  EffectLocation toWhere;
  EffectSelector toSelect;

  TeleportEffect(EffectTarget target, EffectLocation where, EffectSelector select, int targetCount, EffectTarget toTarget, EffectLocation toWhere, EffectSelector toSelect)
  {
    super(EffectType.TELEPORT);
    this.target = target == null ? EffectTarget.SELF : target;
    this.where = where == null ? EffectLocation.ANY : where;
    this.select = select == null ? EffectSelector.PLAYERORENTITY : select;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    this.toTarget = toTarget;
    this.toWhere = toWhere == null ? EffectLocation.ANY : toWhere;
    this.toSelect = toSelect;
  }

  TeleportEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    toTarget = JSON.getEnum(EffectTarget.class, obj, ID_toTarget);
    if (toTarget == null)
      throw new InvalidEffectException("JSONObject for TeleportEffect had no 'toTarget' value!");
    toSelect = JSON.getEnum(EffectSelector.class, obj, ID_toSelect);
    if (toSelect == null)
      throw new InvalidEffectException("JSONObject for TeleportEffect had no 'toSelect' value!");

    // Optional
    target = target == null ? EffectTarget.SELF : target;
    where = where == null ? EffectLocation.ANY : where;
    select = select == null ? EffectSelector.PLAYERORENTITY : select;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    toWhere = JSON.getEnum(EffectLocation.class, obj, ID_toWhere, EffectLocation.ANY);
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setString(ID_target, target.name());
    obj.setString(ID_where, where.name());
    obj.setString(ID_select, select.name());
    obj.setInt(ID_targetCount, targetCount);
    obj.setString(ID_toTarget, toTarget.name());
    obj.setString(ID_toWhere, toWhere.name());
    obj.setString(ID_toSelect, toSelect.name());

    return obj;
  }
}

// ========================== Move Towards ========================== //
// TODO: This class is identical to TeleportEffect, merge them maybe?
static class MoveTowardsEffect extends Effect
{
  static final String ID_toTarget = "toTarget";
  static final String ID_toWhere = "toWhere";
  static final String ID_toSelect = "toSelect";

  EffectTarget toTarget;
  EffectLocation toWhere;
  EffectSelector toSelect;

  MoveTowardsEffect(EffectTarget target, EffectLocation where, EffectSelector select, int targetCount, EffectTarget toTarget, EffectLocation toWhere, EffectSelector toSelect)
  {
    super(EffectType.MOVETOWARDS);
    this.target = target == null ? EffectTarget.SELF : target;
    this.where = where == null ? EffectLocation.ANY : where;
    this.select = select == null ? EffectSelector.PLAYERORENTITY : select;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    this.toTarget = toTarget;
    this.toWhere = toWhere == null ? EffectLocation.ANY : toWhere;
    this.toSelect = toSelect;
  }

  MoveTowardsEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    toTarget = JSON.getEnum(EffectTarget.class, obj, ID_toTarget);
    if (toTarget == null)
      throw new InvalidEffectException("JSONObject for MoveTowardsEffect had no 'toTarget' value!");
    toSelect = JSON.getEnum(EffectSelector.class, obj, ID_toSelect);
    if (toSelect == null)
      throw new InvalidEffectException("JSONObject for MoveTowardsEffect had no 'toSelect' value!");

    // Optional
    target = target == null ? EffectTarget.SELF : target;
    where = where == null ? EffectLocation.ANY : where;
    select = select == null ? EffectSelector.PLAYERORENTITY : select;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
    toWhere = JSON.getEnum(EffectLocation.class, obj, ID_toWhere, EffectLocation.ANY);
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setString(ID_target, target.name());
    obj.setString(ID_where, where.name());
    obj.setString(ID_select, select.name());
    obj.setInt(ID_targetCount, targetCount);
    obj.setString(ID_toTarget, toTarget.name());
    obj.setString(ID_toWhere, toWhere.name());
    obj.setString(ID_toSelect, toSelect.name());

    return obj;
  }
}

// ========================== Move ========================== //
static class MoveEffect extends Effect
{
  MoveEffect(int amount, EffectTarget target, EffectLocation where, EffectSelector select, int targetCount)
  {
    super(EffectType.MOVE);
    this.amount = amount;
    this.target = target == null ? EffectTarget.SELF : target;
    this.where = where == null ? EffectLocation.ANY : where;
    this.select = select == null ? EffectSelector.PLAYER : select;
    this.targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
  }

  MoveEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    if (amount == INVALID_NUMBER)
      throw new InvalidEffectException("JSONObject for MoveEffect had no 'amount' value!");

    // Optional
    target = target == null ? EffectTarget.SELF : target;
    where = where == null ? EffectLocation.ANY : where;
    select = select == null ? EffectSelector.PLAYER : select;
    targetCount = targetCount == INVALID_NUMBER ? 1 : targetCount;
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setInt(ID_amount, amount);
    obj.setString(ID_target, target.name());
    obj.setString(ID_where, where.name());
    obj.setString(ID_select, select.name());
    obj.setInt(ID_targetCount, targetCount);

    return obj;
  }
}

// ========================== Set Variable ========================== //
static class SetVariableEffect extends Effect
{
  static final String ID_variable = "variable";
  static final String ID_value = "value";

  CardVariableType variable;
  float value;

  SetVariableEffect(CardVariableType variable, float value)
  {
    super(EffectType.SETVARIABLE);
    this.variable = variable;
    this.value = value;
  }

  SetVariableEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    variable = JSON.getEnum(CardVariableType.class, obj, ID_variable);
    if (variable == null)
      throw new InvalidEffectException("JSONObject for SetVariableEffect had no 'variable' value!");
    if (!obj.hasKey(ID_value))
      throw new InvalidEffectException("JSONObject for TurnEffect had no 'value' value!");
    value = obj.getFloat(ID_value);
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setString(ID_variable, variable.name());
    obj.setFloat(ID_value, value);

    return obj;
  }
}

// ========================== Change Turn ========================== //
static class ChangeTurnEffect extends Effect
{
  static final String ID_turn = "turn";

  Turn turn;

  ChangeTurnEffect(Turn turn)
  {
    super(EffectType.CHANGETURN);
    this.turn = turn;
  }

  ChangeTurnEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);

    // Required Values
    turn = JSON.getEnum(Turn.class, obj, ID_turn);
    if (turn == null)
      throw new InvalidEffectException("JSONObject for TurnEffect had no 'turn' value!");
  }

  void apply(Context context)
  {
  }

  JSONObject toJSON()
  {
    JSONObject obj = super.toJSON();

    obj.setString(ID_turn, turn.name());

    return obj;
  }
}

// throw new InvalidEffectException("JSONObject for ____Effect had no '____' value!");
