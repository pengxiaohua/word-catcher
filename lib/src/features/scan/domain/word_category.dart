enum WordCategory {
  homeLiving(id: 'HOME_LIVING', label: '居家物品'),
  foodDrink(id: 'FOOD_DRINK', label: '食物饮品'),
  clothingAccessories(id: 'CLOTHING_ACCESSORIES', label: '衣物配饰'),
  schoolOffice(id: 'SCHOOL_OFFICE', label: '学习办公'),
  digitalDevices(id: 'DIGITAL_DEVICES', label: '数码设备'),
  transportation(id: 'TRANSPORTATION', label: '交通出行'),
  naturePlants(id: 'NATURE_PLANTS', label: '自然植物'),
  animals(id: 'ANIMALS', label: '动物'),
  sportsToys(id: 'SPORTS_TOYS', label: '运动玩具'),
  personalCare(id: 'PERSONAL_CARE', label: '个人护理'),
  publicPlaces(id: 'PUBLIC_PLACES', label: '公共场景'),
  otherObjects(id: 'OTHER_OBJECTS', label: '其他物品');

  const WordCategory({required this.id, required this.label});

  final String id;
  final String label;

  static WordCategory fromId(String? id) {
    final normalized = id?.trim().toUpperCase();
    for (final category in values) {
      if (category.id == normalized) {
        return category;
      }
    }
    return WordCategory.otherObjects;
  }
}
