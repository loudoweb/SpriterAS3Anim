package com.acemobe.spriter.data
{
	public class Animation
	{
		public	static	var	NO_LOOPING:int = 0;
		public	static	var	LOOPING:int = 1;
		
		public	var	id:int = 0;
		public	var	name:String = "";
		public	var	loopType:int = LOOPING;
		public	var	length:int = 0;
		
		public	var	mainlineKeys:Array = [];
		public	var	timelines:Array = [];

		public	var	currentTime:int = 0;

		public	var	objectKeys:Array = [];

		public function Animation()
		{
		}
		
		public	function parse (animationXml:XML):void
		{
			if (animationXml.attribute("id").length())
				id = animationXml.@id;
			if (animationXml.attribute("name").length())
				name = animationXml.@name;
			if (animationXml.attribute("length").length())
				length = animationXml.@length;
			if (animationXml.attribute("looping").length())
			{
				if (animationXml.@looping == "true")
					loopType = LOOPING;
				else
					loopType = NO_LOOPING;
			}
			
			for each(var mainlineXml:XML in animationXml.mainline.key)
			{				
				var	mainline:MainlineKey = new MainlineKey ();
				mainline.parse (mainlineXml);
				
				mainlineKeys.push (mainline);
			}

			for each(var timelineXml:XML in animationXml.timeline)
			{				
				var	timeline:TimeLine = new TimeLine ();
				timeline.parse (timelineXml);
				
				timelines.push (timeline);
			}
		}
		
		public	function setCurrentTime(newTime:Number):void
		{
			if(loopType == NO_LOOPING)
			{
				currentTime = Math.min (newTime, length);
			}
			else if(loopType == LOOPING)
			{
				currentTime = newTime % length;
			}
			
			updateCharacter (mainlineKeyFromTime(currentTime),currentTime);
		}
		
		public	function updateCharacter(mainKey:MainlineKey, newTime:int):void
		{
			var	transformedBoneKeys:Array = [];
			var	parentInfo:SpatialInfo;
			var	currentRef:Ref;
			var	currentKey:TimelineKey;
			var	nextKey:TimelineKey;
			objectKeys = [];
			
			for(var	b:int = 0; b < mainKey.boneRefs.length; b++)
			{
				currentRef = mainKey.boneRefs[b];
				
				if (currentRef.parent >= 0)
				{
					parentInfo = transformedBoneKeys[currentRef.parent].info;
				}
				else
				{
					parentInfo = new SpatialInfo ();
				}
			
				currentKey = keyFromRef (currentRef, newTime);
				currentKey.info = currentKey.info.unmapFromParent (parentInfo);
				transformedBoneKeys.push(currentKey);
			}
			
			for(var	o:int = 0; o < mainKey.objectRefs.length; o++)
			{
				currentRef = mainKey.objectRefs[o];
				
				if (currentRef.parent >= 0)
				{
					parentInfo = transformedBoneKeys[currentRef.parent].info;
				}
				else
				{
					parentInfo = new SpatialInfo ();
				}
				
				currentKey = keyFromRef (currentRef, newTime);
				currentKey.info = currentKey.info.unmapFromParent (parentInfo);
				objectKeys.push(currentKey);
			}
		}
		
		public	function mainlineKeyFromTime (time:int):MainlineKey
		{
			var	currentMainKey:int = 0;
			for (var m:int = 0; m < mainlineKeys.length; m++)
			{
				if(mainlineKeys[m].time <= currentTime)
				{
					currentMainKey = m;
				}
				
				if(mainlineKeys[m].time >= currentTime)
				{
					break;
				}
			}
			
			return mainlineKeys[currentMainKey];
		}	
		
		public	function keyFromRef(ref:Ref, newTime:int):TimelineKey
		{
			var timeline:TimeLine = timelines[ref.timeline];
			var	keyA:TimelineKey = timeline.keys[ref.key];
			var	ret:TimelineKey;
			
			if (timeline.keys.length == 1)
			{
				if (keyA is SpriteTimelineKey)
				{
					ret = new SpriteTimelineKey ();
				}
				else if (keyA is BoneTimelineKey)
				{
					ret = new BoneTimelineKey ();
				}
				
				keyA.clone(ret);
				return ret;
			}
			
			var	nextKeyIndex:int = ref.key + 1;
			
			if (nextKeyIndex >= timeline.keys.length)
			{
				if (loopType == LOOPING)
				{
					nextKeyIndex = 0; 
				}
				else
				{
					if (keyA is SpriteTimelineKey)
					{
						ret = new SpriteTimelineKey ();
					}
					else if (keyA is BoneTimelineKey)
					{
						ret = new BoneTimelineKey ();
					}
					
					keyA.clone(ret)					
					return ret;
				}
			}
			
			var keyB:TimelineKey = timeline.keys[nextKeyIndex];
			var	keyBTime:int = keyB.time;
			
			if (keyBTime < keyA.time)
			{
				keyBTime = keyBTime + length;
			}
			
			return keyA.interpolate (keyB, keyBTime, currentTime);
		}	

		public	function getKeyFromRef(ref:Ref, newTime:int):TimelineKey
		{
			var timeline:TimeLine = timelines[ref.timeline];
			var	keyA:TimelineKey = timeline.keys[ref.key];
			var	ret:TimelineKey;
			
			if (timeline.keys.length == 1)
			{
				if (keyA is SpriteTimelineKey)
				{
					ret = new SpriteTimelineKey ();
				}
				else if (keyA is BoneTimelineKey)
				{
					ret = new BoneTimelineKey ();
				}
				
				keyA.clone(ret);
				return ret;
			}
			
			var	nextKeyIndex:int = ref.key + 1;
			
			if (nextKeyIndex >= timeline.keys.length)
			{
				if (loopType == LOOPING)
				{
					nextKeyIndex = 0; 
				}
				else
				{
					if (keyA is SpriteTimelineKey)
					{
						ret = new SpriteTimelineKey ();
					}
					else if (keyA is BoneTimelineKey)
					{
						ret = new BoneTimelineKey ();
					}
					
					keyA.clone(ret)					
					return ret;
				}
			}
			
			var keyB:TimelineKey = timeline.keys[nextKeyIndex];
			return keyB;
		}	
	}
}