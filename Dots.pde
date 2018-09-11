class Dots {
  float x, y, ground; //stores the x and y position of the dot; stores bottom of screen
  int whichColour; // determines the colour of the dot
  int dotSize = 30;
  int cellSize = 60;
  int row, col;
  color colour; // stores the colour of the dot
  Dots leftNeighbour, rightNeighbour, topNeighbour, bottomNeighbour;
  boolean popped = false; // checks if the dot has been "popped"
  Dots belowPoppedDot, poppedDot;
  boolean fall = false, bounce = false; // for dot falling control
  boolean pulse = false;  //for pulsing dot control
  boolean grow = true, shrink = false;
  float opacity = 100;
  float pulseDiameter = dotSize - 10;

  Dots(int numColor, float xPos, float yPos, int rowNum, int colNum) {
    whichColour = numColor;
    //set colour
    if (whichColour == 0) {
      //set as blue
      colour = color(111, 142, 187);
    } else if (whichColour == 1) {
      //set as red
      colour = color(237, 75, 97);
    } else if (whichColour == 2) {
      //set as green
      colour = color(113, 194, 156);
    } else if (whichColour == 3) {
      //set as yellow
      colour = color(255, 204, 122);
    } else if (whichColour == 4) {
      colour = color(243, 241, 244);
    }

    //set position in array
    setPos(rowNum, colNum);

    //set x and y coordinates
    x = xPos;
    y = yPos;
  }
  //(sqrt(sq(belowPoppedDot.x-this.x) + sq(belowPoppedDot.y-this.y)) >= dotSize/2)
  void draw() {
    //CONTROLS FOR DOT FALLING
    if (fall == true) {
      float dx = belowPoppedDot.x - this.x;
      float dy = belowPoppedDot.y - this.y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = dotSize;

      if (distance >= minDist) {
        this.y += 20.0;  //keep falling until falling dot collides with stationary dot
      }
      if (distance < minDist) {
        //if the falling dot has collided with a falling dot, stop falling and make it bounce
        fall = false;
        bounce = true;
      }
    }
    if (bounce == true && (this.y > poppedDot.y)) {
      //bounce back up until the falling dot is higher or the same height as the popped dot
      this.y -= 19.0;
    }
    if (bounce == true && (this.y <= poppedDot.y)) {
      //set the fallen dot's y co-ordinates to be the same as the popped dot when bounce is over
      this.y = poppedDot.y;
      bounce = false;
    }

    //CONTROLS FOR DOT PULSE
    if (pulse && grow) {
      if (pulseDiameter >= (dotSize+10)) {
        shrink = true;
        grow = false;
      }
      opacity --;
      pulseDiameter ++;
      //background(255);
      //Draw the main dot first
      fill(colour);
      noStroke();
      ellipse(x, y, dotSize, dotSize);
      //draw the pulse
      noFill();
      strokeWeight(8);
      stroke(colour, opacity);
      ellipse(x, y, pulseDiameter, pulseDiameter);
    }

    if (pulse && shrink) {
      if (pulseDiameter <= dotSize) {
        shrink = false;
        grow = true;
      }
      opacity ++;
      pulseDiameter --;
      //background(255);
      //Draw the main dot first
      fill(colour);
      noStroke();
      ellipse(x, y, dotSize, dotSize);
      //draw the pulse
      noFill();
      strokeWeight(8);
      stroke(255, opacity);
      ellipse(x, y, pulseDiameter, pulseDiameter);
    }

    //NORMAL DRAW
      fill(colour);
      noStroke();
      ellipse(x, y, dotSize, dotSize);
  }

  void setPos(int rowNum, int colNum) {
    //sets dot's position in the array
    row = rowNum;
    col = colNum;
  }

  int getR() {
    return row;
  }

  int getC() {
    return col;
  }

  void pulse(boolean state) {
    if (state == true) {
      pulse = true;
      grow = true;
    } else {
      pulse = false;
      grow = false;
      shrink = false;
    }
  }

  void pop() {
      //make it seem as if the popped dot has been removed by filling it with white
      popped = true;
      noStroke();
      fill(255);
      ellipse(x, y, dotSize, dotSize);
  }  

  Dots withinBounds(Dots[][] dots) {
      //initialise the neigbours, making sure that they aren't edge cases 
      if (col != 0) {
        leftNeighbour = dots[this.row][this.col - 1];
      }

      if (col != 4) {
        rightNeighbour = dots[this.row][this.col + 1];
      }

      if (row != 0) {
        topNeighbour = dots[this.row - 1][this.col];
      }

      if (row != 4) {
        bottomNeighbour = dots[this.row + 1][this.col];
      }

      //check if mouse is within currentDot's left, right, top, bottom neighbour respectively
      if (leftNeighbour != null && (sqrt(sq(mouseX-leftNeighbour.x) + sq(mouseY-leftNeighbour.y)) <= dotSize/2 ) && leftNeighbour.colour == colour) {
        return leftNeighbour;
      } else if (rightNeighbour != null && (sqrt(sq(mouseX-rightNeighbour.x) + sq(mouseY-rightNeighbour.y)) <= dotSize/2 ) && rightNeighbour.colour == colour) {
        return rightNeighbour;
      } else if (topNeighbour != null && (sqrt(sq(mouseX-topNeighbour.x) + sq(mouseY-topNeighbour.y)) <= dotSize/2 ) && topNeighbour.colour == colour) {
        return topNeighbour;
      } else if (bottomNeighbour != null && (sqrt(sq(mouseX-bottomNeighbour.x) + sq(mouseY-bottomNeighbour.y)) <= dotSize/2 ) && bottomNeighbour.colour == colour) {
        return bottomNeighbour;
      } else {
        return null;
      }
  }

  boolean canBePaired() {
      //checks if this dot can be paired with one of its neighbours and returns true if it can

      //INITIALISE this dot's neighbours
      if (col != 0) {
        leftNeighbour = dots[this.row][this.col - 1];
      }

      if (col != 4) {
        rightNeighbour = dots[this.row][this.col + 1];
      }

      if (row != 0) {
        topNeighbour = dots[this.row - 1][this.col];
      }

      if (row != 4) {
        bottomNeighbour = dots[this.row + 1][this.col];
      }

      //if neighbour exists and it has the same colour as this dot then return true
      if ((leftNeighbour != null && leftNeighbour.colour == colour) || (rightNeighbour != null && rightNeighbour.colour == colour) ||
        (topNeighbour != null && topNeighbour.colour == colour) || (bottomNeighbour != null && bottomNeighbour.colour == colour)) {
        return true;
      } else {
        return false;
      }
  }

  boolean isPopped() {
    return popped;
  }
  boolean withinDot() {
    //returns if the mouse is located within the dot
    if (sqrt(sq(mouseX-this.x) + sq(mouseY-this.y)) <= dotSize/2 ) {
      return true;
    }
    return false;
  }

  void fall(Dots belowPoppedDot, Dots poppedDot) {
      fall = true;
      this.belowPoppedDot = belowPoppedDot;
      this.poppedDot = poppedDot;
  }
}