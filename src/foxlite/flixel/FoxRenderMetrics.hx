package foxlite.flixel;

import StringTools;
import flixel.group.FlxSpriteGroup;
#if dde
import deepend.game.text.DeependBitmapText;
#else
import flixel.text.FlxText;
#end
import foxlite.renderer.FoxRenderer;
import haxe.Timer;

class FoxRenderMetrics extends FlxSpriteGroup {
	public var extraInfo:String = "";

	var HISTORY = 32;
	var cpuDeltas:Array<Float> = [];
	var gpuDeltas:Array<Float> = [];

	var cpuDeltaIdx:Int = 0;
	var gpuDeltaIdx:Int = 0;

	var cpuLastTime:Float = 0;
	var gpuLastTime:Float = 0;
	
	#if dde
	var text:DeependBitmapText = new DeependBitmapText(0, 0, "", 16, "consolas");
	#else
	var text:FlxText = new FlxText();
	#end

	public function new(deltaHistory:Int=32) {
		#if !dde
		text.fieldHeight = 16;
		text.size = 16;
		#end
		super();

		HISTORY = deltaHistory;
		cpuDeltas.resize(HISTORY);
		gpuDeltas.resize(HISTORY);

		for (i in 0...HISTORY) {
			cpuDeltas[i] = 0;
			gpuDeltas[i] = 0;
		}

		add(text);

		if(!FoxRenderer.onPreDraw.has(displayInfo)) FoxRenderer.onPreDraw.add(displayInfo);
	}

	public override function update(elapsed) {
		super.update(elapsed);
		var cpuTime = Timer.stamp();
		cpuDeltas[cpuDeltaIdx] = Math.round(1 / (cpuTime - cpuLastTime));
		cpuDeltaIdx = (cpuDeltaIdx + 1) % HISTORY;
		cpuLastTime = cpuTime;
	}

	public override function draw() {
		super.draw();
		var gpuTime = Timer.stamp();
		gpuDeltas[gpuDeltaIdx] = Math.round(1 / (gpuTime - gpuLastTime));
		gpuDeltaIdx = (gpuDeltaIdx + 1) % HISTORY;
		gpuLastTime = gpuTime;
	}

	public function displayInfo() {

		var cpuFPS:Float = 0;
		var gpuFPS:Float = 0;

		for(i in 0...HISTORY) {
			cpuFPS += cpuDeltas[i];
			gpuFPS += gpuDeltas[i];
		}
		cpuFPS /= HISTORY;
		gpuFPS /= HISTORY;
		
		var version = FoxRenderer.getGLVersion();
		var ctx = FoxRenderer.renderContext;
		if(ctx == "") ctx = "(UNINITIALIZED)";
		
		var instBuf = new StringBuf();
		if (FoxRenderer.renderedInstances > 0)
		{
			instBuf.add('(x');
			instBuf.add(FoxRenderer.renderedInstances);
			instBuf.add(' instance');
			if (FoxRenderer.renderedInstances != 1)
				instBuf.add('s');
			instBuf.add(')');
		}

		var buf = new StringBuf();
		buf.add('-- FoxLite '); 	buf.add(FoxRenderer.BUILD_NAME); 				buf.add(' v'); 		buf.add(FoxRenderer.VERSION); 	buf.add('--\n');
		buf.add('renderContext: '); buf.add(ctx); buf.add(' '); 					buf.add(version); 	buf.add('\n');
		buf.add('drawCalls: '); 	buf.add(FoxRenderer.drawCalls); 				buf.add('\n');
		buf.add('triangles: '); 	buf.add(Std.int(FoxRenderer.verticesDrawn/3)); 	buf.add(' '); 		buf.add(instBuf.toString()); 	buf.add('\n');
		buf.add('stateSwitches: '); buf.add(FoxRenderer.stateSwitches); 			buf.add('\n');
		buf.add('Allocations: '); 	buf.add(FoxRenderer.allocationsThisFrame); 		buf.add('\n');
		buf.add('frameCount: '); 	buf.add(FoxRenderer.frameCount); 				buf.add('\n');
		buf.add('-------------\n');
		buf.add('CPU FPS: '); 		buf.add(Math.round(cpuFPS)); 					buf.add('\n');
		buf.add('GPU FPS: '); 		buf.add(Math.round(gpuFPS)); 					buf.add('\n');
		buf.add('-------------\n');
		buf.add(extraInfo);

		text.text = buf.toString();
	}

	public override function destroy() {
		FoxRenderer.onPreDraw.remove(displayInfo);
		text.destroy();
		super.destroy();
	}
}
