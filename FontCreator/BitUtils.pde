/*

 Bit utilities
 Author: Evan Daveikis
 Written for: SpaceInvaders
 Used/Updated in: RayTracedGame
 Written: September/October 2023
 
 */
// =====================================  Begin Previously Written Code


// All of these functions below are ripped from Space Invaders
void drawBitmap(int bitmap, int numBits, float x, float y, float boxSize)
{
  // Draw whatever bits are set in the bitmap
  // Graphical settings (fill() etc) should be set beforehand

  for (int i = 0; i < numBits; i++)
  {
    // Draw a rect if the bit is set
    if (isBitSet(bitmap, i))
    {
      // Reverse i because bitmaps are backwards
      rect(x + (numBits - i) * boxSize, y, boxSize, boxSize);
    }
  }
}

int numberOfBitsSet(int mask)
{
  int count = 0;

  for (int i = 0; i < 32; i++)
  {
    // Just count through all the bits, seeing how many are set (1)
    if (isBitSet(mask, i))
      count++;
  }

  return count;
}

// Returns true if the bit at bitIndex in mask is 1
boolean isBitSet(int mask, int bitIndex)
{
  //i.e 10011 checking if index 1 is set
  // 10011
  // 00010 <- 1 << 1
  // &
  // 00010 > 0 therefore set

  return (mask & (1 << bitIndex)) > 0; // May not work for 32nd bit?
  // Two's compliment shenanigans or smth
  // Space invaders rows are 11 anyways
}

// Returns mask with the given bit set (1)
int setBit(int mask, int bitIndexToSet)
{
  // OR with the mask of bitIndexToSet
  return mask | (1 << bitIndexToSet);
}

// Returns mask with the given bit cleared (0)
int clearBit(int mask, int bitIndexToClear)
{
  // AND with the inverse mask of bitIndexToClear
  return mask & ~(1 << bitIndexToClear);
}

// Returns mask with the given bit flipped
int toggleBit(int mask, int bitIndex)
{
  if (isBitSet(mask, bitIndex))
    return clearBit(mask, bitIndex);
  return setBit(mask, bitIndex);
}

// =====================================  End Previously Written Code
