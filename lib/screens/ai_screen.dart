import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT: Replace this with your real Anthropic API key.
// Get one free at https://console.anthropic.com
// In production, NEVER hardcode keys — use flutter_dotenv or a backend proxy.
// ─────────────────────────────────────────────────────────────────────────────
const String _apiKey = 'YOUR_ANTHROPIC_API_KEY_HERE';

// ─────────────────────────────────────────────────────────────────────────────
// Message model — represents one chat bubble
// ─────────────────────────────────────────────────────────────────────────────
class _Msg {
  final String text;
  final bool isUser;
  final bool isError;

  const _Msg({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AiScreen — the main widget
// ─────────────────────────────────────────────────────────────────────────────
class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen>
    with AutomaticKeepAliveClientMixin {

  // Keep the chat alive when user switches tabs
  @override
  bool get wantKeepAlive => true;

  final _ctrl        = TextEditingController();
  final _scrollCtrl  = ScrollController();
  final List<_Msg>   _msgs    = [];
  bool               _loading = false;

  // ── Quick suggestion chips shown when chat is empty ──────────────────────
  final _suggestions = [
    'Give me a 7-day study plan for Data Structures',
    'Quiz me on Newton\'s laws of motion',
    'Best technique to memorize formulas?',
    'How do I stay focused while studying?',
  ];

  // ── System prompt — tells Claude to act as a study assistant ─────────────
  // This is sent with EVERY request so Claude always knows its role.
  static const String _systemPrompt = '''
You are Planora AI, a smart and friendly study assistant built into the Planora app.
Your job is to help students:
- Create personalised study plans
- Quiz them on any subject
- Explain concepts clearly
- Give memory and productivity tips
- Keep them motivated

Rules:
- Be concise and friendly. Use bullet points when listing things.
- If a student asks for a study plan, ask about their exam date and available hours first if not provided.
- If asked to quiz, give 3 questions at a time with options labelled A/B/C/D.
- Always end with an encouraging sentence.
- Do NOT answer anything unrelated to studying, learning, or academics.
''';

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Scroll to latest message ─────────────────────────────────────────────
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

  // ── Build the message history Claude needs ───────────────────────────────
  // Claude API needs the full conversation each time (no memory between calls).
  List<Map<String, String>> _buildHistory() {
    return _msgs
        .where((m) => !m.isError) // skip error messages
        .map((m) => {
              'role':    m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();
  }

  // ── The main function: sends message to Claude API ───────────────────────
  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Add user message to chat immediately
    setState(() {
      _msgs.add(_Msg(text: trimmed, isUser: true));
      _loading = true;
      _ctrl.clear();
    });
    _scrollToBottom();

    try {
      // ── Build the full message history to send ───────────────────────────
      // We take all previous messages PLUS the new user message.
      final history = _buildHistory();

      // ── Call the Anthropic Messages API ─────────────────────────────────
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type':      'application/json',
          'x-api-key':         _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model':      'claude-haiku-4-5-20251001', // fast + cheap, perfect for chat
          'max_tokens': 1024,
          'system':     _systemPrompt,               // Claude's role/personality
          'messages':   history,                     // full conversation history
        }),
      );

      if (response.statusCode == 200) {
        // ── Parse Claude's reply ─────────────────────────────────────────
        final data  = jsonDecode(response.body);
        final reply = data['content'][0]['text'] as String;

        setState(() {
          _msgs.add(_Msg(text: reply, isUser: false));
          _loading = false;
        });
      } else {
        // ── Handle API errors (wrong key, rate limit, etc.) ──────────────
        final error = jsonDecode(response.body);
        final msg   = error['error']?['message'] ?? 'Unknown API error';
        _showError('API Error ${response.statusCode}: $msg');
      }
    } catch (e) {
      // ── Handle network errors ────────────────────────────────────────────
      _showError('No internet connection. Check your network and try again.');
    }

    _scrollToBottom();
  }

  // ── Show an error bubble in the chat ─────────────────────────────────────
  void _showError(String message) {
    setState(() {
      _msgs.add(_Msg(text: message, isUser: false, isError: true));
      _loading = false;
    });
  }

  // ── Clear the entire chat ─────────────────────────────────────────────────
  void _clearChat() {
    setState(() => _msgs.clear());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context); // required for keepAlive

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: Column(
          children: [

            // ── Header ────────────────────────────────────────────────────
            _buildHeader(),

            // ── Suggestion chips (only when chat is empty) ────────────────
            if (_msgs.isEmpty) _buildSuggestions(),

            // ── Chat messages ─────────────────────────────────────────────
            if (_msgs.isNotEmpty) _buildMessageList(),

            // ── Typing indicator ──────────────────────────────────────────
            if (_loading) _buildTypingIndicator(),

            // ── Input bar ─────────────────────────────────────────────────
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── Header with title + clear button ─────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planora AI',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Powered by Claude',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          if (_msgs.isNotEmpty)
            TextButton.icon(
              onPressed: _clearChat,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textMuted),
            ),
        ],
      ),
    );
  }

  // ── Suggestion chips ──────────────────────────────────────────────────────
  Widget _buildSuggestions() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Hi! Ask me anything about studying 👋',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try one of these or type your own question',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),
            ..._suggestions.map(
              (s) => GestureDetector(
                onTap: () => _send(s),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Message list ──────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _msgs.length,
        itemBuilder: (_, i) => _buildBubble(_msgs[i]),
      ),
    );
  }

  // ── Single chat bubble ────────────────────────────────────────────────────
  Widget _buildBubble(_Msg msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.primary
              : msg.isError
                  ? const Color(0xFFFFEEEE)
                  : AppTheme.cardBg,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: msg.isError
                      ? Colors.red.shade200
                      : AppTheme.borderColor,
                ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isUser
                ? Colors.white
                : msg.isError
                    ? Colors.red.shade700
                    : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  // ── Typing indicator (animated dots) ─────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: const BorderRadius.only(
            topLeft:     Radius.circular(16),
            topRight:    Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft:  Radius.circular(4),
          ),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DotPulse(delay: 0),
            SizedBox(width: 4),
            _DotPulse(delay: 200),
            SizedBox(width: 4),
            _DotPulse(delay: 400),
          ],
        ),
      ),
    );
  }

  // ── Input bar at the bottom ───────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              enabled: !_loading,
              textInputAction: TextInputAction.send,
              onSubmitted: _send,
              maxLines: null,
              decoration: InputDecoration(
                hintText: _loading ? 'Planora AI is thinking...' : 'Ask anything...',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppTheme.bgPage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _loading ? null : () => _send(_ctrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _loading ? AppTheme.textMuted : AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _loading ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated pulsing dot for the typing indicator
// ─────────────────────────────────────────────────────────────────────────────
class _DotPulse extends StatefulWidget {
  final int delay;
  const _DotPulse({required this.delay});

  @override
  State<_DotPulse> createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
