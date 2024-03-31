import 'package:app/api/plan_service.dart';
import 'package:app/hive/plan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'plan_event.dart';
part 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final PlanService _planService = PlanService.create();
  final userBox = Hive.box('userBox');

  PlanBloc() : super(PlanInitial()) {
    on<PostPlan>(_onPostPlan);
    on<GetPlans>(_onGetPlans);
  }

  void _onPostPlan(PostPlan event, Emitter<PlanState> emit) async {
    emit(PlanCreating());

    final response = await _planService.postPlan(userBox.get("flexusjwt"), {
      "splitCount": event.splitCount,
      "name": event.planName,
      "isWeekly": event.isWeekly,
      "restList": event.isWeekly ? event.weeklyRestList : [false, false, false, false, false, false, false],
    });

    if (response.isSuccessful) {
      emit(PlanCreated());
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
}
