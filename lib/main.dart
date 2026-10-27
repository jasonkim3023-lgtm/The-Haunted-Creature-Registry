import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 🧓 Great-Grandparent
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fun Signup App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const SignupPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Task A: local, deterministic tip data (no network, no AI, no form values)
// ---------------------------------------------------------------------------
const String kTipCategory = 'password_help'; // fixed category
const int kMaxTipLength = 240;

const Map<String, List<String>> kPresetTips = {
  'password_help': [
    'Use at least 6 characters; longer passwords are harder to guess.',
    'Mix letters, numbers, and symbols to make your password stronger.',
    'Avoid reusing a password you already use on another site.',
  ],
};

enum TipStatus { idle, loading, success, error }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // 🔑 The Global Key - acts like a remote control for the form
  final _formKey = GlobalKey<FormState>();

  // 📝 Controllers to track what the user types
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 💡 Tip feature state (completely separate from the form fields)
  TipStatus _tipStatus = TipStatus.idle;
  String _tipText = '';
  int _tipIndex = 0; // cycles through the preset tips in order
  bool _simulateError = false; // demo switch so error/retry can be shown

  @override
  void dispose() {
    // Controllers must be disposed to avoid memory leaks.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _getTip() async {
    setState(() => _tipStatus = TipStatus.loading);

    // Simulated short loading delay (no real network call).
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final tips = kPresetTips[kTipCategory] ?? [];

    // Local error cases: forced by the demo switch, or missing/empty data.
    if (_simulateError || tips.isEmpty) {
      setState(() => _tipStatus = TipStatus.error);
      return;
    }

    // Deterministic selection: next tip in the fixed category list.
    var tip = tips[_tipIndex % tips.length];
    _tipIndex++;

    // Enforce the 240-character maximum.
    if (tip.length > kMaxTipLength) {
      tip = tip.substring(0, kMaxTipLength);
    }

    setState(() {
      _tipText = tip;
      _tipStatus = TipStatus.success;
    });
  }

  Widget _buildTipResult() {
    switch (_tipStatus) {
      case TipStatus.idle:
        return const SizedBox.shrink();

      case TipStatus.loading:
        return const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Loading tip...'),
            ],
          ),
        );

      case TipStatus.success:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_tipText), // plain text only
              const SizedBox(height: 8),
              const Text(
                'Preset demo tip—not live AI.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );

      case TipStatus.error:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            children: [
              const Text(
                "Sorry, we couldn't load a tip. (Local demo error)",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _getTip, // retry
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👨 Parent
      appBar: AppBar(
        title: const Text('Join Us Today for the Cash Money!'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              // 👶 Child
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Create Your Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // 👤 Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 📧 Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🔒 Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 🚀 Sign Up Button (validation stays local and unchanged)
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Demo signup complete — your form passed validation!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // 💡 Task A: Get a signup tip
            TextButton.icon(
              onPressed: _tipStatus == TipStatus.loading ? null : _getTip,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Get a signup tip'),
            ),

            // Demo-only switch so you can show the error + retry case
            SwitchListTile(
              dense: true,
              title: const Text('Simulate tip error (demo)'),
              value: _simulateError,
              onChanged: (v) => setState(() => _simulateError = v),
            ),

            _buildTipResult(),
          ],
        ),
      ),
    );
  }
}
