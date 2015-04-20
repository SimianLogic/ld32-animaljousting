package
{
	public class JoustCardDraw extends JoustCardBase
	{
		
		public var mc:CardDraw;
		
		
		public function JoustCardDraw(name:String, how_many:int)
		{
			hasCardDraw = true;
			cardsToDraw = how_many;
			
			super(name);
			
			mc = new CardDraw();
			mc.draw.text = how_many.toString();
			
			addChild(mc);
		}
		
		override public function copy():JoustCardBase
		{
			return new JoustCardDraw(cardName, cardsToDraw);
		}
	}
}