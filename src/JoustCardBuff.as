package
{
	public class JoustCardBuff extends JoustCardBase
	{
		
		public var mc:CardBuff;
		
		public function JoustCardBuff(name:String, power:int)
		{
			hasBuff = true;
			attackBuff = power;
			
			super(name);
						
			mc = new CardBuff();
			mc.damage.text = "+" + power;
			
			addChild(mc);
			
		}
		
		override public function copy():JoustCardBase
		{
			return new JoustCardBuff(cardName, attackBuff);
		}
	}
}