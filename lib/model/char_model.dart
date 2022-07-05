class CharModel {
  int? id;
  String? name;
  String? vision;
  String? weapon;
  String? nation;
  String? affiliation;
  int? rarity;
  String? constellation;
  String? birthday;
  String? description;
  String? obtain;
  String? gender;
  String? imagePortrait;
  String? imageCard;
  String? imageWish;

  //constructor
  CharModel({
    this.id,
    this.name,
    this.vision,
    this.weapon,
    this.nation,
    this.affiliation,
    this.rarity,
    this.constellation,
    this.birthday,
    this.description,
    this.obtain,
    this.gender,
    this.imagePortrait,
    this.imageCard,
    this.imageWish,
  });

  //mapping data
  CharModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    vision = json["vision"];
    weapon = json["weapon"];
    nation = json["nation"];
    affiliation = json["affiliation"];
    rarity = json["rarity"];
    constellation = json["constellation"];
    birthday = json["birthday"];
    description = json["description"];
    obtain = json["obtain"];
    gender = json["gender"];
    imagePortrait = json["image_portrait"];
    imageCard = json["image_card"];
    imageWish = json["image_wish"];
  }
}
