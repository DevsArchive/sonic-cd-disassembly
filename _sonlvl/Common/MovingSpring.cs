using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;
using SonicRetro.SonLVL.API.SCD;

namespace SCDObjectDefinitions.Common
{
	public class MovingSpring : ObjectDefinition
	{
		private Sprite img_wheel;
		private Sprite[] img_spring = new Sprite[6];

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../Level/_Objects/Spring/Data/Art (Wheel).nem", CompressionType.Nemesis);
			img_wheel = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings (Wheel).asm", 0, 0);

			artfile = ObjectHelper.OpenArtFile("../Level/_Objects/Spring/Data/Art (Normal).nem", CompressionType.Nemesis);
			img_spring[0] = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings.asm", "unk_209BAC", 0);
			img_spring[1] = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings.asm", "unk_209BAC", 1);
			img_spring[2] = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings.asm", "unk_209BCE", 0);
			img_spring[3] = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings.asm", "unk_209BCE", 1);

			artfile = ObjectHelper.OpenArtFile("../Level/_Objects/Spring/Data/Art (Diagonal).nem", CompressionType.Nemesis);
			img_spring[4] = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings.asm", "unk_209BF6", 0);
			img_spring[5] = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings.asm", "unk_209BF6", 1);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new List<byte>() { 0, 2, 4, 6, 8, 0xA }); }
		}

		public override string Name
		{
			get { return "Moving Spring"; }
		}

		public override bool RememberState
		{
			get { return false; }
		}

		public override string SubtypeName(byte subtype)
		{
			switch (subtype)
			{
				case 0x02:
					return "Yellow Vertical";
				case 0x04:
					return "Red Horizontal";
				case 0x06:
					return "Yellow Horizontal";
				case 0x08:
					return "Red Diagonal";
				case 0x0A:
					return "Yellow Diagonal";
				default:
					return "Red Vertical";
			}
		}

		public Sprite SetupSprite(byte subtype)
		{
			List<Sprite> sprs = new List<Sprite>();
			sprs.Add(new Sprite(img_wheel));

			Sprite tmp = new Sprite(img_spring[subtype >> 1]);
			tmp.Offset(new Point(0, -16));
			sprs.Add(tmp);

			return new Sprite(sprs.ToArray());
		}

		public override Sprite Image
		{
			get { return SetupSprite(0); }
		}

		public override Sprite SubtypeImage(byte subtype)
		{
			return SetupSprite(subtype);
		}

		public override Sprite GetSprite(ObjectEntry obj)
		{
			return SetupSprite(obj.SubType);
		}

		private PropertySpec[] customProperties = new PropertySpec[] {
			new PropertySpec("Color", typeof(int), "Extended", "The color of the spring", null, new Dictionary<string, int>
				{
					{ "Red", 0x00 },
					{ "Yellow", 0x01 }
				},
				(obj) => { return (obj.SubType & 0x02) >> 1; },
				(obj, value) => obj.SubType = (byte)((obj.SubType & ~0x02) | (((int)value & 0x01) << 1))),

			new PropertySpec("Direction", typeof(int), "Extended", "The direction of the spring", null, new Dictionary<string, int>
				{
					{ "Vertical", 0x00 },
					{ "Horizontal", 0x01 },
					{ "Diagonal", 0x02 }
				},
				(obj) => { return Math.Min(obj.SubType & 0x0C, 0x08) >> 2; },
				(obj, value) => obj.SubType = (byte)((obj.SubType & ~0x0C) | (((int)value & 0x03) << 2)))
		};

		public override PropertySpec[] CustomProperties
		{
			get
			{
				return customProperties;
			}
		}
	}
}
