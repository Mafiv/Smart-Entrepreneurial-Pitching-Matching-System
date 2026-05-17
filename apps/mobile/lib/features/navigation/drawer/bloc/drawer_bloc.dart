import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/drawer_item_model.dart';
import '../models/navigation_config.dart';

// Events
abstract class DrawerEvent extends Equatable {
  const DrawerEvent();

  @override
  List<Object?> get props => [];
}

class DrawerInitRequested extends DrawerEvent {
  const DrawerInitRequested({
    required this.userInfo,
    required this.userRole,
  });

  final DrawerUserInfo userInfo;
  final UserRole userRole;

  @override
  List<Object?> get props => [userInfo, userRole];
}

class DrawerItemSelected extends DrawerEvent {
  const DrawerItemSelected(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

class DrawerToggled extends DrawerEvent {
  const DrawerToggled();
}

class DrawerOpened extends DrawerEvent {
  const DrawerOpened();
}

class DrawerClosed extends DrawerEvent {
  const DrawerClosed();
}

class DrawerItemBadgeUpdated extends DrawerEvent {
  const DrawerItemBadgeUpdated({
    required this.itemId,
    required this.badgeCount,
  });

  final String itemId;
  final int badgeCount;

  @override
  List<Object?> get props => [itemId, badgeCount];
}

// States
abstract class DrawerState extends Equatable {
  const DrawerState();

  @override
  List<Object?> get props => [];
}

class DrawerInitial extends DrawerState {
  const DrawerInitial();
}

class DrawerLoading extends DrawerState {
  const DrawerLoading();
}

class DrawerLoaded extends DrawerState {
  const DrawerLoaded({
    required this.userInfo,
    required this.items,
    required this.selectedItemId,
    required this.isOpen,
  });

  final DrawerUserInfo userInfo;
  final List<DrawerItemModel> items;
  final String? selectedItemId;
  final bool isOpen;

  @override
  List<Object?> get props => [userInfo, items, selectedItemId, isOpen];

  DrawerLoaded copyWith({
    DrawerUserInfo? userInfo,
    List<DrawerItemModel>? items,
    String? selectedItemId,
    bool? isOpen,
  }) {
    return DrawerLoaded(
      userInfo: userInfo ?? this.userInfo,
      items: items ?? this.items,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class DrawerError extends DrawerState {
  const DrawerError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// BLoC
class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  DrawerBloc() : super(const DrawerInitial()) {
    on<DrawerInitRequested>(_onDrawerInitRequested);
    on<DrawerItemSelected>(_onDrawerItemSelected);
    on<DrawerToggled>(_onDrawerToggled);
    on<DrawerOpened>(_onDrawerOpened);
    on<DrawerClosed>(_onDrawerClosed);
    on<DrawerItemBadgeUpdated>(_onDrawerItemBadgeUpdated);
  }

  Future<void> _onDrawerInitRequested(
    DrawerInitRequested event,
    Emitter<DrawerState> emit,
  ) async {
    emit(const DrawerLoading());
    try {
      // Get items for the user's role
      final items = event.userRole == UserRole.entrepreneur
          ? NavigationConfig.getEntrepreneurDrawerItems()
          : NavigationConfig.getInvestorDrawerItems();

      emit(DrawerLoaded(
        userInfo: event.userInfo,
        items: items,
        selectedItemId: null,
        isOpen: false,
      ));
    } catch (e) {
      emit(DrawerError('Failed to initialize drawer: $e'));
    }
  }

  Future<void> _onDrawerItemSelected(
    DrawerItemSelected event,
    Emitter<DrawerState> emit,
  ) async {
    final currentState = state;
    if (currentState is DrawerLoaded) {
      emit(currentState.copyWith(
        selectedItemId: event.itemId,
        isOpen: false, // Close drawer after selection
      ));
    }
  }

  Future<void> _onDrawerToggled(
    DrawerToggled event,
    Emitter<DrawerState> emit,
  ) async {
    final currentState = state;
    if (currentState is DrawerLoaded) {
      emit(currentState.copyWith(isOpen: !currentState.isOpen));
    }
  }

  Future<void> _onDrawerOpened(
    DrawerOpened event,
    Emitter<DrawerState> emit,
  ) async {
    final currentState = state;
    if (currentState is DrawerLoaded && !currentState.isOpen) {
      emit(currentState.copyWith(isOpen: true));
    }
  }

  Future<void> _onDrawerClosed(
    DrawerClosed event,
    Emitter<DrawerState> emit,
  ) async {
    final currentState = state;
    if (currentState is DrawerLoaded && currentState.isOpen) {
      emit(currentState.copyWith(isOpen: false));
    }
  }

  Future<void> _onDrawerItemBadgeUpdated(
    DrawerItemBadgeUpdated event,
    Emitter<DrawerState> emit,
  ) async {
    final currentState = state;
    if (currentState is DrawerLoaded) {
      // Update the badge count for the specified item
      final updatedItems = currentState.items.map((item) {
        if (item.id == event.itemId) {
          return item.copyWith(badge: event.badgeCount);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(items: updatedItems));
    }
  }
}
