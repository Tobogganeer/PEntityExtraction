
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


// ========================== Draw ========================== //
static class DrawEffect extends Effect
{
  static final String ID_what = "what";

  CardDrawType what;

  DrawEffect()
  {
    super(EffectType.DRAW);
  }

  DrawEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Discard ========================== //
static class DiscardEffect extends Effect
{
  DiscardEffect()
  {
    super(EffectType.DISCARD);
  }

  DiscardEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Attack ========================== //
static class AttackEffect extends Effect
{
  AttackEffect()
  {
    super(EffectType.ATTACK);
  }

  AttackEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Damage ========================== //
static class DamageEffect extends Effect
{
  DamageEffect()
  {
    super(EffectType.DAMAGE);
  }

  DamageEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Heal ========================== //
static class HealEffect extends Effect
{
  HealEffect()
  {
    super(EffectType.HEAL);
  }

  HealEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Reload ========================== //
static class ReloadEffect extends Effect
{
  ReloadEffect()
  {
    super(EffectType.RELOAD);
  }

  ReloadEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Action ========================== //
static class ActionEffect extends Effect
{
  ActionEffect()
  {
    super(EffectType.ACTION);
  }

  ActionEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Optional ========================== //
static class OptionalEffect extends Effect
{
  static final String ID_labels = "labels";
  static final String ID_options = "options";

  String[] labels;
  Effect[] options;

  OptionalEffect()
  {
    super(EffectType.OPTIONAL);
  }

  OptionalEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Multi ========================== //
static class MultiEffect extends Effect
{
  static final String ID_effects = "effects";

  Effect[] effects;

  MultiEffect()
  {
    super(EffectType.MULTI);
  }

  MultiEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Door ========================== //
static class DoorEffect extends Effect
{
  static final String ID_action = "action";

  DoorActionType action;

  DoorEffect()
  {
    super(EffectType.DOOR);
  }

  DoorEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Discover Random Room ========================== //
static class DiscoverRandomRoomEffect extends Effect
{
  DiscoverRandomRoomEffect()
  {
    super(EffectType.DISCOVERRANDOMROOM);
  }

  DiscoverRandomRoomEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Teleport ========================= //
static class TeleportEffect extends Effect
{
  static final String ID_toTarget = "toTarget";
  static final String ID_toWhere = "toWhere";
  static final String ID_toSelect = "toSelect";

  EffectTarget toTarget;
  EffectLocation toWhere;
  EffectSelector toSelect;

  TeleportEffect()
  {
    super(EffectType.TELEPORT);
  }

  TeleportEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Move Towards ========================== //
static class MoveTowardsEffect extends Effect
{
  static final String ID_toTarget = "toTarget";
  static final String ID_toWhere = "toWhere";
  static final String ID_toSelect = "toSelect";

  EffectTarget toTarget;
  EffectLocation toWhere;
  EffectSelector toSelect;

  MoveTowardsEffect()
  {
    super(EffectType.MOVETOWARDS);
  }

  MoveTowardsEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Move ========================== //
static class MoveEffect extends Effect
{
  MoveEffect()
  {
    super(EffectType.MOVE);
  }

  MoveEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Set Variable ========================== //
static class SetVariableEffect extends Effect
{
  static final String ID_variable = "variable";
  static final String ID_value = "value";

  CardVariableType variable;
  float value;

  SetVariableEffect()
  {
    super(EffectType.SETVARIABLE);
  }

  SetVariableEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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

// ========================== Change Turn ========================== //
static class ChangeTurnEffect extends Effect
{
  static final String ID_turn = "turn";

  Turn turn;

  ChangeTurnEffect()
  {
    super(EffectType.CHANGETURN);
  }

  ChangeTurnEffect(JSONObject obj) throws InvalidEffectException
  {
    super(obj);
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
