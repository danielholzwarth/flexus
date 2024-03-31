import 'package:app/api/plan_service.dart';
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
}
