package
{
	import flash.display.*;
	
	[SWF(width="1024", height="768")]
	public class AnimalJousting extends Sprite
	{
		
		public var gameplay:GameplayUI;
		
		public var hand1:MCButton;
		public var hand2:MCButton;
		public var hand3:MCButton;
		public var hand4:MCButton;
		public var hand5:MCButton;
		
		public function AnimalJousting()
		{
			gameplay = new GameplayUI();
			addChild(gameplay);
			
			
			var card1:CardWeapon = new CardWeapon();
			var card2:CardCharacter = new CardCharacter();
			var card3:CardMount = new CardMount();
			
			gameplay.hand1.holder.addChild(card1);
			gameplay.hand2.holder.addChild(card2);
			gameplay.hand3.holder.addChild(card3);
			
			
			hand1 = new MCButton(gameplay.hand1);
			hand2 = new MCButton(gameplay.hand2);
			hand3 = new MCButton(gameplay.hand3);
			hand4 = new MCButton(gameplay.hand4);
			hand5 = new MCButton(gameplay.hand5);
			
		}
	}
}