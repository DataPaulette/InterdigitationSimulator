int zzSpikeCount = 6;          // zig-zag count (how many segments on the X axis)
int zzTotalWidth = 35;         // zig-zag width
int zzStrokeWidth = 45;        // zig-zag stroke width
float zzSpacingFactor = 2.2;   // zig-zag spacing factor between strips

int fingerSize = 5 * zzTotalWidth;

int stripNumber = 7;
int colorRef = stripNumber * 10;

int globalMax = 0;
color[] baseColors = new color[colorRef];

/////////////////////////////////////////////////////////////////
void setup() {
  colorMode(HSB, colorRef);
  size(600, 330);

  // run the histogram once to initialize globalMax
  drawBackground();
  drawFinger(width/2);
  histogram();
}

/////////////////////////////////////////////////////////////////
void draw() {
  // draw zigzags
  drawBackground();

  // draw finger:
  drawFinger(mouseX);

  histogram();
}

/////////////////////////////////////////////////////////////////
boolean isBaseColor(color c) {
  // 1st, test white:
  if (c == color(0, 0, colorRef)) {
    return true;
  }

  // then test the strip colors:
  for (int i = 0; i < baseColors.length; i++)
    if (c == baseColors[i])
      return true;

  return false;
}

/////////////////////////////////////////////////////////////////
void histogram() {

  int[] hist = new int[colorRef];
  // Calculate the histogram
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      int hue = int(hue(get(i, j)));

      // Only focus on the "finger colors"
      if ( !isBaseColor( get(i, j) ) ) {
        hist[hue]++;
      }
    }
  }

  for (int i = 0; i < hist.length; i++) {
    if (hist[i] < 0.06*globalMax) { // 0.6%
      hist[i] = 0;
    }
  }

  // Find the largest value in the histogram
  int histMax = max(hist);
  globalMax = max(histMax, globalMax);

  // Draw the histogram
  for (int i = 0; i < width; i++) {
    // Map i (from 0..width) to a location in the histogram (0..colorRef)
    int which = int(map(i, 0, width, 0, colorRef));

    // Convert the histogram value to a location between
    // the bottom and the top of the picture
    int y = int(map(hist[which],
                    0, globalMax,
                    height, 0));
    stroke(0);
    strokeWeight(5);
    line(i, height, i, y);
  }
}

/////////////////////////////////////////////////////////////////
void drawFinger(int position) {
  strokeWeight(0);
  fill(0, 0, colorRef, 2*colorRef/3);
  ellipse(position, height/2, fingerSize, fingerSize);
}

/////////////////////////////////////////////////////////////////
void drawBackground() {
  // starting point
  int startPosX = zzTotalWidth*2;
  int startPosY = -zzTotalWidth;

  // end point of the line
  int endPosX = zzTotalWidth*2;
  int endPosY = height+zzTotalWidth;

  background(colorRef);
  strokeJoin(MITER);

  for (int i = 0; i<stripNumber; i++) {
    strokeWeight(zzStrokeWidth);

    // Hue, Saturation, Brightness, Alpha
    baseColors[i] = color(i*(colorRef/stripNumber) % colorRef,
                          colorRef, colorRef, colorRef);

    stroke(baseColors[i]);
    drawZigZag(zzSpikeCount, zzTotalWidth,
               startPosX + zzTotalWidth * i * zzSpacingFactor, startPosY,
               endPosX   + zzTotalWidth * i * zzSpacingFactor,   endPosY);
  }
}

/////////////////////////////////////////////////////////////////
void drawZigZag(int segments, float radius, float aX, float aY, float bX, float bY) {

  // Calculate vector from start to end point
  float distX = bX - aX;
  float distY = bY - aY;

  // Calculate length of the above mentioned vector
  float segmentLength = sqrt(distX * distX + distY * distY) / segments;

  // Calculate segment vector
  float segmentX = distX / segments;
  float segmentY = distY / segments;

  // Calculate normal of the segment vector and multiply it with the given radius
  float normalX = -segmentY / segmentLength * radius;
  float normalY = segmentX / segmentLength * radius;

  // Calculate start position of the zig-zag line
  float StartX = aX + normalX;
  float StartY = aY + normalY;

  beginShape();
  vertex(StartX, StartY);

  // Render the zig-zag line
  for (int n = 1; n < segments; n++) {
    float newX = aX + n * segmentX + ((n & 1) == 0 ? normalX : -normalX);
    float newY = aY + n * segmentY + ((n & 1) == 0 ? normalY : -normalY);
    vertex(newX, newY);
  }

  // Render last line
  vertex(bX + ((segments & 1) == 0 ? normalX : -normalX),
         bY + ((segments & 1) == 0 ? normalY : -normalY));

  // roll back to close the shape
  for (int n = segments-1; n >= 1; n--) {
    float newX = aX + n * segmentX + ((n & 1) == 0 ? normalX : -normalX);
    float newY = aY + n * segmentY + ((n & 1) == 0 ? normalY : -normalY);
    vertex(newX, newY);
  }

  endShape();
}

