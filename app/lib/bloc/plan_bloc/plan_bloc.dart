import 'package:app/api/plan/plan_service.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/plan/plan_overview.dart';
import 'package:app/resources/app_settings.dart';
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
    on<GetActivePlan>(_onGetActivePlan);
    on<GetPlans>(_onGetPlans);
    on<PatchPlan>(_onPatchPlan);
    on<DeletePlan>(_onDeletePlan);
    on<GetPlanOverview>(_onGetPlanOverview);
  }

  void _onPostPlan(PostPlan event, Emitter<PlanState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(PlanError(error: "No internet connection!"));
      return;
    }

    final response = await _planService.postPlan(userBox.get("flexusjwt"), {
      "splitCount": event.splitCount,
      "name": event.planName,
      "isWeekly": event.isWeekly,
      "restList": event.isWeekly ? event.weeklyRestList : [false, false, false, false, false, false, false],
      "splits": event.splits,
      "exerciseIDs": event.exercises,
    });

    if (!response.isSuccessful) {
      emit(PlanError(error: response.error.toString()));
      return;
    }

    emit(PlanCreated());
  }

  void _onGetActivePlan(GetActivePlan event, Emitter<PlanState> emit) async {
    Plan? activePlan;

    if (!AppSettings.hasConnection) {
      activePlan = userBox.get("activePlan");
      emit(PlanError(error: "No internet connection!"));
      emit(PlanLoaded(plan: activePlan));
      return;
    }

    final response = await _planService.getActivePlan(userBox.get("flexusjwt"));

    if (!response.isSuccessful) {
      activePlan = userBox.get("activePlan");
      emit(PlanError(error: response.error.toString()));
      emit(PlanLoaded(plan: activePlan));
      return;
    }

    if (response.body != "null") {
      activePlan = Plan.fromJson(response.body);
      userBox.put("activePlan", activePlan);
    }

    emit(PlanLoaded(plan: activePlan));
  }

  void _onGetPlans(GetPlans event, Emitter<PlanState> emit) async {
    List<Plan> plans = [];

    if (!AppSettings.hasConnection) {
      plans = userBox.get("plans")?.cast<Plan>() ?? [];
      emit(PlanError(error: "No internet connection!"));
      return;
    }

    final response = await _planService.getPlans(userBox.get("flexusjwt"));

    if (!response.isSuccessful) {
      plans = userBox.get("plans")?.cast<Plan>() ?? [];
      emit(PlanError(error: response.error.toString()));
      return;
    }

    if (response.body != "null") {
      for (final json in response.body) {
        final Plan plan = Plan.fromJson(json);
        plans.add(plan);
      }
    }

    emit(PlansLoaded(plans: plans));
  }

  void _onPatchPlan(PatchPlan event, Emitter<PlanState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(PlanError(error: "No internet connection!"));
      return;
    }

    Plan? patchedPlan;

    switch (event.name) {
      case "isActive":
        final response = await _planService.patchPlan(
          userBox.get("flexusjwt"),
          event.planID,
          {"isActive": event.value},
        );

        if (!response.isSuccessful) {
          emit(PlanError(error: response.error.toString()));
          break;
        }

        if (response.body != "null") {
          patchedPlan = Plan.fromJson(response.body);
        }

        emit(PlanLoaded(plan: patchedPlan));
        break;

      case "exercise":
        final response = await _planService.patchPlan(
          userBox.get("flexusjwt"),
          event.planID,
          {
            "newExerciseID": event.value,
            "oldExerciseID": event.value2,
            "splitID": event.value3,
          },
        );

        if (!response.isSuccessful) {
          emit(PlanError(error: response.error.toString()));
          break;
        }

        if (response.body != "null") {
          patchedPlan = Plan.fromJson(response.body);
        }

        emit(PlanLoaded(plan: patchedPlan));
        break;

      case "exercises":
        final response = await _planService.patchPlan(
          userBox.get("flexusjwt"),
          event.planID,
          {
            "splitID": event.value,
            "newExerciseIDs": event.value2,
          },
        );

        if (!response.isSuccessful) {
          emit(PlanError(error: response.error.toString()));
          break;
        }

        if (response.body != "null") {
          patchedPlan = Plan.fromJson(response.body);
        }

        emit(PlanLoaded(plan: patchedPlan));
        break;

      default:
        emit(PlanError(error: "This patch is not implemented yet"));
        break;
    }
  }

  void _onDeletePlan(DeletePlan event, Emitter<PlanState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(PlanError(error: "No internet connection!"));
      return;
    }

    final response = await _planService.deletePlan(userBox.get("flexusjwt"), event.planID);
    if (!response.isSuccessful) {
      emit(PlanError(error: response.error.toString()));
      return;
    }

    emit(PlanLoaded(plan: null));
  }

  void _onGetPlanOverview(GetPlanOverview event, Emitter<PlanState> emit) async {
    PlanOverview? planOverview;

    if (!AppSettings.hasConnection) {
      planOverview = userBox.get("planOverview");
      emit(PlanError(error: "No internet connection!"));
      emit(PlanOverviewLoaded(planOverview: planOverview));
      return;
    }

    final response = await _planService.getPlanOverview(userBox.get("flexusjwt"));

    if (!response.isSuccessful) {
      planOverview = userBox.get("planOverview");
      emit(PlanError(error: response.error.toString()));
      emit(PlanOverviewLoaded(planOverview: planOverview));
      return;
    }

    if (response.body != "null") {
      planOverview = PlanOverview.fromJson(response.body);
    }

    emit(PlanOverviewLoaded(planOverview: planOverview));
  }
}
