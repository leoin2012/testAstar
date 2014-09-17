package
{
	import as3TankLib.event.ParamEvent;
	import as3TankLib.manager.TimerManager;
	import as3TankLib.util.Color;
	
	import findPath.FindPath8;
	
	import findWay.AStar;
	import findWay.Grid;
	import findWay.Node;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	[SWF(width = 1000, height = 600)]
	public class testAstar extends Sprite
	{
		private var _cells:Array = [];
		
		private var _grid:Grid;
		
		private var _astar:AStar = new AStar();
		
		private var COL:int = 50;
		
		private var ROW:int = 50;
		
		private var UNWALKABLE:Array = new Array(COL * ROW);
		
		private var _message:TextField;
		
		public function testAstar()
		{
			configWalkable();
			init();
			initText();
		}
		
		private function initText():void
		{
			_message = new TextField();
			_message.height = 20;
			_message.x = 100;
			_message.y = 100;
			_message.textColor = Color.RED;
			_message.background = true;
			_message.backgroundColor = Color.WHITE;
			_message.visible = false;
			addChild(_message);
		}
		
		private function configWalkable():void
		{
						
			for (var i:int = 0; i < COL; i++) 
			{
				UNWALKABLE[i] = [];
				for (var j:int = 0; j < ROW; j++) 
				{
					UNWALKABLE[i][j] = true;
				}
			}
			
			randomMaze();
		}
		
		/** 创建随机迷宫 */
		private function randomMaze():void
		{
			for (var i:int = 0; i < 500; i++) 
			{
				UNWALKABLE[int(COL * Math.random())][int(ROW * Math.random())] = false;
			}
		}
		
		private function init():void
		{
			var cell:Cell;
			_grid = new Grid(COL, ROW);
			
			for (var i:int = 0; i < COL; i++) 
			{
				_cells[i] = [];
				for (var j:int = 0; j < ROW; j++) 
				{
					cell = new Cell(i, j);
					this.addChild(cell);
					_cells[i][j] = cell;
					cell.x = i * (cell.width+1);
					cell.y = j * (cell.height+1);
					
					cell.walkable = UNWALKABLE[i][j];
					_grid.setWalkable(i, j, UNWALKABLE[i][j]);
					
					cell.addEventListener(Cell.SELECT, onCellSelect);
				}
			}
		}
		
		private function onCellSelect(evt:ParamEvent):void
		{
			if(_grid.startNode == null)
				_grid.setStartNode(evt.param[0], evt.param[1]);
			else
			{
				_grid.setEndNode(evt.param[0], evt.param[1]);
				var startTime:int = getTimer();
				if(_astar.findPath(_grid))
				{
					var endTime:int = getTimer();
					trace("寻路用时：" + ((endTime - startTime)/1000) + "ms");
					show("寻路用时：" + ((endTime - startTime)/1000) + "ms");
					
					var cell:Cell;
					for each (var arr:Array in _cells) 
					{
						for each (cell in arr) 
						{
							cell.refresh();
						}
					}
					for each (var node:Node in _astar.path) 
					{
						cell = _cells[node.x][node.y] as Cell;
						cell.draw();
					}
				}
				
				_grid.startNode = null;
				_grid.endNode = null;
			}
		}
		
		private function show(str:String):void
		{
			_message.visible = true;
			_message.text = str;
			setTimeout(hide, 2000);
			
			function hide():void
			{
				_message.visible = false;
			}
		}
		
	}
}