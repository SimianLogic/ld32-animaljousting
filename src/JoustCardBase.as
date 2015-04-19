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
		];
		
		
		public var cardName:String;
		public var portrait:MovieClip;
		
		public var hasWeapon:Boolean = false;
		public var hasCharacter:Boolean = false;
		public var hasMount:Boolean = false;
		
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
			
			this.cardName = name;
			
			var graphic_mc:String = "MC_" + cardName;
			trace("LOAD " + graphic_mc);
			var klass:Class = getDefinitionByName(graphic_mc) as Class;
			portrait = new klass() as MovieClip;
			addChild(portrait);
			
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
	}
}