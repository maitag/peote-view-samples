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
import peote.view.Element;
import peote.view.Texture;

class Elem implements Element
{
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;
	
	@sizeX public var w:Int = 100;
	@sizeY public var h:Int = 100;
	
	@color public var color:Color = 0xff0000ff;
		
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, color:Int=0xff0000ff )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.color = color;
	}
	
	var OPTIONS = { picking:true };
}



class GLPickingAndFBO extends Application
{
	var peoteView:PeoteView;

	var elementPickFBO = new Array<Elem>();	
	var bufferPickFBO:Buffer<Elem>;
	var displayPickFBO:Display;
	var programPickFBO:Program;
	var texturePickFBO:Texture; // texture that will be rendered into
	var isAddDisplay:Bool = false;

	var element = new Array<Elem>();	
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
		
		displayPickFBO = new Display(0, 0,  window.width, window.height);		
		
		bufferPickFBO = new Buffer<Elem>(10);
		
		elementPickFBO[0] = new Elem( 0,   0,   400, 400, Color.RED);
		elementPickFBO[1] = new Elem( 100, 200, 400, 400, Color.YELLOW);
		
		bufferPickFBO.addElement(elementPickFBO[0]);
		bufferPickFBO.addElement(elementPickFBO[1]);	
		
		programPickFBO = new Program(bufferPickFBO);
		displayPickFBO.addProgram(programPickFBO);
		
		
		// ----- create and bind texture to the Displays that have to render into -------		
		texturePickFBO = new Texture(200, 200);
		displayPickFBO.setFramebuffer(texturePickFBO, peoteView);
		
		// peoteView.addDisplay(displayPickFBO); isAddDisplay = true;
		peoteView.addFramebufferDisplay(displayPickFBO); // to render content each frame
		
		
		// ----------------------------------------------------------------------------
		// create display what using the texture where displayPickFBO is rendering into
		// ----------------------------------------------------------------------------

		display = new Display(0, 0,  window.width, window.height);		
		peoteView.addDisplay(display);
		
		buffer = new Buffer<Elem>(10);
		
		element[0] = new Elem( 600, 0, 200, 200, Color.GREEN);
			
		buffer.addElement(element[0]);
		
		program = new Program(buffer);
		program.setTexture(texturePickFBO, "renderFrom");
		program.setColorFormula('renderFrom');
		program.blendEnabled = true;
		program.discardAtAlpha(null);

		display.addProgram(program);
		
	}
	
	// ----------- Lime events ------------------
	
	override function onMouseDown(x:Float, y:Float, button:MouseButton):Void
	{
		var pickedElement = peoteView.getElementAt(x, y, displayPickFBO, programPickFBO);
		trace(pickedElement);
		if (pickedElement >= 0) {
			var elem = bufferPickFBO.getElement(pickedElement);
			elem.color = Color.random();
			elem.color.alpha = 255;
			bufferPickFBO.updateElement(elem);
		}
	}
	
	override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.H: displayPickFBO.isVisible = !displayPickFBO.isVisible;
			case KeyCode.F: displayPickFBO.renderFramebufferEnabled = !displayPickFBO.renderFramebufferEnabled;
			case KeyCode.SPACE: 
				if (isAddDisplay) peoteView.removeDisplay(displayPickFBO); else peoteView.addDisplay(displayPickFBO);
				isAddDisplay = !isAddDisplay;
			default:
		}
		
	}
	
}