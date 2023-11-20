
/*

 Time
 Author: Evan Daveikis
 Written for: RayTracedGame
 Written: October 2023
 Modified: November 14, 2023
 
 */
// =====================================  Begin Previously Written Code

static class Time
{
  static float deltaTime; // Unity convention ig, also not a raytracer anymore, don't need clamping lol
  //float dt; // Delta time (clamped, for gameplay)
  //float dt_actual; // Delta time (raw, for fps display)
  private static int lastMS; // The millisecond of the last frame

  //float CONST_MAX_DT = 0.1; // 100 ms

  static void update()
  {
    int mil = GlobalPApplet.get().millis();
    //dt_actual = (mil - lastMS) / 1000f;
    deltaTime = (mil - lastMS) / 1000f;
    lastMS = mil;
    //dt = min(dt_actual, CONST_MAX_DT);
  }
}

// =====================================  End Previously Written Code
