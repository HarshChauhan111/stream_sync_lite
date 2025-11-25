import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_sync_lite/data/models/user_model.dart';
import 'package:stream_sync_lite/data/repositories/auth_repository.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_event.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testName = 'Test User';
    final testUser = User(
      id: 1,
      name: testName,
      email: testEmail,
      role: 'user',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockAuthRepository.login(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((s) => s.user.name, 'user name', testName)
            .having((s) => s.user.email, 'user email', testEmail),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login(
              email: testEmail,
              password: testPassword,
            )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockAuthRepository.login(
              email: testEmail,
              password: testPassword,
            )).thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>()
            .having((s) => s.message, 'error message', contains('Invalid credentials')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when register succeeds',
      build: () {
        when(() => mockAuthRepository.register(
              name: testName,
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        name: testName,
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((s) => s.user.name, 'user name', testName)
            .having((s) => s.user.email, 'user email', testEmail),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.register(
              name: testName,
              email: testEmail,
              password: testPassword,
            )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when isLoggedIn returns false',
      build: () {
        when(() => mockAuthRepository.isLoggedIn()).thenReturn(false);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout is requested',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );
  });
}
