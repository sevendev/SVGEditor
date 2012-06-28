package component.color.gradient 
{

	public class GradientVo
	{
		public var id:uint;
		public var color:uint;
		public var alpha:Number;
		public var offset:Number;
		
		public function GradientVo( id:uint , color:uint , alpha:Number , offset:Number ) 
		{
			this.id = id;
			this.color = color;
			this.alpha = alpha;
			this.offset = offset;
		}
		
	}

}