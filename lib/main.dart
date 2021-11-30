import 'package:clubhouse_clone/views/user_details_input_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Clubhouse Clone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                elevation: 0,
                titleTextStyle:
                    GoogleFonts.nunito(color: Colors.black, fontSize: 22))),
        home: const UserDetailsInputView());
  }
}
