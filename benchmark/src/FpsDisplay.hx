package;

import haxe.Timer;
import peote.view.text.TextProgram;
import peote.view.text.Text;
import peote.view.*;


class FpsDisplay extends Display
{
	var textProgram:TextProgram;
	var fpsText:Text;
	
	public function new(x:Int, y:Int, size:Int, label:String, fgColor:Color = Color.YELLOW, bgColor:Color = 0)
	{
		super(x, y, size*(label.length+3), size);

		textProgram = new TextProgram({
			fgColor:fgColor,
			bgColor:bgColor,
			letterSpace:0,
			letterWidth: size,
			letterHeight: size
		});

		textProgram.add(new Text(0, 0, label));

		// create a text-instance
		fpsText = new Text(size*4, 0, "   ",);
		textProgram.add(fpsText);
		
		addProgram(textProgram);
	}

	var lastTime:Float = 0;
	var frameCount:Int = 0;
	// var fps:Int = 0;

	public inline function step()
	{
		frameCount++;
		var t = Timer.stamp() - lastTime;
		if (t >= 1.0) {
			// fps = Std.int(frameCount);
			fpsText.text = ((frameCount<10) ? "  " : ( (frameCount<100) ? " " : "" )) + frameCount;
			textProgram.updateText(fpsText);
			lastTime += t;
			frameCount = 0;
		}
	}

}
