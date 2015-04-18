package
{
	import flash.display.*;
	import flash.events.*;
	
	public class MCButton extends MovieClip
	{
		private var mc:MovieClip;
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
		
		public function goBig(e:MouseEvent):void
		{
			mc.gotoAndStop("over");
		}
		public function goHome(e:MouseEvent):void
		{
			mc.gotoAndStop("up");	
		}
		public function goDown(e:MouseEvent):void
		{
			mc.gotoAndStop("down");	
		}
		public function goDoSomething(e:MouseEvent):void
		{
			mc.gotoAndStop("up");
			dispatchEvent(new Event("mc_clicked"));
		}
		
	}
}