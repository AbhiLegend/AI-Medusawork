Creature medusa;
int behavior = 0; // 0: Normal, 1: Evade, 2: Wander

void setup() {
  fullScreen();
  medusa = new Creature(new PVector(width / 2, height / 2), 30, 30, 8, 80, 15, 5); // Medusa
}

void draw() {
  background(0);

  if (behavior == 0) {
    PVector target = new PVector(mouseX, mouseY);
    medusa.update(target.x, target.y); // Normal movement towards the mouse
  } else if (behavior == 1) {
    PVector target = new PVector(mouseX, mouseY);
    medusa.evade(target.x, target.y); // Evasion behavior
  } else if (behavior == 2) {
    medusa.wander(); // Random wandering behavior
  }

  medusa.draw();
}

void keyPressed() {
  if (key == 'b' || key == 'B') {
    medusa.setBlueMode(!medusa.blueMode);
  } else if (key == 'k' || key == 'K') {
    behavior = (behavior + 1) % 3; // Cycle through behaviors
  } else if (key == 'q' || key == 'Q') {
    exit(); // Quit the application
  }
}

class TentaclePart {
  PVector position;
  float width;
  float height;
  color clr;
}

class Tentacle {
  PVector position;
  float orientation;
  int nbParts;
  float compactness;
  ArrayList<TentaclePart> parts;

  Tentacle(PVector pos, int nb, float w, float h, float o, float c) {
    position = pos;
    nbParts = nb;
    float headWidth = w;
    float headHeight = h;
    compactness = c;
    orientation = o;
    parts = new ArrayList<TentaclePart>();
    float coul = 255.0 / nbParts;
    for (int i = 0; i < nbParts; i++) {
      TentaclePart part = new TentaclePart();
      part.width = (nbParts - i) * headWidth / (float) nbParts;
      part.height = (nbParts - i) * headHeight / (float) nbParts;
      part.position = position.get();
      part.position.x += compactness * i * cos(orientation);
      part.position.y += compactness * i * sin(orientation);
      part.clr = color(random(100, 255), random(100, 255), random(100, 255));
      parts.add(part);
    }
  }

  void update() {
    PVector pos0 = parts.get(0).position;
    PVector pos1 = parts.get(1).position;
    pos0.set(position.get());
    pos1.x = pos0.x + (compactness * cos(orientation));
    pos1.y = pos0.y + (compactness * sin(orientation));
    for (int i = 2; i < nbParts; i++) {
      PVector currentPos = parts.get(i).position.get();
      PVector dist = PVector.sub(currentPos, parts.get(i - 2).position.get());
      float distmag = dist.mag();
      PVector pos = parts.get(i - 1).position.get();
      PVector move = PVector.mult(dist, compactness);
      move.div(distmag);
      pos.add(move);
      parts.get(i).position.set(pos);
    }
  }

  void draw() {
    for (int i = nbParts - 1; i >= 0; i--) {
      TentaclePart part = parts.get(i);
      noStroke();
      fill(part.clr);
      ellipse(part.position.x, part.position.y, part.width, part.height);
    }
  }

  void setBlueMode(boolean blueMode) {
    for (TentaclePart part : parts) {
      if (blueMode) {
        part.clr = color(0, 0, 255);
      } else {
        part.clr = color(random(100, 255), random(100, 255), random(100, 255));
      }
    }
  }
}

class Creature {
  PVector position;
  PVector velocity;
  float radX, radY;
  float orientation;
  color headClr;
  ArrayList<Tentacle> tentacles;
  int nbTentacles;
  int tentaclesLength;
  boolean blueMode = false;

  Creature(PVector pos, float rx, float ry, int nb, int l, float ts, float td) {
    position = pos;
    velocity = new PVector(random(-1, 1), random(-1, 1));
    radX = rx;
    radY = ry;
    orientation = 0;
    nbTentacles = nb;
    tentaclesLength = l;
    tentacles = new ArrayList<Tentacle>();
    headClr = color(random(50, 200), random(50, 200), random(50, 200));

    for (int i = 0; i < nbTentacles; i++) {
      float tx = position.x + (cos(i * TWO_PI / nbTentacles) * radX / 2);
      float ty = position.y + (sin(i * TWO_PI / nbTentacles) * radY / 2);
      float tr = atan2(ty - position.y, tx - position.x);
      Tentacle tentacle = new Tentacle(new PVector(tx, ty), tentaclesLength, ts, ts, tr, td);
      tentacles.add(tentacle);
    }
  }

  void update(float targetX, float targetY) {
    position.x += (targetX - position.x) * 0.05;
    position.y += (targetY - position.y) * 0.05;

    headClr = blueMode ? color(0, 0, 255) : color(random(50, 200), random(50, 200), random(50, 200));
    for (int i = 0; i < nbTentacles; i++) {
      Tentacle t = tentacles.get(i);
      t.position.x = position.x + (cos((i * TWO_PI / nbTentacles) + orientation) * radX / 2);
      t.position.y = position.y + (sin((i * TWO_PI / nbTentacles) + orientation) * radY / 2);
      t.orientation = atan2((t.position.y - position.y), (t.position.x - position.x));
      t.update();
    }

    orientation += random(-3, 3) * radians(.1);
    checkBorders();
  }

  void evade(float targetX, float targetY) {
    float distance = dist(position.x, position.y, targetX, targetY);
    if (distance < 100) {
      // Move away from the target
      float angleAway = atan2(position.y - targetY, position.x - targetX);
      position.x += cos(angleAway) * 3;
      position.y += sin(angleAway) * 3;
    } else {
      // Random movement if far away
      position.x += random(-2, 2);
      position.y += random(-2, 2);
    }

    headClr = blueMode ? color(0, 0, 255) : color(random(50, 200), random(50, 200), random(50, 200));
    for (int i = 0; i < nbTentacles; i++) {
      Tentacle t = tentacles.get(i);
      t.position.x = position.x + (cos((i * TWO_PI / nbTentacles) + orientation) * radX / 2);
      t.position.y = position.y + (sin((i * TWO_PI / nbTentacles) + orientation) * radY / 2);
      t.orientation = atan2((t.position.y - position.y), (t.position.x - position.x));
      t.update();
    }

    orientation += random(-3, 3) * radians(.1);
    checkBorders();
  }

  void wander() {
    position.x += random(-2, 2);
    position.y += random(-2, 2);

    headClr = blueMode ? color(0, 0, 255) : color(random(50, 200), random(50, 200), random(50, 200));
    for (int i = 0; i < nbTentacles; i++) {
      Tentacle t = tentacles.get(i);
      t.position.x = position.x + (cos((i * TWO_PI / nbTentacles) + orientation) * radX / 2);
      t.position.y = position.y + (sin((i * TWO_PI / nbTentacles) + orientation) * radY / 2);
      t.orientation = atan2((t.position.y - position.y), (t.position.x - position.x));
      t.update();
    }

    orientation += random(-3, 3) * radians(.1);
    checkBorders();
  }

  void checkBorders() {
    if (position.x < radX) position.x = radX;
    if (position.x > width - radX) position.x = width - radX;
    if (position.y < radY) position.y = radY;
    if (position.y > height - radY) position.y = height - radY;
  }

  void draw() {
    fill(headClr);
    ellipse(position.x, position.y, radX * 2, radY * 2);
    for (int i = 0; i < nbTentacles; i++) {
      tentacles.get(i).draw();
    }
  }

  void setBlueMode(boolean blueMode) {
    this.blueMode = blueMode;
    for (Tentacle t : tentacles) {
      t.setBlueMode(blueMode);
    }
  }
}
