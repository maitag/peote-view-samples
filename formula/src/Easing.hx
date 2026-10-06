package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;

import peote.view.*;
import peote.view.text.*;
import peote.view.intern.*;

// -------------------------------------------------

class Elem implements Element
{
	@posX
	@anim("X", "pingpong")

	// @ease("1.0 - cos((t * 3.14159265359) / 2.0)") // SINE_IN
	// @ease("sin((t * 3.14159265359) / 2.0)") // SINE_OUT
	
	@ease("mix(   (  1.0 - cos((t*2.0 * 3.14159265359) / 2.0)  )*0.5     ,    sin((  ((t-0.5)*2.0) * 3.14159265359) / 2.0) *0.5+0.5  ,    step(t, 0.5)  )") // SINE_IN_OUT
	// TODO: @ease("mix(   (  easeInQuad(t, 0.5) , easeOutExpo(t, 0.5), step(t, 0.5)  )")
	
	// BETTER: if there is no @ease then @easeIn and/or @easeOut can be used instead
	//         @easeIn("sine", 0.3) @easeOut("quad", 0.3) // only at 0.3 of time at start and end
	public var x:Int = 0;
	
	@posY  @const public var y:Int = 0;
	@sizeX @const public var width:Int = 30;
	@sizeY @const public var height:Int = 30;
	@color @const public var c:Color = 0xb95322ff;
	
	/*
	@custom
	@varying
	@anim
	@constStart(23.0)
	// @formula("sin(a)")
	// @ease("1.0 - cos((t * 3.14159265359) / 2.0)") // SINE_IN
	public var a:Int = 42;
	*/
}

// -------------------------------------------------

class Easing extends Application
{
	var peoteView:PeoteView;
	var display:Display;
	var element:Elem;
	var buffer:Buffer<Elem> = new Buffer<Elem>(100);	
	
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{	
		peoteView = new PeoteView(window);		
		display   = new Display(0,0, window.width, window.height); display.color = Color.RED1;
		peoteView.addDisplay(display);

		// titles
		var textProgram = new TextProgram({fgColor:0xaa6642ff});
		display.addProgram(textProgram);
		
		function addEaseProgram(title:String, yPos:Int, easeFunctionX:String)
		{
			textProgram.add(new Text(10, yPos - 14, title));

			var program = new Program(buffer);
			program.setFormula("posY", Util.toFloatString(yPos) );

			program.setEaseFormula("x", easeFunctionX );
			// program.removeEaseFormula("x"); // <- remove easing

			program.snapToPixel(1.0); // <- to let look the anim more smoothly
			display.addProgram(program);
		}

		var yOff:Int = 56;
		var y:Int = 20-yOff;
		addEaseProgram("SINE:", y+=yOff, Ease.In(SINE) ); // Ease.Out(SINE)
		addEaseProgram("QUAD:", y+=yOff, Ease.In(QUAD) );
		addEaseProgram("CUBIC:", y+=yOff, Ease.In(CUBIC) );
		addEaseProgram("CIRC:", y+=yOff, Ease.In(CIRC) );
		addEaseProgram("QUART:", y+=yOff, Ease.In(QUART) );
		addEaseProgram("QUINT:", y+=yOff, Ease.In(QUINT) );
		addEaseProgram("EXPO:", y+=yOff, Ease.In(EXPO) );
		addEaseProgram("BACK:", y+=yOff, Ease.In(BACK) );
		addEaseProgram("ELASTIC:", y+=yOff, Ease.In(ELASTIC) );
		addEaseProgram("BOUNCE:", y+=yOff, Ease.In(BOUNCE) );
		/*
		addEaseProgram("SINE:", y+=yOff, Ease.InOut(SINE) ); 
		addEaseProgram("QUAD:", y+=yOff, Ease.InOut(QUAD) );
		addEaseProgram("CUBIC:", y+=yOff, Ease.InOut(CUBIC) );
		addEaseProgram("CIRC:", y+=yOff, Ease.InOut(CIRC) );
		addEaseProgram("QUART:", y+=yOff, Ease.InOut(QUART) );
		addEaseProgram("QUINT:", y+=yOff, Ease.InOut(QUINT) );
		addEaseProgram("EXPO:", y+=yOff, Ease.InOut(EXPO) );
		addEaseProgram("BACK:", y+=yOff, Ease.InOut(BACK) );
		addEaseProgram("ELASTIC:", y+=yOff, Ease.InOut(ELASTIC) );
		addEaseProgram("BOUNCE:", y+=yOff, Ease.InOut(BOUNCE) );
		*/

		// testing out some easing formulas:
		// trace( '"Ease.In( CIRC, 0.25) ):"', Ease.In( CIRC, 0.25) );
		// trace( '"Ease.Out( SINE, 0.25) ):"', Ease.Out( SINE, 0.25) );
		// trace( '"Ease.InOut( SINE, 0.25, SINE, 0.3) ):"', Ease.InOut( SINE, 0.25, SINE, 0.3) );		

		element  = new Elem();
		element.animX(0, window.width-element.width);
		element.timeX(0.0, 2.0);
		buffer.addElement(element);
		
		// ---------------		
		peoteView.start();
	}
	
}