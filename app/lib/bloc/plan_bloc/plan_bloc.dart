import 'package:app/api/plan/plan_service.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/plan/plan_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/jwt_helper.dart';
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
    if (!AppSettings.hasConnection) {
      emit(PlanError(error: "No internet connection!"));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _planService.postPlan(flexusjwt, {
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

    JWTHelper.saveJWTsFromResponse(response);

    emit(PlanCreated());
  }

  void _onGetActivePlan(GetActivePlan event, Emitter<PlanState> emit) async {
    Plan? activePlan;

    if (!AppSettings.hasConnection) {
      activePlan = userBox.get("activePlan");
      emit(PlanLoaded(plan: activePlan));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _planService.getActivePlan(flexusjwt);

    if (!response.isSuccessful) {
      activePlan = userBox.get("activePlan");
      emit(PlanError(error: response.error.toString()));
      emit(PlanLoaded(plan: activePlan));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

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
      emit(PlansLoaded(plans: plans));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _planService.getPlans(flexusjwt);

    if (!response.isSuccessful) {
      plans = userBox.get("plans")?.cast<Plan>() ?? [];
      emit(PlanError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body != "null") {
      for (final json in response.body) {
        final Plan plan = Plan.fromJson(json);
        plans.add(plan);
      }
      userBox.put("plans", plans);
    }

    emit(PlansLoaded(plans: plans));
  }

  void _onPatchPlan(PatchPlan event, Emitter<PlanState> emit) async {
    Plan? patchedPlan;

    switch (event.name) {
      case "isActive":
        if (!AppSettings.hasConnection) {
          List<Plan> plans = userBox.get("plans")?.cast<Plan>() ?? [];

          if (plans.isEmpty) {
            emit(PlanError(error: "No plans found!"));
            return;
          }

          Plan? activePlan = plans.firstWhereOrNull((element) => element.isActive == true);
          if (activePlan != null) {
            int index = plans.indexOf(activePlan);
            plans[index].isActive = false;
          }

          Plan? planToActivate = plans.firstWhereOrNull((element) => element.id == event.planID);
          if (planToActivate != null) {
            int index = plans.indexOf(planToActivate);
            plans[index].isActive = true;
            userBox.put("activePlan", planToActivate);
          }

          emit(PlanLoaded(plan: planToActivate));
          break;
        }

        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _planService.patchPlan(flexusjwt, event.planID, {"isActive": true});

        if (!response.isSuccessful) {
          emit(PlanError(error: response.error.toString()));
          break;
        }

        JWTHelper.saveJWTsFromResponse(response);

        if (response.body != "null") {
          patchedPlan = Plan.fromJson(response.body);
        }

        emit(PlanLoaded(plan: patchedPlan));
        break;

      case "exercise":
        if (!AppSettings.hasConnection) {
          emit(PlanError(error: "This required internet connection!"));
          break;
        }

        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _planService.patchPlan(
          flexusjwt,
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

        JWTHelper.saveJWTsFromResponse(response);

        if (response.body != "null") {
          patchedPlan = Plan.fromJson(response.body);
        }

        emit(PlanLoaded(plan: patchedPlan));
        break;

      case "exercises":
        if (!AppSettings.hasConnection) {
          emit(PlanError(error: "This required internet connection!"));
          break;
        }

        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _planService.patchPlan(
          flexusjwt,
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

        JWTHelper.saveJWTsFromResponse(response);

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
      List<Plan> plans = userBox.get("plans")?.cast<Plan>() ?? [];

      if (plans.isEmpty) {
        emit(PlanError(error: "No plans found!"));
        return;
      }

      Plan? planToRemove = plans.firstWhereOrNull((element) => element.id == event.planID);
      if (planToRemove != null) {
        plans.remove(planToRemove);
        if (planToRemove.isActive == true) {
          userBox.delete("activePlan");
        }
      }

      userBox.put("plans", plans);

      emit(PlanLoaded(plan: null));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _planService.deletePlan(flexusjwt, event.planID);
    if (!response.isSuccessful) {
      emit(PlanError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    emit(PlanLoaded(plan: null));
  }

  void _onGetPlanOverview(GetPlanOverview event, Emitter<PlanState> emit) async {
    PlanOverview? planOverview;

    if (!AppSettings.hasConnection) {
      planOverview = userBox.get("planOverview${event.planID}");
      userBox.put("splitOverviews${event.planID}", planOverview!.splitOverviews);
      emit(PlanOverviewLoaded(planOverview: planOverview));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _planService.getPlanOverview(flexusjwt);

    if (!response.isSuccessful) {
      planOverview = userBox.get("planOverview${event.planID}");
      emit(PlanError(error: response.error.toString()));
      emit(PlanOverviewLoaded(planOverview: planOverview));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body != "null") {
      planOverview = PlanOverview.fromJson(response.body);
      userBox.put("planOverview${event.planID}", planOverview);
      userBox.put("splitOverviews${event.planID}", planOverview.splitOverviews);
    }

    emit(PlanOverviewLoaded(planOverview: planOverview));
  }
}
