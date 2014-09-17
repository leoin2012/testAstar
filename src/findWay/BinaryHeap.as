package findWay
{
	/**
	 * 二叉堆数据结构 (小顶堆)
	 */        
	public class BinaryHeap {
		private var _data:Array; 
		private var _compareValue:String = "f"; // 依据结点的f值大小排序
		
		public function BinaryHeap() {
			_data = new Array();
		}
		
		/** 
		 *  向二叉堆中添加元素 
		 */
		public function push(node:Node):void {
			// 将新节点添至末尾先
			_data.push(node);
			var len:int = _data.length;
			
			// 若数组中只有一个元素则省略排序过程，否则对新元素执行上浮过程
			if (len > 1) {
				// 新添入节点当前所在位置（即第几个元素）
				var position:int = len;
				// 新节点当前父节点所在索引
				var parentIndex:int = position / 2 - 1;
				
				var temp:Node;
				
				// 和它的父节点（位置为当前位置除以2取整，比如第4个元素的父节点位置是2，第7个元素的父节点位置是3）比较，
				// 如果新元素比父节点元素小则交换这两个元素，然后再和新位置的父节点比较，直到它的父节点不再比它大，
				// 或者已经到达顶端，及第1的位置
				while (compareTwoNodes(node, _data[parentIndex])) {
					temp = _data[parentIndex];
					_data[parentIndex] = node;
					_data[position - 1] = temp;
					position = position >> 1;
					parentIndex = position / 2 - 1;
				}
			}
		}
		
		///
		/// 以下可优化，直接将头和尾元素交换，然后取出尾的值
		///
		///
		///
		///
		
		
		/**
		 *  弹出开启列表中第一个元素
		 */ 
		public function shift():Node {
			// 先弹出列首元素
			var result:Node = _data.shift();
			
			/// 数组长度 
			var len:int = _data.length;
			
			// 若弹出列首元素后数组空了或者其中只有一个元素了则省略排序过程，否则对列尾元素执行下沉过程
			if(len > 1) {
				// 列尾节点
				var lastNode:Node = _data.pop();
				
				// 将列尾元素排至首位，因为取出列尾元素不用改变数组中其它元素的位置，效率较高
				_data.unshift(lastNode);
				
				// 末尾节点当前所在索引 
				var index:int = 0;
				
				// 末尾节点当前第一子节点所在索引
				var childIndex:int = ((index + 1) << 1) - 1;
				
				// 末尾节点当前两个子节点中较小的一个的索引 
				var comparedIndex:int;
				
				var temp:Node;
				
				// 和它的两个子节点比较，如果较小的子节点比它小就将它们交换，直到两个子节点都比它大
				while (childIndex < len) {
					
					if (childIndex + 1 == len ) {
						// 只有一个子节点的情况
						comparedIndex = childIndex;
					} else {
						// 有两个子节点则取其中较小的那个的索引
						comparedIndex = compareTwoNodes(_data[childIndex], _data[childIndex + 1]) 
							? childIndex : childIndex + 1;
					}
					
					if (compareTwoNodes(_data[comparedIndex], lastNode)) {
						// 子节点小于父节点，则交换它们的位置
						temp = _data[comparedIndex];
						_data[comparedIndex] = lastNode;
						_data[index] = temp;
						index = comparedIndex;
						childIndex = ((index + 1) << 1) - 1;
					} else {
						break;
					}
				}
			}
			
			return result;
		}
		
		///
		/// 以下可优化，indexOf损耗很大，可以采用别的形式获得结点
		///
		///
		///
		
		/**
		 *  更新某一个节点的值
		 */  
		public function updateNode(node:Node):void {
			var index:int = _data.indexOf(node) + 1;
			if (index != 0) {
				var parentIndex:int = index / 2 - 1;
				var temp:Object;
				
				// 将二叉堆重新排序
				while (compareTwoNodes(node, _data[parentIndex])) {
					temp = _data[parentIndex];
					_data[parentIndex] = node;
					_data[index - 1] = temp;
					index = index >> 1;
					parentIndex = index / 2 - 1;
				}
			}
		}
		
		/**
		 *  比较两个节点，返回true则表示第一个节点小于第二个
		 */
		private function compareTwoNodes(node1:Node, node2:Node):Boolean {
			return node1[_compareValue] < node2[_compareValue];
			return false;
		} 
		
		public function indexOf(node:Node):int {
			return _data.indexOf(node);
		}
		
		public function get length():uint {
			return _data.length;
		}
	}
}