//Difficulty Settings
int blocksWide = 60; //Width in blocks
int blocksTall = 30; //Height in blocks
int difficulty = 350; //Number of bombs (must be smaller than blocksWide*blocksTall)

//Appearance Settings
int pixPerBlock = 20; //Block size in pixels

//Game Variables
int[][] blocks = new int[blocksTall][blocksWide]; //State of blocks (safe, bomb, etc.)
int[][] nums = new int[blocksTall][blocksWide]; //Count of surrounding bombs
color[] state = { //Color for block states
  #A0A0A0, //Safe, unclicked
  #A0A0A0, //Bomb, unclicked
  #FF5050, //Safe, flagged
  #FF5050, //Bomb, flagged
  #80FF80  //Safe, Cleared
};

boolean gameOver = false;
int bombs = 0;
int found = 0;
boolean setupDone = false;

void setup() {  
  //Setup block arrays
  for (int i=0; i<blocksTall; i++) {
    for (int j=0; j<blocksWide; j++) {
      blocks[i][j] = 0;
    }
  }

  //Prevent while loop hang when placing bombs
  if (blocksWide*blocksTall < bombs) {
    println("Too many bombs");
    exit();
  }

  //Window Setup
  size(pixPerBlock * blocksWide + 1, pixPerBlock * blocksTall + 1);
  background(state[0]);
  drawGrid();
  println("Ready");
}

//On each mouse click
void mouseClicked() {
  //Determine block clicked
  int x = floor(mouseX / pixPerBlock);
  int y = floor(mouseY / pixPerBlock);

  //Run only on first click
  if (!setupDone) {
    //Place bombs
    while (bombs < difficulty) {
      int a = int(random(0, blocksWide));
      int b = int(random(0, blocksTall));
      //Not a block or a surrounding block - there has to be a better way :(
      if (blocks[b][a] != 1 && !((a == x || a-1 == x || a+1 == x) && (b == y || b-1 == y || b+1 == y))) { //Not bomb, block clicked, or surrounding block
        blocks[b][a] = 1; //Set to bomb
        bombs++;
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
      }
    }
    setupDone = true;
    drawGrid();
  }
  //End of first click setup

  //Do correct action for block being pressed
  if (mouseButton == LEFT) { //Normal click
    if (blocks[y][x] == 0) { //Safe, unclicked
      blocks[y][x] = 4; //Cleared

      //Add to auto clear if 0
      if (nums[y][x] == 0) {
        autoclear(x, y); //initiate auto clear
      }
    }
    if (blocks[y][x] == 1) { //Bomb, unclicked
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

  //Check if game is won
  found = 0;
  for (int i=0; i<blocksTall; i++) {
    for (int j=0; j<blocksWide; j++) {
      if (blocks[i][j] == 4) {
        found++;
      }
    }
  }

  if (gameOver) { //Bomb has been clicked
    gameOverScreen();
  } else if (found == (blocksWide * blocksTall) - bombs) { //All bombs found
    gameWinScreen();
  } else {
    drawGrid();
    //println("Waiting for click");
  }
}

//Game over
void gameOverScreen() {
  println("Game Over");

  //Impose bombs as circles on existing grid
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

//Victory
void gameWinScreen() {
  println("You Win");
  fill(#00FF00);
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
    }
  }
}

//Automatically clear out blocks that are around clear blocks
void autoclear(int x, int y) {
  IntList clearX = new IntList();
  IntList clearY = new IntList();

  clearX.append(x);
  clearY.append(y);

  //Loops until all connected 0 blocks are cleared
  while (clearY.size () != 0) {
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
