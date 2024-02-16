package;

import haxe.CallStack;
import haxe.Timer;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;

import peote.view.element.Elem;

class Multibuffer extends Application
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
		
		var displayLeft  = new Display(10, 10, 280, 280);
		displayLeft.color = Color.BLUE;
		
		var displayRight = new Display(300, 10, 280, 280);
		displayRight.color = Color.GREEN;
		
		var bufferLeft  = new Buffer<Elem>(100);
		var bufferRight = new Buffer<Elem>(100);

		var programLeft  = new Program(bufferLeft);
		var programRight = new Program(bufferRight);
		
		displayLeft.addProgram(programLeft);
		displayRight.addProgram(programRight);
		
		peoteView.addDisplay(displayLeft);
		peoteView.addDisplay(displayRight);		
		
		var elementLeft  = new Elem(10, 10, 100, 100, 0, 0, 0, 0, Color.RED);
		bufferLeft.addElement(elementLeft);

		var elementRight  = new Elem(10, 10, 100, 100, 0, 0, 0, 0, Color.RED);
		bufferRight.addElement(elementRight);			
			
		Timer.delay(function() { 
			bufferLeft.addElement(new Elem(10, 120, 100, 100, 0, 0, 0, 0, Color.RED));
		}, 1000);
		Timer.delay(function() { 
			bufferRight.addElement(new Elem(10, 120, 100, 100, 0, 0, 0, 0, Color.RED));
		}, 2000);
		
	}

}