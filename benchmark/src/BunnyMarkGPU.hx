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
import peote.view.Texture;
import peote.view.text.TextProgram;
import peote.view.text.Text;

import peote.view.Element;

import utils.Loader;

class Bunny implements Element
{
	@sizeX @const public var w:Int=26;
	@sizeY @const public var h:Int=37;
	
	//@posX @anim("X","pingpong") @formula("xStart+(uResolution.x-w-xStart)*time0") public var x:Int;
	//@posY @anim("Y","pingpong") @formula("yStart+(uResolution.y-h-yStart)*time1*time1") public var y:Int;
	@posX @constStart(0) @constEnd(800) @anim("X","pingpong") @formula("xStart+(xEnd-w-xStart)*time0") public var x:Int;
	@posY @constStart(0) @constEnd(600) @anim("Y","pingpong") @formula("yStart+(yEnd-h-yStart)*time1*time1") public var y:Int;
	//@posX @constStart(0) @constEnd(800) @anim("X","pingpong") @formula("xStart+(uResolution.x-w-xStart)*time0") public var x:Int;
	//@posY @constStart(0) @constEnd(600) @anim("Y","pingpong") @formula("yStart+(uResolution.y-h-yStart)*time1*time1") public var y:Int;
	
	public function new(x:Int, y:Int, currTime:Float) {
		//this.x = x;
		//this.y = y;
		this.timeX(currTime, 4+Math.random()*15);
		//this.animX();
		this.timeY(currTime, 0.5+Math.random()*2);
		//this.animY(0, 563);
	}
}



class BunnyMarkGPU extends Application
{
	var peoteView:PeoteView;
	var buffer:Buffer<Bunny>;
	
	var bunnyCount:Int = 1000;
	var bunnyToAdd:Int =  100;
	
	var fpsDisplay:FpsDisplay;
	var textProgram:TextProgram;
	var bunniesAmountText:Text;
	
	var addingBunnies = false;
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
		peoteView = new PeoteView(window);
		
		#if bunnies 
		bunnyCount = Std.parseInt (haxe.macro.Compiler.getDefine ("bunnies"));
		#end

		#if bunniesToAdd
		bunnyToAdd = Std.parseInt (haxe.macro.Compiler.getDefine ("bunniesToAdd"));
		#end

		buffer = new Buffer<Bunny>(bunnyCount+65536, 65536); // automatic grow buffersize about 4096
		
		//var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		var display = new Display(0, 0, 800, 600, Color.GREEN);
		
		var program = new Program(buffer);
		
		Loader.image ("assets/wabbit_alpha.png", true, function (image:Image)
		{			
			var texture = new Texture(image.width, image.height);
			
			texture.setData(image);
			
			program.addTexture(texture, "custom");
					
			//program.setVertexFloatPrecision("low");
			//program.setFragmentFloatPrecision("low");
						
			display.addProgram(program);    // programm to display
			peoteView.addDisplay(display);  // display to peoteView
			
			for (i in 0...bunnyCount) addBunny (0,0);

			// -------- bunny counter ----------
			textProgram = new TextProgram({fgColor:Color.YELLOW, bgColor:Color.RED1, letterWidth: 12,	letterHeight: 12});
			textProgram.add(new Text(300, 0, "Bunnies: "));
			bunniesAmountText = new Text(300+9*12, 0, Std.string(bunnyCount));
			textProgram.add(bunniesAmountText);
			display.addProgram(textProgram);
		
			// -------- FpsDisplay ----------
			fpsDisplay = new FpsDisplay(0, 0, 12, Color.YELLOW, Color.RED1);
			peoteView.addDisplay(fpsDisplay);
			
			isStart = true;
			peoteView.start(); // need for GPU-animation
		});
	}
		
	private function addBunny(x:Int, y:Int):Void
	{
		var bunny = new Bunny(x, y, peoteView.time);
		buffer.addElement(bunny);
	}
	
	// ----------- Lime events ------------------

	override function update(deltaTime:Int):Void 
	{
		if (!isStart) return;
		if (addingBunnies)
		{			
			for (i in 0...bunnyToAdd) addBunny (0,0);
			bunniesAmountText.text = Std.string(buffer.length);
			textProgram.updateText(bunniesAmountText);
		}		
	}

	override function render(_):Void 
	{
		if (isStart) fpsDisplay.step();
	}
	
	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		addingBunnies = true;
	}

	override function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{
		addingBunnies = false;
	}
	
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.SPACE:if (peoteView.isRun) peoteView.stop() else peoteView.start();
			default:
		}
	}

}
