import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true; // 🔥 THIS FIXES RESET ISSUE

  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Msg> _msgs = [];
  bool _loading = false;

  final _suggestions = [
    'Give me a study plan',
    'Quiz me on Physics',
    'How to memorize formulas?',
    'Best revision technique?',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _msgs.add(_Msg(text: text, isUser: true));
      _loading = true;
      _ctrl.clear();
    });

    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 900));
    final reply = _mockReply(text);

    setState(() {
      _msgs.add(_Msg(text: reply, isUser: false));
      _loading = false;
    });

    _scrollToBottom();
  }

  String _mockReply(String q) {
    final lower = q.toLowerCase();

    if (lower.contains('plan')) {
      return 'Based on your progress, I suggest:\n• Math: 1 hr/day\n• Physics: 2 hrs/day\n• Chemistry: 1.5 hrs/day';
    }

    if (lower.contains('quiz')) {
      return "Q1: What is Newton's second law?\nA) F = ma\nB) E = mc²\nC) v = u + at";
    }

    if (lower.contains('memorize')) {
      return 'Use spaced repetition + active recall + teaching method.';
    }

    return 'Focus more on weak subjects and revise daily.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 🔥 REQUIRED for keepAlive

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "AI Assistant",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (_msgs.isEmpty)
              Wrap(
                children: _suggestions.map((s) {
                  return GestureDetector(
                    onTap: () => _send(s),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(s),
                    ),
                  );
                }).toList(),
              ),

            if (_msgs.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) {
                    final m = _msgs[i];
                    return ListTile(
                      title: Text(m.text),
                      trailing: m.isUser ? const Icon(Icons.person) : null,
                      leading: !m.isUser ? const Icon(Icons.smart_toy) : null,
                    );
                  },
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _send(_ctrl.text),
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;

  const _Msg({required this.text, required this.isUser});
}