package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;
import peote.view.Element;

import utils.Loader;

class Elem implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color("colred")   public var c0:Color = 0xff0000ff;
	@color("colgreen") public var c1:Color = 0x00ff00ff;
	@color("colblue")  public var c2:Color = 0x0000ffff;
		
	//@texUnit() public var unit:Int;  // unit for all other Layers (max 255)
	@texUnit("base") public var unitColor:Int=0;  //  unit for "base" Layer only
	@texUnit("alpha","mask") public var unitAlphaMask:Int;  //  unit for "alpha" and "mask" Layers only

	// what texture-slot to use
	@texSlot("base") public var slot:Int;  // unsigned 2 bytes integer


	// tiles the slot or manual texture-coordinate into sub-slots
	@texTile public var tile:Int;  // for all other Layers
	@texTile("base", "mask") public var tileBaseMask:Int;  // for "alpha" and "mask" Layers only

	// formula (glsl) to combine colors with textures
	// default is alpha-over:  mix( mix( c0*t0, c1*t1 , (c1*t1).a ) ...)) * cn1 + cn2 * cn3 + cn4 * ...
	// var DEFAULT_COLOR_FORMULA = "alpha * (color * base + shift)";

	// give texture, texturelayer- or custom-to-use identifiers a default value ( if there is no texture set for )
	
	var DEFAULT_FORMULA_VARS = [
		"base"  => 0xff0000ff,
		"alpha" => 0x00ff00ff,
		"mask"  => 0x0000ffff,
		"own"  => 0x0000ffff,
	];
	
	var OPTIONS = { blend:true };
		
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100)
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}
}

class MultiTextures extends Application
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	
	var texture0:Texture;
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
		display   = new Display(10, 10, window.width - 20, window.height - 20, Color.YELLOW);
		peoteView.addDisplay(display);  // display to peoteView
		
		buffer  = new Buffer<Elem>(100);
		program = new Program(buffer);
		element  = new Elem(0,0, 512, 512);
		buffer.addElement(element);     // element to buffer
		display.addProgram(program);    // programm to display
		
		texture0 = new Texture(512, 512);
		texture1 = new Texture(512, 512);
		texture2 = new Texture(512, 512);
		
		program.setMultiTexture([texture0, texture1, texture2], Elem.TEXTURE_base, false);
		//program.setMultiTexture([texture0, texture1],           Elem.TEXTURE_alpha, false);
		program.setTexture(texture1, Elem.TEXTURE_mask, false);
		program.setTexture(texture2, "custom", false);
		/*
		// compositing multiple textures per fragment-shader
		program.setColorFormula(
			'custom + custom.a * color * mask * (shift+base) * ${Elem.TEXTURE_alpha}',
			[
				"custom"   => 0x44444444,
				"base"   => 0x11111111,
				Elem.TEXTURE_alpha => 0x22222222,
				Elem.TEXTURE_mask => 0x33333333,
			]
		);
		*/
		
		program.updateTextures(); // updates gl-textures and rebuilding shadercode
				
		loadImage(texture0, "assets/peote_tiles.png");
		loadImage(texture1, "assets/peote_tiles_bunnys.png");
		//loadImage(texture2, "assets/peote_font.png");
		
	}
	
	public function loadImage(texture:Texture, filename:String, slot:Int=0):Void {
		Loader.image(filename, true, function(image:Image) {
			texture.setData(image, slot);
		});		
	}
	
	// ----------- Lime events ------------------

	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element.x += 100;
		buffer.updateElement(element);		
	}

	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.U:
				trace("switch texture unit");
				element.unitColor = 1; buffer.updateElement(element);
			case KeyCode.R:
				trace("replace texture "); // TODO
				//program.replaceTexture(texture0, texture1);
			case KeyCode.NUMBER_1:
				loadImage(texture0, "assets/test0.png");
			case KeyCode.NUMBER_2:
				loadImage(texture0, "assets/peote_tiles.png");
			case KeyCode.NUMBER_3:
				loadImage(texture1, "assets/wabbit_alpha.png");// TODO: BUG after activating new imagebuffer from second texture
			case KeyCode.NUMBER_4:
				loadImage(texture1, "assets/peote_tiles_bunnys.png");// TODO: BUG after activating new imagebuffer from second texture
			default:
		}
	}

}