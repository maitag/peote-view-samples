package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Element;
import peote.view.Color;
import peote.view.Texture;
import peote.view.TextureData;

class Elem implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	//var OPTIONS = { texRepeatX:true, texRepeatY:true, blend:true };
	
	public function new(x:Int=0, y:Int=0, w:Int=100, h:Int=100)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}

class TextureDataInOut extends Application
{	
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
		var peoteView = new PeoteView(window);
		var display   = new Display(10, 10, 512, 512, Color.GREY3);

		peoteView.addDisplay(display);  // display to view
		
		var buffer  = new Buffer<Elem>(10);
		var program = new Program(buffer);
		
		var element = new Elem(0, 0, 512, 512);
		buffer.addElement(element);
		
		
		var textureData = new TextureData(512, 512);

		// draw something rectangle inside
		for (y in 0...128) {
			for (x in 0...256) {
				textureData.setColor(x,y, Color.YELLOW);
				// textureData.setPixelRGBA(x,y, Color.YELLOW);
			}	
		}

		var texture = new Texture(512, 512);
		texture.setData(textureData);
		
		program.setTexture(texture, "custom");
		//program.discardAtAlpha(0.1);
		//program.alphaEnabled = true;
			
		display.addProgram(program);  // programm to display
	}
	


}
