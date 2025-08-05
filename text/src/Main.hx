package;

import haxe.Timer;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

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
			letterSpace:4,
			lineSpace:4
		});

		display.addProgram(textProgram);

		textProgram.add(new Text(0, 0, "\\o/", {letterWidth: 8, letterHeight: 8}));
		
		// create a text-instance
		var text = new Text(4, 100, "PUSH THE\n BUTTON!\n\nhello world\nyjiJ;Z_", {
			// fgColor:Color.GREEN,
			letterWidth: 32*2,
			letterHeight: 32*2
		});
		textProgram.add(text);


		// trace("this should be null:",text.lineSpace);
		
		
		var text1:Text = textProgram.create(200, 50, "hello world\nHALLO WELT", {
			bgColor:Color.BLUE2,
			fgColor:Color.WHITE,
			letterWidth: 32,
			letterHeight: 24,
			letterSpace:0,
			lineSpace:0,
			zIndex: 1
		});
		

		haxe.Timer.delay( ()->{
			textProgram.remove(text);
		}, 1000);

		haxe.Timer.delay( ()->{
			text.x += 50;
			text.fgColor = Color.ORANGE;
			textProgram.add(text);
		}, 2000);

		haxe.Timer.delay( ()->{
			text.text = "HOHO";
			textProgram.updateText(text);
			
			textProgram.remove(text1);
		}, 4000);

		haxe.Timer.delay( ()->{
			text.x += 100;
			text.y = 50;
			text.letterHeight = 160;
			text.letterSpace = 20;
			text.lineSpace = 10;
			text.text = "winter\nis\ncomming";
			text.bgColor = Color.GREY2;
			textProgram.updateText(text);

			textProgram.add(text1);
		}, 5000);

		// move text1 behind
		haxe.Timer.delay( ()->{
			text1.zIndex = -1;
			textProgram.updateText(text1);
		}, 6000);

		haxe.Timer.delay( ()->{
			textProgram.remove(text);
		}, 7000);



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
