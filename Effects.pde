static class Effect
{
  JSONObject toJSON()
  {
    // TODO: impl
    return null;
  }
  
  static Effect fromJSON(JSONObject obj)
  {
    // TODO: Parse type and choose an appropriate subclass to instantiate
    
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
