package
{
	import flash.display.MovieClip;
	
	public class JoustCardCharacter extends JoustCardBase
	{
		public static var all:Array = [
			new JoustCardCharacter("dog", "Dog", "food", "poking", 3, 2),
			new JoustCardCharacter("gorilla", "Gorilla", "food", "poking", 3, 3),
			new JoustCardCharacter("panda", "Panda", "food", "poking", 3, 1),
			new JoustCardCharacter("hippo", "Hippo", "food", "distracting", 3, 2),
			
			new JoustCardCharacter("cat", "Cat", "distracting", "food", 2, 3),
			new JoustCardCharacter("monkey", "Monkey", "distracting", "poking", 2, 3),
			new JoustCardCharacter("sloth", "Sloth", "poking", "distracting", 2, 1),
			new JoustCardCharacter("baby", "Baby", "distracting", "food", 2, 1),
			
			new JoustCardCharacter("frog", "Frog", "poking", "food", 1, 1),
			new JoustCardCharacter("chameleon", "Chameleon", "distracting", "poking", 1, 3),
			new JoustCardCharacter("hampster", "Hampster", "poking", "distracting", 1, 2),
			new JoustCardCharacter("ferret", "Ferret", "distracting", "poking", 1, 2),
		]
			
		public static function randomCharacter():JoustCardCharacter
		{
			var which:int = Math.floor(all.length * Math.random());			
			return all[which];
		}
		
		
		public var mc:CardCharacter;
		
		public function JoustCardCharacter(name:String, title:String, weakness:String, strength:String, size:int, intelligence:int)
		{
			hasCharacter = true;
			
			characterWeakness = weakness;
			characterStrength = strength;
			
			characterIntelligence = intelligence;
			characterSize = size;
			
			mc = new CardCharacter();
			addChild(mc);
			
			super(name);
			
			mc.nameLabel.text = title;
			
			mc.weaknessDistraction.visible = (weakness == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.weaknessPoking.visible = (weakness == JoustCardWeapon.DAMAGE_POKING);
			mc.weaknessFood.visible = (weakness == JoustCardWeapon.DAMAGE_FOOD);
			
			mc.strengthDistraction.visible = (strength == JoustCardWeapon.DAMAGE_DISTRACTING);
			mc.strengthPoking.visible = (strength == JoustCardWeapon.DAMAGE_POKING);
			mc.strengthFood.visible = (strength == JoustCardWeapon.DAMAGE_FOOD);
			
			
			mc.brainBoxes.fill1.alpha = !(intelligence >= 1);
			mc.brainBoxes.fill2.alpha = !(intelligence >= 2);
			mc.brainBoxes.fill3.alpha = !(intelligence == 3);
			
			mc.sizeBoxes.fill1.alpha = !(size == 1);
			mc.sizeBoxes.fill2.alpha = !(size == 2);
			mc.sizeBoxes.fill3.alpha = !(size == 3);
		}
		
		override public function copy():JoustCardBase
		{
			return new JoustCardCharacter(cardName, mc.nameLabel.text, characterWeakness, characterStrength, characterSize, characterIntelligence);
		}
	}
}