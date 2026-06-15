import 'package:chat_ikokas/models/user_model.dart';
import 'package:chat_ikokas/screen/home_screen.dart';
import 'package:chat_ikokas/screen/messageScreen.dart';
import 'package:chat_ikokas/screen/navigation_screen.dart';
import 'package:chat_ikokas/screen/signIn_screen.dart';
import 'package:chat_ikokas/services/local_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_ikokas/repositories/auth_repository.dart';
import 'package:chat_ikokas/bloc/auth/auth_bloc.dart';
import 'package:chat_ikokas/bloc/auth/auth_event.dart';
import 'package:chat_ikokas/bloc/auth/auth_state.dart';
import 'package:chat_ikokas/repositories/chat_repository.dart';
import 'package:chat_ikokas/bloc/chat/chat_bloc.dart';
import 'package:chat_ikokas/bloc/like/like_bloc.dart';
import 'package:chat_ikokas/bloc/post/post_bloc.dart';
import 'package:chat_ikokas/bloc/post/post_event.dart';
import 'package:chat_ikokas/bloc/profile/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ChatRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ChatBloc(
              chatRepository: RepositoryProvider.of<ChatRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => PostBloc()..add(LoadPosts()),
          ),
          BlocProvider(
            create: (context) => LikeBloc(),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: 
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return const NavigationScreen();
              }
              if (state is Unauthenticated) {
                return const SigninScreen();
              }
             
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
