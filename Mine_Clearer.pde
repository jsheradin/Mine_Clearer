//Difficulty Settings
int blocksWide = 20;
int blocksTall = 10;
float difficulty = 0.6;

//Appearance Settings
int pixPerBlock = 20;
color[] state = new color[5]; //Block States

//Game Variables
int[][] blocks = new int[blocksTall][blocksWide];
int[][] nums = new int[blocksTall][blocksWide];
boolean gameOver = false;
int bombs = 0;
int found = 0;

void setup() {
  //Setup block arrays
  for(int i=0; i<blocksTall; i++) {
    for(int j=0; j<blocksWide; j++) {
      blocks[i][j] = 0;
    }
  }
  
  //Block colors
  state[0] = #A0A0A0; //Safe, unclicked
  state[1] = #A0A0A0; //Bomb, unclicked
  state[2] = #FF0000; //Safe, flagged
  state[3] = #FF0000; //Bomb, flagged
  state[4] = #00FF00; //Cleared
  
  //Place bombs (somewhat random, could be done much better)
  for(int i=0; i<blocksTall; i++) {
    for(int j=0; j<blocksWide; j++) {
      if (blocks[i][j] != 1 && random(0, difficulty) > 0.5) {
        blocks[i][j] = 1;
        bombs++;
      }
    }
  }
  
  //Get numbers for blocks to show when cleared
  for(int i=0; i<blocksTall; i++) {
    for(int j=0; j<blocksWide; j++) {
      nums[i][j] = 0;
      if(i>0 && blocks[i-1][j] == 1) {
        nums[i][j]++;
      }
      if(i<blocksTall-1 && blocks[i+1][j] == 1){
        nums[i][j]++;
      }
      if(j>0 && blocks[i][j-1] == 1) {
        nums[i][j]++;
      }
      if(j<blocksWide-1 && blocks[i][j+1] == 1) {
        nums[i][j]++;
      }
      //println(nums[i][j]);
    }
  }
  
  //Window Setup
  size(pixPerBlock * blocksWide, pixPerBlock * blocksTall);
  background(state[0]);
  drawGrid();
}

//On each mouse click
void mouseClicked() {
  //Determine block clicked
  int x = round(mouseX / pixPerBlock);
  int y = round(mouseY / pixPerBlock);
  
  //Do correct action for block being pressed
  if(mouseButton == LEFT) { //Normal click
    if(blocks[y][x] == 0 || blocks[y][x] == 2) { //Safe, unclicked or safe, flagged
      blocks[y][x] = 4; //Cleared
      found++;
    }
    if(blocks[y][x] == 1 || blocks[y][x] == 3) { //Bomb, unclicked or bomb, flagged
      gameOver = true;
    }
  } else if (mouseButton == RIGHT) { //Click to flag
    if(blocks[y][x] == 0) { //Safe
      blocks[y][x] = 2;
    } else if(blocks[y][x] == 2) { //Safe
      blocks[y][x] = 0;
    } else if(blocks[y][x] == 1) { //Mine
      blocks[y][x] = 3;
    } else if(blocks[y][x] == 3) { //Mine
      blocks[y][x] = 1;
    }
  }
  //println(x + ", " + y);
  if(gameOver) {
    gameOverScreen();
  } else if (found == blocksWide * blocksTall - bombs) {
   gameWinScreen();
  } else {
    drawGrid();
  }
}

//Game over screen
void gameOverScreen() {
  println("Game Over");
  
  //Impose bombs as circles on existing grid
  drawGrid();
  fill(#000000);
  for(int i=0; i<blocksTall; i++) {
    for(int j=0; j<blocksWide; j++) {
      if(blocks[i][j] == 1 || blocks[i][j] == 3) {
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
  rect(0, 0, width, height);
  fill(#FFFFFF);
  textAlign(CENTER, CENTER);
  textSize(pixPerBlock * 2);
  text("You Win", width/2, height/2);
}

//Draw blocks with corresponding color and number if applicable
void drawGrid() {
  for(int i=0; i<blocksTall; i++) {
    for(int j=0; j<blocksWide; j++) {
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

//This loop needs to be here just so the program doesn't terminate after setup
void draw() {
  
}
