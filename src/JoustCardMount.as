package
{
	import flash.display.MovieClip;
	
	public class JoustCardMount extends JoustCardBase
	{
		public static var all:Array = [
			new JoustCardMount("skateboard", "Skateboard", 1, 4),
			new JoustCardMount("roomba", "Robot Vacuum", 1, 3),
			new JoustCardMount("hampsterBall", "Hampster Ball", 1, 1),
			new JoustCardMount("drone", "Drone", 1, 3),
			
			new JoustCardMount("shoppingCart", "Shopping Cart", 2, 5),
			new JoustCardMount("wagon", "Wagon", 2, 4),
			new JoustCardMount("vacuum", "Vacuum Cleaner", 2, 2),
			new JoustCardMount("lawnmower", "Lawnmower", 2, 5),
			
			new JoustCardMount("tricycle", "Bicycle", 3, 6),
			new JoustCardMount("moped", "Moped", 3, 8),
			new JoustCardMount("gyrocopter", "Gyro Copter", 3, 6),
			new JoustCardMount("unicycle", "Unicycle", 3, 5)
		];
		
		public static function randomMount():JoustCardMount
		{
			var which:int = Math.floor(all.length * Math.random());			
			return all[which];
		}
		
		
		public var mc:CardMount;
		
		public function JoustCardMount(name:String, title:String, size:int, damage:int)
		{
			hasMount = true;
			
			mountSize = size;
			mountDamage = damage;
			
			mc = new CardMount();
			addChild(mc);
			
			super(name);
			
			portrait.art.character.graphic.visible = false;
			portrait.art.weapon.graphic.visible = false;
			
			mc.damage.text = damage.toString();
			mc.nameLabel.text = title;
			
			mc.sizeBoxes.fill1.alpha = 0;  //1,2,3
			mc.sizeBoxes.fill2.alpha = !(size > 1);  //1,2
			mc.sizeBoxes.fill3.alpha = !(size > 2);  //3
			
		}
	}
}