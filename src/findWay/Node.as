package findWay
{
	public class Node {
		public var x:int; // X坐标
		public var y:int; // Y坐标
		public var f:Number; // 总代价
		public var g:Number; // 到起始结点的代价
		public var h:Number; // 到目标结点的代价
		public var walkable:Boolean = true; // 是否可穿越（通常把障碍物节点设置为false）
		public var parent:Node; // 该结点的父节点（即前一个结点）
		public var costMultiplier:Number = 1.0; // 代价因子
		public var isOpen:int = 0; // 是否在开放列表中 
		public var isClose:int = 0; // 是否在封闭列表中
		
		public function Node(x:int, y:int) {
			this.x = x;
			this.y = y;
		}
	}
}