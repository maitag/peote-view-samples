package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;

import peote.view.*;
import peote.view.intern.Ease;

// -------------------------------------------------

class Elem implements Element
{
	@posX
	@anim("X", "pingpong")

	// @ease("1.0 - cos((t * 3.14159265359) / 2.0)") // SINE_IN
	// TODO: @ease("easeInSine(t)")
	// @ease("sin((t * 3.14159265359) / 2.0)") // SINE_OUT
	// TODO: @ease("easeOutSine(t)")
	
	@ease("mix(   (  1.0 - cos((t*2.0 * 3.14159265359) / 2.0)  )*0.5     ,    sin((  ((t-0.5)*2.0) * 3.14159265359) / 2.0) *0.5+0.5  ,    step(t, 0.5)  )") // SINE_IN_OUT
	// TODO: @ease("mix(   (  easeInQuad(t, 0.5) , easeOutExpo(t, 0.5), step(t, 0.5)  )")
	
	// BETTER: if there is no @ease then @easeIn and/or @easeOut can be used instead
	//         @easeIn("sine", 0.3) @easeOut("quad", 0.3) // only at 0.3 of time at start and end

	public var x:Int = 0;
	

	// @posY public var y:Int = 0;


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
	var element:Elem;
	var buffer:Buffer<Elem>;
	
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
		buffer = new Buffer<Elem>(100);	
		var display   = new Display(0,0, window.width, window.height); display.color = Color.GREEN1;
		var program   = new Program(buffer);		
		peoteView.addDisplay(display);  // display to peoteView
		display.addProgram(program);    // programm to display


		// testing easing formulas:

		trace( '"Ease.In ( SINE , 0.25) ):"', Ease.In( SINE, 0.25) );
		trace( '"Ease.In( CIRC, 0.25) ):"', Ease.In( CIRC, 0.25) );
		trace( '"Ease.Out( SINE, 0.25) ):"', Ease.Out( SINE, 0.25) );
		trace( '"Ease.InOut( SINE, 0.25, SINE, 0.3) ):"', Ease.InOut( SINE, 0.25, SINE, 0.3) );
		
		program.setEaseFormula("x", Ease.In(SINE) );
		// program.setEaseFormula("x", Ease.In(CIRC) );
		// program.setEaseFormula("x", Ease.Out(SINE) );
		// program.setEaseFormula("x", Ease.Out(SINE, 0.3) );
		// program.setEaseFormula("x", Ease.InOut( SINE, SINE) );
		// program.setEaseFormula("x", Ease.InOut( SINE, 0.3, SINE) );
		// program.setEaseFormula("x", Ease.InOut( SINE, 0.2, SINE, 0.2) );
		// program.setEaseFormula("x", Ease.In( SINE, 0.5 ));
		// program.setEaseFormula("x", Ease.InOut(QUAD, 0.3, CIRC, 0.3) );

		


		
		// program.setEaseFormula("x", "1.0-t"); // <- simple revert the time
		// program.removeEaseFormula("x"); // <- remove easing
		
		// program.setEaseFormula("a", "1.0-t");
		// program.removeEaseFormula("a");
	
		// to let look the anim more smoothly:
		program.snapToPixel(1.0);

		element  = new Elem();
		element.animX(0, 700);
		element.timeX(0.0, 2.0);

		buffer.addElement(element);
		
		// --------------------------
		
		peoteView.start();
	}
	
}