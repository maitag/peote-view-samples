package;

import peote.view.element.Elem;
import peote.view.Program;
import haxe.Timer;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
import peote.view.Buffer;

import peote.view.text.*;

class Main extends Application {

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------

	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);


		// ------- create a new TextProgram ---------
		var textProgram = new TextProgram( {
			letterWidth:16,
			letterHeight:16,
			fgColor:Color.GREY5
		});

		display.addProgram(textProgram);

		// iterate throught all static default Color names and values
		var i:Int = 0;
		for (name in Color.defaultNames) {
			var color = Color.defaultMap.get(name);
			textProgram.add( new Text(8, 8+i*19, name) );
			textProgram.add( new Text(128, 8+i*19, "   ", { bgColor:color }) );
			textProgram.add( new Text(208, 8+i*19, color) );
			i++;
		}

		// alternatively by using a map:
		/*
		for (name => color in Color.defaultMap) {
			textProgram.add( new Text(8, 8+i*20, name) );
			textProgram.add( new Text(128, 8+i*20, "   ", {bgColor:color}) );
			textProgram.add( new Text(208, 8+i*20, color) );
			i++;
		}
		*/

		// create some elements in different colors:
		var buffer = new Buffer<Elem>(4096, 4096);
		var progam = new Program(buffer);
		display.addProgram(progam);

		var x:Int = 360;
		var y:Int = 10;
		var w:Int = 6;
		var h:Int = 6;
		var nx:Int = 20; // amount of horizontal elems
		var ny:Int = 20; // amount of vertical elems
		
		// HSV
		textProgram.add( new Text(x, y, "HSV:") );
		y+=20;
		for (j in 0...ny) {
			for (i in 0...nx) {
				buffer.addElement( new Elem(    x + i*w, y + j*h, w, h, 0.0, 0, 0, 0, Color.HSV((i+1)/nx, (j+1)/ny, 0.25) ) );
				buffer.addElement( new Elem(150+x + i*w, y + j*h, w, h, 0.0, 0, 0, 0, Color.HSV((i+1)/nx, (j+1)/ny, 0.5) ) );
				buffer.addElement( new Elem(300+x + i*w, y + j*h, w, h, 0.0, 0, 0, 0, Color.HSV((i+1)/nx, (j+1)/ny, 0.75) ) );

				buffer.addElement( new Elem(    x + i*w, 130+y + j*h, w, h, 0.0, 0, 0, 0, Color.HSV((i+1)/nx, 0.15, (j+1)/ny) ) );
				buffer.addElement( new Elem(150+x + i*w, 130+y + j*h, w, h, 0.0, 0, 0, 0, Color.HSV((i+1)/nx, 0.5, (j+1)/ny) ) );
				buffer.addElement( new Elem(300+x + i*w, 130+y + j*h, w, h, 0.0, 0, 0, 0, Color.HSV((i+1)/nx, 1.0, (j+1)/ny) ) );
			}
		}

		// HSL
		y += 280;
		textProgram.add( new Text(x, y, "HSL:") );
		y+=20;
		for (j in 0...ny) {
			for (i in 0...nx) {
				buffer.addElement( new Elem(    x + i*w, y + j*h, w, h, 0.0, 0, 0, 0, Color.HSL((i+1)/nx, (j+1)/ny, 0.25) ) );
				buffer.addElement( new Elem(150+x + i*w, y + j*h, w, h, 0.0, 0, 0, 0, Color.HSL((i+1)/nx, (j+1)/ny, 0.5) ) );
				buffer.addElement( new Elem(300+x + i*w, y + j*h, w, h, 0.0, 0, 0, 0, Color.HSL((i+1)/nx, (j+1)/ny, 0.75) ) );

				buffer.addElement( new Elem(    x + i*w, 130+y + j*h, w, h, 0.0, 0, 0, 0, Color.HSL((i+1)/nx, 0.15, (j+1)/ny) ) );
				buffer.addElement( new Elem(150+x + i*w, 130+y + j*h, w, h, 0.0, 0, 0, 0, Color.HSL((i+1)/nx, 0.5, (j+1)/ny) ) );
				buffer.addElement( new Elem(300+x + i*w, 130+y + j*h, w, h, 0.0, 0, 0, 0, Color.HSL((i+1)/nx, 1.0, (j+1)/ny) ) );
			}
		}

		// to test some of Color functions:
		/* 
		var c:Color;

		c = Color.mix(Color.RED, Color.GREEN, 0.7);
		trace("mix"+c);

		c = Color.rnd(0x440000e0, 0x550000ff);
		trace("rnd"+c);

		trace("-- HSV --");
		c = Color.HSV(0.5, 0.5, 1.0);
		trace ("rF:"+c.rF, "gF:"+c.gF, "bF:"+c.bF, "hex:"+c);
		trace ("hue:"+c.hue, "saturationHSV:"+c.saturationHSV, "valueHSV:"+c.valueHSV );

		trace("-- HSL --");
		c = Color.HSL(0.5, 1.0, 0.75);
		trace ("rF:"+c.rF, "gF:"+c.gF, "bF:"+c.bF, "hex:"+c);
		trace ("hue:"+c.hue, "saturationHSL:"+c.saturationHSL, "luminanceHSL:"+c.luminanceHSL );
		*/
	}











	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------

	// override function update(deltaTime:Int):Void {}

	// override function onPreloadComplete():Void {}
	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");
	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}
	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}
	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
}
