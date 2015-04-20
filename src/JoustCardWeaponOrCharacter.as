package
{
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;

	public class JoustCardWeaponOrCharacter extends JoustCardBase
	{
		
		public static function getPug():JoustCardWeaponOrCharacter
		{
			return new JoustCardWeaponOrCharacter("pug", "Pug", 3, "distracting", 2, "food", "poking", 1, 1);
		}
		public static function getCactus():JoustCardWeaponOrCharacter
		{
			return new JoustCardWeaponOrCharacter("cactus", "Cactus", 5, "poking", 2, "food", "poking", 1, 2);
		}
		
		public var mc:CardWeaponOrCharacter;
		
		override public function get weaponString():String
		{
			return "MC_" + cardName + "_weapon";
		}
		
		override public function copy():JoustCardBase
		{
			return new JoustCardWeaponOrCharacter(cardName, mc.nameLabel.text, weaponDamage, weaponDamageType, weaponIntelligence, characterWeakness, characterStrength, characterIntelligence, characterSize);
		}
		
		public function JoustCardWeaponOrCharacter(name:String, title:String, weapon_damage:int, weapon_damageType:String, weapon_intelligence:int, weakness:String, strength:String, character_intelligence:int, size:int)
		{
			hasWeapon = true;
			hasCharacter = true;
			
			weaponDamage = weapon_damage;
			weaponDamageType = weapon_damageType;
			weaponIntelligence = weapon_intelligence;
			
			characterWeakness = weakness;
			characterStrength = strength;
			
			characterIntelligence = character_intelligence;
			characterSize = size;
			
			mc = new CardWeaponOrCharacter();
			addChild(mc);
			
			super(name);		
			
			mc.nameLabel.text = title;
			
			
			//WEAPON SIDE
			mc.damage.text = "+" + weapon_damage;
			
			mc.damageDistraction.visible = (weapon_damageType == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.damagePoking.visible = (weapon_damageType == JoustCardWeapon.DAMAGE_POKING);
			mc.damageFood.visible = (weapon_damageType == JoustCardWeapon.DAMAGE_FOOD);
			
			mc.brainBoxes2.fill1.alpha = !(weapon_intelligence <= 1);
			mc.brainBoxes2.fill2.alpha = !(weapon_intelligence <= 2);
			mc.brainBoxes2.fill3.alpha = !(weapon_intelligence <= 3);
			
			//CHARACTER SIDE
			mc.weaknessDistraction.visible = (weakness == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.weaknessPoking.visible = (weakness == JoustCardWeapon.DAMAGE_POKING);
			mc.weaknessFood.visible = (weakness == JoustCardWeapon.DAMAGE_FOOD);
			
			mc.strengthDistraction.visible = (strength == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.strengthPoking.visible = (strength == JoustCardWeapon.DAMAGE_POKING);
			mc.strengthFood.visible = (strength == JoustCardWeapon.DAMAGE_FOOD);
			
			
			mc.brainBoxes.fill1.alpha = !(character_intelligence >= 1);
			mc.brainBoxes.fill2.alpha = !(character_intelligence >= 2);
			mc.brainBoxes.fill3.alpha = !(character_intelligence == 3);
			
			mc.sizeBoxes.fill1.alpha = !(size == 1);
			mc.sizeBoxes.fill2.alpha = !(size == 2);
			mc.sizeBoxes.fill3.alpha = !(size == 3);
		}
		
		
	}
}