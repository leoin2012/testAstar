package findWay
{
	import flash.geom.Point;
	
	public class AStar {
		private var _open:BinaryHeap; // 开放列表
		private var _close:Array; // 封闭列表
		private var _grid:Grid;
		private var _startNode:Node; // 开始节点
		private var _endNode:Node; // 目标节点
		private var _path:Array; // 最终的路径节点
		private var _heuristic:Function = diagonal; //估计公式
		private var _straightCost:Number = 1.0; //直线代价        
		private var _diagCost:Number = 1.4; //对角线代价   
//		private var _diagCost:Number = Math.SQRT2; //对角线代价   
		private var _useNum:int = 0; // 寻路次数，用于重置节点在开放或封闭列表的状态
		private var _maxCostMultiplier:Number = 10000;
		
		public function AStar() {
		}
		
		/**
		 *  对指定的网络寻找路径
		 */ 
		public function findPath(grid:Grid):Boolean {
			_grid = grid;
			_open = new BinaryHeap();
			_close = new Array();
			_startNode = _grid.endNode;
			_endNode = _grid.startNode;
			_startNode.g = 0;
			_startNode.h = diagonal(_startNode);
			_startNode.f = _startNode.g + _startNode.h;
			_useNum++; // 寻路次数加1
			_path = [];
			
			// 如果两点之间没有障碍物，则直接返回起始点和终点作为路径
			if (isCrossAble(_startNode, _endNode)) {
				_path.push(_endNode);
				_path.push(_startNode);
				return true;
			} else {
				return search();
			}
		}
		
		/**
		 *  计算周围节点代价
		 */ 
		public function search():Boolean {
			// 如果开始节点和目标节点为同一节点，则终止寻路
			if (_startNode == _endNode)
				return false;
			
			var node:Node = _startNode;
			
			// 如果当前节点不是终点
			while (node != _endNode) {
				// 找出相邻节点的x,y范围
				var startX:int = node.x - 1 < 0 ? 0 : node.x - 1;
				var endX:int = node.x + 1 > _grid.numCols - 1 ? _grid.numCols - 1 : node.x + 1;
				var startY:int = node.y - 1 < 0 ? 0 : node.y - 1;
				var endY:int = node.y + 1 > _grid.numRows - 1 ? _grid.numRows - 1 : node.y + 1;
				
				// 循环处理所有相邻节点
				for (var i:int = startX; i <= endX; i++) {
					for (var j:int = startY; j <= endY; j++) {
						var temp:Node = _grid.getNode(i, j); 
						
						// 如果是当前节点则跳过
						if (temp == node)
							continue;
						
						if (!temp.walkable || (!_grid.getNode(node.x, temp.y).walkable 
							&& !_grid.getNode(temp.x, node.y).walkable)) {
							// 将不可通过的节点的行走代价设为一个较大的值 
							temp.costMultiplier = _maxCostMultiplier;  
						} else {
							temp.costMultiplier = 1;
						}
						
						var cost:Number = _straightCost;   
						
						// 如果是对象线，则使用对角代价
						if (node.x != temp.x && node.y != temp.y)
							cost = _diagCost;
						
						// 计算当前节点的总代价                      
						var g:Number = node.g + cost * temp.costMultiplier;
						var h:Number = _heuristic(temp);                      
						var f:Number = g + h;                 
						
						if (temp.isOpen == _useNum || temp.isClose == _useNum) {
							// 如果该点在open或close列表中
							if (f < temp.f) {
								// 如果本次计算的代价更小，则以本次计算为准
								temp.f = f;
								temp.g = g;
								temp.h = h;
								temp.parent = node;// 重新指定该点的父节点为本轮计算中心点
							}
						} else {
							// 如果还不在open列表中，则除了更新代价以及设置父节点，还要加入open数组
							temp.f = f;
							temp.g = g;
							temp.h = h;
							temp.parent = node;
							temp.isOpen = _useNum;
							_open.push(temp);
						}
					}
				}
				
				// 把处理过的本轮中心节点加入close节点  
				node.isClose = _useNum;
				_close.push(node);              
				
				// 如果一个可走的节点都没有找到，则说明无路可走
				if (_open.length == 0)
					return false
				
				// 从open数组中删除代价最小的结节，同时把该节点赋值为node，做为下次的中心点
				node = _open.shift() as Node;
			}
			//循环结束后，构建路径
			buildPath();
			return true;
		}
		
		/**
		 *  根据父节点指向，从终点的父节点反向连接到起点
		 */ 
		private function buildPath():void {
			_path.push(_endNode);
			
			var startNode:Node = _endNode;
			var endNode:Node = startNode.parent;
			
			// 如果开始起点不等于寻路起点并且当前节点可通过
			while (startNode != _startNode && (endNode.walkable && 
				(_grid.getNode(startNode.x, endNode.y).walkable || _grid.getNode(endNode.x, startNode.y).walkable))) {
				_path.push(endNode);
				
				startNode = endNode;
				endNode = startNode.parent;
			}
			
			// 调用弗洛伊德路径平滑算法处理路径
			floyd();
		}
		
		/**
		 *  弗洛伊德路径平滑处理 
		 */
		public function floyd():void {
			if (_path == null)
				return;
			
			var len:int = _path.length;
			var i:int;
			
			// 路径节点数大于2才进行平滑处理
			if (len > 2) {
				var vector:Node = new Node(0, 0);
				var tempVector:Node = new Node(0, 0);
				
				// 遍历路径数组中全部路径节点，合并在同一直线上的路径节点
				// 假设有1,2,3,三点，若2与1的横、纵坐标差值分别与3与2的横、纵坐标差值相等则
				// 判断此三点共线，此时可以删除中间点2
				floydVector(vector, _path[len - 1], _path[len - 2]);
				for (i = len - 3; i >= 0; i--) {
					floydVector(tempVector, _path[i + 1], _path[i]);
					if (vector.x == tempVector.x && vector.y == tempVector.y) {
						_path.splice(i + 1, 1);
					} else {
						vector.x = tempVector.x;
						vector.y = tempVector.y;
					}
				}
			}
			
			// 合并共线节点后进行第二步，消除拐点操作。算法流程如下：
			// 如果一个路径由1-10十个节点组成，那么由节点10从1开始检查
			// 节点间是否存在障碍物，若它们之间不存在障碍物，则直接合并
			// 此两路径节点间所有节点。
			len = _path.length;
			for (i = len - 1; i >= 0; i--) {
				for (var j:int = 0; j < i - 1; j++) {
					if (isCrossAble(_path[i], _path[j])) {
						for (var k:int = i - 1; k > j; k--) {
							_path.splice(k, 1);
						}
						
						i = j;
						len = _path.length;
						break;
					}
				}
			}
		}
		
		/**
		 *  布兰森汉姆算法，获得两点所连成的直线经过的点，并判断是否有障碍物,
		 *  从而判断两点之间是否可以直接通过
		 */
		private function isCrossAble(n1:Node, n2:Node):Boolean {
			var p1:Point = new Point(n1.x, n1.y);
			var p2:Point = new Point(n2.x, n2.y);
			
			// 两点连成的直线倾斜度大于45度（即斜率不在0-1之间）
			var steep:Boolean = Math.abs(p2.y - p1.y) > Math.abs(p2.x - p1.x);
			
			// 如果直线斜率不在0-1之间，则交换x和y坐标的值，使斜率在0-1之间
			if (steep) {
				var temp:int = p1.x;
				p1.x = p1.y;
				p1.y = temp;
				temp = p2.x;
				p2.x = p2.y;
				p2.y = temp;
			}
			
			// 下一个点在x轴的步长
			var stepX:int = p2.x > p1.x ? 1 : (p2.x < p1.x ? -1 : 0);
			
			// 下一个点在y轴上的误差值，通过公式推导可得这个误差值等于直线的斜率
			var deltay:Number = (p2.y - p1.y) / Math.abs(p2.x - p1.x);
			if(p2.x == p1.x)deltay = 0;
			
			// 得到下一个点在X轴和Y轴上的取值
			var nowX:Number = p1.x + stepX;
			var nowY:Number = p1.y + deltay;
			
			// 如果起点就是障碍物，则直接不可穿透
			if (steep) {
				if (isBarrier(p1.y, p1.x)) return false;
			} else {
				if (isBarrier(p1.x, p1.y)) return false;
			}
			
			// 如果斜率等于1（即倾斜度为45度）
			if (Math.abs(p1.x - p2.x) == Math.abs(p1.y - p2.y)) {
				if (p1.x < p2.x && p1.y < p2.y) {
					if (isBarrier(p1.x, p1.y + 1) || isBarrier(p1.x, p1.y - 1))
						return false;
				} else if (p1.x > p2.x && p1.y > p2.y) {
					if (isBarrier(p1.x, p1.y - 1) || isBarrier(p1.x, p1.y + 1))
						return false;
				} else if (p1.x < p2.x && p1.y > p2.y) {
					if (isBarrier(p1.x, p1.y - 1) || isBarrier(p2.x, p2.y + 1))
						return false;
				} else if (p1.x > p2.x && p1.y < p2.y) {
					if (isBarrier(p1.x, p1.y + 1) || isBarrier(p2.x, p2.y - 1))
						return false;
				}
			}
			
			// 当前x的值不等于终点的x的值时
			while (nowX != p2.x) {
				var fy:int = Math.floor(nowY)
				var cy:int = Math.ceil(nowY);
				if (steep) {
					if (isBarrier(fy, nowX)) return false;
				} else {
					if (isBarrier(nowX, fy)) return false;
				}
				
				if (fy != cy) {
					if (steep) {
						if (isBarrier(cy, nowX)) return false;
					} else {
						if (isBarrier(nowX, cy)) return false;
					}
				} else if(deltay != 0) {
					if (steep) {
						if (isBarrier(cy+1, nowX) || isBarrier(cy-1, nowX))
							return false;
					}else{
						if (isBarrier(nowX, cy+1) || isBarrier(nowX, cy-1))
							return false;
					}
				}
				nowX += stepX;
				nowY += deltay;
			}
			
			if (steep) {
				if (isBarrier(p2.y, p2.x)) return false;
			}else {
				if (isBarrier(p2.x, p2.y)) return false;
			}
			return true;
		}
		
		/**
		 *  计算两点
		 */
		private function floydVector(target:Node, n1:Node, n2:Node):void {
			target.x = n1.x - n2.x;
			target.y = n1.y - n2.y;
		}
		
		/**
		 *  判断节点是否为障碍物
		 */
		private function isBarrier(x:int, y:int):Boolean {
			return !_grid.getNode(x, y).walkable;
		}
		
		/**
		 *  曼哈顿估价法
		 */
		private function manhattan(node:Node):Number {
			return Math.abs(node.x - _endNode.x) * _straightCost + Math.abs(node.y - _endNode.y) * _straightCost;
		}
		
		/**
		 *  几何估价法
		 */
		private function euclidian(node:Node):Number {
			var dx:Number=node.x - _endNode.x;
			var dy:Number=node.y - _endNode.y;
			return Math.sqrt(dx * dx + dy * dy) * _straightCost;
		}
		
		/**
		 *  对角线估价法（估算节点到目标节点的代价）
		 */ 
		private function diagonal(node:Node):Number {
			var dx:Number = Math.abs(node.x - _endNode.x);
			var dy:Number = Math.abs(node.y - _endNode.y);
			var diag:Number = Math.min(dx, dy);
			var straight:Number = dx + dy;
			return _diagCost * diag + _straightCost * (straight - 2 * diag);
		}
		
		public function get visited():Array {
			return _close.concat(_open);
		}
		
		public function get openArray():BinaryHeap {
			return this._open;
		}
		
		public function get closedArray():Array {
			return this._close;
		}
		
		public function get path():Array {
			return _path;
		}
	}
}