package;

import peote.view.TextureFormat;
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
import peote.view.Element;
import peote.view.TextureConfig;
import peote.view.TextureCache;

import utils.Loader;

class Elem implements Element
{
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	@texW public var tw:Int=100;
	@texH public var th:Int=100;	
	@texUnit public var unit:Int=0;
	@texSlot public var slot:Int = 0;
	
	//var OPTIONS = { blend:false };
		
	public function new(positionX:Int, positionY:Int, width:Int, height:Int, texW:Int, texH:Int, unit:Int, slot:Int)
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.tw = texW;
		this.th = texH;
		this.unit = unit;
		this.slot = slot;
	}
}

class TextureCaching extends Application
{
	var peoteView:PeoteView;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	
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
		display   = new Display(0,0, window.width, window.height, Color.GREEN);
		peoteView.addDisplay(display);
		
		buffer  = new Buffer<Elem>(100);
		program = new Program(buffer);
		display.addProgram(program);		
		
		// var textureConfig:TextureConfig = { maxTextureSize:peoteView.gl.getParameter(peoteView.gl.MAX_TEXTURE_SIZE), powerOfTwo: true };
		var textureConfig:TextureConfig = { maxTextureSize:4096, powerOfTwo: false };

		var textureCache = new TextureCache(
			[
				{ width:64,   height:64,   slots:8  , config:textureConfig },
				{ width:256,  height:256,  slots:4  , config:textureConfig },
				{ width:512,  height:512,  slots:8  , config:textureConfig },
				{ width:1024, height:1024, slots:16 , config:textureConfig },
				{ width:1920, height:1280, slots:8  , config:textureConfig },
			]
		);
		
		Loader.corsServer = "cors-anywhere.herokuapp.com";
		
		program.setMultiTexture(textureCache.textures, "custom");
		
		Loader.imageArray([
			"assets/test0.png",
			"assets/test1.png",
			"assets/peote_tiles.png",
			"assets/test2.png",
			"assets/wabbit_alpha.png",
			"assets/test3.png",
			"http://maitag.de/semmi/blender/hxMeat.jpg",
			"http://maitag.de/semmi/blender/mandelbulb/mandelbulb_volume_1001f.blend.png",
			"http://maitag.de/semmi/blender/lyapunov/example_images/displace-FOSSIL-13.blend.png",
			"https://upload.wikimedia.org/wikipedia/commons/8/80/Salvador_Dali_The_Rainbow_1972.jpg",
			"http://maitag.de/semmi/blender/spheresfractal_07_lights.png",
			"http://maitag.de/semmi/blender/lyapunov/example_images/displace-FOSSIL-19.blend.png",
			"http://maitag.de/semmi/blender/lyapunov/example_images/volume-fake_07.blend.png",
			"http://maitag.de/semmi/blender/lyapunov/example_images/microcycles/lyap-displace-test_19.blend.png",
			"http://maitag.de/semmi/blender/lyapunov/example_images/microcycles/lyap-displace-test_07.blend.png",
			"http://maitag.de/semmi/blender/mandelbulb/mandelverse_10.blend.jpg",
			"http://maitag.de/semmi/blender/mandelbulb/mandelverse_11.blend.jpg",
			"http://maitag.de/semmi/blender/mandelbulb/mandelverse_12.blend.jpg",
			"http://maitag.de/semmi/blender/mandelbulb/mandelverse_13.blend.jpg",
			], //true,
			function(index:Int, loaded:Int, size:Int) {
				// trace(' File number $index progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},
			function(loaded:Int, size:Int) {
				// trace(' Progress overall: ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},
			function(index:Int, image:Image) { // after every single image is loaded
				trace('File number $index loaded completely.');
				var p = textureCache.addData(image);
				if (p!=null) {
					trace( '${image.width}x${image.height}', "texture-unit:"+p.unit,"texture-slot"+p.slot);
					var x = index % 8;
					var y = Std.int(index / 8);
					buffer.addElement(new Elem(x*100, y*100, 100, 100, image.width, image.height, p.unit, p.slot));
				}
				else throw("Cache is full");
			},
			function(images:Array<Image>) { // after all images is loaded
				trace(' --- all images loaded ---');
			}
		);
		
	}
	
	// ----------- Lime events ------------------
	
	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		display.zoom *= 2;	
	}

	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.NUMBER_1: // todo: testing here to add/remove images from textureCache
			case KeyCode.NUMBER_2:
			default:
		}
	}

}
