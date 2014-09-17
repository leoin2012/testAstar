package
{
	import as3TankLib.event.ParamEvent;
	import as3TankLib.util.Color;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * 寻路格子
	 *@author Leo
	 */
	public class Cell extends Sprite
	{
		/** 选中格子 */
		public static const SELECT:String = "SELECT";
		
		private var _isMark:Boolean;
		/** 所处行 */
		private var row:int;
		/** 所处列 */
		private var col:int;
		
		private var SIDE_LENGTH:int = 10;
		
		/** 是否可走 */
		private var _walkable:Boolean;
		
		public function Cell(col:int, row:int)
		{
			this.col = col;
			this.row = row;
			initUI();
		}
		
		private function initUI():void
		{
			this.graphics.clear();
			this.graphics.beginFill(Color.BLACK);
			this.graphics.drawRect(0,0, SIDE_LENGTH, SIDE_LENGTH);
			this.graphics.endFill();
		}
		
		public function refresh():void
		{
			initUI();
			walkable = _walkable;
		}
		
		public function set walkable(value:Boolean):void
		{
			_walkable = value;
			if(!value)
			{
				this.graphics.clear();
				this.graphics.beginFill(Color.WHITE);
				this.graphics.drawRect(0,0, SIDE_LENGTH, SIDE_LENGTH);
				this.graphics.endFill();
			}else
			{
				this.graphics.clear();
				this.graphics.beginFill(Color.BLACK);
				this.graphics.drawRect(0,0, SIDE_LENGTH, SIDE_LENGTH);
				this.graphics.endFill();
				this.addEventListener(MouseEvent.CLICK, onMouseClick);
			}
		}
		
		public function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(Color.RED);
			this.graphics.drawRect(0,0, SIDE_LENGTH, SIDE_LENGTH);
			this.graphics.endFill();
		}
		
		private function onMouseClick(evt:MouseEvent):void
		{
			_isMark = !_isMark;
			if(_isMark)
			{
				this.graphics.clear();
				this.graphics.beginFill(Color.BLUE);
				this.graphics.drawRect(0,0, SIDE_LENGTH, SIDE_LENGTH);
				this.graphics.endFill();
			}
			else
			{
				this.graphics.clear();
				this.graphics.beginFill(Color.BLACK);
				this.graphics.drawRect(0,0, SIDE_LENGTH, SIDE_LENGTH);
				this.graphics.endFill();
			}
			this.dispatchEvent(new ParamEvent(SELECT, [col, row]));
		}
		
	}
}