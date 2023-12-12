static class Particle
{
  static ArrayList<Particle> all = new ArrayList<Particle>();

  static final float defaultGravity = Applet.height * 3; // Downward is the default accel

  PVector position, velocity, acceleration;
  float angle, angularVelocity;
  float scale, scaleVelocity; // ? idk what to call it
  float lifetime;
  float maximumDuration;

  Particle(PVector position)
  {
    this(position, new PVector(), new PVector(0, defaultGravity), 0, 0);
  }

  Particle(PVector position, PVector velocity)
  {
    this(position, velocity, new PVector(0, defaultGravity), 0, 0);
  }

  Particle(PVector position, PVector velocity, float angle)
  {
    this(position, velocity, new PVector(0, defaultGravity), angle, 0);
  }

  Particle(PVector position, PVector velocity, float angle, float angularVelocity)
  {
    this(position, velocity, new PVector(0, defaultGravity), angle, angularVelocity);
  }

  Particle(PVector position, PVector velocity, PVector acceleration)
  {
    this(position, velocity, acceleration, 0, 0);
  }

  Particle(PVector position, PVector velocity, PVector acceleration, float angle, float angularVelocity)
  {
    this(position, velocity, acceleration, angle, angularVelocity, 1, 0);
  }

  Particle(PVector position, PVector velocity, PVector acceleration, float angle, float angularVelocity, float scale, float scaleVelocity)
  {
    this.position = position.copy();
    this.velocity = velocity.copy();
    this.acceleration = acceleration.copy();
    this.angle = angle;
    this.angularVelocity = angularVelocity;
    this.scale = scale;
    this.scaleVelocity = scaleVelocity;
    lifetime = 0;
    maximumDuration = 10; // Live for 10 seconds - change after the constructor if you want longer

    all.add(this);
  }

  // Bit of a misnomer - updates & draws all particles
  static void updateAll()
  {
    for (Particle p : all)
    {
      if (p != null)
      {
        p.update(Time.deltaTime);
        p.draw();
      }
    }

    all.removeIf((p) -> p == null || p.lifetime > p.maximumDuration || p.scale < 0);
  }

  void update(float dt)
  {
    // I recall some video explaining how acceleration changes and stuff
    // should be applied in half increments to be physically correct
    // (not that it matters at all here lol)
    velocity.add(acceleration.copy().mult(dt * 0.5)); // Add half dt
    position.add(velocity.copy().mult(dt));
    velocity.add(acceleration.copy().mult(dt * 0.5)); // Add other half dt

    angle += angularVelocity * dt;
    scale += scaleVelocity * dt;

    lifetime += dt;
  }

  // Overriden in subclasses
  void draw() {
  }
}

static class CardParticle extends Particle
{
  static final float randomVelocityMult = 400;
  static final float upwardsMult = 2;

  Card card;

  CardParticle(Card card)
  {
    super(card.position, PVector.random2D().add(0, -upwardsMult).mult(randomVelocityMult), card.angle, Applet.get().random(-360, 360));
    this.scale = card.scale;
    this.scaleVelocity = -0.4;
    this.card = card;
  }

  void draw()
  {
    card.draw();
  }
  
  void update(float dt)
  {
    super.update(dt);
    card.position = position;
    card.angle = angle;
    card.scale = scale;
  }
}
