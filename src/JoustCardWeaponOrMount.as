package
{
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;

	public class JoustCardWeaponOrMount extends JoustCardBase
	{
		public static var PogoStick:JoustCardWeaponOrMount = new JoustCardWeaponOrMount("pogostick", "Pogo Stick", 2, "poking", 2, 3, 1);	
		
		public var mc:CardWeaponOrMount;
		
		override public function get weaponString():String
		{
			return "MC_" + cardName + "_weapon";
		}
		
		public function JoustCardWeaponOrMount(name:String, title:String, weapon_damage:int, weapon_damageType:String, intelligence:int, size:int, mount_damage:int)
		{
			hasMount = true;
			hasWeapon = true;
			
			weaponDamage = weapon_damage;
			weaponDamageType = weapon_damageType;
			weaponIntelligence = intelligence;
			
			mountSize = size;
			mountDamage = mount_damage;
			
			mc = new CardWeaponOrMount();
			addChild(mc);
			
			super(name);
			mc.nameLabel.text = title;
			
			
			//WEAPON SIDE
			mc.damage.text = weapon_damage.toString();
			
			mc.damageDistraction.visible = (weapon_damageType == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.damagePoking.visible = (weapon_damageType == JoustCardWeapon.DAMAGE_POKING);
			mc.damageFood.visible = (weapon_damageType == JoustCardWeapon.DAMAGE_FOOD);
			
			mc.brainBoxes.fill1.alpha = !(intelligence <= 1);
			mc.brainBoxes.fill2.alpha = !(intelligence <= 2);
			mc.brainBoxes.fill3.alpha = !(intelligence <= 3);
			
			//MOUNT SIDE
			mc.damage.text = mount_damage.toString();
			
			mc.sizeBoxes.fill1.alpha = 0;  //1,2,3
			mc.sizeBoxes.fill2.alpha = !(size > 1);  //1,2
			mc.sizeBoxes.fill3.alpha = !(size > 2);  //3
		}
	}
}