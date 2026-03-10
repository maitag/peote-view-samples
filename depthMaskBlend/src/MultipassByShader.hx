package;

import peote.view.DepthFunc;
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


class MultipassByShader extends Application
{
	var activeElement:ElementSimple;
	
	var element1:ElementSimple;
	var element2:ElementSimple;
	var element3:ElementSimple;
	var element4:ElementSimple;
	
	var buffer:Buffer<ElementSimple>;
	var display:Display;

	var program0:Program;
	var program1:Program;
	
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
		
		display  = new Display(0, 0, 800, 600);
		peoteView.addDisplay(display);

		buffer  = new Buffer<ElementSimple>(100);
		program0 = new Program(buffer);
		program1 = new Program(buffer);
		
		Load.image("assets/peote_tiles.png", true, function(image:Image) {
			var texture = new Texture(image.width, image.height);
			texture.tilesX = 16;
			texture.tilesY = 16;
			texture.setData(image);
			// texture.smoothExpand = true;
			program0.setTexture(texture, "tex");
			program1.setTexture(texture, "tex");			
			// zero ALPHA to FULL alpha			
			program1.setColorFormula("vec4(tex.r, tex.g, tex.b, (tex.a == 1.0) ? 0.0 : tex.a )");
		});
		
		program0.depthFunc = DepthFunc.LESS;
		program1.depthFunc = DepthFunc.LESS;

		program0.discardAtAlpha(0.95);
		program0.blendEnabled = false; // don't use alpha blending
		program0.zIndexEnabled = true; // use depth-buffer for depth-test
		

		program1.discardAtAlpha(0.0);
		program1.blendEnabled = true;  // use alpha blending
		program1.zIndexEnabled = true; // use depth-buffer for depth-test
		program1.depthMask = false; // do not write into the depth-buffer while drawing

				
		display.addProgram(program0);
		display.addProgram(program1);

		
		element1 = new ElementSimple(100, 100, 200, 200, 3); element1.z = 3;
		element2 = new ElementSimple(200, 130, 200, 200, 2); element2.z = 2;
		element3 = new ElementSimple(120, 220, 200, 200, 5); element3.z = 1;
		element4 = new ElementSimple(250, 250, 200, 200, 6); element4.z = 0;

		buffer.addElement(element1);
		buffer.addElement(element2);
		buffer.addElement(element3);
		buffer.addElement(element4);
				
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
				if (discardValue1 > 0.9) program0.discardAtAlpha(); else program0.discardAtAlpha(discardValue1);
			case KeyCode.F: 
				discardValue2+= 0.1;
				if (discardValue2 > 1.0) discardValue2 = 0.0;
				if (discardValue2 > 0.9) program1.discardAtAlpha(); else program1.discardAtAlpha(discardValue2);
			case KeyCode.X: program0.blendEnabled = !program0.blendEnabled;  trace("program0.blendEnabled", program0.blendEnabled);
			case KeyCode.Y: program1.blendEnabled = !program1.blendEnabled;  trace("program1.blendEnabled", program1.blendEnabled);
			case KeyCode.C: program0.zIndexEnabled = !program0.zIndexEnabled; trace("program0.zIndexEnabled", program0.zIndexEnabled);
			case KeyCode.V: program1.zIndexEnabled = !program1.zIndexEnabled; trace("program1.zIndexEnabled", program1.zIndexEnabled);
			case KeyCode.Q: program0.depthMask = !program0.depthMask; trace("program0.depthMask", program0.depthMask);
			case KeyCode.W: program1.depthMask = !program1.depthMask; trace("program1.depthMask", program1.depthMask);
			case KeyCode.NUMBER_1: activeElement = element1;
			case KeyCode.NUMBER_2: activeElement = element2;
			case KeyCode.NUMBER_3: activeElement = element3;
			case KeyCode.NUMBER_4: activeElement = element4;
			case KeyCode.LEFT:  activeElement.x -= 10;
			case KeyCode.RIGHT: activeElement.x += 10;
			case KeyCode.UP:    activeElement.y -= 10;
			case KeyCode.DOWN:  activeElement.y += 10;
			case KeyCode.NUMPAD_PLUS: activeElement.z += 1; trace(activeElement.z);
			case KeyCode.NUMPAD_MINUS:activeElement.z -= 1; trace(activeElement.z);
			default:
		}

		buffer.update();
	}
		
}
