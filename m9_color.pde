Creature medusa;
color[] colors;
int currentColorIndex = 0;

void setup() {
  fullScreen();
  medusa = new Creature(new PVector(width / 2, height / 2), 30, 30, 8, 80, 15, 5); // Medusa
  colors = new color[] {
    color(255, 0, 0), // Red
    color(0, 255, 0), // Green
    color(0, 0, 255), // Blue
    color(135, 206, 250), // Skyblue
    color(128, 128, 128), // Grey
    color(204, 255, 0), // Fluorescent Green
    color(255, 192, 203), // Pink
    color(255, 165, 0), // Orange
    color(148, 0, 211), // Purple
  };
  medusa.setColor(colors[currentColorIndex]);
}

void draw() {
  background(0);
  PVector target = new PVector(mouseX, mouseY);
  medusa.update(target.x, target.y); // Normal movement towards the mouse
  medusa.draw();
}

void keyPressed() {
  if (key == 'h' || key == 'H') {
    currentColorIndex = (currentColorIndex + 1) % colors.length;
    medusa.setColor(colors[currentColorIndex]);
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

  void setColor(color clr) {
    for (TentaclePart part : parts) {
      part.clr = clr;
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

  void setColor(color clr) {
    headClr = clr;
    for (Tentacle t : tentacles) {
      t.setColor(clr);
    }
  }
}
