/*

 Easing (tweening, smooth transitions, non-linear interpolation)
 Easing examples from Squirrel Eiserloh: 
 	[Math for Game Programmers: Fast and Funky 1D Nonlinear Transformations](https://youtu.be/mr5xkf6zSzk)
	
*/

//------------------------------ Global program configurable variables

int animationCicleFrames = 70; // frames to complete the animation cicle. Last 10% of frames are used to wait the next cicle.

//------------------------------ Global program static variables

// initial functions
String functionNames[] = {
	"bounceBezier3",
	"smoothStep2",
	"smoothStart26",
	"smoothStop3"
};

// color palette used to represent each function
Color colors[] = {
	0xFFFF0000, // red
	0xFFFF00FF, // magenta
	0xFF00FFFF, // cyan
	0xFF00FF00, // green
	0xFFFFFF00, // yellow
	0xFF0000FF // blue
};

//------------------------------ Main class variables

ColorSequence colorGenerator;
ArrayList functions;
int effectiveAnimationCicleFrames;
int currentWitdh;
int	currentHeight;
int componentSpace;
int componentSize;
int componentHeightPosition;

//------------------------------ Classes

class ColorSequence {

	private Color[] colors;
	private int position;

	ColorSequence(Color[] colors) {
		this.position = 0;
		this.colors = colors;
	}

	public Color next() {
		Color color = this.colors[this.position];
		this.position = (this.position == this.colors.length) ? 0 : this.position + 1;
		return color;
	}
}

class Function {

	float values[];
	float scaledValues[];
	Color color;
	String name;

	Function(EasingFunction func, String name, int values, int scale, Color color) {
		this.name = name;
		this.values = new float[values];
		this.scaledValues = new float[values];
		this.color = color;

		for (int i = 0; i < values; i++) {
			t = map(i, 0, values, 0, 1);
			value = func.generic(name, t);
			this.values[i] = value;
			this.scaledValues[i] = map(value, 0, 1, 0, scale);
		}
	}
}

//------------------------------ Main

void gradient(PVector position, int width, int height, int frame) {
	int ySize = height / functions.size();
	int diameter = ySize / 4;
	// clear
	fill(0);
	noStroke();
	rect(position.x - diameter, position.y - diameter, width + 2 * diameter, height + 2 * diameter);

	Function f;
	int y;
	for (int i = 0; i < width; i++) {
		y = position.y;
		for (int functionNumber = 0; functionNumber < functions.size(); functionNumber++) {
			f = functions.get(functionNumber);
			stroke(f.values[i] * 255);
			rect(position.x + i, y, 1, ySize);
			y += ySize;
		}
	}
	// Animation
	y = position.y + ySize / 2;
	for (int functionNumber = 0; functionNumber < functions.size(); functionNumber++) {
		Function f = functions.get(functionNumber);
		fill(f.color);
		stroke(0);
		ellipse(position.x + f.scaledValues[frame], y, diameter, diameter);
		y += ySize;
	}
}

void fadeFunctionNames(PVector position, int width, int height, frame) {
	fill(0);
	noStroke();
	rect(position.x, position.y, width, height);
	textAlign(CENTER, CENTER);
	int ySize = height / functions.size();
	pushMatrix();
	translate(0, position.y + ySize / 2);
	scale(1, -1); // revert to original Y axis sign
	for (int functionNumber = 0; functionNumber < functions.size(); functionNumber++) {
		Function f = functions.get(functionNumber);
		fill(color(f.color, f.values[frame] * 255)); // hex, alpha
		text(f.name, position.x + width / 2, 0, width);
		translate(0, -ySize);
	}
	popMatrix();
}

void plot(PVector position, int width, int height, int frame) {
	int diameter = height / (functions.size() * 4);
	// clear
	fill(0);
	noStroke();
	rect(position.x - diameter, position.y - diameter, width + 2 * diameter, height + 2 * diameter);
	// paint
	noFill();
	stroke(255);
	rect(position.x, position.y, width, height);
	for (int i = 0; i < width; i++) {
		for (int functionNumber = 0; functionNumber < functions.size(); functionNumber++) {
			Function f = functions.get(functionNumber);
			point(position.x + i, position.y + f.scaledValues[i]);
		}
	}
	// Animation
	for (int functionNumber = 0; functionNumber < functions.size(); functionNumber++) {
		Function f = functions.get(functionNumber);
		fill(f.color);
		stroke(f.color);
		ellipse(position.x + frame, position.y + f.scaledValues[frame], diameter, diameter);
	}
}

void setup() {
	effectiveAnimationCicleFrames = animationCicleFrames * 0.9;
	colorGenerator = new ColorSequence(colors);
	functions = new ArrayList();
	EasingFunction func = new EasingFunction();
	background(0);
	currentWitdh = screen.width * 0.75;
	currentHeight = screen.height * 0.75;
	size(currentWitdh, currentHeight);
	componentSpace = currentWitdh * 0.1 / 4;
	componentSize = currentWitdh * 0.9 / 3;
	componentHeightPosition = (currentHeight - componentSize) / 2;
	PFont font = createFont("Arial", componentSize / (functionNames.length() * 2));
	textFont(font);
	Function f;
	for (int functionNumber = 0; functionNumber < functionNames.length(); functionNumber++) {
		f = new Function(func, functionNames[functionNumber], componentSize, componentSize, colorGenerator.next());
		functions.add(f);
	}
}

void draw() {
	int cicleFrame = frameCount % (animationCicleFrames);
	int frame = (cicleFrame <= effectiveAnimationCicleFrames) ? int(map(cicleFrame, 0, effectiveAnimationCicleFrames, 0, componentSize - 1)) : componentSize - 1;
	//println(frameCount);
	pushMatrix();
	scale(1, -1); // invert Y axis sign
	translate(0, -currentHeight); // move Y = 0 to bottom of the screen
	stroke(255, 255, 255);
	plot(new PVector(componentSpace, componentHeightPosition), componentSize, componentSize, frame);
	gradient(new PVector((2 * componentSpace) + componentSize, componentHeightPosition), componentSize, componentSize, frame);
	fadeFunctionNames(new PVector((3 * componentSpace) + 2 * componentSize, componentHeightPosition), componentSize, componentSize, frame);
	popMatrix();
}

public class EasingFunction {

	float generic(String methodName, float t) {
		switch (methodName) {
			case "smoothStart2":
				return smoothStart2(t);
			case "smoothStart3":
				return smoothStart3(t);
			case "smoothStop2":
				return smoothStop2(t);
			case "smoothStop3":
				return smoothStop3(t);
			case "smoothStop4":
				return smoothStop4(t);
			case "smoothStep2":
				return smoothStep2(t);
			case "smoothStart26":
				return smoothStart26(t);
			case "arch2":
				return arch2(t);
			case "bezier3a":
				return bezier3a(t);
			case "bounceBezier3":
				return bounceBezier3(t);
			default:
				return linear(t);
		}
	}

	float linear(float t) {
		return t;
	}

	float flip(float t) {
		return 1 - t;
	}

	float scale(float scale, float t) {
		return scale * t;
	}

	float mix(float t1, float t2, float weight) {
		return (1 - weight) * t1 + weight * t2;
	}

	float bounceClampBottom(float t) {
		return abs(t);
	}

	float bounceClampTop(float t) {
		return flip(abs(flip(t)));
	}

	float bounceClampBottomTop(float t) {
		return bounceClampBottom(bounceClampTop(t));
	}

	// Normalized cubic (3rd) Bezier A, B, C, D where A start, D end, are 0 and 1 respectively
	float bezier3(float b, float c, float t) {
		float s = 1 - t;
		float t2 = t * t;
		float s2 = s * s;
		float t3 = t * t2;
		return (3.0 * b * s2 * t) + (3.0 * c * s * t2) + t3;
	}

	float smoothStep2(float t) {
		return mix(smoothStart2(t), smoothStop2(t), t);
	}

	float arch2(float t) {
		return scale(4, scale(t, flip(t)));
	}

	float smoothStart26(float t) {
		return mix(smoothStart2(t), smoothStart3(t), 0.6); // x^2.6
	}

	float smoothStart2(float t) {
		return t * t;
	}

	float smoothStart3(float t) {
		return t * t * t * t;
	}

	float smoothStop2(float t) {
		return flip(smoothStart2(flip(t))); // 1 - (1-t)^2
	}

	float smoothStop3(float t) {
		return flip(smoothStart3(flip(t)));
	}

	float smoothStop4(float t) {
		return flip(smoothStart4(flip(t)));
	}

	float bezier3a(float t) {
		return bezier3(2, -1, t);
	}

	float bounceBezier3(float t) {
		return bounceClampTop(bezier3(2.6, 0.5, t));
	}
}