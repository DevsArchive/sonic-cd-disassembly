using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace SCDObjectDefinitions.Common
{
	public class Checkpoint : ObjectDefinition
	{
		private Sprite img;
		private Sprite img2;

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../Level/_Objects/Checkpoint/Data/Art.nem", CompressionType.Nemesis);
			img = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Checkpoint/Data/Mappings.asm", 0, 0);
			img2 = ObjectHelper.MapASMToBmp(artfile, "../Level/_Objects/Checkpoint/Data/Mappings.asm", 1, 0);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new List<byte>()); }
		}

		public override string Name
		{
			get { return "Checkpoint"; }
		}

		public override bool RememberState
		{
			get { return false; }
		}

		public override string SubtypeName(byte subtype)
		{
			return string.Empty;
		}

		public Sprite SetupSprite()
		{
			List<Sprite> sprs = new List<Sprite>();
			sprs.Add(new Sprite(img));
			Sprite tmp = new Sprite(img2);
			tmp.Offset(new Point(0, -32));
			sprs.Add(tmp);
			return new Sprite(sprs.ToArray());
		}

		public override Sprite Image
		{
			get { return SetupSprite(); }
		}

		public override Sprite SubtypeImage(byte subtype)
		{
			return SetupSprite();
		}

		public override Sprite GetSprite(ObjectEntry obj)
		{
			return SetupSprite();
		}
	}
}
