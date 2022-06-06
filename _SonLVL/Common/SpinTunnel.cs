using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace SCDObjectDefinitions.Common
{
	public class SpinTunnel : ObjectDefinition
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
			get { return new ReadOnlyCollection<byte>(new byte[] { 0, 1, 2, 3, 4 }); }
		}

		public override string Name
		{
			get { return "Spin Tunnel Tag"; }
		}

		public override bool RememberState
		{
			get { return true; }
		}

		public override string SubtypeName(byte subtype)
		{
			switch (subtype)
			{
				case 0:
					return "Horizontal (Forced)";
				case 1:
					return "Vertical (Forced)";
				case 2:
					return "Horizontal (D-Pad, Up only)";
				case 3:
					return "Horizontal (D-Pad, Down only)";
				case 4:
					return "Upwards (D-Pad, Right only)";
				default:
					return string.Empty;
			}
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
	}
}
