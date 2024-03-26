package;

import haxe.CallStack;
import haxe.io.Bytes;

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
import peote.view.TextureFormat;

import utils.Loader;

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

class TextureDataPNG extends Application
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
		var display   = new Display(10, 10, 512, 512, Color.GREEN);

		peoteView.addDisplay(display);  // display to view
		
		var buffer  = new Buffer<Elem>(10);
		var program = new Program(buffer);
		
		var element = new Elem(0, 0, 512, 512);
		buffer.addElement(element);
		

		// images saved by gimp:
		// Loader.bytes("assets/suzanneGrey.png", true, function (bytes:Bytes)
		// Loader.bytes("assets/suzanneGrey16.png", true, function (bytes:Bytes)  // 16 bit per colorchannel will result here into FLOAT_R
		Loader.bytes("assets/suzanneGreyAlpha.png", true, function (bytes:Bytes)
		// Loader.bytes("assets/suzanneGreyAlpha16.png", true, function (bytes:Bytes)  // 16 bit per colorchannel will result here into FLOAT_RG
		
		// images saved by blender compositor:
		// Loader.bytes("assets/suzanneBW.png", true, function (bytes:Bytes)
		// Loader.bytes("assets/suzanneBW16.png", true, function (bytes:Bytes)  // 16 bit per colorchannel will result here into FLOAT_R
		// Loader.bytes("assets/suzanneRGB.png", true, function (bytes:Bytes)
		// Loader.bytes("assets/suzanneRGB16.png", true, function (bytes:Bytes)
		// Loader.bytes("assets/suzanneRGBA.png", true, function (bytes:Bytes)
		// Loader.bytes("assets/suzanneRGBA16.png", true, function (bytes:Bytes)
		{
			var textureData = TextureData.fromFormatPNG(bytes);

			switch(textureData.format) {
				case LUMINANCE: trace("LUMINANCE");
				case LUMINANCE_ALPHA: trace("LUMINANCE_ALPHA");
				case RGB: trace("RGB");
				case RGBA: trace("RGBA");
				case FLOAT_RGBA: trace("FLOAT_RGBA");
				case FLOAT_RGB: trace("FLOAT_RGB");
				case FLOAT_RG: trace("FLOAT_RG");
				case FLOAT_R: trace("FLOAT_R");
				default:
			}

			var texture = new Texture(textureData.width, textureData.height, 1, {format: textureData.format});
			texture.setData(textureData);
		
			program.setTexture(texture, "custom");
			//program.discardAtAlpha(0.1);
			program.blendEnabled = true;

			display.addProgram(program);  // programm to display
		});

	}
	


}
