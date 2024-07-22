float alpha = 0.1;  // Learning rate
float gamma = 0.9;  // Discount factor
int numActions = 8; // Number of possible actions (directions)
float[] qValues;    // Q-values for each action
Creature medusa;

void setup() {
  fullScreen();
  qValues = new float[numActions];
  medusa = new Creature(new PVector(width / 4, height / 2), 50, 50, 8, 100, 20, 5);
}

void draw() {
  background(0);
  medusa.update(mouseX, mouseY);
  medusa.draw();
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
}

class Creature {
  PVector position;
  float radX, radY;
  float orientation;
  color headClr;
  ArrayList<Tentacle> tentacles;
  int nbTentacles;
  int tentaclesLength;
  int currentAction;

  Creature(PVector pos, float rx, float ry, int nb, int l, float ts, float td) {
    position = pos;
    radX = rx;
    radY = ry;
    orientation = 0;
    nbTentacles = nb;
    tentaclesLength = l;
    tentacles = new ArrayList<Tentacle>();
    headClr = color(random(100, 255), random(100, 255), random(100, 255));

    for (int i = 0; i < nbTentacles; i++) {
      float tx = position.x + (cos(i * TWO_PI / nbTentacles) * radX / 2);
      float ty = position.y + (sin(i * TWO_PI / nbTentacles) * radY / 2);
      float tr = atan2(ty - position.y, tx - position.x);
      Tentacle tentacle = new Tentacle(new PVector(tx, ty), tentaclesLength, ts, ts, tr, td);
      tentacles.add(tentacle);
    }

    currentAction = 0;
  }

  void update(float targetX, float targetY) {
    // SARSA method
    int nextAction = chooseAction();
    float reward = calculateReward(targetX, targetY);
    updateQValues(currentAction, reward, nextAction);
    performAction(nextAction);
    currentAction = nextAction;

    for (int i = 0; i < nbTentacles; i++) {
      Tentacle t = tentacles.get(i);
      t.position.x = position.x + (cos((i * TWO_PI / nbTentacles) + orientation) * radX / 2);
      t.position.y = position.y + (sin((i * TWO_PI / nbTentacles) + orientation) * radY / 2);
      t.orientation = atan2((t.position.y - position.y), (t.position.x - position.x));
      t.update();
    }

    orientation += random(-3, 3) * radians(.1);
  }

  void draw() {
    fill(headClr);
    ellipse(position.x, position.y, radX * 2, radY * 2);
    for (int i = 0; i < nbTentacles; i++) {
      tentacles.get(i).draw();
    }
  }

  int chooseAction() {
    // Epsilon-greedy action selection
    float epsilon = 0.1;
    if (random(1) < epsilon) {
      return int(random(numActions));  // Random action
    } else {
      return findBestAction();  // Best action based on Q-values
    }
  }

  int findBestAction() {
    int bestAction = 0;
    float bestValue = qValues[0];
    for (int i = 1; i < numActions; i++) {
      if (qValues[i] > bestValue) {
        bestValue = qValues[i];
        bestAction = i;
      }
    }
    return bestAction;
  }

  void updateQValues(int action, float reward, int nextAction) {
    float qValue = qValues[action];
    float nextQValue = qValues[nextAction];
    qValues[action] = qValue + alpha * (reward + gamma * nextQValue - qValue);
  }

  float calculateReward(float targetX, float targetY) {
    float distance = dist(position.x, position.y, targetX, targetY);
    return -distance;  // Negative reward for distance
  }

  void performAction(int action) {
    float angle = action * TWO_PI / numActions;
    position.x += cos(angle) * 2;
    position.y += sin(angle) * 2;
  }
}
