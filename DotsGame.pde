//author: Deanne Alabastro date: October 2017
import java.util.ArrayDeque;
import java.util.HashSet; 

Dots[][] dots;
int rows = 5, cols = 5; //number of rows and cols in the dots grid
int boardStartX = 55, boardStartY = 100, cellSize = 60, cellPadding = 10;
int dotSize = 30;
float prevX, prevY, curX, curY; //previous and current x and y for line between them
Dots current, previous, next; //dot pointers
boolean mouseDragged = false, mouseReleased = false;
boolean pairsPresent = false; //true if there is at least one pair of some coloured dots that can be popped
ArrayList<Dots> toPop = new ArrayList<Dots>(); //list of dots waiting to be popped
boolean pulsing = false; //controls how many times checkForSquares and pulsing is called
Table scores; //holds highscores
PFont font; //holds font
int dotCount = 0; //keeps count of the user's current score for timed mode
//counts for objective mode
int redCount = 0;
int blueCount = 0;
int greenCount = 0;
int yellowCount = 0;
int dotTotal = 15; // total amount of dots to get in objective mode
int moves;
int level = 1;
boolean won = false;
int gamePlay = 1;


//the active screen that the user sees - 0: Home Screen - initScreen, 1: Instructions - InstructScreen, 
//2: getUserName, 3: GameScreen, 4: GameOverScreen, 5: chooseGamePlay
int activeScreen = 0;

//timer variables: note - got help from here:
//https://forum.processing.org/one/topic/how-to-make-millus-count-down-from-a-number.html
int time, begin, duration;

//user input for name , Note got help from here:
//https://forum.processing.org/one/topic/how-to-input-text-and-process-it.html
String userName="";

//highscore
boolean updateScore = false;
String fileName = "dotsScores.csv";
int randomNum = 0; // used for randomly selecting dot colours

void setup() {
  size(400, 500);
  textAlign(CENTER);
  font = createFont("Raleway-Regular", 48);
  textFont(font);
  scores = loadTable("dotsScores.csv", "header");
  begin = millis();
  time = duration = 60;
  restart();
}

void draw() {
  if (activeScreen == 0) {
    initScreen();
  } else if (activeScreen == 1) {
    instructScreen();
  } else if (activeScreen == 2) {
    getUserName();
  } else if (activeScreen == 3) {
    gameScreen();
  } else if (activeScreen == 4) {
    gameOverScreen();
    if (gamePlay == 1 || (gamePlay == 2 && won == false && level == 1)) {
      userName = "";
    }
  } else if (activeScreen == 5) {
    chooseGamePlay();
  }
}

void restart() {
  //INITIALISE DOTS
  dots = new Dots[rows][cols];
  
  //choose a random number for deciding the number of different coloured dots
  if (gamePlay == 2 && level == 1) {
    randomNum = 3;
  }
  if ((gamePlay == 2 && level == 2) || gamePlay == 1) {
    randomNum = 4;
  } 
  
  //create the dots and place them in an array
  for (int row = 0; row < rows; row ++) {
    for (int col = 0; col < cols; col ++) {
      dots[row][col] = new Dots(int(random(randomNum)), (col*cellSize) + boardStartX + (dotSize-cellPadding), 
        (row*cellSize) + boardStartY + (dotSize-cellPadding), row, col);
    }
  }

  //INITIALISE DOT POINTERS
  current = null;
  previous = null;
  next = null;

  //INITIALISE GAME CONTROLS
  pairsPresent = false; //true if there is at least one pair of some coloured dots that can be popped
  toPop = new ArrayList<Dots>(); //list of dots waiting to be popped
  pulsing = false; //controls how many times checkForSquares and pulsing is called

  //INITIALISE SCORES
  dotCount = 0;
  redCount = 0;
  blueCount = 0;
  greenCount = 0;
  yellowCount = 0;
  updateScore = false;
  won = false;

  //INITIALISE TIME AND NUM OF MOVES
  begin = millis();
  time = duration;
  if (gamePlay == 2 && level == 1) {
    moves = 20;
  } else if (gamePlay == 2&& level == 2) {
    moves = 30;
  }
}

//GAME SCREEN CODE 

void initScreen() {  
  background(247, 240, 231); //yellow
  fill(255, 113, 111); //red
  textSize(48);
  text("DOTS GAME", width/2, 150);

  //make the play button
  noStroke();
  fill(113, 194, 155); //green
  rect(50, 210, 300, 50, 100);
  textSize(24);
  fill(255);
  text("PLAY", width/2, 245);

  //make the instructions button
  fill(82, 106, 140); //blue
  rect(50, 300, 300, 50, 100);
  fill(255);
  text("INSTRUCTIONS", width/2, 335);

  //MOUSE CONTROLS
  if (mousePressed) {
    //f user clicks instructions, change to instructScreen
    if (mouseX > 50 && mouseX < 350 && mouseY > 300 && mouseY < 350) {
      activeScreen = 1;
    } //if user clicks play, change to get user name
    else if (mouseX > 50 && mouseX < 350 && mouseY > 210 && mouseY < 260) {
      activeScreen = 2;
      restart();
    } else {
      return;
    }
  }
}

void instructScreen() {
  background(247, 240, 231);
  //instructions title
  textAlign(CENTER);
  fill(82, 106, 140); 
  textSize(48);
  text("INSTRUCTIONS", width/2, 60);
  
  //text for the instructions
  textSize(16);
  textAlign(LEFT);
  fill(61);
  text("1. Connect as many dots as you can within the", 10, 100);
  text("    time limit in timed mode", 10, 125);
  text("    or complete the objectives within the set", 10, 150);
  text("    amount of moves in objective mode", 10, 175);
  text("2. You must at least connect 2 dots of the same", 10, 210);
  text("    colour to pop them", 10, 235);
  fill(113, 194, 155);
  text("Drag to connect and", width/3 -10, 270);
  text("  Release to pop", width/3, 295);
  fill(61);
  text("3. You can only connect dots", 10, 330);
  fill(113, 194, 155);
  text("horizontally and vertically", width/3- 20, 355);
  fill(255, 113, 111);
  text("but never diagonally", width/3 -20, 380);
  fill(61);
  text("4. Make a square to pop all dots of the same colour", 10, 415);

  //make play now button
  fill(113, 194, 155);
  rect(60, 430, 275, 50, 100);
  fill(255);
  noStroke();
  textAlign(CENTER);
  text("PLAY NOW", 197.5, 465);

  //mouse controls
  if (mousePressed && mouseX > 60 && mouseX < 335 && mouseY > 430 && mouseY < 480) {
    activeScreen = 2; //if user clicks play again button, ask for username
    restart();
  }
}

//Game screen and display bar
void gameScreen() {
  background(255);
  displayScoreBar();
  noStroke();
  drawDots();
  addFirstDot();
  contAddDots();
  popDots();
  checkPopped();
}

void displayScoreBar() {
  noStroke();
  //makes the background of the bar
  //top
  fill(239, 239, 239);
  rect(0, 0, width, 50);
  //bottom
  fill(239, 239, 239);
  rect(0, height - 50, width, 50);

  //squares for current time, restart, dotCount(for objective mode), and home text
  fill(220, 221, 225);
  rect(0, 0, 50, 50);//current time
  rect(width-50, 0, 50, 50);//restart
  rect(0, height-50, 50, 50);//dotCount(objective mode)
  rect(width-50, height-50, 50, 50);//home

  //MAKE HOME BUTTON
  //house icon
  stroke(104, 113, 120);
  strokeWeight(3);
  noFill();
  rect(width-37, height - 30, 25, 20, 5);
  triangle(width-10, height-30, width-39, height - 30, width-25, height - 45);


  //MAKE RESTART BUTTON
  noFill();
  stroke(104, 113, 120);
  strokeWeight(5);
  arc(width-25, 25, 25, 25, 0, PI+HALF_PI+QUARTER_PI, PIE);
  noStroke();
  fill(220, 221, 225);
  ellipse(width-25, 25, 25, 25);
  strokeWeight(3);
  stroke(104, 113, 120);
  line(width-15, 18, width-20, 18);
  line(width-15, 18, width-15, 13);

  //if gameplay == 1 (timed)
  if (gamePlay == 1) {
    //timer text
    fill(104, 113, 120);

    //timer control
    if (time > 0) {
      time = duration - (millis() - begin)/1000;
    }
    if (time == 0) {
      activeScreen = 4;
    }
    textSize(24);
    text(time, 25, 25);
    text(dotCount, width/2, 25);
    textSize(14);
    text("Time", 25, 45);
    text("Score", width/2, 45);
  } 
  //OBJECTIVE MODE CONTROLS AND DESIGN
  else {
    if (level == 1 && moves == 0 && (blueCount < dotTotal || redCount < dotTotal || greenCount < dotTotal)) {
      won = false;
      activeScreen = 4; //switch to game over screen if total moves is 0 and dotTotals haven't been filled
    } else if (level == 1 && (blueCount >= dotTotal && redCount >= dotTotal && greenCount >= dotTotal)) {
      if (moves != 0) { //if user completes level 1 with leftover moves
        while (moves > 0) {
          dotCount += 5; // increment 5+ dotCount for each move
          moves--;
        }
      } 
      won = true;
      activeScreen = 4; //switch to game over screen (in this case, end of round);
    } else if (level == 2 && moves == 0 && (blueCount < dotTotal || redCount < dotTotal || greenCount < dotTotal || yellowCount <dotTotal)) {
      won = false; //if user doesn't complete level 2
      activeScreen = 4;
    } else if (level == 2 && (blueCount >= dotTotal && redCount >= dotTotal && greenCount >= dotTotal && yellowCount >= dotTotal)) {
      if (moves != 0) { // if user completes level 2 with left over moves
        while (moves > 0) {
          dotCount += 5; //increment 5+ dotCount for each move
          moves--;
        }
      }
      won = true;
      activeScreen = 4; //switch to game over screen (in this case, end of round);
    }

    fill(104, 113, 120);
    textSize(24);
    text(moves, 25, 25);
    text(dotCount, 25, height-30);
    textSize(14);
    text("Score", 25, height-10);
    text("Moves", 25, 45);
    textSize(36);
    text("Level " + level, width/2, height-15);
    displayDotCounts();
  }

  //mouseControls
  if (mousePressed && mouseX > width-50 && mouseX < width && mouseY > 0 && mouseY < 50) {
    restart();  //if user presses restart button
  } else if (mousePressed && mouseX > width -50 && mouseX < width && mouseY > height - 50 && mouseY < height) {
    //if user presses the home button
    level = 1;
    userName = "";
    activeScreen = 0;
  }
}

void displayDotCounts() {
  //displays the number of coloured dots out of the total (objective) is popped Note: only used for objective mode
  fill(0);
  noStroke();
  textSize(14);
  int dotCountPadding = 0;
  int numOfDotCounts = 0;
  if (level == 1) {
    dotCountPadding = 100;
    numOfDotCounts = 3;
  } else {
    dotCountPadding = 75;
    numOfDotCounts = 4;
  }

  for (int i = 0; i < numOfDotCounts; i++) {
    int textX = 50 + (dotCountPadding/2) + (dotCountPadding*i);
    fill(104, 113, 120);
    if (i == 0) {
      if (blueCount < dotTotal) {
        text(blueCount+"/"+dotTotal, textX, 45);
      } else {
        text("Done", textX, 45);
      }
      fill(111, 142, 187);
    } else if (i == 1) {
      if (redCount < dotTotal) {
        text(redCount+"/"+dotTotal, textX, 45);
      } else {
        text("Done", textX, 45);
      }
      fill(237, 75, 97);
    } else if (i == 2) {
      if (greenCount < dotTotal) {
        text(greenCount+"/"+dotTotal, textX, 45);
      } else {
        text("Done", textX, 45);
      }
      fill(113, 194, 156);
    } else {
      if (yellowCount < dotTotal) {
        text(yellowCount+"/"+dotTotal, textX, 45);
      } else {
        text("Done", textX, 45);
      }
      fill(255, 204, 122);
    }
    ellipse(50 + (dotCountPadding/2) + (dotCountPadding*i), 20, 20, 20);
  }
}

//Game over screen and highscores 
void gameOverScreen() {
  scores = loadTable(fileName, "header");
  background(247, 240, 231);
  noStroke();
  fill(255);
  rect(0, 25, width, 50);
  fill(255, 113, 111);
  textSize(36);
  text("END OF ROUND", width/2, 60);

  //MAKE HOME BUTTON
  //background square
  fill(220, 221, 225);
  rect(0, 25, 50, 50);
  //house icon
  stroke(104, 113, 120);
  strokeWeight(3);
  noFill();
  rect(12.5, 45, 25, 20, 5);
  triangle(10, 45, 39, 45, 25, 30);
  
  //only show calculated scores if the player won

  if (won == true || gamePlay == 1) {
    if (dotCount > 0 && updateScore == false) {
      calculateScores();
    }

    int bestScore = scores.getInt(0, "Score");

    //SCORE DISPLAYS
    //background squares
    fill(255);
    noStroke();
    rect(60, 90, width/2 - 75, 100); //this round background
    rect(width/2 + 10, 90, width/2 - 75, 100); //highest score background
    rect(60, 220, 275, 200); //top scores background

    fill(180);
    textSize(14);
    text("This Round", width/2 - 80, 120);
    text("Highest Score", width/2 + 75, 120);
    text("Top Scores", width/2, 210);

    textSize(18);
    textAlign(LEFT);
    for (int i = 0; i < scores.getRowCount(); i++) {
      if (i == 0) {
        fill(255, 113, 111);
      } else {
        fill(61);
      }
      if (scores.getInt(i, "Score") != 0) {
        text(scores.getString(i, "Name"), 80, 250 + (i*38));
        text(scores.getInt(i, "Score"), 280, 250 + (i*38));
      }
    }
    fill(61);
    textAlign(CENTER);
    textSize(48);
    text(dotCount, width/2 - 80, 160); //this round text
    //highestScore text
    if (bestScore == 0) {
      text("0", width/2 + 75, 160);
    } else {
      text(bestScore, width/2 + 75, 160);
    }
  } else {
    //show this if the user did not complete the objective (they lost)
    textSize(24);
    fill(255);
    noStroke();
    rect(60, 90, 275, 300);
    fill(104, 113, 120);
    text("You have run out of", 197.5, 190);
    text("moves and have not", 198, 220);
    text("completed the", 198.5, 250);
    text("objective :(", 199, 280);
  }

  //PLAY AGAIN BUTTON
  fill(113, 194, 155);
  rect(60, 430, 275, 50, 100);
  fill(255);
  textSize(24);
  if (gamePlay == 1 || (gamePlay == 2 && won == false)) {
    text("PLAY AGAIN", 197.5, 465);
  } else if (gamePlay == 2 && won == true && level == 1) {
    text("Next Level", 197.5, 465);
  } else {
    text("Back to Menu", 197.5, 465);
  }

  //MOUSE CONTROLS

  if (mousePressed && mouseX > 0 && mouseX < 50 && mouseY > 25 && mouseY < 75) {
    activeScreen = 0; //if user clicks house, return to initscreen
    level = 1;
    userName = "";
  } else if (mousePressed && mouseX > 60 && mouseX < 335 && mouseY > 430 && mouseY < 480) {
    if (gamePlay == 1 || (gamePlay == 2 && won == false)) {
      activeScreen = 2; //get userName
      restart();
    } else if (gamePlay == 2 && won == true && level == 1) {
      level = 2;
      fileName = "level2Scores.csv";
      activeScreen = 3; //go straight to gameScreen
      restart();
    } else {
      level = 1;
      userName = "";
      activeScreen = 0; //go to home screen
    }
  }
}

void calculateScores() {
  background(255, 100);
  int row = scores.findRowIndex("", "Score");
  String name = userName;
  if(name == null || name.equals("")){
    name = "Anonymous";
  }

  //if there no blank score space, set the row to the last row of the score table
  if (row == -1 ) {
    row = scores.getRowCount()-1;
  }

  //start from the end of the list
  for (int i = row; i >= 0; i--) {
    //if the user's score is greater than the current row's score
    if (dotCount >= scores.getInt(i, "Score")) {
      //if it is the last score, replace it with user's
      if (i == scores.getRowCount()-1) {
        //replace current row's details with user's details
        scores.setString(i, "Name", name);
        scores.setInt(i, "Score", dotCount);
      }
      //if it is not the last score, store the current row's details and switch it to the one after it.
      //user's score gets inputted into the current row
      else {
        //store the current row's details
        String tempName = scores.getString(i, "Name");
        int tempScore = scores.getInt(i, "Score");
        //move the current row's details down the list (towards the end) 
        scores.setString(i+1, "Name", tempName);
        scores.setInt(i+1, "Score", tempScore);
        //replace current row's details with user's details
        scores.setString(i, "Name", name);
        scores.setInt(i, "Score", dotCount);
      }
    }
  }

  updateScore = true;
  saveTable(scores, "data/"+fileName);
  scores = loadTable(fileName, "header");
}

//Get username code

void getUserName() {
  noStroke();
  textSize(24);
  background(255);
  fill(0);
  textAlign(CENTER);
  text("Enter Name", width/4 + 100, height/3 + 20);
  text(userName, width/2, 230);
}

void keyPressed() {
  if (key==BACKSPACE) {
    //delete string by one character
    if (userName.length()>0) {
      userName=userName.substring(0, userName.length()-1);
    }
  } else if (key==RETURN || key==ENTER) {
    //choose Gameplay
    activeScreen = 5;
  } else {
    if (keyCode == SHIFT || keyCode == 20) {
      return;
    } else {
      //add the pressed key to the username string (does not include the shift and capslock (20) characters
      userName+=key;
    }
  }
}

void chooseGamePlay() {
  background(247, 240, 231);
  fill(255, 204, 122);
  textAlign(CENTER);
  textSize(48);
  text("Choose", width/2, 100);
  text("Gameplay", width/2, 150);

  //make timed play button
  noStroke();
  fill(113, 194, 155); //green
  rect(50, 210, 300, 50, 100);
  textSize(24);
  fill(255);
  text("TIMED", width/2, 245);

  //make objectives button
  fill(82, 106, 140); //blue
  rect(50, 300, 300, 50, 100);
  fill(255);
  text("OBJECTIVES", width/2, 335);

  if (mousePressed) {
    //f user clicks objectives gameplay = objectives
    if (mouseX > 50 && mouseX < 350 && mouseY > 300 && mouseY < 350) {
      gamePlay = 2;
      fileName = "level1Scores.csv";
      activeScreen = 3;
      restart();
    } //if user clicks timed gameplay = timed
    else if (mouseX > 50 && mouseX < 350 && mouseY > 210 && mouseY < 260) {
      gamePlay = 1;
      fileName = "dotsScores.csv";
      activeScreen = 3;
      restart();
    } else {
      return;
    }
  }
}

//GAMEPLAY CODE
void drawDots() {
  //change background colour if user makes a square
  if (pulsing == true && toPop.size() >= 5) {
    strokeWeight(5);
    stroke(toPop.get(0).colour);
    fill(toPop.get(0).colour, 50);
    rect(0, 50, width-3, height - 103);
  }
  //draw dots
  for (int row = 0; row < rows; row ++) {
    for (int col = 0; col < cols; col ++) {
      dots[row][col].draw();
    }
  } 
  checkForPairs();
}

void checkForPairs() {
  //if there is a pair of dots with the same colour present, set pairsPresent as true and return
  for (int row = 0; row < rows; row ++) {
    for (int col = 0; col < cols; col ++) {
      if (dots[row][col].canBePaired() == true) {
        pairsPresent = true;
        return;
      }
    }
  }

  shuffleDots();
}

void shuffleDots() {
  //shuffles dots if there are no pairs based on modern Fisher-Yates Algorithm
  for (int row = dots.length - 1; row >= 0; row--) {
    for (int col = dots[row].length - 1; col >= 0; col--) {
      //generates a random position for where the current dot in the array should swap position
      int newRow = int(random(row+1));
      int newCol = int(random(col+1));

      if (newRow != row && newCol != col) {
        Dots temp = dots[row][col]; //temp used for swapping
        //swap position, row, and col
        //random dot into current
        dots[row][col] = dots[newRow][newCol];
        dots[row][col].row = row;
        dots[row][col].col = col;
        dots[row][col].x = (col*cellSize) + boardStartX + (dotSize-cellPadding); 
        dots[row][col].y = (row*cellSize) + boardStartY + (dotSize-cellPadding);
        //current into random dot's position
        dots[newRow][newCol] = temp;
        temp.row = newRow;
        temp.col = newCol;
        temp.x = (newCol*cellSize) + boardStartX + (dotSize-cellPadding);
        temp.y = (newRow*cellSize) + boardStartY + (dotSize-cellPadding);
      }
    }
  }
  drawDots();
}

void drawLines() {
  if (toPop.size() > 1 && mouseDragged) {
    for (int count = 0; count < toPop.size()-1; count++) {
      strokeWeight(10);
      stroke(toPop.get(count).colour);
      line(toPop.get(count).x, toPop.get(count).y, toPop.get(count+1).x, toPop.get(count+1).y);
    }
  }
}


void addFirstDot() {
  if (mousePressed && toPop.isEmpty()) {
    //check to see if the mouse is on a dot (and which one it is) and save it to current
    for ( int row = 0; row < dots.length; row++ ) {
      for (int col = 0; col < dots[row].length; col++) {
        if (dots[row][col].withinDot()) {
          current = dots[row][col] ;
          toPop.add(current);
          toPop.get(toPop.size() - 1).pulse(true); //turn pulse on
        }
      }
    }
  }
}

void contAddDots() {
  if (mouseDragged && toPop.size() >= 1) {
    //draw the pointer line
    if (current != null) {
      strokeWeight(10);
      stroke(current.colour);
      line(current.x, current.y, mouseX, mouseY);
    }
    //check if the next dot is withinBounds
    next = current.withinBounds(dots);
    //if it is within bounds i.e. next is not = null.
    if (next != null) {
      //if the next dot's co-ordinates is the same as the previous dot's then remove(current) from the list, set current as previous, 
      if (previous != null && next.row == previous.row && next.col == previous.col) {
        toPop.get(toPop.size() - 1).pulse(false); //turn pulse off for previous dot
        toPop.remove(toPop.size()-1);

        current = previous;
        toPop.get(toPop.size() - 1).pulse(true); //turn pulse on for current dot

        //check if the current dot is the only one in the list; set previous as the dot one less than the current
        if (toPop.size() > 1) {
          previous = toPop.get(toPop.size()-2);
        } else {
          previous = null;
        }
      }
      //else set the previous as current, the current as next, and add current to the list
      else {
        previous = current;
        current = next;
        toPop.add(current);
        //pulse control
        toPop.get(toPop.size() - 2).pulse(false); //turn pulse off for previous dot
        toPop.get(toPop.size() - 1).pulse(true); //turn pulse on for current dot
      }
    }
    if (pulsing == false || (pulsing == true && toPop.size() <5)) {
      checkForDotSquares();
    }
    drawLines();
  }
}

void popDots() {
  //only sets the dot to popped and resets dot pointers - checkedPop makes the dots fall and removes them
  if (mouseReleased) {
    mouseDragged = false;
    //if there is only one dot then clear the list (i.e. it is not valid so do not pop)
    if (toPop.size() == 1) {
      toPop.get(0).pulse(false);
      toPop.clear();
    }
    //if there is at least two dots then call pop on each dot, set their position in the array as null and then clear the list.
    else if (toPop.size() >= 2) {
      //first check if the user has drawn a square - if they have, pop all like colours and clear list, otherwise continue with above comment
      if (checkForDotSquares()) {
        for (int row = 0; row < dots.length; row++) {
          for (int col = 0; col < dots[row].length; col++) {
            if (dots[row][col].colour == toPop.get(0).colour) {
              dots[row][col].pop();
              dotCount++;
              if (gamePlay == 2) {
                if (toPop.get(0).colour == color(111, 142, 187) && blueCount < dotTotal) {
                  blueCount++;
                } else if (toPop.get(0).colour == color(237, 75, 97) && redCount < dotTotal) {
                  redCount++;
                } else if (toPop.get(0).colour == color(255, 204, 122) && yellowCount < dotTotal) {
                  yellowCount++;
                } else if (toPop.get(0).colour == color(113, 194, 156) && greenCount < dotTotal) {
                  greenCount++;
                }
              }
            }
          }
        }
        moves--;
        pulsing = false;
        toPop.clear();
      } else {
        for (int count = 0; count < toPop.size(); count++) {
          toPop.get(count).pop();
          dotCount++;
          if (gamePlay == 2) {
            if (toPop.get(0).colour == color(111, 142, 187) && blueCount < dotTotal) {
              blueCount++;
            } else if (toPop.get(0).colour == color(237, 75, 97) && redCount < dotTotal) {
              redCount++;
            } else if (toPop.get(0).colour == color(255, 204, 122) && yellowCount < dotTotal) {
              yellowCount++;
            } else if (toPop.get(0).colour == color(113, 194, 156) && greenCount < dotTotal) {
              greenCount++;
            }
          }
        }
        moves--;
        toPop.clear();
      }
    }
    //reset the dot pointers
    current = null;
    previous = null;
    next = null;
    mouseReleased = false;
  }
}

void checkPopped() {
  ArrayList<Dots> popped = new ArrayList<Dots>();

  //start from the end of the array and check for dots that have been popped (1 row at a time);
  for (int row = dots.length-1; row >= 0; row--) {
    for (int col = dots[row].length-1; col >=0; col--) {
      //if a dot has been popped, then add it to the popped list
      if (dots[row][col].isPopped() == true) {
        popped.add(dots[row][col]);
      }
      //if the loop has reached both the end of the row and the col and there's something in the list - make the dots fall
      if (col == 0 && row == 0 && popped.size() > 0) {
        dotFall(popped);
      }
    }
  }
}

void dotFall(ArrayList<Dots> popped) {
  Dots topNeighbour = null;

  for (int dot = 0; dot < popped.size(); dot++) {
    if (popped.get(dot).row != 0) {
      //for each popped dot, find the nearest topNeighbour that isn't popped.
      topNeighbour = findTopNeighbour(popped.get(dot));

      if (topNeighbour != null) {
        //make the topNeighbour fall until it touches the position of the popped dot 

        if (popped.get(dot).row == dots.length - 1) {
          topNeighbour.fall(dots[(popped.get(dot).row)][popped.get(dot).col], popped.get(dot)); //for the dots at the bottom row
        } else {
          topNeighbour.fall(dots[(popped.get(dot).row) + 1][popped.get(dot).col], popped.get(dot)); //for all the other dots (except the top row)
        }
        //set poppedDot array position to topNeighbour's
        dots[popped.get(dot).row][popped.get(dot).col] = topNeighbour;

        //set a temp new dot to take the place of topNeighbour's old spot (this is so it isnt null) then set it to pop so that one of the 
        //current dots in the board can replace it
        dots[topNeighbour.row][topNeighbour.col] = new Dots(int(random(randomNum)), (topNeighbour.col*cellSize) + boardStartX + (dotSize-cellPadding), 
          (topNeighbour.row*cellSize) + boardStartY + (dotSize-cellPadding), topNeighbour.row, topNeighbour.col);

        dots[topNeighbour.row][topNeighbour.col].pop();
        topNeighbour.row = popped.get(dot).row;
        topNeighbour.col = popped.get(dot).col;
      }
    } else if (popped.get(dot).row == 0 && topNeighbour == null) {
      //if top neighbour doesn't exist at all i.e. becuase it's also popped or it's the first row, create a new dot to replace
      //note: it uses the popped dot's info
      topNeighbour = new Dots(int(random(randomNum)), ((popped.get(dot).col)*cellSize) + boardStartX + (dotSize-cellPadding), 
        0-(dotSize/2.0), popped.get(dot).row, popped.get(dot).col);

      //get the topNeighbour to fall to the nearest popped dot
      topNeighbour.fall(dots[(popped.get(dot).row) + 1][popped.get(dot).col], popped.get(dot));

      //set the popped dot's location in the array as topNeighbour
      dots[popped.get(dot).row][popped.get(dot).col] = topNeighbour;
    }
  }
}

Dots findTopNeighbour(Dots dot) {
  //finds the nearest topNeighbour that is not popped
  if (dot.row == 0 || dots[dot.row-1][dot.col] == null || dots[dot.row-1][dot.col].isPopped()) {
    return null;
  }

  Dots topNeighbour = dots[dot.row][dot.col];

  for (int count = 0; topNeighbour.isPopped(); count ++) {
    topNeighbour = dots[dot.row - count][dot.col];
    //if the topNeighbour is still the same as the dot that was passed to this method, then return null (because unpopped dot doesn't exist)
    if ((dot.row - count == 0) && (topNeighbour == dots[dot.row][dot.col])) {
      return null;
    }
  }
  return topNeighbour;
}

boolean checkForDotSquares() {
  HashSet<Dots> noDupDots = new HashSet<Dots>(toPop);
  if (toPop.size() >= 5 && (noDupDots.size() < toPop.size())) {
    current.pulse(false);
    for (int row = 0; row < dots.length; row++) {
      for (int col = 0; col < dots[row].length; col++) {
        if (dots[row][col].colour == toPop.get(0).colour) {
          dots[row][col].pulse(true);
        }
      }
    }
    pulsing = true;
    return true;
  } else if (mouseReleased || (pulsing == true && toPop.size() < 5)) {
    for (int row = dots.length-1; row >= 0; row--) {
      for (int col = dots[row].length-1; col >=0; col--) {
        dots[row][col].pulse(false);
      }
    }
    if (current != null) {
      current.pulse(true);
    }
    pulsing = false;
  }
  return false;
}

void mousePressed() {
  mouseDragged = false;
  mouseReleased = false;
}
void mouseDragged() {
  mouseDragged = true;
}

void mouseReleased() {
  mouseReleased = true;
}
