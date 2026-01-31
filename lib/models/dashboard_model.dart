class BannerModel {
  final int id;
  final String name;
  final String image;

  BannerModel({required this.id, required this.name, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? "",
      slug: json['slug']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
    );
  }
}

class SubCategoryModel {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String image;
  final String categoryName;

  SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.image,
    required this.categoryName,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      categoryId: int.tryParse(json['category_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? "",
      slug: json['slug']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
      categoryName: json['category_name']?.toString() ?? "",
    );
  }
}

class DesignModel {
  final int id;
  final String title;
  final String slug;
  final String image;
  final bool isFav;

  DesignModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.image,
    required this.isFav,
  });

  factory DesignModel.fromJson(Map<String, dynamic> json) {
    return DesignModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? "",
      slug: json['slug']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
      isFav: json['is_fav'] == true || json['is_fav'].toString() == "1",
    );
  }
}

class DashboardData {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<DesignModel> designs;
  final int notificationCount;

  DashboardData({
    required this.banners,
    required this.categories,
    required this.designs,
    required this.notificationCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      banners:
          (json['banners'] as List?)
              ?.map((e) => BannerModel.fromJson(e))
              .toList() ??
          [],
      categories:
          (json['categories'] as List?)
              ?.map((e) => CategoryModel.fromJson(e))
              .toList() ??
          [],
      designs:
          (json['designs'] as List?)
              ?.map((e) => DesignModel.fromJson(e))
              .toList() ??
          [],
      notificationCount:
          int.tryParse(json['notification_count'].toString()) ?? 0,
    );
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String? image;
  final String date;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.image,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? "",
      message: json['message']?.toString() ?? "",
      image: json['image']?.toString(),
      date: json['date']?.toString() ?? "",
    );
  }
}
