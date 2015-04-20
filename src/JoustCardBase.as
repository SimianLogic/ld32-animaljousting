package
{
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	
	public class JoustCardBase extends MovieClip
	{
		//just so all these get compiled
		private var importedClasses:Array = [MC_wagon, MC_vacuum, MC_unicycle, MC_tricycle, 
			MC_toasterLauncher, MC_sloth, MC_skateboard, MC_shoppingCart, MC_roomba, 
			MC_pug, MC_pogostick, MC_panda, MC_moped, MC_mop, MC_monkey, MC_lawnmower,
			MC_lavalamp, MC_laserpointer, MC_horse, MC_hippo, MC_hampsterBall, 
			MC_hampster, MC_ham, MC_gyrocopter, MC_gorilla, MC_golfclub, MC_drone, 
			MC_frog, MC_flagpole, MC_ferret, MC_dog, MC_discoball, MC_chocolatefountain, 
			MC_chameleon, MC_cat, MC_cardboardtube, MC_cactus, MC_bubblewand, 
			MC_bananas, MC_baby, MC_pug_weapon, MC_pogostick_weapon, MC_cactus_weapon,
			
			MC_wagon_card, MC_vacuum_card, MC_unicycle_card, MC_tricycle_card, 
			MC_toasterLauncher_card, MC_sloth_card, MC_skateboard_card, MC_shoppingCart_card, MC_roomba_card, 
			MC_pug_card, MC_pogostick_card, MC_panda_card, MC_moped_card, MC_mop_card, MC_monkey_card, 
			MC_lavalamp_card, MC_horse_card, MC_hippo_card, MC_hampsterBall_card, 
			MC_hampster_card, MC_gyrocopter_card, MC_gorilla_card, MC_golfclub_card, MC_drone_card, 
			MC_frog_card, MC_flagpole_card, MC_ferret_card, MC_dog_card, MC_discoball_card, MC_chocolatefountain_card, 
			MC_chameleon_card, MC_cat_card, MC_cardboardtube_card, MC_cactus_card, MC_bubblewand_card, 
			MC_bananas_card, MC_baby_card, MC_lawnmower_card, 
			MC_laserpointer_card, 
			MC_ham_card
		];
		
		public var goHome:Function = null;
		
		public var cardName:String;
		public var portrait:MovieClip;
		
		public var hasWeapon:Boolean = false;
		public var hasCharacter:Boolean = false;
		public var hasMount:Boolean = false;
		
		public var hasCardDraw:Boolean = false;
		public var hasBuff:Boolean = false;
		
		public var cardsToDraw:int = 0;
		public var attackBuff:int = 0;
		
		//didn't feel like making interfaces, so lots of properties that a card CAN have come here into the base class...

		//WEAPON ATTRIBUTES
		public var weaponDamage:int;
		public var weaponDamageType:String;
		public var weaponIntelligence:int;
		
		//CHARACTER ATTRIBUTES
		public var characterSize:int;
		public var characterIntelligence:int;
		public var characterWeakness:String;
		public var characterStrength:String;
		
		//MOUNT ATTRIBUTES	
		public var mountSize:int;
		public var mountDamage:int;
		
		public function JoustCardBase(name:String)
		{
			super();
			
			this.name = name;
			this.cardName = name;
			
			if(!hasCardDraw && !hasBuff)
			{
				var graphic_mc:String = "MC_" + cardName + "_card";
				trace("LOAD " + graphic_mc);
				var klass:Class = getDefinitionByName(graphic_mc) as Class;
				portrait = new klass() as MovieClip;
				addChild(portrait);				
			}
		}
		
		public function get weaponString():String
		{
			return "MC_" + cardName;
		}
		
		//default to up until told otherwise
		private var isFaceUp:Boolean = true;
		private var cardBack:CardBack;
		public function faceDown():void
		{
			if(cardBack == null)
			{
				cardBack = new CardBack();
				addChild(cardBack);
			}
			
			cardBack.visible = true;
		}
		
		public function faceUp():void
		{
			if(cardBack == null) return;
			
			cardBack.visible = false;	
		}
		
		
		public function copy():JoustCardBase
		{
			throw new Error("OVERRIDE ME");
		}
	}
}