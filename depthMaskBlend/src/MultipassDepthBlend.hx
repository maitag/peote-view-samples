package;

import peote.view.BlendFactor;
import peote.view.BlendFunc;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.graphics.Image;
import lime.math.Rectangle;
import lime.math.Vector2;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;
import peote.view.Element;
import peote.view.Load;

class ElementSimple implements Element
{
	@posX public var x:Int; // signed 2 bytes integer
	@posY public var y:Int; // signed 2 bytes integer
	
	@sizeX public var w:Int; // signed 2 bytes integer
	@sizeY public var h:Int; // signed 2 bytes integer
	
	@zIndex public var z:Int;

	@texTile public var t:Int = 0;
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, tile:Int)
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.t = tile;
	}
}


class MultipassDepthBlend extends Application
{
	var activeElement:ElementSimple;
	
	var element1:ElementSimple;
	var element2:ElementSimple;
	var element3:ElementSimple;
	
	var buffer:Buffer<ElementSimple>;
	var display:Display;

	var program0:Program;
	var program1:Program;
	var program2:Program;
	
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
		
		display  = new Display(0, 0, 800, 600, Color.BLUE2);
		peoteView.addDisplay(display);

		buffer  = new Buffer<ElementSimple>(100);
		program0 = new Program(buffer);
		program1 = new Program(buffer);
		program2 = new Program(buffer);
		
		Load.image("assets/peote_tiles.png", true, function(image:Image) {
			var texture = new Texture(image.width, image.height);
			texture.tilesX = 16;
			texture.tilesY = 16;
			texture.setData(image);
			// texture.smoothExpand = true;
			program0.setTexture(texture);
			program1.setTexture(texture);
			program2.setTexture(texture);
		});
		
		program0.discardAtAlpha(0.8);
		program0.zIndexEnabled = true;
		program0.blendEnabled = false;

		program1.discardAtAlpha(0);
		program1.clearDepth = true;
		program1.zIndexEnabled = true;
		program1.colorEnabled = false;
		// program1.enableColorChannel(false,false,false,true);
		program1.blendEnabled = false;
		
		program2.discardAtAlpha();
		program2.zIndexEnabled = true;
		program2.depthMask = false;
		program2.blendEnabled = true;
		
				
		display.addProgram(program0);
		display.addProgram(program1);
		display.addProgram(program2);

		
		element1 = new ElementSimple(100, 100, 200, 200, 3); element1.z = 2;
		element2 = new ElementSimple(200, 130, 200, 200, 2); element2.z = 1;
		element3 = new ElementSimple(150, 200, 200, 200, 5); element3.z = 0;

		buffer.addElement(element1);
		buffer.addElement(element2);
		buffer.addElement(element3);
				
		activeElement = element1;
	}
	
	// ----------- Lime events ------------------
		
	var discardValue1 = 0.0;
	var discardValue2 = 0.0;
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.D: 
				discardValue1+= 0.1;
				if (discardValue1 > 1.0) discardValue1 = 0.0;
				if (discardValue1 > 0.9) program1.discardAtAlpha(); else program1.discardAtAlpha(discardValue1);
			case KeyCode.F: 
				discardValue2+= 0.1;
				if (discardValue2 > 1.0) discardValue2 = 0.0;
				if (discardValue2 > 0.9) program2.discardAtAlpha(); else program2.discardAtAlpha(discardValue2);
			case KeyCode.X: program1.blendEnabled = !program1.blendEnabled;  trace("program1.blendEnabled", program1.blendEnabled);
			case KeyCode.Y: program2.blendEnabled = !program2.blendEnabled;  trace("program2.blendEnabled", program2.blendEnabled);
			case KeyCode.C: program1.zIndexEnabled = !program1.zIndexEnabled; trace("program1.zIndexEnabled", program1.zIndexEnabled);
			case KeyCode.V: program2.zIndexEnabled = !program2.zIndexEnabled; trace("program2.zIndexEnabled", program2.zIndexEnabled);
			case KeyCode.Q: program1.depthMask = !program1.depthMask; trace("program1.depthMask", program1.depthMask);
			case KeyCode.W: program2.depthMask = !program2.depthMask; trace("program2.depthMask", program2.depthMask);
			case KeyCode.NUMBER_1: activeElement = element1;
			case KeyCode.NUMBER_2: activeElement = element2;
			case KeyCode.NUMBER_3: activeElement = element3;
			case KeyCode.LEFT:  activeElement.x -= 10;
			case KeyCode.RIGHT: activeElement.x += 10;
			case KeyCode.UP:    activeElement.y -= 10;
			case KeyCode.DOWN:  activeElement.y += 10;
			case KeyCode.NUMPAD_PLUS: activeElement.z += 1; trace(activeElement.z);
			case KeyCode.NUMPAD_MINUS:activeElement.z -= 1; trace(activeElement.z);
			case KeyCode.N: program1.colorEnabled = ! program1.colorEnabled;
			case KeyCode.M: program2.colorEnabled = ! program2.colorEnabled;
			default:
		}

		buffer.update();
	}
		
}
