import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../widgets/ui/motion_system.dart';
import '../widgets/ui/page_atmosphere.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();

  late final TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerPhoneController = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _submitting = true);
    try {
      await _authService.signInWithEmailPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(e, isRegister: false))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _register() async {
    setState(() => _submitting = true);
    try {
      await _authService.registerWithEmailPassword(
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        phoneNumber: _registerPhoneController.text.trim().isEmpty
            ? null
            : _registerPhoneController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(e, isRegister: true))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _friendlyError(Object error, {required bool isRegister}) {
    if (error is AuthFlowException) return error.message;

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return '此 Email 已被註冊，請改用登入。';
        case 'invalid-email':
          return 'Email 格式不正確。';
        case 'weak-password':
          return '密碼強度不足，請至少 6 碼。';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return '帳號或密碼錯誤。';
        default:
          return (isRegister ? '註冊失敗：' : '登入失敗：') +
              (error.message ?? error.code);
      }
    }

    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'Firestore 權限不足，請確認 rules 已允許使用者建立自己的 users 文件。';
    }

    return (isRegister ? '註冊失敗：' : '登入失敗：') + error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: MotionPresetBuilder(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('登入 / 註冊'),
            actions: const [MotionPresetSwitcherButton()],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '登入'),
                Tab(text: '註冊'),
              ],
            ),
          ),
          body: PageAtmosphere(
            child: PageEnterTransition(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    margin: const EdgeInsets.all(AppTokens.space4),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.space4),
                      child: Column(
                        children: [
                          StaggerReveal(
                            index: 0,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '歡迎回來',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          StaggerReveal(
                            index: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '登入或註冊後可跨裝置同步收藏與紀錄。',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTokens.space3),
                          StaggerReveal(
                            index: 2,
                            child: SizedBox(
                              height: 360,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _AuthForm(
                                    submitting: _submitting,
                                    fields: [
                                      TextField(
                                        controller: _loginEmailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: _loginPasswordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: '密碼',
                                        ),
                                      ),
                                    ],
                                    buttonText: '登入',
                                    onSubmit: _login,
                                  ),
                                  _AuthForm(
                                    submitting: _submitting,
                                    fields: [
                                      TextField(
                                        controller: _registerEmailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: _registerPasswordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: '密碼（至少 6 碼）',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: _registerPhoneController,
                                        keyboardType: TextInputType.phone,
                                        decoration: const InputDecoration(
                                          labelText: '手機（選填）',
                                        ),
                                      ),
                                    ],
                                    buttonText: '註冊',
                                    onSubmit: _register,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.fields,
    required this.buttonText,
    required this.onSubmit,
    required this.submitting,
  });

  final List<Widget> fields;
  final String buttonText;
  final VoidCallback onSubmit;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...fields,
        const SizedBox(height: 16),
        SizedBox(
          height: 46,
          child: FilledButton(
            onPressed: submitting ? null : onSubmit,
            child: submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(buttonText),
          ),
        ),
      ],
    );
  }
}
