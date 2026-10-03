package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;

// --------------------------------------------------- custom formula for attributes
class Elem implements Element
{
	@posX @formula("x + px - sin(y*0.1)*20.0") public var x:Int=0;
	//@posX @formula("x + px") public var x:Int=0;
	@posY @constStart(0) @constEnd(500) @anim("Y","pingpong") public var y:Int=0;
	
	@sizeX @const public var w:Int=100;
	//@sizeX @const @formula("100.0 + sin(y*0.1)*40.0") public var w:Int=100;
	@sizeY @const @formula("45.0+time0*45.0") public var h:Int = 110;
	
	@rotation @const @formula("(h-45.0)*8.0") var r:Float = 30.0;
	
	@pivotX @const @formula("w") public var px:Int=50;
	@pivotY @const @formula("h-45.0") public var py:Int=50;
	
	@texX public var tx:Int = 0;
	@texX("B") public var txb:Int = 0;
	@texY @const @formula("11.0") public var ty:Int = 0;
	
	@custom public var c:Int = 0;
	@custom("seed") @varying public var s:Int = 0;
	
	static public var buffer:Buffer<Elem>;
	static public var program:Program;

	static public function init(display:Display) {
		buffer = new Buffer<Elem>(100);
		program = new Program(Elem.buffer);
		program.injectIntoVertexShader(
		"
			float simpleRandom(vec2 co, float seed){
				return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * seed);
			}		
		");
		//program.setFormula("sizeX", "45.0+time0*45.0");
		//program.setFormula("rotation", "-y");
		program.setFormula("r", "-y");
		// TODO: program.setFormula("seed", "seed * y");
		display.addProgram(program);
	}
	
	public function new(positionX:Int=0, positionY:Int=0) {
		this.x = positionX; //this.xEnd = 100;
		//this.y = positionY; this.yEnd = 500;
		this.timeYStart = 0.0; this.timeYDuration = 3.0;
		buffer.addElement(this);
	}	
}

// -------------------------------------------------------------------------------
// -------------------------------------------------------------------------------
// -------------------------------------------------------------------------------

class FormulaMix extends Application
{
	var peoteView:PeoteView;
	
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
		
		var display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		peoteView.addDisplay(display);
		
		Elem.init(display); new Elem( 0, 0);
	}
	
	// ----------- Lime events ------------------

	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		if (!peoteView.isRun) peoteView.start();
		else peoteView.stop();
	}

}
