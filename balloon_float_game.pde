/**********GLOBAL VARIABLES**********/
int screenShown = 0;
// screenShown variable will control which screen is shown
// 0 = initial screen
// 1 = play screen
// 2 = game over screen
color balloonColor = color(255, 0, 0);
int balloonSizeX = 30;
int balloonSizeY = 45;
int balloonX;
int balloonY;
int wallSpeed = 3;
float acceleration = 0.9;
int wallInterval = 1250;
float timeAcceleration = 5;
float lastAddTime = 0;
int minStartLength;
int maxStartLength;
int wallHeight = 80;
int minWallGap = 70;
int maxWallGap = 100;
ArrayList <int []> walls = new ArrayList<int []>();
// stores info about the walls in the following format:
// [gapStartX, gapStartY, gapWidth, gapHeight, switch]
color wallColor = color(255);
int health = 100;
int score = 0;

/**********SETUP**********/
void setup()
{
  size(500, 800);
  balloonY = height-100;
  balloonX = width/2;
  minStartLength = 50;
  maxStartLength = width - maxWallGap;
}

/**********DRAW**********/
void draw()
{
  if (screenShown == 0)
    initialScreen();
  if (screenShown == 1)
    playScreen();
  if (screenShown == 2)
    gameoverScreen();
}

/**********SCREENS**********/
void initialScreen()
{
  background(#6FD4FA); // sky blue
  textAlign(CENTER);
  textSize(50);
  text("BALLOON FLOAT!", width/2, height/2 - 40);
  textSize(25);
  text("Click to Start", width/2, height/2 + 20);
}

void playScreen()
{
  background(0);
  drawBalloon();
  wallAdder();
  wallHandler();
  accelerate();
  drawHealth();
  printScore();
}

void gameoverScreen()
{
  background(0); 
  textAlign(CENTER);
  textSize(50);
  fill (255);
  text("GAME OVER :(", width/2, height/2 - 40);
  textSize(25);
  text("Your Score Is:" + score, width/2, height/2+10);
  text("Click to Restart", width/2, height/2 + 60);
}

/**********USER INPUT**********/
public void mousePressed()
{
  if (screenShown == 0)
    startGame();
  if (screenShown == 2)
    restartGame();
}

/**********FUNCTIONS**********/
void startGame()
{
  screenShown = 1;
}

void restartGame()
{
  screenShown = 0;
  health = 100;
  walls.clear();
  lastAddTime = 0;
  wallSpeed = 3;
  wallInterval = 1250;
  score = 0;
}

void drawBalloon()
{
  balloonX = mouseX;
  stroke(255);
  line(balloonX, balloonY, balloonX, balloonY+50);
  fill(balloonColor);
  ellipse(balloonX, balloonY, balloonSizeX, balloonSizeY);
}

void wallAdder()
{
  if (millis()-lastAddTime > wallInterval)
  {
    int randomGapStart = round(random(minStartLength, maxStartLength));
    int randomGapSize = round(random(minWallGap, maxWallGap));
    // [gapStartX, gapStartY, gapWidth, gapHeight]
    // [4] 0 = not scored, 1 = scored
    int [] randWall = {randomGapStart, -wallHeight, randomGapSize, wallHeight, 0};
    walls.add(randWall);
    lastAddTime = millis();
    if (wallInterval >= 1000)
    {
      wallInterval -= timeAcceleration;
    }
  }
}

void wallHandler()
{
  for (int i = 0; i < walls.size(); i++)
  {
    wallRemover(i);
    wallMover(i);
    wallDrawer(i);
    watchWallCollision(i);
  }
}

void wallDrawer (int index)
{
  int [] wall = walls.get(index);
  // [gapStartX, gapStartY, gapWidth, gapHeight]
  int gapStartX = wall[0];
  int gapStartY = wall[1];
  int gapWidth = wall[2];
  int gapHeight = wall[3];
  rectMode(CORNER);
  fill(wallColor);
  rect(0, gapStartY, gapStartX, gapHeight);
  rect(gapStartX + gapWidth, gapStartY, width-(gapStartX + gapWidth), gapHeight);
}

void wallMover (int index)
{
  int [] wall = walls.get(index);
  wall[1] += wallSpeed;
}

void wallRemover(int index)
{
  int [] wall = walls.get(index);
  if (wall[1] >= height)
  {
    walls.remove(index);
  }
}

void watchWallCollision (int index)
{
  int [] wall = walls.get(index);
  int gapStartX = wall[0];
  int gapStartY = wall[1];
  int gapWidth = wall[2];
  int gapHeight = wall[3];
  // left wall
  int leftWallX = 0;
  int leftWallY = gapStartY;
  int leftWallWidth = gapStartX;
  int leftWallHeight = gapHeight;
  // right wall
  int rightWallX = gapStartX + gapWidth;
  int rightWallY = gapStartY;
  int rightWallWidth = width - (gapStartX + gapWidth);
  int rightWallHeight = gapHeight;

  // left wall collision
  if (
    (balloonX-(balloonSizeX/2) < leftWallWidth) &&
    (balloonX+(balloonSizeX/2) > leftWallX) &&
    (balloonY-(balloonSizeY/2) < leftWallY+leftWallHeight) &&
    (balloonY+(balloonSizeY/2) > leftWallY)
    )
  {
      decreaseHealth();
  }

  // right wall collision
  if (
    (balloonX-(balloonSizeX/2) < width) &&
    (balloonX+(balloonSizeX/2) > rightWallX) &&
    (balloonY-(balloonSizeY/2) < rightWallY+rightWallHeight) &&
    (balloonY+(balloonSizeY/2) > rightWallY)
    )
  {
      decreaseHealth();
  }
  
  // score
  if (balloonY < gapStartY && wall[4] == 0)
  {
    wall[4] = 1;
    scored();
  }
}

void accelerate()
{
  if (wallSpeed <= 15)
    wallSpeed += acceleration;
}

void drawHealth()
{
  stroke(0);
  fill (100);
  rect (0, 0, width, 10);

  if (health > 80)
    fill (#00FF01);
  else if (health > 30)
    fill (#FEFF00);
  else 
  fill (#FF0D00);

  rect (0, 0, (width/100)*health, 10);
} 

void decreaseHealth()
{
  health-=1;
  if (health == 0)
    screenShown = 2;
}

void scored()
{
  score++;
}

void printScore()
{
  textAlign(CENTER);
  fill(#6FD4FA);
  textSize(30);
  text(score, width/2, 45);
}
