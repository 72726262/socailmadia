abstract class CreateUserState {}

class CreateUserInitial extends CreateUserState {}

class CreateUserLoading extends CreateUserState {}

class CreateUserSuccess extends CreateUserState {}

class CreateUserFailure extends CreateUserState {
  final String message;
  CreateUserFailure(this.message);
}
