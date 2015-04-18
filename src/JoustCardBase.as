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
			MC_hampster, MC_ham, MC_gyrocopter, MC_gorilla, MC_golfclub, MC_glider, 
			MC_frog, MC_flagpole, MC_ferret, MC_dog, MC_discoball, MC_chocolatefountain, 
			MC_chameleon, MC_cat, MC_cardboardtube, MC_cactus, MC_bubblewand, 
			MC_bananas, MC_baby];
		
		
		public var cardName:String;
		public var portrait:MovieClip;
		
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
		
	}
}