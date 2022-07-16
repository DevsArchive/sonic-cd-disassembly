using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;
using SonicRetro.SonLVL.API.SCD;

namespace SCDObjectDefinitions.PPZ
{
	public class TunnelPath : ObjectDefinition
	{
		private Sprite img;

		public override void Init(ObjectData data)
		{
			byte[] art = LevelData.ReadFile("../Level/_Objects/Sonic/Data/Art.bin", CompressionType.Uncompressed);
			byte[] map = LevelData.ASMToBin("../Level/_Objects/Sonic/Data/Mappings.asm", EngineVersion.S1);
			byte[] plc = LevelData.ASMToBin("../Level/_Objects/Sonic/Data/DPLCs.asm", EngineVersion.S2);
			img = ObjectHelper.MapDPLCToBmp(art, map, plc, 45, 0, true);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new List<byte>()); }
		}

		public override string Name
		{
			get { return "Tunnel Path"; }
		}

		public override bool RememberState
		{
			get { return true; }
		}

		public override string SubtypeName(byte subtype)
		{
			return string.Empty;
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
			return img;
		}

		private PropertySpec[] customProperties = new PropertySpec[] {
			new PropertySpec("Path", typeof(int), "Extended", "The path ID of the spin tunnel", null, new Dictionary<string, int>
				{
					{ "Path 1", 0x00 },
					{ "Path 2", 0x01 },
					{ "Path 3", 0x02 }
				},
				(obj) => { return obj.SubType & 0x03; },
				(obj, value) => obj.SubType = (byte)((obj.SubType & ~0x03) | (Math.Min((int)value & 0x03, 0x02)))),

			new PropertySpec("Launch Out", typeof(bool), "Extended", "If set, it launches the player when they exit the tunnel", null,
				(obj) => { return obj.SubType < 0x80; },
				(obj, value) => obj.SubType = (byte)((obj.SubType & ~0x80) | ((bool)value ? 0x00 : 0x80))),

			new PropertySpec("Hide Sprite", typeof(bool), "Extended", "If set, it hides the player's sprite when activated", null,
				(obj) => { return (((SCDObjectEntry)obj).SubType2) != 0x00; },
				(obj, value) => ((SCDObjectEntry)obj).SubType2 = (byte)((bool)value ? 0x01 : 0x00)),
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
