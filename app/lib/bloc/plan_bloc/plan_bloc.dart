import 'package:app/api/plan/plan_service.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/plan/plan_overview.dart';
import 'package:app/hive/split/split.dart';
import 'package:app/hive/split/split_overview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

part 'plan_event.dart';
part 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final PlanService _planService = PlanService.create();
  final userBox = Hive.box('userBox');

  PlanBloc() : super(PlanInitial()) {
    on<PostPlan>(_onPostPlan);
    on<GetActivePlan>(_onGetActivePlan);
    on<GetPlans>(_onGetPlans);
    on<PatchPlan>(_onPatchPlan);
    on<DeletePlan>(_onDeletePlan);
    on<GetPlanOverview>(_onGetPlanOverview);
  }

  void _onPostPlan(PostPlan event, Emitter<PlanState> emit) async {
    emit(PlanCreating());

    final response = await _planService.postPlan(userBox.get("flexusjwt"), {
      "splitCount": event.splitCount,
      "name": event.planName,
      "isWeekly": event.isWeekly,
      "restList": event.isWeekly ? event.weeklyRestList : [false, false, false, false, false, false, false],
      "splits": event.splits,
      "exerciseIDs": event.exercises,
    });

    if (response.isSuccessful) {
      emit(PlanCreated());
    } else {
      emit(PlanError(error: response.error.toString()));
    }
  }

  void _onGetActivePlan(GetActivePlan event, Emitter<PlanState> emit) async {
    emit(PlanLoading());

    final response = await _planService.getActivePlan(userBox.get("flexusjwt"));

    if (response.isSuccessful) {
      if (response.body != "null") {
        final Map<String, dynamic> jsonMap = response.body;

        final Plan plan = Plan(
          id: jsonMap['id'],
          userID: jsonMap['userAccountID'],
          splitCount: jsonMap['splitCount'],
          name: jsonMap['name'],
          createdAt: DateTime.parse(jsonMap['createdAt']),
          isActive: jsonMap['isActive'],
          isWeekly: jsonMap['isWeekly'],
          restList: [
            jsonMap['isMondayRest'],
            jsonMap['isTuesdayRest'],
            jsonMap['isWednesdayRest'],
            jsonMap['isThursdayRest'],
            jsonMap['isFridayRest'],
            jsonMap['isSaturdayRest'],
            jsonMap['isSundayRest'],
          ],
        );

        emit(PlanLoaded(plan: plan));
      } else {
        emit(PlanLoaded(plan: null));
      }
    } else {
      emit(PlanError(error: response.error.toString()));
    }
  }

  void _onGetPlans(GetPlans event, Emitter<PlanState> emit) async {
    emit(PlansLoading());

    final response = await _planService.getPlans(userBox.get("flexusjwt"));

    if (response.isSuccessful) {
      List<Plan> plans = [];
      if (response.body != "null") {
        final List<dynamic> jsonList = response.body;

        for (final planData in jsonList) {
          final Plan plan = Plan(
            id: planData['id'],
            userID: planData['userAccountID'],
            splitCount: planData['splitCount'],
            name: planData['name'],
            createdAt: DateTime.parse(planData['createdAt']),
            isActive: planData['isActive'],
            isWeekly: planData['isWeekly'],
            restList: [
              planData['isMondayRest'],
              planData['isTuesdayRest'],
              planData['isWednesdayRest'],
              planData['isThursdayRest'],
              planData['isFridayRest'],
              planData['isSaturdayRest'],
              planData['isSundayRest'],
            ],
          );
          plans.add(plan);
        }

        emit(PlansLoaded(plans: plans));
      } else {
        emit(PlansLoaded(plans: plans));
      }
    } else {
      emit(PlanError(error: response.error.toString()));
    }
  }

  void _onPatchPlan(PatchPlan event, Emitter<PlanState> emit) async {
    emit(PlanPatching());

    switch (event.name) {
      case "isActive":
        final response = await _planService.patchPlan(
          userBox.get("flexusjwt"),
          event.planID,
          {"isActive": event.value},
        );

        if (response.isSuccessful) {
          if (response.body != "null") {
            final Map<String, dynamic> jsonMap = response.body;

            final Plan plan = Plan(
              id: jsonMap['id'],
              userID: jsonMap['userAccountID'],
              splitCount: jsonMap['splitCount'],
              name: jsonMap['name'],
              createdAt: DateTime.parse(jsonMap['createdAt']),
              isActive: jsonMap['isActive'],
              isWeekly: jsonMap['isWeekly'],
              restList: [
                jsonMap['isMondayRest'],
                jsonMap['isTuesdayRest'],
                jsonMap['isWednesdayRest'],
                jsonMap['isThursdayRest'],
                jsonMap['isFridayRest'],
                jsonMap['isSaturdayRest'],
                jsonMap['isSundayRest'],
              ],
            );

            emit(PlanLoaded(plan: plan));
          } else {
            emit(PlanLoaded(plan: null));
          }
        }
        break;

      default:
        emit(PlanError(error: "This patch is not implemented yet"));
        break;
    }
  }

  void _onDeletePlan(DeletePlan event, Emitter<PlanState> emit) async {
    emit(PlanDeleting());

    final response = await _planService.deletePlan(userBox.get("flexusjwt"), event.planID);
    if (response.isSuccessful) {
      emit(PlanLoaded(plan: null));
    } else {
      emit(PlanError(error: response.error.toString()));
    }
  }

  void _onGetPlanOverview(GetPlanOverview event, Emitter<PlanState> emit) async {
    emit(PlanOverviewLoading());

    final response = await _planService.getPlanOverview(userBox.get("flexusjwt"));
    printInfo(info: response.bodyString);

    if (response.isSuccessful) {
      if (response.body != "null") {
        final Map<String, dynamic> jsonMap = response.body;

        final Plan plan = Plan(
          id: jsonMap['plan']['id'],
          userID: jsonMap['plan']['userAccountID'],
          splitCount: jsonMap['plan']['splitCount'],
          name: jsonMap['plan']['name'],
          createdAt: DateTime.parse(jsonMap['plan']['createdAt']),
          isActive: jsonMap['plan']['isActive'],
          isWeekly: jsonMap['plan']['isWeekly'],
          restList: [
            jsonMap['plan']['isMondayRest'],
            jsonMap['plan']['isTuesdayRest'],
            jsonMap['plan']['isWednesdayRest'],
            jsonMap['plan']['isThursdayRest'],
            jsonMap['plan']['isFridayRest'],
            jsonMap['plan']['isSaturdayRest'],
            jsonMap['plan']['isSundayRest'],
          ],
        );

        final List<dynamic> splitOverviewsJson = jsonMap['splitOverviews'];
        final List<SplitOverview> splitOverviews = splitOverviewsJson.map((splitJson) {
          return SplitOverview(
            split: Split(
              id: splitJson['split']['id'],
              planID: splitJson['split']['planID'],
              name: splitJson['split']['name'],
              orderInPlan: splitJson['split']['orderInPlan'],
            ),
            exercises: splitJson['exercises'] != null
                ? List<Exercise>.from(splitJson['exercises'].map((exerciseJson) {
                    return Exercise(
                      id: exerciseJson['id'],
                      creatorID: exerciseJson['creatorID'],
                      name: exerciseJson['name'],
                      typeID: exerciseJson['typeID'],
                    );
                  }))
                : [],
            measurements: [],
            //splitJson['measurements'] != null ? List<String>.from(splitJson['measurements'].map((measurementJson) => List<String>.from(measurementJson))): [],
          );
        }).toList();

        final PlanOverview planOverview = PlanOverview(plan: plan, splitOverviews: splitOverviews);

        emit(PlanOverviewLoaded(planOverview: planOverview));
      } else {
        emit(PlanOverviewLoaded(planOverview: null));
      }
    } else {
      emit(PlanError(error: response.error.toString()));
    }
  }
}
