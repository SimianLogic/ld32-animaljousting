package
{
	import com.eclecticdesignstudio.motion.Actuate;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
		public var discard:Array = [];
		
		//1-indexed
		public var playerHands:Array = [null, [],[],[],[]];
		public var playerScores:Array = [null, 0, 0, 0, 0];
		
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
			
			hand1.isEnabled = false;
			hand2.isEnabled = false;
			hand3.isEnabled = false;
			hand4.isEnabled = false;
			hand5.isEnabled = false;
			
			hand1.addEventListener("mc_down", handleCardDown);
			hand2.addEventListener("mc_down", handleCardDown);
			hand3.addEventListener("mc_down", handleCardDown);
			hand4.addEventListener("mc_down", handleCardDown);
			hand5.addEventListener("mc_down", handleCardDown);
			
			gameplay.handSize.text = "0";
			gameplay.victoryPoints.text = "0";
			
			gameplay.dropWeapon.gotoAndStop(1);
			gameplay.dropCharacter.gotoAndStop(1);
			gameplay.dropMount.gotoAndStop(1);
			
			var i:int;
			
			for(i = 2; i <= 4; i++)
			{
				gameplay["player" + i].victoryPoints.text = "0";
				gameplay["player" + i].handSize.text = "0";
			}
			gameplay.deckCount.text = "DECK: " + deck.length;
			gameplay.discardCount.text = "DISCARD: " + discard.length;
			
			var delay:int = 0;
			for(i = 0; i < STARTING_HAND_SIZE; i++)
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
			
			gameplay.buttons.trade.addEventListener(MouseEvent.CLICK, handleTrade);
			gameplay.buttons.skip.addEventListener(MouseEvent.CLICK, handleSkip);
		}
		
		public function handleTrade(e:Event):void
		{
			//TODO: CHECK IF IT'S OUR TURN
			var discards:int = 0;
			while(playerHands[1].length > 0)
			{
				var first:JoustCardBase = playerHands[1].shift();
				if(first != null)
				{
					discards++;
					discard.push(first);
					
					first.x = first.localToGlobal(new Point(0,0)).x;
					first.y = first.localToGlobal(new Point(0,0)).y;
					first.scaleX = gameplay.hand1.scaleX;
					first.scaleY = gameplay.hand1.scaleY;
					
					addChild(first);
					
					Actuate.tween(first, 0.5, { 
						x:gameplay.discardPile.x,
						y:gameplay.discardPile.y
					});
				}				
			}
			
			//reset to empty array, clear out the nils
			playerHands[1] = [];
			
			setTimeout(function():void
			{
				var delay:int = 0;
				for(var i:int = 0; i < discards; i++)
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
			}, 500);
			
			
		}
		
		public function handleSkip(e:Event):void
		{
			//TODO: CHECK IF IT'S OUR TURN
			trace("TODO: SKIP");
		}
		
		public function handleCardDown(e:Event):void
		{
			if(e.target == hand1)
			{
				startCardDrag(0);
			}else if(e.target == hand2){
				startCardDrag(1);
			}else if(e.target == hand3){
				startCardDrag(2);
			}else if(e.target == hand4){
				startCardDrag(3);
			}else if(e.target == hand5){
				startCardDrag(4);
			}
			
		}
		
		public var dragIndex:int = -1;
		public var isDragging:Boolean = false;
		
		public var activeHand:MovieClip = null;
		public var activeCard:JoustCardBase = null;
		public var activeDrop:MovieClip = null;
		
		private var lastDragX:Number = Number.MAX_VALUE;
		private var lastDragY:Number = Number.MAX_VALUE;
		public function startCardDrag(index:int):void
		{
			dragIndex = index;
			
			activeCard = playerHands[1][index] as JoustCardBase;
			
			addChild(activeCard);
			activeCard.x = this["hand" + (1+index)].x;
			activeCard.y = this["hand" + (1+index)].y;
			
			activeHand = this["hand" + (1+index)];
			
			activeCard.scaleX = gameplay.hand1.scaleX;
			activeCard.scaleY = gameplay.hand1.scaleY;
			
			addEventListener(MouseEvent.MOUSE_MOVE, keepDragging);
			stage.addEventListener(MouseEvent.MOUSE_UP, finishDragging);
	
			lastDragX = Number.MAX_VALUE;
			lastDragY = Number.MAX_VALUE;	
		}
		
		public function keepDragging(event:MouseEvent):void
		{
			if(lastDragX == Number.MAX_VALUE)
			{
				lastDragX = mouseX;
				lastDragY = mouseY;
				return;
			}
			
			if(!isDragging && Math.abs(lastDragX - mouseX) > 15 || Math.abs(lastDragY - mouseY) > 15)
			{
				trace("REALLY START DRAGGING");
				isDragging = true;
			}

			if(!isDragging)
			{
				return;
			}
			
			var dx:Number = mouseX - lastDragX;
			var dy:Number = mouseY - lastDragY;
			
			lastDragX = mouseX;
			lastDragY = mouseY;
			
			activeCard.x += dx;
			activeCard.y += dy;
			
			var mount_intersect:Rectangle = activeCard.getRect(stage).intersection(gameplay.dropMount.getRect(stage));
			var mount_area:Number = mount_intersect.width * mount_intersect.height;
			
			var character_intersect:Rectangle = activeCard.getRect(stage).intersection(gameplay.dropCharacter.getRect(stage));
			var character_area:Number = character_intersect.width * character_intersect.height;
			
			var weapon_intersect:Rectangle = activeCard.getRect(stage).intersection(gameplay.dropWeapon.getRect(stage));
			var weapon_area:Number = weapon_intersect.width * weapon_intersect.height;
			
			var keeper:int = -1;
			var targets:Array = [gameplay.dropMount, gameplay.dropCharacter, gameplay.dropWeapon];
			var eligible:Array = [activeCard.hasMount, activeCard.hasCharacter, activeCard.hasWeapon];
			var overlaps:Array = [mount_area, character_area, weapon_area];
			
			trace("ELIGIBLE: " + eligible);
			trace("OVERLAPS: " + overlaps);
			
			var max_area:int = 0;
			activeDrop = null;
			for(var i:int = 0; i < 3; i++)
			{
				targets[i].gotoAndStop(1);
				if(eligible[i] && overlaps[i] > max_area)
				{
					keeper = i;
					max_area = overlaps[i];
				}
			}
			
			if(keeper >= 0)
			{
				trace("KEEPER: " + keeper);
				targets[keeper].gotoAndStop(2);
				activeDrop = targets[keeper];
			}			
		}
		public function finishDragging(event:MouseEvent):void
		{	
			removeEventListener(MouseEvent.MOUSE_MOVE, keepDragging);
			stage.removeEventListener(MouseEvent.MOUSE_UP, finishDragging);
			
			if(!isDragging)
			{
				//never passed the dead zone
				trace("NOT DRAGGING, GO HOME");
				playerCardDealt(dragIndex + 1);
				return;
			}
			
			isDragging = false; 
			
			if(activeDrop == null)
			{
				trace("NO ACTIVE DROP, GO HOME");
				Actuate.tween(activeCard, 1, { 
					x:activeHand.x,
					y:activeHand.y
				}).onComplete (playerCardDealt,(dragIndex+1));
				
				return;
			}
			
			
			//close in on our target!
			Actuate.tween(activeCard, 0.25, { 
				x:activeDrop.x,
				y:activeDrop.y
			});
			
			//closure binding
			var active_card:MovieClip = activeCard;
			var active_hand:MovieClip = activeHand;
			var active_drop:MovieClip = activeDrop;
			var drag_index:int = dragIndex;
			
			setTimeout(function():void{
				active_drop.gotoAndStop(1);
				active_card.addEventListener(MouseEvent.CLICK, function(event:Event):void
				{
					event.currentTarget.removeEventListener(event.type, arguments.callee);
					
					Actuate.tween(active_card, 1, { 
						x:active_hand.x,
						y:active_hand.y
					}).onComplete(playerCardDealt,(drag_index+1));
					
				});
			}, 250);

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
				this["hand"+index].isEnabled = true;
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
			
			gameplay.deckCount.text = "DECK: " + deck.length;
			
			var index:int = playerHands[1].length + 1;
			playerHands[1].push(card);
			
			var handsize:int = 0;
			for(var i:int = 0; i < playerHands[1].length; i++)
			{
				if(playerHands[1][i] != null)
				{
					handsize++;
				}
			}
			gameplay.handSize.text = handsize.toString();
			
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