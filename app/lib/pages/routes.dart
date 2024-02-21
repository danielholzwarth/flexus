import 'package:app/pages/friends/add_friend.dart';
import 'package:app/pages/friends/locations.dart';
import 'package:app/pages/friends/scan_qr.dart';
import 'package:app/pages/friends/show_qr.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/pages/home/leveling.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/pages/home/profile_picture.dart';
import 'package:app/pages/home/settings.dart';
import 'package:app/pages/login/login.dart';
import 'package:app/pages/login/register_name.dart';
import 'package:app/pages/login/register_password.dart';
import 'package:app/pages/login/register_username.dart';
import 'package:app/pages/login/startup.dart';
import 'package:app/pages/workout_documentation/create_exercise.dart';
import 'package:app/pages/workout_documentation/document_workout.dart';
import 'package:app/pages/workout_documentation/exercise_explanation.dart';
import 'package:app/pages/workout_documentation/exercises.dart';
import 'package:app/pages/workout_documentation/start_workout.dart';
import 'package:app/pages/workout_documentation/timer.dart';
import 'package:app/pages/workout_documentation/view_workout.dart';
import 'package:app/pages/workoutplan_creation/create_plan.dart';
import 'package:app/pages/workoutplan_creation/create_plan_count.dart';
import 'package:app/pages/workoutplan_creation/create_plan_distribution.dart';
import 'package:app/pages/workoutplan_creation/create_plan_exercises.dart';
import 'package:app/pages/workoutplan_creation/create_plan_name.dart';
import 'package:app/pages/workoutplan_creation/create_plan_splits.dart';
import 'package:app/pages/workoutplan_creation/create_plan_style.dart';
import 'package:app/pages/workoutplan_creation/plan.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      //LOGIN
      case '/':
        return MaterialPageRoute(builder: (_) => const StartUpPage());
      case '/register_username':
        return MaterialPageRoute(builder: (_) => const RegisterUsernamePage());
      case '/register_name':
        String username = args as String;
        return MaterialPageRoute(builder: (_) => RegisterNamePage(username: username));
      case '/register_password':
        List<dynamic> userInfo = args as List<dynamic>;
        return MaterialPageRoute(builder: (_) => RegisterPasswordPage(username: userInfo[0], name: userInfo[1]));
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      //HOME
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/profile':
        List<dynamic> userInfo = args as List<dynamic>;
        return MaterialPageRoute(builder: (_) => ProfilePage(isOwnProfile: userInfo[0], userID: userInfo[1]));
      case '/profile_picture':
        return MaterialPageRoute(builder: (_) => const ProfilePicturePage());
      case '/leveling':
        return MaterialPageRoute(builder: (_) => const LevelingPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      //FRIENDS
      case '/locations':
        return MaterialPageRoute(builder: (_) => const LocationsPage());
      case '/add_friend':
        return MaterialPageRoute(builder: (_) => const AddFriendPage());
      case '/scan_qr':
        return MaterialPageRoute(builder: (_) => const ScanQRPage());
      case '/show_qr':
        return MaterialPageRoute(builder: (_) => const ShowQRPage());
      //WORKOUTPLAN CREATION
      case '/plan':
        return MaterialPageRoute(builder: (_) => const PlanPage());
      case '/create_plan':
        return MaterialPageRoute(builder: (_) => const CreatePlanPage());
      case '/create_plan_name':
        return MaterialPageRoute(builder: (_) => const CreatePlanNamePage());
      case '/create_plan_count':
        return MaterialPageRoute(builder: (_) => const CreatePlanCountPage());
      case '/create_plan_splits':
        return MaterialPageRoute(builder: (_) => const CreatePlanSplitsPage());
      case '/create_plan_exercises':
        return MaterialPageRoute(builder: (_) => const CreatePlanExercisesPage());
      case '/create_plan_style':
        return MaterialPageRoute(builder: (_) => const CreatePlanStylePage());
      case '/create_plan_distribution':
        return MaterialPageRoute(builder: (_) => const CreatePlanDistributionPage());
      //WORKOUT DOCUMENTATION
      case '/view_workout':
        return MaterialPageRoute(builder: (_) => const ViewWorkoutPage());
      case '/timer':
        return MaterialPageRoute(builder: (_) => const TimerPage());
      case '/start_workout':
        return MaterialPageRoute(builder: (_) => const StartWorkoutPage());
      case '/exercises':
        return MaterialPageRoute(builder: (_) => const ExercisesPage());
      case '/exercise_explanation':
        return MaterialPageRoute(builder: (_) => const ExerciseExplanationPage());
      case '/document_workout':
        return MaterialPageRoute(builder: (_) => const DocumentWorkoutPage());
      case '/create_exercise':
        return MaterialPageRoute(builder: (_) => const CreateExercisePage());
      //STATISTICS
      case '/statistics':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
