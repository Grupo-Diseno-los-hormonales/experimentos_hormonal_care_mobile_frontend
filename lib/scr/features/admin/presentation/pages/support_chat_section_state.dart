// support_chat_section_state.dart
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/fake_admin_chat_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';

class SupportUserChatSection extends StatefulWidget {
  const SupportUserChatSection({super.key});

  @override
  State<SupportUserChatSection> createState() => _SupportUserChatSectionState();
}

class _SupportUserChatSectionState extends State<SupportUserChatSection> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndMessages();
  }

  Future<void> _loadUserIdAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic userIdRaw = prefs.get('user_id');
    String userId;
    if (userIdRaw == null) {
      userId = 'unknown_user';
    } else if (userIdRaw is int) {
      userId = userIdRaw.toString();
    } else {
      userId = userIdRaw.toString();
    }
    setState(() {
      _userId = userId;
    });
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await FakeAdminGlobalChatApi.getMessages();
    final filtered = msgs.where((msg) => msg['userId'] == _userId).toList();
    setState(() {
      _messages = filtered;
      _loading = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _userId == null) return;
    
    final msg = {
      'type': 'message',
      'userId': _userId,
      'text': text,
      'sender': 'user',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await FakeAdminGlobalChatApi.addMessage(msg);
    _controller.clear();
    await _loadMessages();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            children: [
              // Header del chat
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: themeProvider.isDarkMode 
                          ? Colors.white24 
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(Icons.support_agent, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soporte Técnico',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Text(
                            'Estamos aquí para ayudarte',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: 12,
                    ),
                  ],
                ),
              ),

              // Área de mensajes
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: themeProvider.isDarkMode ? Colors.white54 : Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '¡Hola! 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Escribe tu primera pregunta\ny te ayudaremos',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode 
                                  ? Color(0xFF1A1A1A) 
                                  : Colors.grey[50],
                            ),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                final isUser = msg['sender'] == 'user';
                                final timestamp = DateTime.tryParse(msg['timestamp'] ?? '');

                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment: isUser 
                                        ? MainAxisAlignment.end 
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isUser) ...[
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Theme.of(context).primaryColor,
                                          child: Icon(
                                            Icons.support_agent,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: isUser 
                                              ? CrossAxisAlignment.end 
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                                              ),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isUser 
                                                    ? Theme.of(context).primaryColor
                                                    : (themeProvider.isDarkMode 
                                                        ? Color(0xFF3A3A3A) 
                                                        : Colors.white),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                                                  bottomRight: Radius.circular(isUser ? 4 : 16),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: themeProvider.isDarkMode 
                                                        ? Colors.black.withOpacity(0.3)
                                                        : Colors.grey.withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                msg['text'] ?? '',
                                                style: TextStyle(
                                                  color: isUser 
                                                      ? Colors.white
                                                      : (themeProvider.isDarkMode 
                                                          ? Colors.white 
                                                          : Colors.black87),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            if (timestamp != null) ...[
                                              SizedBox(height: 4),
                                              Text(
                                                DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
                                                style: TextStyle(
                                                  color: themeProvider.isDarkMode 
                                                      ? Colors.white54 
                                                      : Colors.grey[500],
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isUser) ...[
                                        SizedBox(width: 8),
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.blue,
                                          child: Icon(
                                            Icons.person,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),

              // Input para escribir mensaje
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(
                      color: themeProvider.isDarkMode 
                          ? Colors.white24 
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode 
                              ? Color(0xFF2A2A2A) 
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: themeProvider.isDarkMode 
                                ? Colors.white24 
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu mensaje...',
                            hintStyle: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white54 : Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                          maxLines: null,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}