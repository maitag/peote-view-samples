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


class DepthFuncReverse extends Application
{
	var peoteView:PeoteView;

	var activeElement:ElementSimple;
	
	var element0:ElementSimple;
	var element1:ElementSimple;
	var element2:ElementSimple;
	var element3:ElementSimple;
	var element4:ElementSimple;
	
	var display0:Display;
	var display1:Display;
	
	var buffer:Buffer<ElementSimple>;
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
		peoteView = new PeoteView(window);
		
		display0  = new Display(0, 0, 800, 300, 0x2222aa99);
		display1  = new Display(0, 200, 800, 300, 0xaa222299);
		peoteView.addDisplay(display0);
		peoteView.addDisplay(display1);

		buffer  = new Buffer<ElementSimple>(100);
		program0 = new Program(buffer);
		program1 = new Program(buffer);

		display0.addProgram(program0);
		display1.addProgram(program1);

		Load.image("assets/peote_tiles.png", true, function(image:Image) {
			var texture = new Texture(image.width, image.height);
			texture.tilesX = 16;
			texture.tilesY = 16;
			texture.setData(image);
			// texture.smoothExpand = true;
			program0.setTexture(texture);
			program1.setTexture(texture);
		});

		element0 = new ElementSimple(100, 50, 200, 200, 3); element0.z = -2;
		element1 = new ElementSimple(200, 50, 200, 200, 4); element1.z = -1;
		element2 = new ElementSimple(300, 50, 200, 200, 5); element2.z = 0;
		element3 = new ElementSimple(400, 50, 200, 200, 6); element3.z = 1;
		element4 = new ElementSimple(500, 50, 200, 200, 7); element4.z = 2;

		buffer.addElement(element0);
		buffer.addElement(element1);
		buffer.addElement(element2);
		buffer.addElement(element3);
		buffer.addElement(element4);

		activeElement = element0;
		

		display0.backgroundZ = 0;
		display1.backgroundZ = 0;

		program0.zIndexEnabled = true;
		program1.zIndexEnabled = true;

	}
	
	// ----------- Lime events ------------------
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.Q:
				display0.backgroundDepth = !display0.backgroundDepth;
				trace("display0.backgroundDepth", display0.backgroundDepth);
			case KeyCode.W:
				display0.backgroundAlpha = !display0.backgroundAlpha;
				trace("display0.backgroundAlpha", display0.backgroundAlpha);
			case KeyCode.E:
				display0.backgroundEnabled = !display0.backgroundEnabled;
				trace("display0.backgroundEnabled", display0.backgroundEnabled);
			case KeyCode.R:
				display0.backgroundZ++;
				trace("display0.backgroundZ", display0.backgroundZ);
			case KeyCode.T:
				display0.backgroundZ--;
				trace("display0.backgroundZ", display0.backgroundZ);
			case KeyCode.Z:
				display0.clearDepth = !display0.clearDepth;
				trace("display0.clearDepth", display0.clearDepth);
			case KeyCode.U: 
				if (display0.clearDepthIndex != -ElementSimple.MAX_ZINDEX) {
					display0.clearDepthIndex = -ElementSimple.MAX_ZINDEX;
					trace("display0.clearDepthIndex", display0.clearDepthIndex);
				}
				else {
					peoteView.clearDepthIndex = ElementSimple.MAX_ZINDEX;
					trace("peoteView clearDepthIndex", peoteView.clearDepthIndex);
				}
	
			case KeyCode.A:
				display1.backgroundDepth = !display1.backgroundDepth;
				trace("display1.backgroundDepth", display1.backgroundDepth);
			case KeyCode.S:
				display1.backgroundAlpha = !display1.backgroundAlpha;
				trace("display1.backgroundAlpha", display1.backgroundAlpha);
			case KeyCode.D:
				display1.backgroundEnabled = !display1.backgroundEnabled;
				trace("display1.backgroundEnabled", display1.backgroundEnabled);
			case KeyCode.F:
				display1.backgroundZ++;
				trace("display1.backgroundZ", display1.backgroundZ);
			case KeyCode.G:
				display1.backgroundZ--;
				trace("display1.backgroundZ", display1.backgroundZ);
			case KeyCode.H:
				display1.clearDepth = !display1.clearDepth;
				trace("display1.clearDepth", display1.clearDepth);
			case KeyCode.J: 
				if (display1.clearDepthIndex != -ElementSimple.MAX_ZINDEX) {
					display1.clearDepthIndex = -ElementSimple.MAX_ZINDEX;
					trace("display0.clearDepthIndex", display1.clearDepthIndex);
				}
				else {
					display1.clearDepthIndex = ElementSimple.MAX_ZINDEX;
					trace("display1.clearDepthIndex", display1.clearDepthIndex);
				}
	
		
			case KeyCode.V:
				program0.zIndexEnabled = !program0.zIndexEnabled;
				trace("program0.zIndexEnabled", program0.zIndexEnabled);
			case KeyCode.B:
				program1.zIndexEnabled = !program1.zIndexEnabled;
				trace("program1.zIndexEnabled", program1.zIndexEnabled);

			case KeyCode.N:
				program0.clearDepth = !program0.clearDepth;
				trace("program0.clearDepth", program0.clearDepth);
			case KeyCode.M:
				program1.clearDepth = !program1.clearDepth;
				trace("program1.clearDepth", program1.clearDepth);

			case KeyCode.Y: 
				if (program0.depthFunc != DepthFunc.LESS_EQUAL) {
					program0.depthFunc = display0.backgroundDepthFunc = DepthFunc.LESS_EQUAL;
					program0.clearDepthIndex = -ElementSimple.MAX_ZINDEX;
					trace("program0 LESS_EQUAL");
				}
				else {
					program0.depthFunc = DepthFunc.GREATER_EQUAL;
					program0.clearDepthIndex = ElementSimple.MAX_ZINDEX;
					trace("program0 GREATER_EQUAL");
				}

			case KeyCode.X: 
				if (program1.depthFunc != DepthFunc.LESS_EQUAL) {
					program1.depthFunc = DepthFunc.LESS_EQUAL;
					program1.clearDepthIndex = -ElementSimple.MAX_ZINDEX;
					trace("program1 LESS_EQUAL");
				}
				else {
					program1.depthFunc = DepthFunc.GREATER_EQUAL;
					program1.clearDepthIndex = ElementSimple.MAX_ZINDEX;
					trace("program1 GREATER_EQUAL");
				}

			case KeyCode.C: 
				if (peoteView.clearDepthIndex != -ElementSimple.MAX_ZINDEX) {
					peoteView.clearDepthIndex = -ElementSimple.MAX_ZINDEX;
					trace("peoteView clearDepthIndex", peoteView.clearDepthIndex);
				}
				else {
					peoteView.clearDepthIndex = ElementSimple.MAX_ZINDEX;
					trace("peoteView clearDepthIndex", peoteView.clearDepthIndex);
				}
	
			case KeyCode.P: 
				peoteView.clearDepth = !peoteView.clearDepth;
				trace("peoteView.clearDepth", peoteView.clearDepth);
	
			case KeyCode.NUMBER_1: activeElement = element0;
			case KeyCode.NUMBER_2: activeElement = element1;
			case KeyCode.NUMBER_3: activeElement = element2;
			case KeyCode.NUMBER_4: activeElement = element3;
			case KeyCode.NUMBER_5: activeElement = element4;
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
