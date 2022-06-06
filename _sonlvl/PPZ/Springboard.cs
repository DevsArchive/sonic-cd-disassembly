using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Drawing;
using SonicRetro.SonLVL.API;
using SonicRetro.SonLVL.API.SCD;

namespace SCDObjectDefinitions.PPZ
{
	public class Springboard : ObjectDefinition
	{
		private Sprite img;
		private Sprite img2;

		public override void Init(ObjectData data)
		{
			byte[] artfile = ObjectHelper.OpenArtFile("../Level/Palmtree Panic/Objects/Springboard/Data/Art.nem", CompressionType.Nemesis);
			img = ObjectHelper.MapASMToBmp(artfile, "../Level/Palmtree Panic/Objects/Springboard/Data/Mappings.asm", 0, 0);
			img2 = ObjectHelper.MapASMToBmp(artfile, "../Level/Palmtree Panic/Objects/Springboard/Data/Mappings.asm", 3, 0);
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return new ReadOnlyCollection<byte>(new List<byte>() { 0, 1 }); }
		}

		public override string Name
		{
			get { return "Springboard"; }
		}

		public override bool RememberState
		{
			get { return false; }
		}

		public override string SubtypeName(byte subtype)
		{
			switch (subtype)
			{
				case 0x00:
					return "Normal";
				default:
					return "Flipped";
			}
		}

		public Sprite SetupSprite(bool flipped)
		{
			if (flipped)
				return img2;
			return img;
		}

		public override Sprite Image
		{
			get { return SetupSprite(false); }
		}

		public override Sprite SubtypeImage(byte subtype)
		{
			return SetupSprite(subtype > 0);
		}

		public override Sprite GetSprite(ObjectEntry obj)
		{
			return SetupSprite(obj.XFlip || (obj.SubType > 0));
		}

		private PropertySpec[] customProperties = new PropertySpec[] {
			new PropertySpec("Flipped", typeof(bool), "Extended", "If set, it flips the object", null,
				(obj) => { return (obj.SubType > 0); },
				(obj, value) => obj.SubType = (byte)((bool)value ? 0x01 : 0x00))
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
