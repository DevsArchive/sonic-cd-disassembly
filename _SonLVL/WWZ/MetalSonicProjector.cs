using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace SCDObjectDefinitions.WWZ
{
	public class MetalSonicProjector : ObjectDefinition
	{
		private Sprite img_projector;
		private Sprite img_light;
		private Sprite img_metalsonic;

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../Level/Wacky Workbench/Objects/Projector/Data/Art.nem", CompressionType.Nemesis);
			img_projector = ObjectHelper.MapASMToBmp(artfile, "../Level/Wacky Workbench/Objects/Projector/Data/Mappings.asm", 0, 0);
			img_light = ObjectHelper.MapASMToBmp(artfile, "../Level/Wacky Workbench/Objects/Projector/Data/Mappings.asm", 2, 0);
			img_metalsonic = ObjectHelper.MapASMToBmp(artfile, "../Level/Wacky Workbench/Objects/Projector/Data/Mappings.asm", 4, 0);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new List<byte>()); }
		}

		public override string Name
		{
			get { return "Metal Sonic Holographic Projector"; }
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
			sprs.Add(new Sprite(img_projector));

			Sprite tmp = new Sprite(img_light);
			tmp.Offset(new Point(-15, -7));
			sprs.Add(new Sprite(tmp));

			tmp = new Sprite(img_metalsonic);
			tmp.Offset(new Point(-72, -4));
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
