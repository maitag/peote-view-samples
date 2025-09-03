package;

import haxe.ds.Vector;
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
import peote.view.Load;
import peote.view.text.TextProgram;
import peote.view.text.Text;

import peote.view.Element;

class Bunny implements Element
{
	@sizeX @const public var w:Int=26;
	@sizeY @const public var h:Int=37;
	
	@posX public var x:Float; // using 32 bit Float for glBuffer
	@posY public var y:Float;
	/*
	@posX public var xi:Int;  // using 16 bit Integer for glBuffer
	@posY public var yi:Int;
	
	public var x(default, set):Float=0;
	inline function set_x(a):Float {
		xi = Std.int(x);
		return x=a;
	}
	
	public var y(default, set):Float=0;
	inline function set_y(a):Float {
		yi = Std.int(y);
		return y=a;
	}
	*/
	
	public var speedX:Float;
	public var speedY:Float;
}



class BunnyMarkMulti extends Application
{
	var bunnies:Array<Bunny>;
	var buffers:Vector<Buffer<Bunny>>;
	var textures:Vector<Texture>;
	
	var peoteView:PeoteView;
	
	var gravity:Float;
	var minX:Int;
	var minY:Int;
	var maxX:Int;
	var maxY:Int;
	
	var programCount:Int = 1000;
	var textureCount:Int = 32;
	var bunnyCount:Int = 300;
	
	var fpsDisplay:FpsDisplay;
	var textProgram:TextProgram;
	var bunniesAmountText:Text;

	var isStart:Bool = false;
	
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
		#if programs
		programCount = Std.parseInt (haxe.macro.Compiler.getDefine ("programs"));
		#end
		trace("Programs:", programCount);

		#if textures
		textureCount = Std.parseInt (haxe.macro.Compiler.getDefine ("textures"));
		#end
		trace("Textures:", textureCount);

		#if bunniesPerProgram
		bunnyCount = Std.parseInt (haxe.macro.Compiler.getDefine ("bunniesPerProgram"));
		#end
		trace("bunniesPerProgram:", bunnyCount);

		minX = 0;
		maxX = window.width;
		minY = 0;
		maxY = window.height;
		gravity = 0.5;
		
		bunnies = new Array ();
		peoteView = new PeoteView(window); // at now this should stay first ( to initialize PeoteGL from gl-context! )

		Load.image ("assets/wabbit_alpha.png", true, onImageLoad);
	}

	private function onImageLoad(image:Image)
	{
		// create textures
		textures = new Vector(textureCount);
		for (t in 0...textureCount) {
			var texture = new Texture(image.width, image.height);
			texture.setData(image);
			textures.set(t, texture);
		}

		// create buffers
		buffers = new Vector(programCount);
		var display = new Display(0, 0, maxX, maxY, Color.GREEN);

		var t:Int = 0;
		for (i in 0...programCount) {
			var buffer = new Buffer<Bunny>(bunnyCount);
			buffers.set(i, buffer);
			
			var program = new Program(buffer); //Sprite buffer

			program.addTexture(textures.get(t), "custom"); //Sets image for the sprites

			t = (t+1) % textureCount;
			
			//program.setVertexFloatPrecision("low");
			//program.setFragmentFloatPrecision("low");

			display.addProgram(program);    // program to display
		}

		peoteView.addDisplay(display);  // display to peoteView

		// adding bunnies
		for (i in 0...programCount)
			for (_ in 0...bunnyCount) {
				var bunny = new Bunny();
				bunny.x = 0;
				bunny.y = 0;
				bunny.speedX = Math.random () * 5;
				bunny.speedY = (Math.random () * 5) - 2.5;
				bunnies.push(bunny);
				buffers.get(i).addElement(bunny);
			}

		// -------- bunny counter ----------
		textProgram = new TextProgram({fgColor:Color.YELLOW, bgColor:Color.RED1, letterWidth: 12,	letterHeight: 12});
		textProgram.add(new Text(300, 0, "Bunnies: "));
		bunniesAmountText = new Text(300+9*12, 0, Std.string(programCount*bunnyCount));
		textProgram.add(bunniesAmountText);
		display.addProgram(textProgram);
	
		// -------- FpsDisplay ----------
		fpsDisplay = new FpsDisplay(0, 0, 12, Color.YELLOW, Color.RED1);
		peoteView.addDisplay(fpsDisplay);

		isStart = true;
	}
			
	// ----------- Lime events ------------------

	override function update(deltaTime:Int):Void 
	{
		if (!isStart) return;
		
		for (bunny in bunnies)
		{
			bunny.x += bunny.speedX;
			bunny.y += bunny.speedY;
			bunny.speedY += gravity;
			
			if (bunny.x > maxX) 
			{
				bunny.speedX *= -1;
				bunny.x = maxX;
			} 
			else if (bunny.x < minX)
			{
				bunny.speedX *= -1;
				bunny.x = minX;
			}
			
			if (bunny.y > maxY)
			{
				bunny.speedY *= -0.8;
				bunny.y = maxY;
				
				if (Math.random () > 0.5)
				{
					bunny.speedY -= 3 + Math.random() * 4;
				}
				
			}
			else if (bunny.y < minY)
			{
				bunny.speedY = 0;
				bunny.y = minY;
			}
		}
				
		for (i in 0...programCount) buffers.get(i).update();			
	}

	override function render(_):Void 
	{
		if (isStart) fpsDisplay.step();
	}
	
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.SPACE:isStart = !isStart;
			default:
		}
	}

}

