package
{
	import flash.display.MovieClip;
	
	public class JoustCardMount extends JoustCardBase
	{
		public static var all:Array = [
			new JoustCardMount("skateboard", "Skateboard", 1, 4),
			new JoustCardMount("roomba", "Robot Vacuum", 1, 3),
			new JoustCardMount("hampsterBall", "Hampster Ball", 1, 1),
			new JoustCardMount("gyrocopter", "Gyro Copter", 1, 3),
			
			new JoustCardMount("shoppingCart", "Shopping Cart", 1, 5),
			new JoustCardMount("wagon", "Wagon", 1, 4),
			new JoustCardMount("vacuum", "Vacuum Cleaner", 1, 2),
			new JoustCardMount("lawnmower", "Lawnmower", 1, 5),
			
			new JoustCardMount("tricycle", "Tricycle", 1, 6),
			new JoustCardMount("moped", "Moped", 1, 8),
			new JoustCardMount("glider", "Glider", 1, 6),
			new JoustCardMount("unicycle", "Unicycle", 1, 5)
		];
		
		public static function randomMount():JoustCardMount
		{
			var which:int = Math.floor(all.length * Math.random());			
			return all[which];
		}
		
		
		public var mc:CardMount;
		
		public var size:int;
		public var damage:int;
		
		public function JoustCardMount(name:String, title:String, size:int, damage:int)
		{
			this.size = size;
			this.damage = damage;
			
			mc = new CardMount();
			addChild(mc);
			
			super(name);
			
			portrait.y += 16;
			
			mc.damage.text = damage.toString();
			mc.nameLabel.text = title;
			
			mc.sizeBoxes.fill1.alpha = !(size <= 1);
			mc.sizeBoxes.fill2.alpha = !(size <= 2);
			mc.sizeBoxes.fill3.alpha = !(size <= 3);
			
		}
	}
}