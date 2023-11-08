import 'package:genshin_characters/getx/modules/home_binding.dart';
import 'package:genshin_characters/getx/routes/app_routes.dart';
import 'package:genshin_characters/screens/code_screen_full.dart';
import 'package:genshin_characters/screens/home_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
        name: AppRoutes.home,
        page: () => const HomeScreen(),
        binding: HomeBinding()),
    GetPage(name: AppRoutes.codeScreenFull, page: () => const CodeScreenFull())
  ];
}
