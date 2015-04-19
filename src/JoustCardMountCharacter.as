package
{
	import flash.display.MovieClip;

	public class JoustCardMountCharacter extends JoustCardBase
	{
		
		public static var Horse:JoustCardMountCharacter = new JoustCardMountCharacter("horse", "Horse", "poking", "distracting", 8);
		
		public var mc:CardMountCharacter;
		
		public function JoustCardMountCharacter(name:String, title:String, weakness:String, strength:String, damage:int)
		{
			hasCharacter = true;
			hasMount = true;
			
			characterWeakness = weakness;
			characterStrength = strength;
			mountDamage = damage;

			//parity!
			characterSize = 0;
			mountSize = 0;

			mc = new CardMountCharacter();
			addChild(mc);
			
			super(name);
			
			portrait.y += 16;
			
			mc.nameLabel.text = title;
			
			mc.damage.text = damage.toString();
			
			mc.weaknessDistraction.visible = (weakness == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.weaknessPointing.visible = (weakness == JoustCardWeapon.DAMAGE_POKING);
			mc.weaknessFood.visible = (weakness == JoustCardWeapon.DAMAGE_FOOD);
			
			mc.strengthDistraction.visible = (strength == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.strengthPointing.visible = (strength == JoustCardWeapon.DAMAGE_POKING);
			mc.strengthFood.visible = (strength == JoustCardWeapon.DAMAGE_FOOD);
			
		}
	}
}