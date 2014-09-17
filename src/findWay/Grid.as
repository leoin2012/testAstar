package findWay
{
	public class Grid {
		public var startNode:Node; // 开始节点
		public var endNode:Node; // 目标节点
		public var nodes:Array; // 节点数组
		public var numRows:int; // 行数
		public var numCols:int; // 列数
		
		public function Grid(numCols:int, numRows:int) {
			this.numRows = numRows;
			this.numCols = numCols;
			nodes = [];
			for (var i:int = 0; i < numCols; i++) {
				nodes[i] = [];
				for (var j:int = 0; j < numRows; j++) {
					nodes[i][j] = new Node(i, j);
				}
			}
		}
		
		public function getNode(x:int, y:int):Node {
			return nodes[x][y] as Node;
		}
		
		public function setEndNode(x:int, y:int):void {
			endNode = nodes[x][y] as Node;
		}
		
		public function setStartNode(x:int, y:int):void {
			startNode = nodes[x][y] as Node;
		}
		
		public function setWalkable(x:int, y:int, value:Boolean):void {
			nodes[x][y].walkable = value;
		}
	}
}