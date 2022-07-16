using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace SCDObjectDefinitions.WWZ
{
	public class Seesaw : ObjectDefinition
	{
		private Sprite img_center;
		private Sprite img_platform;

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../Level/Wacky Workbench/Objects/Seesaw/Data/Art.nem", CompressionType.Nemesis);
			img_center = ObjectHelper.MapASMToBmp(artfile, "../Level/Wacky Workbench/Objects/Seesaw/Data/Mappings.asm", 0, 0);
			img_platform = ObjectHelper.MapASMToBmp(artfile, "../Level/Wacky Workbench/Objects/Seesaw/Data/Mappings.asm", 9, 0);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new List<byte>()); }
		}

		public override string Name
		{
			get { return "Seesaw"; }
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
			sprs.Add(new Sprite(img_center));

			Sprite tmp = new Sprite(img_platform);
			tmp.Offset(new Point(-40, -24));
			sprs.Add(new Sprite(tmp));
			tmp.Offset(new Point(80, 48));
			sprs.Add(new Sprite(tmp));

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
