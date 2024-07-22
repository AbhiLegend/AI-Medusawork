Creature medusa;

void setup() {
  size(1900, 800);
  medusa = new Creature(new PVector(width / 4, height / 2), 13, 13, 8, 50, 10, 3);
}

void draw() {
  background(0);
  medusa.update(mouseX, mouseY);
}

void mousePressed() {
  // No action needed for mousePressed, since we only have one medusa
}

static class Penner {
  static float easeInOutExpo(float t, float b, float c, float d) {
    if (t == 0) return b;
    if (t == d) return b + c;
    if ((t /= d / 2) < 1) return c / 2 * pow(2, 10 * (t - 1)) + b;
    return c / 2 * (-pow(2, -10 * --t) + 2) + b;
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
      part.clr = color(120, 153, 255 - coul * i);
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
}

class Creature {
  PVector position;
  float radX, radY;
  float orientation;
  color headClr;
  ArrayList<Tentacle> tentacles;
  int nbTentacles;
  int tentaclesLength;

  Creature(PVector pos, float rx, float ry, int nb, int l, float ts, float td) {
    position = pos;
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

    for (int i = 0; i < nbTentacles; i++) {
      Tentacle t = tentacles.get(i);
      t.position.x = position.x + (cos((i * TWO_PI / nbTentacles) + orientation) * radX / 2);
      t.position.y = position.y + (sin((i * TWO_PI / nbTentacles) + orientation) * radY / 2);
      t.orientation = atan2((t.position.y - position.y), (t.position.x - position.x));
      t.update();
    }

    orientation += random(-3, 3) * radians(.1);

    fill(200);
    for (int i = 0; i < nbTentacles; i++) {
      tentacles.get(i).draw();
    }
  }
}
