//Difficulty Settings
int blocksWide = 30; //Width in blocks
int blocksTall = 30; //Height in blocks
float difficulty = .625; //Bomb spawning probability (sort of)

//Appearance Settings
int pixPerBlock = 20; //Block size in pixels

//Game Variables
int[][] blocks = new int[blocksTall][blocksWide];
int[][] nums = new int[blocksTall][blocksWide];
color[] state = new color[5]; //Block States
boolean gameOver = false;
int bombs = 0;
int found = 0;

IntList clearX = new IntList();
IntList clearY = new IntList();

void setup() {  
  //Setup block arrays
  for (int i=0; i<blocksTall; i++) {
    for (int j=0; j<blocksWide; j++) {
      blocks[i][j] = 0;
    }
  }

  //Block colors
  state[0] = #A0A0A0; //Safe, unclicked
  state[1] = #A0A0A0; //Bomb, unclicked
  state[2] = #FF5050; //Safe, flagged
  state[3] = #FF5050; //Bomb, flagged
  state[4] = #80FF80; //Cleared

  //Place bombs (somewhat random, could be done much better)
  for (int i=0; i<blocksTall; i++) {
    for (int j=0; j<blocksWide; j++) {
      if (random(0, difficulty) > 0.5) {
        blocks[i][j] = 1;
        bombs++;
      }
    }
  }

  //Get numbers for blocks to show when cleared
  for (int i=0; i<blocksTall; i++) {
    for (int j=0; j<blocksWide; j++) {
      nums[i][j] = 0;
      //Top
      if (i>0 && blocks[i-1][j] == 1) {
        nums[i][j]++;
      }
      //Bottom
      if (i<blocksTall-1 && blocks[i+1][j] == 1) {
        nums[i][j]++;
      }
      //Left
      if (j>0 && blocks[i][j-1] == 1) {
        nums[i][j]++;
      }
      //Right
      if (j<blocksWide-1 && blocks[i][j+1] == 1) {
        nums[i][j]++;
      }
      //Top right
      if (i>0 && j<blocksWide-1 && blocks[i-1][j+1] == 1) {
        nums[i][j]++;
      }
      //Top Left
      if (j>0 && i>0 && blocks[i-1][j-1] == 1) {
        nums[i][j]++;
      }
      //Bottom Left
      if (j>0 && i<blocksTall-1 && blocks[i+1][j-1] == 1) {
        nums[i][j]++;
      }
      //Bottom Right
      if (i<blocksTall-1 && j<blocksWide-1 && blocks[i+1][j+1] == 1) {
        nums[i][j]++;
      }
      //println(nums[i][j]);
    }
  }

  //Window Setup
  println("Done");
  size(pixPerBlock * blocksWide, pixPerBlock * blocksTall);
  background(state[0]);
  drawGrid();
}

//On each mouse click
void mouseClicked() {
  //Determine block clicked
  int x = floor(mouseX / pixPerBlock);
  int y = floor(mouseY / pixPerBlock);

  //Do correct action for block being pressed
  if (mouseButton == LEFT) { //Normal click
    if (blocks[y][x] == 0 || blocks[y][x] == 2) { //Safe, unclicked or safe, flagged
      blocks[y][x] = 4; //Cleared

      //Add to auto clear if 0
      if (nums[y][x] == 0) {
        clearX.append(x);
        clearY.append(y);
        autoclear(); //initiate auto clear
      }
    }
    if (blocks[y][x] == 1 || blocks[y][x] == 3) { //Bomb, unclicked or bomb, flagged
      gameOver = true;
    }
  } else if (mouseButton == RIGHT) { //Click to flag
    if (blocks[y][x] == 0) { //Safe
      blocks[y][x] = 2;
    } else if (blocks[y][x] == 2) { //Safe
      blocks[y][x] = 0;
    } else if (blocks[y][x] == 1) { //Mine
      blocks[y][x] = 3;
    } else if (blocks[y][x] == 3) { //Mine
      blocks[y][x] = 1;
    }
  }
  //println(x + ", " + y);
  
  //Check if game is won
  found = 0;
  for (int i=0; i<blocksTall; i++) {
    for (int j=0; j<blocksWide; j++) {
      if (blocks[i][j] == 4) {
        found++;
      }
    }
  }
  
  if (gameOver) {
    gameOverScreen();
  } else if (found == (blocksWide * blocksTall) - bombs) {
    gameWinScreen();
  } else {
    drawGrid();
  }

  //println(clearY.size());
}

//Game over screen
void gameOverScreen() {
  println("Game Over");

  //Impose bombs as circles on existing grid
  drawGrid();
  fill(#000000);
  for (int i=0; i<blocksTall; i++) {
    for (int j=0; j<blocksWide; j++) {
      if (blocks[i][j] == 1 || blocks[i][j] == 3) {
        ellipse(j*pixPerBlock + pixPerBlock/2, i*pixPerBlock + pixPerBlock/2, pixPerBlock/2, pixPerBlock/2);
      }
    }
  }

  //"Game Over" text
  fill(#FF0000);
  textAlign(CENTER, CENTER);
  textSize(pixPerBlock * 2);
  text("Game Over", width/2, height/2);
}

void gameWinScreen() {
  fill(#00FF00);
  //rect(0, 0, width, height);
  fill(#FFFFFF);
  textAlign(CENTER, CENTER);
  textSize(pixPerBlock * 2);
  text("You Win", width/2, height/2);
}

//Draw blocks with corresponding color and number if applicable
void drawGrid() {
  for (int i=0; i<blocksTall; i++) {
    for (int j=0; j<blocksWide; j++) {
      fill(state[blocks[i][j]]);
      rect(j*pixPerBlock, i*pixPerBlock, pixPerBlock, pixPerBlock);
      if (blocks[i][j] == 4 && nums[i][j] != 0) {
        fill(#000000);
        textAlign(CENTER, CENTER);
        text(nums[i][j], j*pixPerBlock + pixPerBlock/2, i*pixPerBlock + pixPerBlock/2);
      }
      //println(state[blocks[i][j]]);
      //println(nums[i][j]);
    }
  }
}

//Automatically clear out blocks that are around clear blocks
void autoclear() {
  while (clearY.size () != 0) {
    //print("loop");

    //Scan surrounding blocks and add to clear list
    int i = clearY.get(0);
    int j = clearX.get(0);

    //Top
    if (i>0 && nums[i-1][j] == 0 && blocks[i-1][j] != 4) {
      clearY.append(i-1);
      clearX.append(j);
    }
    //Bottom
    if (i<blocksTall-1 && nums[i+1][j] == 0 && blocks[i+1][j] != 4) {
      clearY.append(i+1);
      clearX.append(j);
    }
    //Left
    if (j>0 && nums[i][j-1] == 0 && blocks[i][j-1] != 4) {
      clearY.append(i);
      clearX.append(j-1);
    }
    //Right
    if (j<blocksWide-1 && nums[i][j+1] == 0 && blocks[i][j+1] != 4) {
      clearY.append(i);
      clearX.append(j+1);
    }
    //Top right
    if (i>0 && j<blocksWide-1 && nums[i-1][j+1] == 0 && blocks[i-1][j+1] != 4) {
      clearY.append(i-1);
      clearX.append(j+1);
    }
    //Top Left
    if (j>0 && i>0 && nums[i-1][j-1] == 0 && blocks[i-1][j-1] != 4) {
      clearY.append(i-1);
      clearX.append(j-1);
    }
    //Bottom Left
    if (j>0 && i<blocksTall-1 && nums[i+1][j-1] == 0 && blocks[i+1][j-1] != 4) {
      clearY.append(i+1);
      clearX.append(j-1);
    }
    //Bottom Right
    if (i<blocksTall-1 && j<blocksWide-1 && nums[i+1][j+1] == 0 && blocks[i+1][j+1] != 4) {
      clearY.append(i+1);
      clearX.append(j+1);
    }

    //Set block to clear
    blocks[i][j] = 4;

    //Clear surrounding blocks
    if (i>0) {
      blocks[i-1][j] = 4;
    }
    //Bottom
    if (i<blocksTall-1) {
      blocks[i+1][j] = 4;
    }
    //Left
    if (j>0) {
      blocks[i][j-1] = 4;
    }
    //Right
    if (j<blocksWide-1) {
      blocks[i][j+1] = 4;
    }
    //Top right
    if (i>0 && j<blocksWide-1) {
      blocks[i-1][j+1] = 4;
    }
    //Top Left
    if (j>0 && i>0) {
      blocks[i-1][j-1] = 4;
    }
    //Bottom Left
    if (j>0 && i<blocksTall-1) {
      blocks[i+1][j-1] = 4;
    }
    //Bottom Right
    if (i<blocksTall-1 && j<blocksWide-1) {
      blocks[i+1][j+1] = 4;
    }

    //Remove from list
    clearX.remove(0);
    clearY.remove(0);
  }
}

//This loop needs to be here just so the program doesn't terminate after setup
void draw() {
}

