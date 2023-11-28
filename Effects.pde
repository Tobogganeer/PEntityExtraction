static class Effect
{
  Effect()
  {
  }

  JSONObject toJSON()
  {
    // TODO: impl
    return null;
  }

  // Returns the correct subclass
  static Effect fromJSON(JSONObject obj)
  {
    if (obj == null)
    {
      println("Tried to parse an effect from a null JSONObject.");
      return null;
    }

    /*
    if (!obj.hasKey(ID_type))
     throw new InvalidCardException("Tried to parse a card with no type.");
     
     CardType jsonType = JSON.getEnum(CardType.class, obj.getString(ID_type));
     if (jsonType == null)
     throw new InvalidCardException("Tried to parse a card with an invalid type.");
     
     */
    return null;
  }

  static Effect[] fromJSONArray(JSONArray jsonEffects) throws InvalidCardException
  {
    Effect[] effects = new Effect[jsonEffects.size()];
    for (int i = 0; i < effects.length; i++)
      effects[i] = Effect.fromJSON(jsonEffects.getJSONObject(i));
    return effects;
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
