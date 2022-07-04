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
  String? image_portrait;
  String? image_card;
  String? image_wish;

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
    this.image_portrait,
    this.image_card,
    this.image_wish,
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
    image_portrait = json["image_portrait"];
    image_card = json["image_card"];
    image_wish = json["image_wish"];
  }
}
