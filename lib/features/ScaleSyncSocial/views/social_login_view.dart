import 'package:flutter/material.dart';

class SocialLoginView extends StatefulWidget {
  const SocialLoginView({super.key});

  @override
  State<SocialLoginView> createState() => _SocialLoginViewState();
}

class _SocialLoginViewState extends State<SocialLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final List<String> _terminalOutput = [
    'Initializing ScaleSync Social authentication secure handshake...',
    'Requesting client credentials...',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _executeLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _terminalOutput.add('> exec login --user=${_emailController.text}');
        _terminalOutput.add('Connecting to database node social-db-01...');
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _terminalOutput.add('Handshake successful. Session token granted.');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access Granted. Session established.', style: TextStyle(fontFamily: 'monospace', color: Color(0xFF00FF00))),
              backgroundColor: Colors.black,
            ),
          );
          Navigator.of(context).pop();
        }
      });
    } else {
      setState(() {
        _terminalOutput.add('Error: Validation failed. Missing email or password.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark terminal background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF00)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00FF00), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF00).withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ASCII Banner
                      const Center(
                        child: Text(
                          ' ____   ____ ____  _     _\n'
                          '/ ___| / ___/ ___|| |   | |\n'
                          '\\___ \\| |   \\___ \\| |   | |\n'
                          ' ___) | |___ ___) | |___| |___\n'
                          '|____/ \\____|____/|_____|_____|\n'
                          '  S O C I A L   T E R M I N A L',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF00FF00),
                            fontSize: 10,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFF00FF00), thickness: 1),
                      const SizedBox(height: 12),

                      // System output log
                      Container(
                        padding: const EdgeInsets.all(12),
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF003300)),
                        ),
                        child: ListView.builder(
                          itemCount: _terminalOutput.length,
                          itemBuilder: (context, index) {
                            return Text(
                              _terminalOutput[index],
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFF00BB00),
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Username/Email Input
                      const Text(
                        'scalesync@social:~\$ enter_email',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF00FF00),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF00FF00),
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          hintText: 'user@domain.com',
                          hintStyle: TextStyle(color: Color(0xFF003300), fontFamily: 'monospace'),
                          prefixIcon: Icon(Icons.chevron_right, color: Color(0xFF00FF00), size: 16),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF005500)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ERROR: EMAIL_REQUIRED';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      const Text(
                        'scalesync@social:~\$ enter_password',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF00FF00),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF00FF00),
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          hintText: '******',
                          hintStyle: TextStyle(color: Color(0xFF003300), fontFamily: 'monospace'),
                          prefixIcon: Icon(Icons.chevron_right, color: Color(0xFF00FF00), size: 16),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF005500)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'ERROR: PASSPHRASE_TOO_SHORT';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _executeLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00FF00),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                        ),
                                      )
                                    : const Text(
                                        'EXEC_LOGIN',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _terminalOutput.add('> exec register');
                                    _terminalOutput.add('Feature flagged: Account creation online only.');
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Terminal Mode: Registration requires live connection.', style: TextStyle(fontFamily: 'monospace', color: Colors.orange)),
                                      backgroundColor: Colors.black,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF00FF00)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text(
                                  'CREATE_ACCOUNT',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: Color(0xFF00FF00),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
