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
	
	public class JoustGameplayScreen extends Sprite
	{
		public var CURRENT_PLAYER:int = 0;
		
		public var gameplay:UIGameplay;
		public var discardPop:UIDiscard;
		public var help:UIHelp;
		
		public var startingDeck:Array = [];
		public var deck:Array = [];
		public var discard:Array = [];
		
		//1-indexed
		public var handSlots:Array = [null];
		public var discardSlots:Array = [null];
		
		public var playerHands:Array = [null, [],[],[],[]];
		public var playerScores:Array = [null, 0, 0, 0, 0];
		
		
		public static var STARTING_HAND_SIZE:int = 4;
		public static var MAX_HAND_SIZE:int = 7;
		public static var VICTORY_SCORE:int = 7;
		
		public var workingStack:Array = [null,null,null,null];
		
		
		public var kingPlayerIndex:int = 0; //no one is king yet!
		public var kingStack:Array = [null,null,null];
		public var challengerStack:Array = [null,null,null]; 
		
		public var kingCardStack:Array = [null,null,null, null];
		public var challengerCardStack:Array = [null,null,null,null];
		
		public function JoustGameplayScreen()
		{
			super();
			
			startingDeck = deck.concat(JoustCardWeapon.all, JoustCardMount.all, JoustCardCharacter.all, [JoustCardWeaponOrCharacter.getCactus(), JoustCardWeaponOrCharacter.getPug(), JoustCardMountCharacter.getHorse(), JoustCardWeaponOrMount.getPogoStick(), JoustCardWeaponOrCharacter.getCactus(), JoustCardWeaponOrCharacter.getPug(), JoustCardMountCharacter.getHorse(), JoustCardWeaponOrMount.getPogoStick(), new JoustCardDraw("draw1", 2), new JoustCardDraw("draw1", 2), new JoustCardDraw("draw1", 2), new JoustCardDraw("draw1", 2), new JoustCardDraw("draw1", 2), new JoustCardDraw("draw1", 2), new JoustCardDraw("draw1", 2), new JoustCardDraw("draw1", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2), new JoustCardBuff("buff2", 2)]);
			//working copy
			
			deck = startingDeck.concat();
			for each(var card:Object in startingDeck)
			{
				trace(card);
				(card as JoustCardBase).faceDown();
			}
			
			setupGameplay();			
			setupDiscard();
			
			var i:int;
			
			var delay:int = 0;
			var delay_step:int = 250;
			for(i = 0; i < STARTING_HAND_SIZE; i++)
			{
				setTimeout(function():void{
					dealCardToPlayer();	
				}, delay);
				delay += delay_step;
				
				setTimeout(function():void{
					dealCardToAI(2);	
				}, delay);
				delay += delay_step;
				
				setTimeout(function():void{
					dealCardToAI(3);	
				}, delay);
				delay += delay_step;
				
				setTimeout(function():void{
					dealCardToAI(4);	
				}, delay);
				delay += delay_step;
			}
			
			//DEBUG -- GIMME MORE CARDS
			gameplay.deckPile.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				dealCardToPlayer();
			});
			
			setTimeout(nextTurn, delay + 1000);
		}
		
		
		public function setupGameplay():void
		{
			gameplay = new UIGameplay();
			addChild(gameplay);
			
			gameplay.turnAnnouncement.stop();
			gameplay.turnAnnouncement.visible = false;
			gameplay.turnAnnouncement.addEventListener("yourturn", dealNextCard);
			
			gameplay.winnerAnnouncement.stop();
			gameplay.winnerAnnouncement.visible = false;
			gameplay.winnerAnnouncement.addEventListener("yourturn", cleanUpBattle);
			
			var i:int;
			
			for(i =1; i <= 4; i++)
			{
				gameplay["king" + i].visible = false;
			}
			
			for(i = 1; i <= MAX_HAND_SIZE; i++)
			{
				var hand :MCButton= new MCButton(gameplay["hand" + i]);
				hand.isEnabled = false;
				hand.addEventListener("mc_down", handleCardDown);
				handSlots.push(hand);
			}
			
			gameplay.victoryPoints.text = "0";
			
			gameplay.dropBuff.gotoAndStop(1);
			gameplay.dropWeapon.gotoAndStop(1);
			gameplay.dropCharacter.gotoAndStop(1);
			gameplay.dropMount.gotoAndStop(1);
			gameplay.discardPile.gotoAndStop(1);
			
			var enemy_names:Array = ["Pug","Cactus","Monkey"];
			var enemy_portraits:Array = [new portrait_pug(), new portrait_cactus(), new portrait_monkey()];
			for(i = 2; i <= 4; i++)
			{
				gameplay["player" + i].victoryPoints.text = "0";
				gameplay["player" + i].handSize.text = "0";
				gameplay["player" + i].playerName.text = enemy_names[i - 2];
				gameplay["player" + i].portrait.addChild(enemy_portraits[i-2]);
			}
			gameplay.deckCount.text = "DECK: " + deck.length;
			
			gameplay.trade.addEventListener(MouseEvent.CLICK, handleTrade);
			gameplay.skip.addEventListener(MouseEvent.CLICK, handleSkip);
			gameplay.submit.addEventListener(MouseEvent.CLICK, handleSubmit);
			
			gameplay.jouster1.visible = false;
			gameplay.jouster2.visible = false;
			
			gameplay.music_off.visible = false;
			gameplay.sound_off.visible = false;
			
			gameplay.music_off.addEventListener(MouseEvent.CLICK, toggleMusic);
			gameplay.music_on.addEventListener(MouseEvent.CLICK, toggleMusic);
			
			gameplay.sound_off.addEventListener(MouseEvent.CLICK, toggleSound);
			gameplay.sound_on.addEventListener(MouseEvent.CLICK, toggleSound);
			
			gameplay.help.addEventListener(MouseEvent.CLICK, toggleHelp);
		}
		
		public function toggleHelp(e:Event):void
		{
			AnimalJousting.buttonSound();
			if(help == null)
			{
				help = new UIHelp();
				help.help_play.addEventListener(MouseEvent.CLICK, toggleHelpOff);
			}
			stage.addChild(help);
		}
		
		public function toggleHelpOff(e:Event):void
		{
			AnimalJousting.buttonSound();
			stage.removeChild(help);
		}
		
		public function toggleMusic(e:Event):void
		{
			AnimalJousting.buttonSound();
			trace(e.currentTarget.name);
			if(e.currentTarget.name == "music_off")
			{
				gameplay.music_off.visible = false;
				gameplay.music_on.visible = true;
				AnimalJousting.musicEnabled = true;
				AnimalJousting.playMusic();
			}else{
				gameplay.music_off.visible = true;
				gameplay.music_on.visible = false;
				AnimalJousting.musicEnabled = false;
				AnimalJousting.stopMusic();
			}
		}
		public function toggleSound(e:Event):void
		{
			AnimalJousting.buttonSound();
			trace(e.currentTarget.name);
			if(e.currentTarget.name == "sound_off")
			{
				gameplay.sound_off.visible = false;
				gameplay.sound_on.visible = true;
				AnimalJousting.soundEnabled = true;
			}else{
				gameplay.sound_off.visible = true;
				gameplay.sound_on.visible = false;
				AnimalJousting.soundEnabled = false;	
			}
		}
		
		public function setupDiscard():void
		{
			discardPop = new UIDiscard();
			
			for(var i:int = 1; i <= 8; i++)
			{
				var hand:MCButton= new MCButton(discardPop["hand" + i]);
				hand.isEnabled = false;
				hand.name = i.toString();
				hand.addEventListener("mc_down", discardACard);
				discardSlots.push(hand);
			}
		}
		
		public function nextTurn():void
		{
			if(isGameOver) return;
			refreshStack();
			
			CURRENT_PLAYER += 1;
			
			if(CURRENT_PLAYER == 5)
			{
				CURRENT_PLAYER = 1;
			}
			
			var banners:Array = [null, "YOUR TURN", "PUG'S TURN", "CACTUS'S TURN", "MONKEY'S TURN"];
			
			if(CURRENT_PLAYER == kingPlayerIndex)
			{
				AnimalJousting.newKingSound();
				playerScores[CURRENT_PLAYER] += 1;
				updateLabels();
			}
			
			addChild(gameplay.turnAnnouncement);
			gameplay.turnAnnouncement.gotoAndPlay(1);
			gameplay.turnAnnouncement.bannerClip.bannerText.text = banners[CURRENT_PLAYER];
			gameplay.turnAnnouncement.visible = true;
			
		}
		
		public function dealNextCard(e:Event = null):void
		{
			setTimeout(function():void{
				gameplay.turnAnnouncement.visible = false;	
			}, 1000);
			
			if(CURRENT_PLAYER == 1)
			{
				dealCardToPlayer();	
			}else{
				dealCardToAI(CURRENT_PLAYER);
			}
			
			if(CURRENT_PLAYER != 1)
			{
				//when do we think about our move?
				var delay:int = 2000;
				
				if(playerHands[CURRENT_PLAYER].length > MAX_HAND_SIZE)
				{
					//discarding, think longer
					delay += 1000;
					setTimeout(function():void
					{
						var which:int = Math.floor(Math.random() * playerHands[CURRENT_PLAYER].length);
						var card:JoustCardBase = playerHands[CURRENT_PLAYER].splice(which, 1)[0];
						discard.push(card);
						addChild(card);
						card.rotation = 0;
						card.faceUp();
						Actuate.tween(card, 0.5, { 
							x:gameplay.discardPile.x,
							y:gameplay.discardPile.y
						});
					}, 1000);
					
					
				}
				
				
				
				setTimeout(function():void{
					takeEnemyTurn();
				}, delay);
			}
		}
		
		public function takeEnemyTurn():void
		{
			var move:Array = getBestMove(CURRENT_PLAYER);
			
			if(move != null)
			{
				var delay:Number = 0;
				var drop_targets:Array = [gameplay.dropMount, gameplay.dropCharacter, gameplay.dropWeapon, gameplay.dropBuff];
				for(var i:int = 0; i < move.length; i++)
				{
					if(move[i] != null)
					{
						trace("PLAY " + move[i].name);
						
						var card:JoustCardBase = move[i];
						
						addChild(card);
						card.rotation = 0;
						card.faceUp();
						
						var drop_target:MovieClip = drop_targets[i];
						
						workingStack[i] = card;
						for(var j:int = 0; j < playerHands[CURRENT_PLAYER].length; j++)
						{
							if(playerHands[CURRENT_PLAYER][j] == card)
							{
								playerHands[CURRENT_PLAYER][j] = null;
							}
						}
						refreshStack();
						
						//close in on our target!
						Actuate.tween(card, 0.25, { 
							x:drop_target.x,
							y:drop_target.y
						}).delay(delay);
						
						delay += 0.25;
					}
				}
				
				setTimeout(resolveBattle, 1500);
			}else{
				nextTurn();
			}
		}
		
		public function getBestMove(player_index:int):Array
		{
			var valid_combinations:Array = [];
			
			var mounts:Array = [];
			var characters:Array = [];
			var weapons:Array = [];
			var buffs:Array = [];
			var i:int;
			
			var hasHorse:Boolean = false;
			for(i = 0; i < playerHands[player_index].length; i++)
			{
				if(playerHands[player_index][i] != null)
				{
					var card:JoustCardBase = playerHands[player_index][i];
					
					if(card is JoustCardMountCharacter)
					{
						hasHorse = true;
					}
					
					if(card.hasMount)
					{
						mounts.push(card);
					}
					if(card.hasCharacter)
					{
						characters.push(card);
					}
					if(card.hasWeapon)
					{
						weapons.push(card);
					}
					if(card.hasBuff)
					{
						buffs.push(card);
					}
				}
			}
			
			if(weapons.length == 0)
			{
				trace("NO WEAPONS");
				return null;
			}
			if(characters.length == 0)
			{
				trace("NO CHARACTERS");
				return null;
			}
			if(mounts.length == 0)
			{
				trace("NO MOUNTS");
				return null;
			}
			
			var first_pass:Array = [];
			
			for each(var mount_card:JoustCardBase in mounts)
			{
				if(mount_card is JoustCardMountCharacter)
				{
					first_pass.push([mount_card, null, null, null]);	
				}else{
					for each(var char_card:JoustCardBase in characters)
					{
						if(char_card is JoustCardMountCharacter)
						{
							continue;
						}
						
						if(char_card.characterSize <= mount_card.mountSize)
						{
							first_pass.push([mount_card, char_card, null, null]);
						}
					}
				}
			}
			
			trace("FIRST PASS: " + first_pass.length + " POSSIBILITIES");
			
			var second_pass:Array = [];
			for(i = 0; i < first_pass.length; i++)
			{
				var mount:JoustCardBase = first_pass[i][0];
				var rider:JoustCardBase;
				
				if(mount is JoustCardMountCharacter)
				{
					rider = mount;
				}else{
					rider = first_pass[i][1];
				}
				
				for each(var weapon_card:JoustCardBase in weapons)
				{
					//no dupes in case of cactus/pug/pogo
					if(first_pass[i][0] == weapon_card || first_pass[i][1] == weapon_card)
					{
						continue;
					}
					
					if(rider.characterIntelligence >= weapon_card.weaponIntelligence)
					{
						first_pass[i][2] = weapon_card;
						second_pass.push(first_pass[i]);
					}
				}
			}
			
			trace("SECOND PASS: " + second_pass.length + " POSSIBILITIES");
			trace(second_pass);
			
			var high_score:int = -1;
			var high_score_index:int = -1;
			
			
			for(i = 0; i < second_pass.length; i++)
			{
				var score:int = calculateScore(second_pass[i], kingCardStack);
				if(score > high_score)
				{
					high_score = score;
					high_score_index = i;
				}
			}
			
			
			if(high_score > 0)
			{
				if(kingPlayerIndex == 0)
				{
					trace("NO KING, TAKE OVER!");
					return second_pass[high_score_index];	
				}else{
					
					var reigning_score:int = parseInt(gameplay.stats1.damage.text);
					trace("REIGNING SCORE: " + reigning_score + " vs CHALLENGER " + high_score);
					if(high_score >= reigning_score)
					{
						return second_pass[high_score_index];
					}else{
						
						for(i = 0; i < buffs.length; i++)
						{
							trace("GOT A BUFF WITH +" + buffs[i].attackBuff);
							if(high_score + buffs[i].attackBuff > reigning_score)
							{
								second_pass[high_score_index][3] = buffs[i];
								return second_pass[high_score_index];
							}
						}
						
						
						trace("GOT A MATCH, BUT NOT BETTER  " + high_score + " vs " + reigning_score);						
						return null;
					}
				}
				
			}
			return null;
		}
		
		public function calculateScore(stack_1:Array, stack_2:Array):int
		{
			var mount:JoustCardBase = stack_1[0];
			var rider:JoustCardBase = stack_1[1];
			var weapon:JoustCardBase = stack_1[2];
			
			trace("TESTING " + (mount ? mount.name : "null") + " | " 
				+ (rider ? rider.name : "null") + " | " 
				+ (weapon ? weapon.name : "null")); 
			
			trace("TESTING " + (mount ? mount.mountDamage : "null") + " | " 
				+ (rider ? (rider.characterWeakness + "+" + rider.characterStrength) : "null") + " | " 
				+ (weapon ? weapon.weaponDamage : "null")); 
				
			//TODO: BOOST
			
			var enemyMount:JoustCardBase = stack_2[0];
			var enemyRider:JoustCardBase = stack_2[1];
			var enemyWeapon:JoustCardBase = stack_2[2];
			
			trace("ENEMY IS " + (enemyMount ? enemyMount.name : "null") + " | " 
				+ (enemyRider ? enemyRider.name : "null") + " | " 
				+ (enemyWeapon ? enemyWeapon.name : "null")); 
			
			trace("ENEMY IS  " + (enemyMount ? enemyMount.mountDamage : "null") + " | " 
				+ (enemyRider ? (enemyRider.characterWeakness + "+" + enemyRider.characterStrength) : "null") + " | " 
				+ (enemyWeapon ? enemyWeapon.weaponDamage : "null")); 
			
			var power:int = 0;
			var damageType:String = "";
			var weakness:String = "";
			var strength:String = "";
			
			var enemyPower:int = 0;
			var enemyDamageType:String = "";
			var enemyWeakness:String = "";
			var enemyStrength:String = "";
			
			if(rider is JoustCardMountCharacter)
			{
				mount = rider;
				rider = null;
				
				weakness = mount.characterWeakness;
				strength = mount.characterStrength;
			}else if(mount is JoustCardMountCharacter){
				weakness = mount.characterWeakness;
				strength = mount.characterStrength;
			}
			
			if(enemyRider is JoustCardMountCharacter)
			{
				enemyMount = enemyRider;
				enemyRider = null;
				
				enemyWeakness = enemyMount.characterWeakness;
				enemyStrength = enemyMount.characterStrength;
			}else if(enemyMount is JoustCardMountCharacter){
				
				enemyWeakness = enemyMount.characterWeakness;
				enemyStrength = enemyMount.characterStrength;
			}
			
			if(mount != null)
			{
				power += mount.mountDamage;
			}
			
			if(rider != null)
			{
				weakness = rider.characterWeakness;
				strength = rider.characterStrength;
			}
			
			if(weapon != null)
			{
				power += weapon.weaponDamage;
				damageType = weapon.weaponDamageType;
			}
			
			if(enemyRider != null)
			{
				enemyWeakness = enemyRider.characterWeakness;
				enemyStrength = enemyRider.characterStrength;
			}
			
			//CHECK OUR OPPONENT
			if(enemyWeapon != null)
			{
				if(enemyWeapon.weaponDamageType == weakness)
				{
					trace("i'm weak to the king's " + enemyWeapon.name + ": -3");
					power -= 3;
				}else if(enemyWeapon.weaponDamageType == strength){
					trace("strong vs the king's " + enemyWeapon.name + ": +3");
					power += 3;
				}
			}
			
			//IN CALCULATING THE BEST MOVE, WE ALSO NEED TO CHECK THE OPPONENT'S CHARACTER AGAINST OURS
			if(weapon != null)
			{
				trace("comparing " + damageType + " to " + enemyWeakness);
				trace("comparing " + damageType + " to " + enemyStrength);
				if(damageType == enemyWeakness)
				{
					trace("the king is weak to " + weapon.name + " -- effectively +3");
					power += 3;
				}else if(damageType == enemyStrength){
					trace("the king is strong to " + weapon.name + " -- effectively -3");
					power -= 3;
				}
			}
			
			return power;
		}
		
		
		
		public function handleSubmit(e:Event):void
		{
			AnimalJousting.buttonSound();
			
			if(CURRENT_PLAYER != 1)
			{
				return;
			}
			
			var i:int;
			
			
			if(workingStack[0] == null && !(workingStack[1] is JoustCardMountCharacter))
			{
				gameplay.statusMessage.text = "You're missing a mount!";
				return;
			}
			
			if(workingStack[1] == null && !(workingStack[0] is JoustCardMountCharacter))
			{
				gameplay.statusMessage.text = "You're missing a rider!";
				return;
			}
			
			if(workingStack[2] == null)
			{
				gameplay.statusMessage.text = "You're missing a weapon!";
				return;
			}
			
			resolveBattle();
		}
		
		public function resolveBattle():void
		{
			trace(workingStack);
			
			if(workingStack[3] != null)
			{
				if(workingStack[3].goHome != null && workingStack[3].hasEventListener(MouseEvent.CLICK))
				{
					workingStack[3].removeEventListener(MouseEvent.CLICK, workingStack[3].goHome);		
				}
				
				discard.push(workingStack[3]);
				Actuate.tween(workingStack[3], 0.5, { 
					x:gameplay.discardPile.x,
					y:gameplay.discardPile.y
				});
				workingStack[3] = null;
			}
			
			if(kingPlayerIndex == 0)
			{
				newSheriffInTown();
				
				addChild(gameplay.winnerAnnouncement);
				gameplay.winnerAnnouncement.gotoAndPlay(1);
				gameplay.winnerAnnouncement.bannerClip.bannerText.text = "NEW KING!";
				gameplay.winnerAnnouncement.visible = true;
				
				kingCardStack = workingStack.concat();
				for(i = 0; i < 3; i++)
				{
					if(workingStack[i] != null)
					{
						workingStack[i].parent.removeChild(workingStack[i]);
						workingStack[i] = null;	
					}
				}
				return;
			}
			
			var i:int;
			
			var king_score:int = parseInt(gameplay.stats1.damage.text);
			var challenger_score:int = parseInt(gameplay.stats2.damage.text);
			
			if(challenger_score >= king_score)
			{
				newSheriffInTown();
				
				addChild(gameplay.winnerAnnouncement);
				gameplay.winnerAnnouncement.gotoAndPlay(1);
				gameplay.winnerAnnouncement.bannerClip.bannerText.text = "CHALLENGER WINS!";
				gameplay.winnerAnnouncement.visible = true;
				
				
				trace(kingCardStack);
				trace(kingStack);
				for(i = 0; i < kingCardStack.length; i++)
				{
					if(kingCardStack[i] != null)
					{
						addChild(kingCardStack[i]);
						kingCardStack[i].x = gameplay.jouster1.x;
						kingCardStack[i].y = gameplay.jouster1.y;						
						
						Actuate.tween(kingCardStack[i], 0.5, { 
							x:gameplay.discardPile.x,
							y:gameplay.discardPile.y
						});
						
						discard.push(kingCardStack[i]);
						kingCardStack[i] = null;
					}
				}
				
				kingCardStack = workingStack.concat();
				for(i = 0; i < 3; i++)
				{
					if(workingStack[i] != null)
					{
						workingStack[i].parent.removeChild(workingStack[i]);
						workingStack[i] = null;	
					}
				}
				
			}else{
				addChild(gameplay.winnerAnnouncement);
				gameplay.winnerAnnouncement.gotoAndPlay(1);
				gameplay.winnerAnnouncement.bannerClip.bannerText.text = "KING WINS!";
				gameplay.winnerAnnouncement.visible = true;
				
				for(i = 0; i < workingStack.length - 1; i++) //don't bother with the top one
				{
					if(workingStack[i] != null)
					{
						addChild(workingStack[i]);
						Actuate.tween(workingStack[i], 0.5, { 
							x:gameplay.discardPile.x,
							y:gameplay.discardPile.y
						});
						
						discard.push(workingStack[i]);
						workingStack[i] = null;
					}
				}
			}
			
		}
		
		public function cleanUpBattle(e:Event = null):void
		{
			setTimeout(function():void {
				gameplay.winnerAnnouncement.visible = false;
				nextTurn();
			}, 1000);
		}
		
		public function newSheriffInTown():void
		{
			playerScores[CURRENT_PLAYER] += 1;
			updateLabels();
			
			kingPlayerIndex = CURRENT_PLAYER;
			AnimalJousting.newKingSound();
			
			gameplay.crown.x = gameplay["king"+CURRENT_PLAYER].x;
			gameplay.crown.y = gameplay["king"+CURRENT_PLAYER].y;
			gameplay.crown.scaleX = [1, 0.5, 0.5, 0.5][CURRENT_PLAYER];
			gameplay.crown.scaleY = [1, 0.5, 0.5, 0.5][CURRENT_PLAYER];
		}
		
		public function handleTrade(e:Event):void
		{
			AnimalJousting.buttonSound();
			if(CURRENT_PLAYER != 1) return;
			
			var got_one:Boolean = false;
			for(var i:int = 0; i < workingStack.length; i++)
			{
				if(workingStack[i] != null)
				{
					workingStack[i].goHome();
					got_one = true;
				}
			}
			
			if(got_one)
			{
				setTimeout(actuallyTrade, 1000);
			}else{
				actuallyTrade();	
			}
		}
		
		public function actuallyTrade():void
		{
			
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
				
				setTimeout(nextTurn, delay + 500);
				
			}, 500);
			
		}
		
		public function handleSkip(e:Event):void
		{
			AnimalJousting.buttonSound();
			
			if(CURRENT_PLAYER != 1)
			{
				return;
			}
			
			var got_one:Boolean = false;
			for(var i:int = 0; i < workingStack.length; i++)
			{
				if(workingStack[i] != null)
				{
					workingStack[i].goHome();
					got_one = true;
				}
			}
			
			if(got_one)
			{
				setTimeout(nextTurn, 1000);
			}else{
				nextTurn();	
			}
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
			
			var buff_intersect:Rectangle = activeCard.getRect(stage).intersection(gameplay.dropBuff.getRect(stage));
			var buff_area:Number = buff_intersect.width * buff_intersect.height;
			
			var discard_intersect:Rectangle = activeCard.getRect(stage).intersection(gameplay.discardPile.getRect(stage));
			var discard_area:Number = discard_intersect.width * discard_intersect.height;
			
			var keeper:int = -1;
			var targets:Array = [gameplay.dropMount, gameplay.dropCharacter, gameplay.dropWeapon, gameplay.dropBuff, gameplay.discardPile];
			var eligible:Array = [activeCard.hasMount, activeCard.hasCharacter, activeCard.hasWeapon, activeCard.hasBuff, activeCard.hasCardDraw];
			var overlaps:Array = [mount_area, character_area, weapon_area, buff_area, discard_area];
			
			var max_area:int = 0;
			activeDrop = null;
			for(var i:int = 0; i < targets.length; i++)
			{
				targets[i].gotoAndStop(1);
				if(eligible[i] && overlaps[i] > max_area && canDrop(activeCard, i))
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
			if(card is JoustCardMountCharacter)
			{
				return true;
			}
			
			if(workingStack[0] is JoustCardMountCharacter && slot == 1)
			{
				return true;
			}
			
			if(workingStack[1] is JoustCardMountCharacter && slot == 0)
			{
				return true;
			}
			
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
			}else if(activeDrop == gameplay.dropBuff){
				stack_index = 3;
			}else if(activeDrop == gameplay.discardPile){
				stack_index = 4;
			}
			
			var i:int;
			if(stack_index == 4)
			{
				discard.push(activeCard);
				for(i = 0; i < playerHands[1].length; i++)
				{
					if(playerHands[1][i] == activeCard)
					{
						playerHands[1][i] = null;
						handSlots[dragIndex].isEnabled = false;
					}
				}
				
				Actuate.tween(activeCard, 0.25, { 
					x:activeDrop.x,
					y:activeDrop.y
				});
				
				for(i = 0; i < activeCard.cardsToDraw; i++)
				{
					dealCardToPlayer();
				}
				return;
				
				
			}
			
			
			
			
			if(workingStack[stack_index] != null)
			{
				workingStack[stack_index].goHome();	
			}
			
			//HORSE STUFF
			
			if(activeDrop == gameplay.dropMount && workingStack[1] != null && workingStack[1] is JoustCardMountCharacter)
			{
				workingStack[1].goHome();
				workingStack[1] = null;
			}
			if(activeDrop == gameplay.dropCharacter && workingStack[0] != null && workingStack[0] is JoustCardMountCharacter)
			{
				workingStack[0].goHome();
				workingStack[0] = null;
			}
			
			if(activeCard is JoustCardMountCharacter && stack_index == 0 && workingStack[1] != null)
			{
				workingStack[1].goHome();
				workingStack[1] = null;
			}
			if(activeCard is JoustCardMountCharacter && stack_index == 1 && workingStack[0] != null)
			{
				workingStack[0].goHome();
				workingStack[0] = null;
			}
			
			//END HORSE STUFF
			
			
			workingStack[stack_index] = activeCard;
			var card_index:int = -1;
			for(i = 0; i < playerHands[1].length; i++)
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
			
			active_card.goHome = function(event:Event = null):void
			{
				active_card.removeEventListener(MouseEvent.CLICK, active_card.goHome);
				
				workingStack[stack_index] = null;
				playerHands[1][card_index] = active_card;
				
				updateLabels();
				
				refreshStack();
				
				Actuate.tween(active_card, 1, { 
					x:active_hand.x,
					y:active_hand.y
				}).onComplete(playerCardDealt, drag_index);
				
			}
			
			setTimeout(function():void{
				active_drop.gotoAndStop(1);
				active_card.addEventListener(MouseEvent.CLICK, active_card.goHome);
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
			var buff:JoustCardBuff = kingCardStack[3];
			
			var power:int = 0;
			var damageType:String = "";
			var weakness:String = "";
			var strength:String = "";
			
			if(rider is JoustCardMountCharacter)
			{
				mount = rider;
				rider = null;
				
				weakness = mount.characterWeakness;
				strength = mount.characterStrength;
			}else if(mount is JoustCardMountCharacter){
				weakness = mount.characterWeakness;
				strength = mount.characterStrength;
			}
			
			for(var i:int = 0; i < 3; i++)
			{
				if(kingStack[i] != null)
				{
					kingStack[i].stop();
					kingStack[i].parent.removeChild(kingStack[i]);
					kingStack[i] = null;
				}	
			}
			
			var mount_clip:MovieClip;
			var rider_clip:MovieClip;
			var weapon_clip:MovieClip;
			
			var klass:Class;
			
			if(mount != null)
			{
				klass = getDefinitionByName("MC_" + mount.cardName) as Class;
				mount_clip = new klass() as MovieClip;
				addChild(mount_clip);
				
				if(mount_clip.hasOwnProperty("character"))
				{
					mount_clip.character.graphic.visible = false;		
				}
				mount_clip.weapon.graphic.visible = false;
				
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
			
			if(buff != null)
			{
				power += buff.attackBuff;
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
			var buff:JoustCardBuff = challengerCardStack[3];
			
			
			var power:int = 0;
			var damageType:String = "";
			var weakness:String = "";
			var strength:String = "";
			
			if(rider is JoustCardMountCharacter)
			{
				mount = rider;
				rider = null;
				weakness = mount.characterWeakness;
				strength = mount.characterStrength;
			}else if(mount is JoustCardMountCharacter){
				weakness = mount.characterWeakness;
				strength = mount.characterStrength;
			}
			
			for(var i:int = 0; i < 3; i++)
			{
				if(challengerStack[i] != null)
				{
					challengerStack[i].stop();
					challengerStack[i].parent.removeChild(challengerStack[i]);
					challengerStack[i] = null;
				}	
			}
			
			var mount_clip:MovieClip;
			var rider_clip:MovieClip;
			var weapon_clip:MovieClip;
			
			var klass:Class;
			
			if(mount != null)
			{
				trace("ADDING MOUNT");
				klass = getDefinitionByName("MC_" + mount.cardName) as Class;
				mount_clip = new klass() as MovieClip;
				if(mount_clip.hasOwnProperty("character"))
				{
					mount_clip.character.graphic.visible = false;		
				}
				mount_clip.weapon.graphic.visible = false;
				addChild(mount_clip);
				
				mount_clip.x = gameplay.jouster2.x;
				mount_clip.y = gameplay.jouster2.y;
				
				mount_clip.scaleX = -1;
				
				challengerStack[0] = mount_clip;
				
				power += mount.mountDamage;
			}
			
			if(rider != null)
			{
				trace("ADDING RIDER");
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
				trace("ADDING WEAPON");
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
			
			if(buff != null)
			{
				power += buff.attackBuff;
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
		
		private var isGameOver:Boolean = false;
		public function updateLabels():void
		{
			if(isGameOver)
			{
				return;
			}
			
			var i:int;			
			for(i = 2; i <= 4; i++)
			{
				var hand_size:int = 0;
				for(var j:int = 0; j < playerHands[i].length; j++)
				{
					if(playerHands[i][j] != null)
					{
						hand_size++;
					}
				}
				gameplay["player" + i].handSize.text = hand_size.toString();
				gameplay["player" + i].victoryPoints.text = playerScores[i].toString();
				
				if(playerScores[i] >= VICTORY_SCORE)
				{
					isGameOver = true;
					dispatchEvent(new Event([null,"you","pug","cactus","monkey"][i]));
				}
			}
			
			if(playerScores[1] >= VICTORY_SCORE)
			{
				isGameOver = true;
				dispatchEvent(new Event("you"));
			}
			
			gameplay.victoryPoints.text = playerScores[1].toString();
			
			gameplay.deckCount.text = "DECK: " + deck.length;
		}
		
		public function dealCardToAI(player:int):void
		{
			if(deck.length == 0)
			{
				reshuffle();
			}
			
			var which:int = Math.floor(Math.random() * deck.length);
			var card:JoustCardBase = deck.splice(which, 1)[0];
			gameplay.deckCount.text = "DECK: " + deck.length;
			
			var empty:int = -1;
			//check for empties
			for(var i:int = 0; i < playerHands[player].length; i++)
			{
				if(playerHands[player][i] == null)
				{
					empty = i;
					break;
				}
			}
			
			if(empty == -1)
			{
				playerHands[player].push(card);
			}else{
				playerHands[player][empty] = card;
			}
			
			updateLabels();
			
			var target_x:Number = gameplay["player" + player].x;
			var target_y:Number = gameplay["player" + player].y;
			var target_duration:Number = 1.0;
			var target_rotation:Number = 180.0;
			
			addChild(card);
			card.x = gameplay.deckPile.x;
			card.y = gameplay.deckPile.y;
			card.scaleX = gameplay.hand1.scaleX;
			card.scaleY = gameplay.hand1.scaleY;
			
			Actuate.tween(card, target_duration, { 
				x:target_x,
				y:target_y,
				rotation:target_rotation
			});
			
			setTimeout(function():void{
				removeChild(card);
			}, target_duration * 1000);	
		}
		
		public function reshuffle():void
		{
			while(discard.length > 0)
			{
				var which:int = Math.floor(Math.random() * discard.length);
				var card:JoustCardBase = discard.splice(which, 1)[0];
				deck.push(card);
			}
			
			for(var i:int = 0; i < deck.length; i++)
			{
				deck[i].faceDown();
				
				deck[i].x = gameplay.deckPile.x;
				deck[i].y = gameplay.deckPile.y;
				
				deck[i].rotation = 0;
			}
		}
		
		public function dealCardToPlayer():void
		{
			if(deck.length == 0)
			{
				trace("OUT OF CARDS");
				reshuffle();
			}
			
			var which:int = Math.floor(Math.random() * deck.length);
			var card:JoustCardBase = deck.splice(which, 1)[0];
			
			gameplay.deckCount.text = "DECK: " + deck.length;
			
			var index:int = -1;
			//check for empties
			for(var i:int = 0; i < playerHands[1].length; i++)
			{
				if(playerHands[1][i] == null)
				{
					index = i + 1;
					break;
				}
			}
			
			if(index == -1)
			{
				index = playerHands[1].length + 1;
				playerHands[1].push(card);
			}else{
				playerHands[1][index-1] = card;
			}
			
			updateLabels();			
			
			var target_x:Number;
			var target_y:Number;
			var target_rotation:Number;
			var target_duration:Number = 1.0;
			
			addChild(card);
			card.x = gameplay.deckPile.x;
			card.y = gameplay.deckPile.y;
			card.scaleX = gameplay.hand1.scaleX;
			card.scaleY = gameplay.hand1.scaleY;
			
			if(index <= MAX_HAND_SIZE)
			{
				target_x = handSlots[index].x;
				target_y = handSlots[index].y;
				target_duration = 1.0;
				target_rotation = 180.0;
				
				Actuate.tween(card, target_duration, { 
					x:target_x,
					y:target_y,
					rotation:target_rotation
				}).onComplete (playerCardDealt,index);
			}else{
				card.faceUp();
				handleDiscard();
			}
		}
		
		
		public function handleDiscard():void
		{
			addChild(discardPop);
			
			for(var i:int = 0; i < playerHands[1].length; i++)
			{
				discardPop["hand" + (i+1)].holder.addChild(playerHands[1][i].copy());
				discardSlots[i+1].isEnabled = true;
			}
			
		}
		
		public function discardACard(event:Event):void
		{
			removeChild(discardPop);
			
			var index:int = parseInt(event.currentTarget.name);
			
			//card 8 is the easy case!
			if(index == 8)
			{
				var card:JoustCardBase = playerHands[1][index-1];
				playerHands[1][index-1] = null;
				discard.push(card);
				
				Actuate.tween(card, 0.5, { 
					x:gameplay.discardPile.x,
					y:gameplay.discardPile.y
				});
				return;
			}
			
			
			var discarded_card:JoustCardBase = playerHands[1][index - 1] as JoustCardBase;
			addChild(discarded_card);
			
			discarded_card.x = handSlots[index].x;
			discarded_card.y = handSlots[index].y;
			
			discarded_card.scaleX = gameplay.hand1.scaleX;
			discarded_card.scaleY = gameplay.hand1.scaleY;
			
			var new_card:JoustCardBase = playerHands[1][playerHands[1].length - 1];
			playerHands[1][index-1] = new_card;
			playerHands[1][playerHands[1].length - 1] = null;
			discard.push(discarded_card);
			
			Actuate.tween(discarded_card, 0.5, { 
				x:gameplay.discardPile.x,
				y:gameplay.discardPile.y
			});
			
			var target_x:Number = handSlots[index].x;
			var target_y:Number = handSlots[index].y;
			var target_duration:Number = 1.0
			
			Actuate.tween(new_card, target_duration, { 
				x:target_x,
				y:target_y
			}).onComplete (playerCardDealt,index);
			
		}
	}
}