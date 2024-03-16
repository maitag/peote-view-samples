package;

import haxe.Timer;
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
	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}
}

class TextureMipmapFilter extends Application
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	var display = new Array<Display>();
	var program = new Array<Program>();
	var texture = new Array<Texture>();
	var timer:Timer;
	
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
		
		display[0] = new Display(0, 0, 300, 300);
		display[1] = new Display(300, 0, 300, 300);
		display[2] = new Display(0, 300, 300, 300);
		display[3] = new Display(300, 300, 300, 300);
		
		display[0].xOffset = display[0].yOffset = 150;
		display[1].xOffset = display[1].yOffset = 150;
		display[2].xOffset = display[2].yOffset = 150;
		display[3].xOffset = display[3].yOffset = 150;
		
		peoteView.addDisplay(display[0]);
		peoteView.addDisplay(display[1]);
		peoteView.addDisplay(display[2]);
		peoteView.addDisplay(display[3]);
		
		buffer  = new Buffer<Elem>(100);
		element  = new Elem(-256, -256, 512, 512);
		buffer.addElement(element);
				
		program[0] = new Program(buffer);
		program[1] = new Program(buffer);
		program[2] = new Program(buffer);
		program[3] = new Program(buffer);
		
		display[0].addProgram(program[0]);
		display[1].addProgram(program[1]);
		display[2].addProgram(program[2]);
		display[3].addProgram(program[3]);

		texture[0] = new Texture(512, 512, { smoothExpand:true });
		texture[1] = new Texture(512, 512, { smoothShrink:true });
		texture[2] = new Texture(512, 512, { mipmap:true });
		texture[3] = new Texture(512, 512, { mipmap:true, smoothShrink:true, smoothMipmap:true });
		
		Loader.image("assets/peote_font.png", true, function (image:Image) {
			texture[0].setData(image);
			texture[1].setData(image);
			texture[2].setData(image);
			texture[3].setData(image);
			
			program[0].setTexture(texture[0], "custom");
			program[1].setTexture(texture[1], "custom");
			program[2].setTexture(texture[2], "custom");
			program[3].setTexture(texture[3], "custom");
			
			program[1].setActiveTextureGlIndex(texture[1], 1);
			program[2].setActiveTextureGlIndex(texture[2], 2);
			program[3].setActiveTextureGlIndex(texture[3], 3);
			
			timer = new Timer(40);
			zoomIn();
		});
	}
	

	public function zoomIn() {
		var fz:Float = 0.1;		
		timer.run = function() {
			if (fz < 2.0) fz *= 1.01; else zoomOut();
			display[0].zoom = display[1].zoom = display[2].zoom = display[3].zoom = fz;
		}
	}
	
	public function zoomOut() {
		var fz:Float = 2.0;
		timer.run = function() {
			if (fz > 0.1) fz /= 1.01; else zoomIn();
			display[0].zoom = display[1].zoom = display[2].zoom = display[3].zoom = fz;
		}
	}
	
	// ----------- Lime events ------------------
	
	var isStop = false;
	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		if (!isStop) { timer.stop(); isStop = true; }
		else { timer = new Timer(40); zoomIn(); isStop = false; }
	}

	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		timer.stop();
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
				display[0].zoom *= 1.1;
				display[1].zoom *= 1.1;
				display[2].zoom *= 1.1;
				display[3].zoom *= 1.1;
			case KeyCode.NUMPAD_MINUS:
				display[0].zoom /= 1.1;
				display[1].zoom /= 1.1;
				display[2].zoom /= 1.1;
				display[3].zoom /= 1.1;
			default:
		}
	}

}