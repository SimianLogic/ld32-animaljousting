package
{
	import com.eclecticdesignstudio.motion.Actuate;
	
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	
	[SWF(width="1024", height="768")]
	public class AnimalJousting extends Sprite
	{
		
		public var gameplay:UIGameplay;
		
		public var hand1:MCButton;
		public var hand2:MCButton;
		public var hand3:MCButton;
		public var hand4:MCButton;
		public var hand5:MCButton;
		
		public var startingDeck:Array = [];
		public var deck:Array = [];
		
		//1-indexed
		public var playerHands:Array = [null, [],[],[],[]];
		
		public static var STARTING_HAND_SIZE:int = 3;
		
		public function AnimalJousting()
		{
			startingDeck = deck.concat(JoustCardWeapon.all, JoustCardMount.all, JoustCardCharacter.all, [JoustCardWeaponOrCharacter.Cactus, JoustCardWeaponOrCharacter.Pug, JoustCardMountCharacter.Horse, JoustCardWeaponOrMount.PogoStick]);
			//working copy
			
			deck = startingDeck.concat();
			for each(var card:Object in startingDeck)
			{
				trace(card);
				(card as JoustCardBase).faceDown();
			}
			
			gameplay = new UIGameplay();
			addChild(gameplay);
			
			hand1 = new MCButton(gameplay.hand1);
			hand2 = new MCButton(gameplay.hand2);
			hand3 = new MCButton(gameplay.hand3);
			hand4 = new MCButton(gameplay.hand4);
			hand5 = new MCButton(gameplay.hand5);
			
			
			var delay:int = 0;
			for(var i:int = 0; i < STARTING_HAND_SIZE; i++)
			{
				if(delay > 0)
				{
					setTimeout(function():void{
						dealCardToPlayer();	
					}, delay);
				}else{
					dealCardToPlayer();	
				}
				delay += 1000;
			}
			
			gameplay.deckPile.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				dealCardToPlayer();
			});
		}
		
		public function playerCardDealt(index:int):void
		{
			trace("FINISHED " + index);
			
			var card:JoustCardBase = playerHands[1][index-1] as JoustCardBase;
			
			card.rotation = 0;
			card.faceUp();
			
			if(index < 6)
			{
				card.x = 0;
				card.y = 0;
				card.scaleX = 1;
				card.scaleY = 1;
				
				gameplay["hand" + index].holder.addChild(card);
			}
			
		}
		
		public function dealCardToPlayer():void
		{
			if(deck.length == 0)
			{
				trace("OUT OF CARDS");
				return;
			}
			
			var which:int = Math.floor(Math.random() * deck.length);
			var card:JoustCardBase = deck.splice(which, 1)[0];
			
			var index:int = playerHands[1].length + 1;
			playerHands[1].push(card);
			
			var target_x:Number;
			var target_y:Number;
			var target_rotation:Number;
			var target_duration:Number = 1.0;
						
			if(index < 6)
			{
				target_x = this["hand" + index].x;
				target_y = this["hand" + index].y;
				trace("GOTO hand" + index + "     " + target_x + "," + target_y);
				target_duration = 1.0;
				target_rotation = 180.0;
			}else{
				target_x = gameplay.deckPile.x;
				target_y = gameplay.deckPile.y;
				target_duration = 0.0;	
				target_rotation = 0;
			}
			
			addChild(card);
			card.x = gameplay.deckPile.x;
			card.y = gameplay.deckPile.y;
			card.scaleX = gameplay.hand1.scaleX;
			card.scaleY = gameplay.hand1.scaleY;
			
			Actuate.tween(card, target_duration, { 
				x:target_x,
				y:target_y,
				rotation:target_rotation
			}).onComplete (playerCardDealt,index);
		}
		
	}
}