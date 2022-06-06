using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;
using SonicRetro.SonLVL.API.SCD;

namespace SCDObjectDefinitions.PPZ
{
	public class Platform : ObjectDefinition
	{
		private Sprite[] img_ptfm = new Sprite[3];
		private Sprite[] img_spring = new Sprite[2];

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../Level/Palmtree Panic/Objects/Platform/Data/Art.nem", CompressionType.Nemesis);
			img_ptfm[0] = ObjectHelper.MapASMToBmp(artfile, "../Level/Palmtree Panic/Objects/Platform/Data/Mappings (Platform 1).asm", 0, 2);
			img_ptfm[1] = ObjectHelper.MapASMToBmp(artfile, "../Level/Palmtree Panic/Objects/Platform/Data/Mappings (Platform 1).asm", 1, 2);
			img_ptfm[2] = ObjectHelper.MapASMToBmp(artfile, "../Level/Palmtree Panic/Objects/Platform/Data/Mappings (Platform 1).asm", 2, 2);

			artfile = ObjectHelper.OpenArtFile("../Level/_Objects/Spring/Data/Art (Normal).nem", CompressionType.Nemesis);
			img_spring[0] = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings.asm", "unk_209BAC", 0);
			img_spring[1] = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Spring/Data/Mappings.asm", "unk_209BAC", 1);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new List<byte>()); }
		}

		public override string Name
		{
			get { return "Platform"; }
		}

		public override bool RememberState
		{
			get { return false; }
		}

		public override string SubtypeName(byte subtype)
		{
			switch (subtype & 0xF0)
			{
				case 0x10:
					return "Moves left and right";
				case 0x20:
					return "Moves in a circle clockwise";
				case 0x30:
					return "Moves in a circle counter-clockwise";
				case 0x40:
					return "Stationary";
				case 0x50:
					return "Falls when stood on";
				case 0x60:
					return "Moves down when stood on";
				case 0x70:
					return "Moves up when stood on";
				case 0x80:
					return "Moves right when stood on";
				case 0x90:
					return "Moves left when stood on";
				default:
					return "Moves up and down";
			}
		}

		public Sprite SetupSprite(byte subtype, byte subtype2)
		{
			List<Sprite> sprs = new List<Sprite>();
			sprs.Add(new Sprite(img_ptfm[Math.Min(2, subtype & 3)]));

			if (subtype2 > 0)
			{
				Sprite tmp = new Sprite(img_spring[subtype2 >> 1]);
				tmp.Offset(new Point(0, -16));
				sprs.Add(tmp);
			}
			return new Sprite(sprs.ToArray());
		}

		public override Sprite Image
		{
			get { return SetupSprite(0, 0); }
		}

		public override Sprite SubtypeImage(byte subtype)
		{
			return SetupSprite(subtype, 0);
		}

		public override Sprite GetSprite(ObjectEntry obj)
		{
			return SetupSprite(obj.SubType, ((SCDObjectEntry)obj).SubType2);
		}

		private PropertySpec[] customProperties = new PropertySpec[] {
			new PropertySpec("Size", typeof(int), "Extended", "The size of the platform", null, new Dictionary<string, int>
				{
					{ "Small", 0x00 },
					{ "Medium", 0x01 },
					{ "Large", 0x02 }
				},
				(obj) => { return Math.Min(obj.SubType & 0x03, 0x02); },
				(obj, value) => obj.SubType = (byte)((obj.SubType & ~0x03) | ((int)value & 0x03))),

			new PropertySpec("Range", typeof(int), "Extended", "The range of motion", null, new Dictionary<string, int>
				{
					{ "32px", 0x00 },
					{ "48px", 0x01 },
					{ "64px", 0x02 },
					{ "96px", 0x03 }
				},
				(obj) => { return (obj.SubType & 0x0C) >> 2; },
				(obj, value) => obj.SubType = (byte)((obj.SubType & ~0x0C) | (((int)value & 0x03) << 2))),

			new PropertySpec("Has Spring", typeof(bool), "Extended", "If set, it adds a spring on top of the platform", null,
				(obj) => { return (((SCDObjectEntry)obj).SubType2 & 0x01) == 0x01; },
				(obj, value) => ((SCDObjectEntry)obj).SubType2 = (byte)((((SCDObjectEntry)obj).SubType2 & ~0x01) | ((bool)value ? 0x01 : 0x00))),

			new PropertySpec("Spring Color", typeof(int), "Extended", "The color of the spring on top of the platform if it exists", null, new Dictionary<string, int>
				{
					{ "Red", 0x00 },
					{ "Yellow", 0x01 },
				},
				(obj) => { return (((SCDObjectEntry)obj).SubType2 & 0x02) >> 1; },
				(obj, value) => ((SCDObjectEntry)obj).SubType2 = (byte)((((SCDObjectEntry)obj).SubType2 & ~0x02) | (((int)value & 0x01) << 1)))
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
