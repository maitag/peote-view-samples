package;

import haxe.CallStack;
import peote.view.Mask;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Mask;

import peote.view.element.Elem;
import peote.view.element.ElemAnim;

class StencilMask extends Application
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
		var display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		peoteView.addDisplay(display);		
		
		// program that act as a mask
		var maskBuffer  = new Buffer<ElemAnim>(4, 4, true);
		var maskProgram = new Program(maskBuffer);
		var maskElement = new ElemAnim(100, 100, 100, 100, 0, 0, 0, 0, Color.WHITE);
		
		maskElement.setPivot(50, 50);
		maskElement.animRotation(0, 180);
		maskElement.timeRotation(0, 5);
		peoteView.start();
		
		maskProgram.mask = Mask.DRAW;
		maskProgram.colorEnabled = false;
		//maskProgram.clearMask = true; // only need if there are multiple mask into queue
		
		display.addProgram(maskProgram);
		maskBuffer.addElement(maskElement);
		
		
		// program that is masked
		var buffer  = new Buffer<Elem>(4, 4, true);
		var program = new Program(buffer);
		var element = new Elem(0, 0, 100, 100, 0, 0, 0, 0, Color.BLUE);

		program.mask = Mask.USE;
		
		display.addProgram(program);
		buffer.addElement(element);
		
	}
		
}