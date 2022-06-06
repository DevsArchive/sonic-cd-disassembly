using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;
using SonicRetro.SonLVL.API.SCD;

namespace SCDObjectDefinitions.PPZ
{
	public class ThreeDimensionalRamp : ObjectDefinition
	{
		private Sprite img_booster;
		private Sprite img_sonic;

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../Level/Palmtree Panic/Objects/3D Ramp/Data/Art (Booster).nem", CompressionType.Nemesis);
			img_booster = ObjectHelper.MapASMToBmp(artfile, "../Level/Palmtree Panic/Objects/3D Ramp/Data/Mappings (Booster).asm", 0, 0);

			artfile = LevelData.ReadFile("../Level/_Objects/Sonic/Data/Art.bin", CompressionType.Uncompressed);
			byte[] map = LevelData.ASMToBin("../Level/_Objects/Sonic/Data/Mappings.asm", EngineVersion.S1);
			byte[] plc = LevelData.ASMToBin("../Level/_Objects/Sonic/Data/DPLCs.asm", EngineVersion.S2);
			img_sonic = ObjectHelper.MapDPLCToBmp(artfile, map, plc, 23, 0, true);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new List<byte>()); }
		}

		public override string Name
		{
			get { return "3D Ramp Marker"; }
		}

		public override bool RememberState
		{
			get { return false; }
		}

		public override string SubtypeName(byte subtype)
		{
			return string.Empty;
		}

		public Sprite SetupSprite(byte subtype, byte subtype2)
		{
			if (subtype2 > 0)
				return new Sprite(img_sonic, subtype > 0, false);
			else
				return new Sprite(img_booster, subtype > 0, false);
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
			new PropertySpec("Flipped", typeof(bool), "Extended", "If set, it horizontally flips the object", null,
				(obj) => { return (obj.SubType & 0x01) == 0x01; },
				(obj, value) => obj.SubType = (byte)((obj.SubType & ~0x01) | ((bool)value ? 0x01 : 0x00))),

			new PropertySpec("Type", typeof(int), "Extended", "The type of 3D ramp marker", null, new Dictionary<string, int>
				{
					{ "Boost", 0x00 },
					{ "Fall", 0x01 },
				},
				(obj) => { return ((SCDObjectEntry)obj).SubType2 & 0x01; },
				(obj, value) => ((SCDObjectEntry)obj).SubType2 = (byte)((((SCDObjectEntry)obj).SubType2 & ~0x01) | ((int)value & 0x01)))
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
