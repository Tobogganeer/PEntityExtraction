// Stores the IDs all of data in the game
static class IDs
{
  static class Tag
  {
    static final String NoDiscard = "nodiscard";
    static final String StartDiscovered = "startdiscovered";
    static final String EntityItem = "entityitem";
    static final String Small = "small";
    static final String Medium = "medium";
    static final String Large = "large";
    static final String BlocksMovement = "blocksmovement";
  }

  // AIRLOCK, HALL, COMPLEXHALL, ROOM, CONSUMABLE, EFFECT, ENTITY, ENTITYITEM, WEAPON;
  static class Tile
  {
    static class Airlock
    {
      static final String Airlock1 = "tile.airlock.airlock1";
      static final String Airlock2 = "tile.airlock.airlock2";
    }

    static class Hall
    {
      static final String _3Hall = "tile.hall.3hall";
      static final String _4Hall = "tile.hall.4hall";
      static final String Lockable3Hall = "tile.hall.lockable3hall";
      static final String Corner2Hall = "tile.hall.corner2hall";
      static final String Straight2Hall = "tile.hall.straight2hall";
    }

    static class ComplexHall
    {
      static final String Bunks = "tile.complexhall.bunks";
      static final String Lockers = "tile.complexhall.lockers";
    }

    static class Room
    {
      static final String StorageRoom = "tile.room.storageroom";
      static final String Medbay = "tile.room.medbay";
      static final String Gate = "tile.room.gate";
      static final String Breach = "tile.room.breach";
      static final String Cafeteria = "tile.room.cafeteria";
    }
  }

  static class Entity
  {
    static class Item
    {
      static final String OddMachine = "entity.item.oddmachine";
    }

    static final String Lank = "entity.lank";
    static final String Host = "entity.host";
  }

  static class Item
  {
    static class Consumable
    {
      static final String Medkit = "item.consumable.medkit";
      static final String Bandage = "item.consumable.bandage";
    }

    static class Effect
    {
      static final String MartialArts = "item.effect.martialarts";
    }

    static class Weapon
    {
      static class Small
      {
        static final String Pistol = "item.weapon.small.pistol";
      }

      static class Medium
      {
      }

      static class Large
      {
      }
    }
  }
}
