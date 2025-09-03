package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
import peote.view.Load;

import peote.view.text.*;

class LoadText extends Application {

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
		var display = new Display(0, 0, window.width, window.height, Color.BLUE3);
		peoteView.addDisplay(display);


		// ------- to customize the bitmap-font -------
		// var bmFont = new BMFontData(BMFont.data); // this is the default full ascii one 

		// the BMFontSimple contains lesser letter ranges:
		// var bmFontSimple = new BMFontData(BMFontSimple.data, BMFontSimple.ranges);

		// ------- create a new TextProgram ---------
		// var textProgram = new TextProgram(bmFontSimple, {
		var textProgram = new TextProgram( {
			fgColor:Color.YELLOW,
			bgColor:Color.RED2,
			letterWidth:16,
			letterHeight:16,
			letterSpace:0,
			lineSpace:0
		});

		display.addProgram(textProgram);

		// look at here how to use the `Load` tool:
		// http://maitag.de/semmi/haxelime/peote-view-api/peote/view/Load.html

		Load.text
		(			
			// filename
			"assets/testANSI.txt",
			
			// debug
			// true,
							
			// onLoad
			// do always use the onLoad handler or a `null` here,
			// because the onError have same type and all callback params are optional 
			function(s:String) {
				trace("onload", s);
				// create a text-instance
				var text = new Text(50, 30, s);
				textProgram.add(text);
			},

			// onError
			function(error:String) { trace ('ERROR: $error'); },
			
		);
		

		Load.textArray
		(			
			// filenames
			[ "assets/testANSI.txt", "assets/testUTF8.txt" ],
			
			// debug
			// true,
			
			// onLoad
			// do always use the onLoad handler or a `null` here,
			// because the onError have same type and all callback params are optional 
			function(i, s:String) {
				trace("onload", i, s);
				// create a text-instance
				var text = new Text(50 + 200*i, 100, s);
				textProgram.add(text);
			},

			// onError
			function(i:Int, error:String) { trace ('ERROR: $i, $error'); },
			
		);




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
