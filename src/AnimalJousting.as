package
{
	import com.eclecticdesignstudio.motion.Actuate;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	
	[SWF(width="1024", height="768")]
	public class AnimalJousting extends Sprite
	{
		
		public var gameplay:UIGameplay;
		
		public var startingDeck:Array = [];
		public var deck:Array = [];
		public var discard:Array = [];
		
		//1-indexed
		public var handSlots:Array = [null];
		public var playerHands:Array = [null, [],[],[],[]];
		public var playerScores:Array = [null, 0, 0, 0, 0];
		
		
		public static var STARTING_HAND_SIZE:int = 4;
		public static var MAX_HAND_SIZE:int = 7;
		
		public var workingStack:Array = [null,null,null];
		
		
		public var kingPlayerIndex:int = 0; //no one is king yet!
		public var kingStack:Array = [null,null,null];
		public var challengerStack:Array = [null,null,null]; 
		
		public var kingCardStack:Array = [null,null,null];
		public var challengerCardStack:Array = [null,null,null];
		
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
			
			var i:int;
			
			for(i = 1; i <= MAX_HAND_SIZE; i++)
			{
				var hand :MCButton= new MCButton(gameplay["hand" + i]);
				hand.isEnabled = false;
				hand.addEventListener("mc_down", handleCardDown);
				handSlots.push(hand);
			}
			
			gameplay.victoryPoints.text = "0";
			
			gameplay.dropWeapon.gotoAndStop(1);
			gameplay.dropCharacter.gotoAndStop(1);
			gameplay.dropMount.gotoAndStop(1);
			
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
			
			gameplay.trade.addEventListener(MouseEvent.CLICK, handleTrade);
			gameplay.skip.addEventListener(MouseEvent.CLICK, handleSkip);
			gameplay.submit.addEventListener(MouseEvent.CLICK, handleSubmit);
			
			
			gameplay.jouster1.visible = false;
			gameplay.jouster2.visible = false;
			
			refreshStack();
		}
		
		public function handleSubmit(e:Event):void
		{
			var i:int;
			
			//TODO: CHECK IF IT'S OUR TURN
			for(i = 0; i < 3; i++)
			{
				if(workingStack[i] == null)
				{
					//TODO: CHECK FOR THE HORSE
					gameplay.statusMessage.text = ["You're missing a mount!", "You're missing a rider!", "You're missing a weapon!"][i];
					return;
				}
			}
			
			if(kingPlayerIndex == 0)
			{
				//TODO: give credit to the current player, not just meeeeee
				kingPlayerIndex = 1;
			}
			
			
			for(i = 0; i < 3; i++)
			{
				workingStack[i].parent.removeChild(workingStack[i]);
				workingStack[i] = null;
			}
			
		}
		
		public function handleTrade(e:Event):void
		{
			//TODO: CHECK IF IT'S OUR TURN
			
			
			for(var i:int = 0; i < workingStack.length; i++)
			{
				if(workingStack[i] != null)
				{
					gameplay.statusMessage.text = "Can't trade with cards on the stack!";
					return;
				}
			}
			
			
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
			for(var i:int = 1; i < handSlots.length; i++)
			{
				if(e.target == handSlots[i])
				{
					startCardDrag(i);		
				}
			}
		}
		
		public var dragIndex:int = -1;
		public var isDragging:Boolean = false;
		
		public var activeHand:MovieClip = null;
		public var activeCard:JoustCardBase = null;
		public var activeDrop:MovieClip = null;
		
		private var lastDragX:Number = Number.MAX_VALUE;
		private var lastDragY:Number = Number.MAX_VALUE;
		public function startCardDrag(index:int):void  //1-indexed
		{
			dragIndex = index;
			
			//hand is 0-based, everything else is name-based
			activeCard = playerHands[1][index - 1] as JoustCardBase;
			
			addChild(activeCard);
			
			activeCard.x = handSlots[index].x;
			activeCard.y = handSlots[index].y;
			
			activeHand = handSlots[index];
			
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
			
			if(!isDragging && (Math.abs(lastDragX - mouseX) > 15 || Math.abs(lastDragY - mouseY) > 15) )
			{
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
			
			var max_area:int = 0;
			activeDrop = null;
			for(var i:int = 0; i < 3; i++)
			{
				targets[i].gotoAndStop(1);
				if(eligible[i] && workingStack[i] == null && overlaps[i] > max_area && canDrop(activeCard, i))
				{
					keeper = i;
					max_area = overlaps[i];
				}
			}
			
			if(keeper >= 0)
			{
				targets[keeper].gotoAndStop(2);
				activeDrop = targets[keeper];
			}			
		}
		
		public function canDrop(card:JoustCardBase, slot:int):Boolean
		{
			//DROPPING A MOUNT, MAKE SURE IT CAN HOLD OUR RIDER
			if(slot == 0 && workingStack[1] != null)
			{
				if((workingStack[1] as JoustCardBase).characterSize > card.mountSize)
				{
					return false;
				}
			}
			
			//DROP A CHARACTER, SAME CHECK
			if(slot == 1 && workingStack[0] != null)
			{
				if((workingStack[0] as JoustCardBase).mountSize < card.characterSize)
				{
					return false;
				}
			}
			
			
			//DROPPING A WEAPON, CHECK TO SEE IF WE'RE SMART ENOUGH
			if(slot == 2 && workingStack[1] != null)
			{
				if((workingStack[1] as JoustCardBase).characterIntelligence < card.weaponIntelligence)
				{
					return false;
				}
			}
			
			//DROPPING A CHARACTER, SAME CHECK
			if(slot == 1 && workingStack[2] != null)
			{
				if((workingStack[2] as JoustCardBase).weaponIntelligence > card.characterIntelligence)
				{
					return false;
				}
			}

			
			return true;
		}
		public function finishDragging(event:MouseEvent):void
		{	
			removeEventListener(MouseEvent.MOUSE_MOVE, keepDragging);
			stage.removeEventListener(MouseEvent.MOUSE_UP, finishDragging);
			
			if(!isDragging)
			{
				//never passed the dead zone
				trace("NOT DRAGGING, GO HOME");
				playerCardDealt(dragIndex);
				return;
			}
			
			isDragging = false; 
			
			if(activeDrop == null)
			{
				trace("NO ACTIVE DROP, GO HOME");
				Actuate.tween(activeCard, 1, { 
					x:activeHand.x,
					y:activeHand.y
				}).onComplete (playerCardDealt,dragIndex);
				
				return;
			}
			
			var stack_index:int = -1;
			if(activeDrop == gameplay.dropMount){
				stack_index = 0;
			}else if(activeDrop == gameplay.dropCharacter){
				stack_index = 1;
			}else if(activeDrop == gameplay.dropWeapon){
				stack_index = 2;
			}
			
			workingStack[stack_index] = activeCard;
			var card_index:int = -1;
			for(var i:int = 0; i < playerHands[1].length; i++)
			{
				if(playerHands[1][i] == activeCard)
				{
					playerHands[1][i] = null;
					handSlots[dragIndex].isEnabled = false;
					card_index = i;
				}
			}
			refreshStack();
			
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

					workingStack[stack_index] = null;
					playerHands[1][card_index] = active_card;
					
					updateLabels();
					
					refreshStack();
					
					Actuate.tween(active_card, 1, { 
						x:active_hand.x,
						y:active_hand.y
					}).onComplete(playerCardDealt, drag_index);
					
				});
			}, 250);

		}
		
		public function playerCardDealt(index:int):void
		{
			var card:JoustCardBase = playerHands[1][index-1] as JoustCardBase;
			
			card.rotation = 0;
			card.faceUp();
			
			if(index <= MAX_HAND_SIZE)
			{
				card.x = 0;
				card.y = 0;
				card.scaleX = 1;
				card.scaleY = 1;
				
				gameplay["hand" + index].holder.addChild(card);
				gameplay.setChildIndex(handSlots[index], gameplay.numChildren - 1);
				handSlots[index].isEnabled = true;
			}
			
		}
		
		public function refreshStack():void
		{
			if(kingPlayerIndex == 0)
			{
				kingCardStack = workingStack.concat();
			}else{
				challengerCardStack = workingStack.concat();
			}
			refreshKing();
			refreshChallenger();
		}
		
		public function refreshKing():void
		{
			var mount:JoustCardBase = kingCardStack[0];
			var rider:JoustCardBase = kingCardStack[1];
			var weapon:JoustCardBase = kingCardStack[2];
			
			for(var i:int = 0; i < 3; i++)
			{
				if(kingStack[i] != null)
				{
					kingStack[i].parent.removeChild(kingStack[i]);
					kingStack[i] = null;
				}	
			}
			
			var mount_clip:MovieClip;
			var rider_clip:MovieClip;
			var weapon_clip:MovieClip;
			
			var klass:Class;
			
			var power:int = 0;
			var damageType:String = "";
			var weakness:String = "";
			var strength:String = "";
						
			if(mount != null)
			{
				klass = getDefinitionByName("MC_" + mount.cardName) as Class;
				mount_clip = new klass() as MovieClip;
				addChild(mount_clip);
				
				mount_clip.x = gameplay.jouster1.x;
				mount_clip.y = gameplay.jouster1.y;
				
				kingStack[0] = mount_clip;
				
				power += mount.mountDamage;
			}
			
			if(rider != null)
			{
				klass = getDefinitionByName("MC_" + rider.cardName) as Class;
				rider_clip = new klass() as MovieClip;
				
				if(mount_clip == null)
				{
					addChild(rider_clip);
					rider_clip.x = gameplay.jouster1.x;
					rider_clip.y = gameplay.jouster1.y;	
				}else{
					mount_clip["character"].addChild(rider_clip);
				}
				
				kingStack[2] = rider_clip;
				weakness = rider.characterWeakness;
				strength = rider.characterStrength;
			}
			
			if(weapon != null)
			{
				klass = getDefinitionByName(weapon.weaponString) as Class;
				weapon_clip = new klass() as MovieClip;
				addChild(weapon_clip);
				
				if(mount_clip == null)
				{
					addChild(weapon_clip);
					weapon_clip.x = gameplay.jouster1.x;
					weapon_clip.y = gameplay.jouster1.y;	
				}else{
					mount_clip["weapon"].addChild(weapon_clip);
				}
				
				kingStack[1] = weapon_clip;
				
				power += weapon.weaponDamage;
				damageType = weapon.weaponDamageType;
			}
			
			//CHECK OUR OPPONENT
			if(challengerCardStack[2] != null)
			{
				if(challengerCardStack[2].weaponDamageType == weakness)
				{
					trace("King is weak to challenger attack!");
					power -= 3;
				}else if(challengerCardStack[2].weaponDamageType == strength){
					trace("King is strong to challenger attack!");
					power += 3;
				}else{
					trace("King is unphased by challenger attack!");
				}
			}else{
				trace("CHALLENGER HAS NO WEAPON");
			}
			
			gameplay.stats1.damage.text = power;
			gameplay.stats1.damageDistraction.visible = (damageType == JoustCardWeapon.DAMAGE_DISTRACTING);
			gameplay.stats1.damagePoking.visible = (damageType == JoustCardWeapon.DAMAGE_POKING);
			gameplay.stats1.damageFood.visible = (damageType == JoustCardWeapon.DAMAGE_FOOD);
			
			gameplay.stats1.weaknessDistraction.visible = (weakness == JoustCardWeapon.DAMAGE_DISTRACTING);
			gameplay.stats1.weaknessPoking.visible = (weakness == JoustCardWeapon.DAMAGE_POKING);
			gameplay.stats1.weaknessFood.visible = (weakness == JoustCardWeapon.DAMAGE_FOOD);
			
			gameplay.stats1.strengthDistraction.visible = (strength == JoustCardWeapon.DAMAGE_DISTRACTING);
			gameplay.stats1.strengthPoking.visible = (strength == JoustCardWeapon.DAMAGE_POKING);
			gameplay.stats1.strengthFood.visible = (strength == JoustCardWeapon.DAMAGE_FOOD);
			
		}
		
		public function refreshChallenger():void
		{
			var mount:JoustCardBase = challengerCardStack[0];
			var rider:JoustCardBase = challengerCardStack[1];
			var weapon:JoustCardBase = challengerCardStack[2];
			
			for(var i:int = 0; i < 3; i++)
			{
				if(challengerStack[i] != null)
				{
					challengerStack[i].parent.removeChild(challengerStack[i]);
					challengerStack[i] = null;
				}	
			}
			
			var mount_clip:MovieClip;
			var rider_clip:MovieClip;
			var weapon_clip:MovieClip;
			
			var klass:Class;
			
			var power:int = 0;
			var damageType:String = "";
			var weakness:String = "";
			var strength:String = "";
			
			if(mount != null)
			{
				klass = getDefinitionByName("MC_" + mount.cardName) as Class;
				mount_clip = new klass() as MovieClip;
				addChild(mount_clip);
				
				mount_clip.x = gameplay.jouster2.x;
				mount_clip.y = gameplay.jouster2.y;
				
				mount_clip.scaleX = -1;
				
				challengerStack[0] = mount_clip;
				
				power += mount.mountDamage;
			}
			
			if(rider != null)
			{
				klass = getDefinitionByName("MC_" + rider.cardName) as Class;
				rider_clip = new klass() as MovieClip;
				
				if(mount_clip == null)
				{
					addChild(rider_clip);
					rider_clip.x = gameplay.jouster2.x;
					rider_clip.y = gameplay.jouster2.y;
					rider_clip.scaleX = -1;
				}else{
					mount_clip["character"].addChild(rider_clip);
				}
				
				challengerStack[2] = rider_clip;
				weakness = rider.characterWeakness;
				strength = rider.characterStrength;
			}
			
			if(weapon != null)
			{
				klass = getDefinitionByName(weapon.weaponString) as Class;
				weapon_clip = new klass() as MovieClip;
				addChild(weapon_clip);
				
				if(mount_clip == null)
				{
					addChild(weapon_clip);
					weapon_clip.x = gameplay.jouster2.x;
					weapon_clip.y = gameplay.jouster2.y;
					weapon_clip.scaleX = -1;
				}else{
					mount_clip["weapon"].addChild(weapon_clip);
				}
				
				challengerStack[1] = weapon_clip;
				
				power += weapon.weaponDamage;
				damageType = weapon.weaponDamageType;
			}
			
			//CHECK OUR OPPONENT
			if(kingCardStack[2] != null)
			{
				if(kingCardStack[2].weaponDamageType == weakness)
				{
					trace("CHALLENGER IS WEAK TO KING ATTACK");
					power -= 3;
				}else if(kingCardStack[2].weaponDamageType == strength){
					trace("CHALLENGER IS STRONG TO KING ATTACK");
					power += 3;
				}else{
					trace("CHALLENGER INDIFFERENT TO KING ATTACK");
				}
			}
			
			gameplay.stats2.damage.text = power;
			gameplay.stats2.damageDistraction.visible = (damageType == JoustCardWeapon.DAMAGE_DISTRACTING);
			gameplay.stats2.damagePoking.visible = (damageType == JoustCardWeapon.DAMAGE_POKING);
			gameplay.stats2.damageFood.visible = (damageType == JoustCardWeapon.DAMAGE_FOOD);
			
			gameplay.stats2.weaknessDistraction.visible = (weakness == JoustCardWeapon.DAMAGE_DISTRACTING);
			gameplay.stats2.weaknessPoking.visible = (weakness == JoustCardWeapon.DAMAGE_POKING);
			gameplay.stats2.weaknessFood.visible = (weakness == JoustCardWeapon.DAMAGE_FOOD);
			
			gameplay.stats2.strengthDistraction.visible = (strength == JoustCardWeapon.DAMAGE_DISTRACTING);
			gameplay.stats2.strengthPoking.visible = (strength == JoustCardWeapon.DAMAGE_POKING);
			gameplay.stats2.strengthFood.visible = (strength == JoustCardWeapon.DAMAGE_FOOD);
		}
		
		public function updateLabels():void
		{
			var handsize:int = 0;
			for(var i:int = 0; i < playerHands[1].length; i++)
			{
				if(playerHands[1][i] != null)
				{
					handsize++;
				}
			}
			
			gameplay.deckCount.text = "DECK: " + deck.length;
			gameplay.discardCount.text = "DISCARD: " + discard.length;
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
			
			updateLabels();			
			
			var target_x:Number;
			var target_y:Number;
			var target_rotation:Number;
			var target_duration:Number = 1.0;
						
			if(index <= MAX_HAND_SIZE)
			{
				target_x = handSlots[index].x;
				target_y = handSlots[index].y;
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