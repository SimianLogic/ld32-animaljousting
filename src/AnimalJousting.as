package
{
	import com.eclecticdesignstudio.motion.Actuate;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	
	[SWF(width="1024", height="768")]
	public class AnimalJousting extends Sprite
	{
		
		public var game:JoustGameplayScreen;
		public var splash:UISplash;
		
		
		public static var musicEnabled:Boolean = true;
		public static var soundEnabled:Boolean = true;		
		
		public function AnimalJousting()
		{
			stage.color = 0xCC33FF;
			splash = new UISplash(); 
			addChild(splash);
			
			splash.playButton.addEventListener(MouseEvent.CLICK, playGame);

		}
		
		public static var buttonSound:sfx_pop;
		public static function buttonPressed():void
		{
			if(buttonSound == null)
			{
				buttonSound = new sfx_pop();
			}
			
			if(soundEnabled)
			{
				(buttonSound as Sound).play();	
			}
		}
		
		public function playGame(e:Event):void
		{
			
			AnimalJousting.buttonPressed();
			stage.color = 0xffffff;
			
			game = new JoustGameplayScreen();
			addChild(game);			
			
			splash.stop();
			removeChild(splash);
		}
		
		
	}
}