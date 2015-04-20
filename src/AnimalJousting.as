package
{
	import com.eclecticdesignstudio.motion.Actuate;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	
	[SWF(width="1024", height="768")]
	public class AnimalJousting extends Sprite
	{
		
		public var game:JoustGameplayScreen;
		public var splash:UISplash;
		public var gameover:UIWin;
		
		
		public static var musicEnabled:Boolean = true;
		public static var soundEnabled:Boolean = true;		
		
		public function AnimalJousting()
		{
			stage.color = 0xCC33FF;
			splash = new UISplash(); 
			addChild(splash);
			
			splash.playButton.addEventListener(MouseEvent.CLICK, playGame);
			playMusic();
		}
		
		public static var button:sfx_pop;
		public static function buttonSound():void
		{
			if(button == null)
			{
				button = new sfx_pop();
			}
			
			if(soundEnabled)
			{
				(button as Sound).play();	
			}
		}
		
		public static var motor:sfx_motorRumble;
		public static function motorSound():void
		{
			if(motor == null)
			{
				motor = new sfx_motorRumble();
			}
			
			if(soundEnabled)
			{
				(motor as Sound).play();	
			}
		}
		
		public static var newKing:sfx_hornBlow;
		public static function newKingSound():void
		{
			if(newKing == null)
			{
				newKing = new sfx_hornBlow();
			}
			
			if(soundEnabled)
			{
				(newKing as Sound).play();	
			}
		}
		
		private static var musicSounds:Array;
		private static var musicChannel:SoundChannel;
		public static function playMusic():void
		{
			if(musicSounds == null)
			{
				musicSounds = [new Loop1Court(), new Loop2Court(), new Loop3Court()];
			}
			
			var which:int = Math.floor(Math.random() * musicSounds.length);
			musicChannel = musicSounds[which].play(0);
			musicChannel.addEventListener(Event.SOUND_COMPLETE, musicLoop);			
		}
		
		//  this is called when the sound channel completes.
		public static function musicLoop(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.SOUND_COMPLETE, musicLoop);
			if(musicEnabled)
			{
				playMusic();	
			}
		}
		
		public static function stopMusic():void
		{
			musicChannel.stop();	
		}
		
		public function playGame(e:Event):void
		{
			
			AnimalJousting.buttonSound();
			stage.color = 0xffffff;
			
			if(game != null && contains(game))
			{
				removeChild(game);
			}
			
			game = new JoustGameplayScreen();
			addChild(game);			
			
			splash.stop();
			if(contains(splash))
			{
				removeChild(splash);	
			}
			
			
			if(gameover != null)
			{
				removeChild(gameover);
			}
			
			game.addEventListener("you",showGameOver);
			game.addEventListener("pug",showGameOver);
			game.addEventListener("cactus",showGameOver);
			game.addEventListener("monkey",showGameOver);
		}
		
		
		public function showGameOver(e:Event):void
		{
			if(gameover == null)
			{
				gameover = new UIWin();
				gameover.again.addEventListener(MouseEvent.CLICK, playGame);
			}
			
			gameover.gotoAndStop(e.type);
			
			removeChild(game);
			addChild(gameover);
		}
		
		
	}
}