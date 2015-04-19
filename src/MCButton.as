package
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.getTimer;
	
	public class MCButton extends MovieClip
	{
		private var mc:MovieClip;
		
		public var isEnabled:Boolean = true;
		
		public function MCButton(mc:MovieClip)
		{
			super();
			
			this.mc  = mc;
			mc.stop();
			this.x = mc.x;
			this.y = mc.y;
			mc.x = 0;
			mc.y = 0;
			
			mc.parent.addChildAt(this, mc.parent.getChildIndex(mc));
			addChild(mc);
			
			addEventListener(MouseEvent.MOUSE_OVER, goBig);
			addEventListener(MouseEvent.MOUSE_OUT, goHome);
			addEventListener(MouseEvent.MOUSE_DOWN, goDown);
			addEventListener(MouseEvent.MOUSE_UP, goDoSomething);
		}
		
		public var isDown:Boolean = false;
		
		public function goBig(e:MouseEvent):void
		{
			if(!isEnabled) return;
			if(isDown) return;
			
			mc.gotoAndStop("over");
			
			parent.setChildIndex(this, parent.numChildren-1);
		}
		public function goHome(e:MouseEvent):void
		{
			if(!isEnabled) return;
			isDown = false;
			mc.gotoAndStop("up");	
		}
		public function goDown(e:MouseEvent):void
		{
			if(!isEnabled) return;
			isDown = true;
			mc.gotoAndStop("up");	
			dispatchEvent(new Event("mc_down"));
		}
		public function goDoSomething(e:MouseEvent):void
		{
			if(!isEnabled) return;
			isDown = false;
			
			mc.gotoAndStop("up");
			dispatchEvent(new Event("mc_clicked"));
		}
		
	}
}