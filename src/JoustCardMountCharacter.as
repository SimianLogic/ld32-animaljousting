package
{
	import flash.display.MovieClip;

	public class JoustCardMountCharacter extends JoustCardBase
	{
		
		public static function getHorse():JoustCardMountCharacter
		{
			return new JoustCardMountCharacter("horse", "Horse", "poking", "distracting", 2, 6);
		}
		
		public var mc:CardMountCharacter;
		
		public function JoustCardMountCharacter(name:String, title:String, weakness:String, strength:String, intelligence:int, damage:int)
		{
			hasCharacter = true;
			hasMount = true;
			
			characterWeakness = weakness;
			characterStrength = strength;
			characterIntelligence = intelligence
			mountDamage = damage;

			//parity!
			characterSize = 0;
			mountSize = 0;

			mc = new CardMountCharacter();
			addChild(mc);
			
			super(name);
			
			trace("MOUNTCHARACTER: " + portrait);
			portrait.art.stop();
			
			mc.nameLabel.text = title;
			
			mc.damage.text = damage.toString();
			
			mc.weaknessDistraction.visible = (weakness == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.weaknessPoking.visible = (weakness == JoustCardWeapon.DAMAGE_POKING);
			mc.weaknessFood.visible = (weakness == JoustCardWeapon.DAMAGE_FOOD);
			
			mc.strengthDistraction.visible = (strength == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.strengthPoking.visible = (strength == JoustCardWeapon.DAMAGE_POKING);
			mc.strengthFood.visible = (strength == JoustCardWeapon.DAMAGE_FOOD);
			
			mc.brainBoxes.fill1.alpha = !(intelligence >= 1);
			mc.brainBoxes.fill2.alpha = !(intelligence >= 2);
			mc.brainBoxes.fill3.alpha = !(intelligence == 3);
			
		}
		
		override public function copy():JoustCardBase
		{
			return new JoustCardMountCharacter(cardName, mc.nameLabel.text, characterWeakness, characterStrength, characterIntelligence, mountDamage);
		}
	}
}