import 'package:flutter_bloc/flutter_bloc.dart';

import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(counter: 0)) {
    on<CounterIncrementPressed>((event, emit) async {
      await Future.delayed(const Duration(seconds: 1));

      emit(CounterState(counter: state.counter + 1));
    });

    on<CounterDecrementPressed>((event, emit) {
      emit(CounterState(counter: state.counter - 1));
    });

    on<CounterResetPressed>((event, emit) {
      emit(const CounterState(counter: 0));
    });
  }
}
