// admin_chat_section.dart
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/fake_admin_chat_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';

class AdminGlobalChatSection extends StatefulWidget {
  const AdminGlobalChatSection({super.key});

  @override
  State<AdminGlobalChatSection> createState() => _AdminGlobalChatSectionState();
}

class _AdminGlobalChatSectionState extends State<AdminGlobalChatSection> {
  Map<String, List<Map<String, dynamic>>> _tickets = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final msgs = await FakeAdminGlobalChatApi.getMessages();
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final msg in msgs) {
      final userId = msg['userId'] ?? 'unknown_user';
      if (!grouped.containsKey(userId)) grouped[userId] = [];
      grouped[userId]!.add(msg);
    }
    setState(() {
      _tickets = grouped;
      for (final userId in grouped.keys) {
        if (!_controllers.containsKey(userId)) {
          _controllers[userId] = TextEditingController();
        }
      }
      _loading = false;
    });
  }

  Future<void> _sendMessage(String userId) async {
    final controller = _controllers[userId];
    if (controller == null) return;
    final text = controller.text.trim();
    if (text.isEmpty) return;
    
    final msg = {
      'type': 'message',
      'userId': userId,
      'text': text,
      'sender': 'admin',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await FakeAdminGlobalChatApi.addMessage(msg);
    controller.clear();
    await _loadTickets();
  }

  Future<void> _endTicket(String userId) async {
    await FakeAdminGlobalChatApi.clearChatForUser(userId);
    _controllers[userId]?.dispose();
    _controllers.remove(userId);
    await _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (_loading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          );
        }
        
        if (_tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.support_agent,
                  size: 64,
                  color: themeProvider.isDarkMode ? Colors.white54 : Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No hay tickets de soporte',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: _tickets.length,
          itemBuilder: (context, index) {
            final userId = _tickets.keys.elementAt(index);
            final messages = _tickets[userId]!;
            
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.isDarkMode 
                      ? Colors.white24 
                      : Colors.grey.withOpacity(0.3),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del ticket
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Usuario: $userId',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _endTicket(userId),
                        tooltip: 'Cerrar ticket',
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  
                  // Mensajes del chat
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode 
                          ? Color(0xFF1A1A1A) 
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeProvider.isDarkMode 
                            ? Colors.white12 
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, msgIndex) {
                        final msg = messages[msgIndex];
                        final isAdmin = msg['sender'] == 'admin';
                        final timestamp = DateTime.tryParse(msg['timestamp'] ?? '');
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: isAdmin 
                                ? MainAxisAlignment.end 
                                : MainAxisAlignment.start,
                            children: [
                              if (!isAdmin) ...[
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isAdmin 
                                        ? Theme.of(context).primaryColor
                                        : (themeProvider.isDarkMode 
                                            ? Color(0xFF3A3A3A) 
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(18),
                                    border: !isAdmin ? Border.all(
                                      color: themeProvider.isDarkMode 
                                          ? Colors.white24 
                                          : Colors.grey.withOpacity(0.3),
                                    ) : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg['text'] ?? '',
                                        style: TextStyle(
                                          color: isAdmin 
                                              ? Colors.white
                                              : (themeProvider.isDarkMode 
                                                  ? Colors.white 
                                                  : Colors.black87),
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (timestamp != null) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          DateFormat('HH:mm').format(timestamp),
                                          style: TextStyle(
                                            color: isAdmin 
                                                ? Colors.white70
                                                : (themeProvider.isDarkMode 
                                                    ? Colors.white54 
                                                    : Colors.grey[600]),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              if (isAdmin) ...[
                                SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    size: 14,
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
                  SizedBox(height: 12),
                  
                  // Input para responder
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode 
                                ? Color(0xFF2A2A2A) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: themeProvider.isDarkMode 
                                  ? Colors.white24 
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            controller: _controllers[userId],
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Escribe tu respuesta...',
                              hintStyle: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white54 : Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (_) => _sendMessage(userId),
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
                          icon: Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: () => _sendMessage(userId),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}