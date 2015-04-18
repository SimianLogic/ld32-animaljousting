package
{
	import flash.display.MovieClip;
	
	public class JoustCardWeapon extends JoustCardBase
	{
		public static var all:Array = [
			new JoustCardWeapon("lavalamp", "Lava Lamp", 5, DAMAGE_DISTRACTING, 2),
			new JoustCardWeapon("laserpointer", "Laser Pointer", 1, DAMAGE_DISTRACTING, 3),
			new JoustCardWeapon("bubblewand", "Bubble Wand", 1, DAMAGE_DISTRACTING, 1),
			new JoustCardWeapon("discoball", "Disco ball", 2, DAMAGE_DISTRACTING, 2),
			
			new JoustCardWeapon("chocolatefountain", "Chocolate Fountain", 4, DAMAGE_FOOD, 3),
			new JoustCardWeapon("toasterLauncher", "Toaster Launcher", 3, DAMAGE_FOOD, 2),
			new JoustCardWeapon("bananas", "Bananas", 1, DAMAGE_FOOD, 1),
			new JoustCardWeapon("ham", "Ham", 2, DAMAGE_FOOD, 1),
			
			new JoustCardWeapon("cardboardtube", "Cardboard Tube", 1, DAMAGE_POKING, 1),
			new JoustCardWeapon("mop", "Mop", 3, DAMAGE_POKING, 1),
			new JoustCardWeapon("flagpole", "Flag Pole", 4, DAMAGE_POKING, 1),
			new JoustCardWeapon("golfclub", "Golf Club", 2, DAMAGE_POKING, 1)
		];
		
		public static function randomWeapon():JoustCardWeapon
		{
			var which:int = Math.floor(all.length * Math.random());			
			return all[which];
		}
		
		
		public static var DAMAGE_POKING:String = "poking";
		public static var DAMAGE_DISTRACTING:String = "distracting";
		public static var DAMAGE_FOOD:String = "food";
		
		public var mc:CardWeapon;
		
		public var damage:int;
		public var damageType:String;
		
		public var intelligence:int;
		
		public function JoustCardWeapon(name:String, title:String, damage:int, damageType:String, intelligence:int)
		{
			this.damage = damage;
			this.damageType = damageType;
			this.intelligence = intelligence;
			
			mc = new CardWeapon();
			addChild(mc);
			
			super(name);
			
			portrait.x -= portrait.width/2;
			
			
			mc.nameLabel.text = title;
			mc.damage.text = damage.toString();
			
			mc.damageDistraction.visible = (damageType == DAMAGE_DISTRACTING);
			mc.damagePointing.visible = (damageType == DAMAGE_POKING);
			mc.damageFood.visible = (damageType == DAMAGE_FOOD);
			
			trace("INTELLIGENCE IS " + intelligence);
			mc.brainBoxes.fill1.alpha = !(intelligence <= 1);
			mc.brainBoxes.fill2.alpha = !(intelligence <= 2);
			mc.brainBoxes.fill3.alpha = !(intelligence <= 3);
		}
	}
}