/*

Math Functions
Author: Evan Daveikis
Written for: RayTracedGame
Written: October 2023

*/
// =====================================  Begin Previously Written Code

// Welcome to the shed of random math functions


int sign(float f) // Returns the sign of F
{
  if (f < 0) return -1;
  if (f > 0) return 1;
  return 0;
}

float lerp_float(float a, float b, float t) // Linear interpolation
{
  return (1 - t) * a + t * b;
}

PVector invert(PVector p) // Inverts a vector (I hate PVector semantics, I loooove unity Vector3s so much more now)
{
  return new PVector(0, 0, 0).sub(p);
}

PVector reflect(PVector ray, PVector normal) // Reflects a vector across a normal
{
  float dot = ray.dot(normal);
  return ray.copy().sub(normal.copy().mult(dot * 2));
}

float saturate(float value) // clamp(value, 0, 1);
{
  return constrain(value, 0f, 1f);
}

PVector flatten(PVector value) // Returns a vector with the y component set to 0
{
  return new PVector(value.x, 0, value.z);
}

float sqrMag(PVector v) // Square magnitude of a vector (cheaper than v.mag(), avoids a sqrt)
{
  return v.x * v.x + v.y * v.y + v.z * v.z;
}

float sqrDist(PVector a, PVector b) // Square distance (cheap)
{
  return sqrMag(a.copy().sub(b));
}

// =====================================  End Previously Written Code




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
