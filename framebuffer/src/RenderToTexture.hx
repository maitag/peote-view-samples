package;

import haxe.Timer;
import haxe.CallStack;
import lime.ui.MouseWheelMode;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;
import peote.view.Element;

class Elem implements Element
{
	@posX @anim("PosSize", "pingpong") public var x:Int = 0;	
	@posY @anim("PosSize", "pingpong") public var y:Int = 0;
		
	@sizeX @anim("PosSize", "pingpong") public var w:Int = 100;	
	@sizeY @anim("PosSize", "pingpong") public var h:Int = 100;
	
	@zIndex public var z:Int = 0;	

	@rotation @anim("Rotation", "constant") public var r:Float;
	
	@pivotX @set("Pivot") public var px:Int;
	@pivotY @set("Pivot") public var py:Int;
	
	@texSlot public var slot:Int = 0;
	
	@color public var c:Color = 0xffff00ff;
		
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=64, height:Int=64, c:Int=0xFFFF00FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}
}

class RenderToTexture extends Application
{
	var peoteView:PeoteView;
	
	var displayFrom1:Display;
	var displayFrom2:Display;

	var texture:Texture; // texture that will be used from both
	
	var displayTo:Display;
	
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

		// ------------------- upper left display to renderToTexture -------------------
		
		displayFrom1 = new Display(0, 0, 256, 256, Color.GREEN);
		peoteView.addDisplay(displayFrom1);
		
		var bufferFrom  = new Buffer<Elem>(100);
		var programFrom = new Program(bufferFrom);
		
		displayFrom1.addProgram(programFrom);
		
		// rotation Elements
		var elementFrom = new Elem(128, 128, 32, 80, Color.RED);
		elementFrom.setPivot(16, 106 + 16);
		elementFrom.animRotation(0, 360);
		elementFrom.timeRotation(0, 2);
		elementFrom.z = 1;
		bufferFrom.addElement(elementFrom);
		
		var elemBG = new Elem(64-45, 64-45, 128+90, 128+90, Color.YELLOW);
		elemBG.z = 0;
		bufferFrom.addElement(elemBG);
		
		
		// ------------ bottom left display to renderToTexture -------------
		
		displayFrom2 = new Display(0, 260, 256, 256, 0xdd3344aa);
		displayFrom2.backgroundAlpha = true;
		peoteView.addDisplay(displayFrom2);
		
		var bufferFrom  = new Buffer<Elem>(100);
		var programFrom = new Program(bufferFrom);
		
		displayFrom2.addProgram(programFrom);
		
		// rotation Elements
		var elementFrom = new Elem(128, 128, 32, 80, Color.BLUE);
		elementFrom.setPivot(16, 106 + 16);
		elementFrom.animRotation(0, 360);
		elementFrom.timeRotation(0, 2);
		elementFrom.z = 1;
		bufferFrom.addElement(elementFrom);
		
		var elemBG = new Elem(64-45, 64-45, 128+90, 128+90, Color.CYAN);
		elemBG.z = 0;
		bufferFrom.addElement(elemBG);
		
		// --------------- texture with 2 slots to render into --------------
		
		texture = new Texture(256, 256 , 2, {mipmap:true, smoothShrink: true, smoothMipmap: true, smoothExpand: true}); // 2 Slots
		
		// ----- bind texture to the Displays that should render into -------
		
		// Attention, peoteView is need here if display is not added already (to renderlist or to framebuffer-renderlist)
		
		//displayFrom1.setFramebuffer(texture, peoteView);
		//peoteView.setFramebuffer(displayFrom1, texture); // <- alternatively
		
		displayFrom1.setFramebuffer(texture);
		displayFrom2.setFramebuffer(texture);

		
		// to unbind (is need before using this texture with different gl-context!)
		
		// displayFrom1.removeFramebuffer();
		// displayFrom2.removeFramebuffer();
		
		
		// ------- display with program that is using this texture -----------
		
		displayTo = new Display(260, 0, 512, 512, Color.BLUE);
		peoteView.addDisplay(displayTo);
		
		var bufferTo  = new Buffer<Elem>(100);
		var programTo = new Program(bufferTo);
		
		programTo.setTexture(texture, "renderFrom");
		programTo.setColorFormula('renderFrom');
		programTo.blendEnabled = true;
		programTo.discardAtAlpha(null);
		displayTo.addProgram(programTo);
		
		// element in middle is using texture-slot 0
		var elementTo = new Elem(64, 64, 384, 384);
		elementTo.slot = 0;
		elementTo.animPosSize(256-8, 256-8, 16, 16, 0, 0, 512, 512);
		elementTo.timePosSize(0, 16);
		bufferTo.addElement(elementTo);
		
		// rotating elements is using texture-slot 1
		for (i in 0...8) {
			var elementToRot = new Elem(256, 256, 64, 64, Color.CYAN);
			elementToRot.slot = 1;
			elementToRot.setPivot(32, 256 - 16);
			elementToRot.animRotation(0, 360);
			elementToRot.timeRotation(i, 8);
			bufferTo.addElement(elementToRot);
		}
		
		// ------------  RenderToTexture  ---------------
		
		peoteView.renderToTexture(displayFrom1, 0); // render one frame into slot 0
		peoteView.renderToTexture(displayFrom2, 1); // render one frame into slot 1
		
		// the blue one is updating the framebuffer-texture by a Timer (so into sync with animation)
		displayFrom2.framebufferTextureSlot = 1; // render into slot 1 by default
		var timer = new Timer(500);
		timer.run = function() {
			peoteView.renderToTexture(displayFrom2); // <- renders new frame every 500 millisecond 
		}
		
		// the yellow one is updating the framebuffer-texture automatically
		displayFrom1.renderFramebufferEnabled = false;
		
		displayFrom1.renderFramebufferSkipFrames = 2; // at 1/3 framerate (after render a frame skip 2)
		
		// add the display also to the hidden RenderList for updating the Framebuffer Textures
		peoteView.addFramebufferDisplay(displayFrom1);
		
		peoteView.start();
	}
	
	// ----------- Lime events ------------------

	override function onMouseMove (x:Float, y:Float):Void
	{
		displayFrom1.xOffset = -displayFrom1.width  * (0.5 - x/window.width);
		displayFrom1.yOffset = -displayFrom1.height * (0.5 - y/window.height);
	}
	override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode)
	{
		if (dy > 0)	displayFrom1.zoom += 0.1;
		else if (dy < 0) displayFrom1.zoom -= 0.1;
	}
	
	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		displayFrom1.renderFramebufferEnabled = !displayFrom1.renderFramebufferEnabled;
	}
	
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
					if (modifier.shiftKey) peoteView.zoom+=0.01;
					else displayFrom1.zoom+=0.1;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.shiftKey) peoteView.zoom-=0.01;
					else displayFrom1.zoom -= 0.1;
			case KeyCode.UP: displayFrom1.yOffset -= (modifier.shiftKey) ? 8 : 1;
			case KeyCode.DOWN: displayFrom1.yOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.RIGHT: displayFrom1.xOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.LEFT: displayFrom1.xOffset -= (modifier.shiftKey) ? 8 : 1;
			case KeyCode.SPACE:
				if (displayFrom1.framebufferTextureSlot == 0) {					
					displayFrom1.framebufferTextureSlot = 1;
					displayFrom2.framebufferTextureSlot = 0;
				} 
				else {
					displayFrom1.framebufferTextureSlot = 0;
					displayFrom2.framebufferTextureSlot = 1;
				}
				if (!displayFrom1.renderFramebufferEnabled) peoteView.renderToTexture(displayFrom1); // render one frame into the new slot
				
			default:
		}
	}

}
