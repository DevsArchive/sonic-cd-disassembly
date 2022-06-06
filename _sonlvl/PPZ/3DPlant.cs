using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace SCDObjectDefinitions.PPZ
{
	public class ThreeDimensionalPlant : ObjectDefinition
	{
		private int[] Offsets1 = {
									 0x40,
									 0x80,
									 -0x40,
									 -0x80
								 };
		private int[] Offsets2 = {
									 0x00,
									 0x60,
									 -0x60
								 };

		private Sprite img, img2;

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../Level/Palmtree Panic/Objects/3D Ramp/Data/Art (Plant).nem", CompressionType.Nemesis);
			img = ObjectHelper.MapASMToBmp(artfile, "../Level/Palmtree Panic/Objects/3D Ramp/Data/Mappings (Plant).asm", 0, 2);
			img2 = ObjectHelper.MapASMToBmp(artfile, "../Level/Palmtree Panic/Objects/3D Ramp/Data/Mappings (Plant).asm", 1, 2);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new byte[] { 0, 1 }); }
		}

		public override string Name
		{
			get { return "3D Plant"; }
		}

		public override bool RememberState
		{
			get { return false; }
		}

		public override string SubtypeName(byte subtype)
		{
			return (((subtype & 1) + 1) * 2) + " bushes";
		}

		public override Sprite Image
		{
			get { return img; }
		}

		public override Sprite SubtypeImage(byte subtype)
		{
			return img;
		}

		public override Sprite GetSprite(ObjectEntry obj)
		{
			int fgCount = (obj.SubType & 1) == 1 ? 2 : 4;
			List<Sprite> sprs = new List<Sprite>();

			for (int i = fgCount - 1; i >= 0; i--)
			{
				Sprite tmp = new Sprite(img);
				Point loc = new Point();
				loc.X += Offsets1[i];
				tmp.Offset(loc);
				sprs.Add(tmp);
			}

			for (int i = 2 - 1; i >= 0; i--)
			{
				Sprite tmp = new Sprite(img2);
				Point loc = new Point();
				loc.X += Offsets2[i];
				tmp.Offset(loc);
				sprs.Add(tmp);
			}

			return new Sprite(sprs.ToArray());
		}
	}
}
