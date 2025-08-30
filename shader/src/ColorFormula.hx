package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Program;
import peote.view.Texture;
import peote.view.Color;

import utils.Loader;

class Elem implements Element
{
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color("tint") public var tint:Color = 0xffffffff;
	
	// give texture, texturelayer- or custom-to-use identifiers a default value ( if there is no texture set for )	
	var DEFAULT_FORMULA_VARS = [
		"layer1"  => 0xff0000ff,
		"layer2"  => 0x00ff00ff,
	];
	
	// formula (glsl) to combine colors and textures
	var DEFAULT_COLOR_FORMULA = "tint * mix( layer1, layer2, vTexCoord.x )";
	
	var OPTIONS = { blend:true };
		
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100)
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}
}

class ColorFormula extends Application
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	
	var texture1:Texture;
	var texture2:Texture;
				
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		
		// create display
		display   = new Display(0, 0, window.width, window.height, Color.GREY1);
		
		// add display to peoteView
		peoteView.addDisplay(display);
		
		// create new buffer and add one element
		buffer  = new Buffer<Elem>(1);
		element  = new Elem(200, 150, 400, 300);		
		buffer.addElement(element);

		// create program of buffer
		program = new Program(buffer);

		// inject a glsl function for blur effect
		program.injectIntoFragmentShader("
			float normpdf(in float x, in float sigma) { return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma; }
			
			vec4 blur( int textureID ) {
				const int mSize = 11;				
				const int kSize = (mSize-1)/2;
				float kernel[mSize];				
				float sigma = 7.0;
				float Z = 0.0;				
				for (int j = 0; j <= kSize; ++j) kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
				for (int j = 0; j <  mSize; ++j) Z += kernel[j];				
				vec3 final_colour = vec3(0.0);				
				for (int i = -kSize; i <= kSize; ++i) {
					for (int j = -kSize; j <= kSize; ++j) {
						final_colour += kernel[kSize+j] * kernel[kSize+i] *
							getTextureColor(  textureID, vTexCoord + vec2(float(i), float(j)) / getTextureResolution(textureID)  ).rgb;
					}
				}				
				return vec4(final_colour / (Z * Z), 1.0);
			}"
		,false // no uTime
		,true // no update() to rebuild shader at this time is need
		);

		// add programm to display
		display.addProgram(program);
		
		// load images into textures (async)
		Loader.image("assets/test1.png", true, (img:Image) -> texture1 = Texture.fromData(img));
		Loader.image("assets/test2.png", true, (img:Image) -> texture2 = Texture.fromData(img));
	
		
	}
		
	// ----------- Lime events ------------------

	override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void
	{	
		switch (keyCode)
		{
			case KeyCode.NUMBER_1:
				if (! program.hasTexture(texture1, Elem.TEXTURE_layer1)) {
					trace("add texture1");
					program.setTexture(texture1, Elem.TEXTURE_layer1);
				}
				else {
					trace("remove texture1");
					program.removeTexture(texture1, Elem.TEXTURE_layer1);
					// program.removeTexture(texture1);
				}

			// -------------------

			case KeyCode.NUMBER_2:
				if (! program.hasTexture(texture2, Elem.TEXTURE_layer2)) {
					trace("add texture2");
					program.setTexture(texture2, Elem.TEXTURE_layer2);
				}
				else {
					trace("remove texture2");
					program.removeTexture(texture2, Elem.TEXTURE_layer2);
					// program.removeTexture(texture2);
				}

			// -------------------

			case KeyCode.ESCAPE:
				trace("setColorFormula -> DEFAULT");
				program.setColorFormula();

			// -------------------

			case KeyCode.B:
				trace("setColorFormula -> blur of image 1");
				if (program.hasTexture(texture1, Elem.TEXTURE_layer1)) {
					program.setColorFormula('blur(${Elem.TEXTURE_ID_layer1})');
				}
			
			// --- TODO ---				
			// case KeyCode.R:
				// trace("replace texture ");
				// program.replaceTexture(texture0, texture1);
				
			default:
		}
		
		// trace("---------------------------------");
		// trace(program.hasTexture(texture1, Elem.TEXTURE_layer1), program.hasTexture(texture2, Elem.TEXTURE_layer2));
		// trace(program.hasTexture(texture1), program.hasTexture(texture2));
	}

}