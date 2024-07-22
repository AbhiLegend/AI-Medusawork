ArrayList<Medusa> medusas;
ArrayList<PVector> path;
boolean flocking = false;

void setup() {
  size(1900, 1300);
  medusas = new ArrayList<Medusa>();
  medusas.add(new Medusa(new PVector(width / 4, height / 2), 13, 13, 8, 50, 10, 3));
  path = new ArrayList<PVector>();
}

void draw() {
  background(0);

  if (!medusas.isEmpty()) {
    Medusa leader = medusas.get(0);
    leader.update();
    path.add(leader.position.copy());
    leader.draw();
  }

  for (int i = 1; i < medusas.size(); i++) {
    Medusa medusa = medusas.get(i);
    if (flocking) {
      medusa.flock(medusas);
    } else {
      medusa.followPath(path);
    }
    medusa.update();
    medusa.draw();
  }

  drawPath();
  handleCollisions();
}

void keyPressed() {
  // Move the Medusa based on arrow key presses
  Medusa medusa = medusas.get(0); // Assuming the first Medusa is the leader
  switch (keyCode) {
    case UP: medusa.position.y -= 5; break;
    case DOWN: medusa.position.y += 5; break;
    case LEFT: medusa.position.x -= 5; break;
    case RIGHT: medusa.position.x += 5; break;
    case 'c': path.clear(); break; // Clear the path when 'c' is pressed
  }

  // Add a new Medusa when 'p' key is pressed
  if (key == 'p') {
    Medusa newMedusa = new Medusa(new PVector(random(width), random(height)), 13, 13, 8, 50, 10, 3);
    newMedusa.following = true;
    medusas.add(newMedusa);
  }

  // Change leader color when 'l' key is pressed
  if (key == 'l') {
    medusa.headClr = color(random(100, 255), random(100, 255), random(100, 255));
  }

  // Change the color of the lead Medusa to green when 'd' key is pressed
  if (key == 'd') {
    println("Changing color of lead Medusa to green");
    medusa.headClr = color(0, 255, 0);
  }

  // Enable or disable flocking behavior when 'f' key is pressed
  if (key == 'f') {
    flocking = !flocking;
    println("Flocking " + (flocking ? "enabled" : "disabled"));
  }
}

void mouseMoved() {
  // Move the Medusa based on mouse movements
  if (!medusas.isEmpty()) {
    Medusa medusa = medusas.get(0);
    medusa.position.x = mouseX;
    medusa.position.y = mouseY;
  }
}

void drawPath() {
  fill(255, 165, 0); // Orange color for the triangles
  noStroke();
  for (PVector pos : path) {
    drawTriangle(pos.x, pos.y, 5);
  }
}

void drawTriangle(float x, float y, float size) {
  beginShape();
  vertex(x, y - size);
  vertex(x - size, y + size);
  vertex(x + size, y + size);
  endShape(CLOSE);
}

void handleCollisions() {
  for (int i = 0; i < medusas.size(); i++) {
    for (int j = i + 1; j < medusas.size(); j++) {
      Medusa m1 = medusas.get(i);
      Medusa m2 = medusas.get(j);
      if (dist(m1.position.x, m1.position.y, m2.position.x, m2.position.y) < 30) {
        m1.headClr = color(255, 0, 0);
        m2.headClr = color(255, 0, 0);
      }
    }
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
      part.position = position.copy();
      part.position.x += compactness * i * cos(orientation);
      part.position.y += compactness * i * sin(orientation);
      part.clr = color(random(100, 255), random(100, 255), random(100, 255));
      parts.add(part);
    }
  }

  void update() {
    PVector pos0 = parts.get(0).position;
    PVector pos1 = parts.get(1).position;
    pos0.set(position);
    pos1.x = pos0.x + (compactness * cos(orientation));
    pos1.y = pos0.y + (compactness * sin(orientation));
    for (int i = 2; i < nbParts; i++) {
      PVector currentPos = parts.get(i).position.copy();
      PVector dist = PVector.sub(currentPos, parts.get(i - 2).position.copy());
      float distmag = dist.mag();
      PVector pos = parts.get(i - 1).position.copy();
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

class Medusa {
  PVector position;
  float radX, radY;
  float orientation;
  color headClr;
  color originalClr;
  ArrayList<Tentacle> tentacles;
  int nbTentacles;
  int tentaclesLength;
  boolean following;
  PVector velocity;
  PVector acceleration;
  float maxSpeed;
  float maxForce;

  Medusa(PVector pos, float rx, float ry, int nb, int l, float ts, float td) {
    position = pos;
    radX = rx;
    radY = ry;
    orientation = 0;
    nbTentacles = nb;
    tentaclesLength = l;
    headClr = color(random(100, 255), random(100, 255), random(100, 255));
    originalClr = headClr;
    following = false;

    velocity = PVector.random2D();
    acceleration = new PVector();
    maxSpeed = 2;
    maxForce = 0.1;

    tentacles = new ArrayList<Tentacle>();
    for (int i = 0; i < nbTentacles; i++) {
      float tx = position.x + (cos(i * TWO_PI / nbTentacles) * radX / 2);
      float ty = position.y + (sin(i * TWO_PI / nbTentacles) * radY / 2);
      float tr = atan2(ty - position.y, tx - position.x);
      Tentacle tentacle = new Tentacle(new PVector(tx, ty), tentaclesLength, ts, ts, tr, td);
      tentacles.add(tentacle);
    }
  }

  void update() {
    if (!following) {
      position.add(velocity);
      velocity.add(acceleration);
      velocity.limit(maxSpeed);
      acceleration.mult(0); // Reset acceleration to 0 each cycle
    }

    for (int i = 0; i < nbTentacles; i++) {
      Tentacle t = tentacles.get(i);
      t.position.x = position.x + (cos((i * TWO_PI / nbTentacles) + orientation) * radX / 2);
      t.position.y = position.y + (sin((i * TWO_PI / nbTentacles) + orientation) * radY / 2);
      t.orientation = atan2((t.position.y - position.y), (t.position.x - position.x));
      t.update();
    }

    orientation += random(-3, 3) * radians(.1);
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void flock(ArrayList<Medusa> medusas) {
    PVector sep = separate(medusas);
    PVector ali = align(medusas);
    PVector coh = cohesion(medusas);

    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  PVector separate(ArrayList<Medusa> medusas) {
    float desiredSeparation = 25.0;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;

    for (Medusa other : medusas) {
      if (other == this) continue;
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < desiredSeparation)) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        count++;
      }
    }

    if (count > 0) {
      steer.div((float) count);
    }

    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    return steer;
  }

  PVector align(ArrayList<Medusa> medusas) {
    float neighborDist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Medusa other : medusas) {
      if (other == this) continue;
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighborDist)) {
        sum.add(other.velocity);
        count++;
      }
    }

    if (count > 0) {
      sum.div((float) count);
      sum.normalize();
      sum.mult(maxSpeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  PVector cohesion(ArrayList<Medusa> medusas) {
    float neighborDist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Medusa other : medusas) {
      if (other == this) continue;
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighborDist)) {
        sum.add(other.position);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    } else {
      return new PVector(0, 0);
    }
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.normalize();
    desired.mult(maxSpeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    return steer;
  }

  void followPath(ArrayList<PVector> path) {
    if (path.size() > 0) {
      PVector target = path.get(0);
      if (path.size() > 1) {
        float closestDist = dist(position.x, position.y, target.x, target.y);
        int closestIndex = 0;
        for (int i = 1; i < path.size(); i++) {
          float d = dist(position.x, position.y, path.get(i).x, path.get(i).y);
          if (d < closestDist) {
            closestDist = d;
            closestIndex = i;
          }
        }
        target = path.get(closestIndex);
      }

      PVector desired = PVector.sub(target, position);
      desired.normalize();
      desired.mult(2);
      position.add(desired);
    }

    if (dist(mouseX, mouseY, position.x, position.y) < 50) {
      PVector evade = PVector.sub(position, new PVector(mouseX, mouseY));
      evade.normalize();
      evade.mult(5);
      position.add(evade);
    }
  }

  void draw() {
    fill(headClr);
    ellipse(position.x, position.y, radX * 2, radY * 2);

    for (int i = 0; i < nbTentacles; i++) {
      tentacles.get(i).draw();
    }
  }
}
