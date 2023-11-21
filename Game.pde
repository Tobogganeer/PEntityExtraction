static class Game
{
  Settings settings;

  Game()
  {
    settings = new Settings(3, 5, 4);
  }

  // TODO: Impl




  class Settings
  {
    final int maxHealth;
    final int maxAmmo;
    final int maxItems;

    Settings(int maxHealth, int maxAmmo, int maxItems)
    {
      this.maxHealth = maxHealth;
      this.maxAmmo = maxAmmo;
      this.maxItems = maxItems;
    }
  }
}
