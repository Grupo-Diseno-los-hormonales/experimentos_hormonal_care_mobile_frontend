import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/diagnosis/domain/usecases/fakechat_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DoctorChatScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final int currentUserId;

  const DoctorChatScreen({
    Key? key,
    required this.doctor,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _DoctorChatScreenState createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? _doctorProfileId;
  int? _patientProfileId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    setState(() => _isLoading = true);

    // Determinar doctor y paciente
    _doctorProfileId = widget.doctor['profileId'] ?? widget.doctor['userId'] ?? widget.doctor['id'];
    _patientProfileId = widget.currentUserId == _doctorProfileId
        ? widget.doctor['patientId']
        : widget.currentUserId;

    if (_doctorProfileId == null || _patientProfileId == null) {
      setState(() => _isLoading = false);
      return;
    }

    await _loadMessages();
    setState(() => _isLoading = false);
  }

  Future<void> _loadMessages() async {
    final msgs = await FakeChatApi.getMessages(_doctorProfileId!, _patientProfileId!);
    setState(() {
      _messages
        ..clear()
        ..addAll(msgs.map((msg) => ChatMessage(
              text: msg['text'],
              senderId: msg['senderProfileId'],
              timestamp: DateTime.parse(msg['sentAt']),
            )));
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final msg = {
      'text': text,
      'senderProfileId': widget.currentUserId,
      'sentAt': DateTime.now().toIso8601String(),
    };
    await FakeChatApi.addMessage(_doctorProfileId!, _patientProfileId!, msg);
    _messageController.clear();
    await _loadMessages();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode 
              ? Color(0xFF1E1E1E) 
              : Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: themeProvider.isDarkMode 
                      ? Color(0xFF8F7193) 
                      : Color(0xFFA78AAB),
                  child: Icon(
                    Icons.medical_services,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.doctor['fullName'] ?? 'Doctor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: themeProvider.isDarkMode 
                ? Color(0xFF8F7193) 
                : Color(0xFFA78AAB),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
                        SizedBox(width: 4),
                        Text(
                          'En línea',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Área de mensajes
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode 
                        ? Color(0xFF1A1A1A) 
                        : Colors.grey[50],
                  ),
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  themeProvider.isDarkMode 
                                      ? Color(0xFF8F7193) 
                                      : Color(0xFFA78AAB),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Cargando conversación...',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode 
                                      ? Colors.white70 
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
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
                                    color: themeProvider.isDarkMode 
                                        ? Colors.white54 
                                        : Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '¡Hola! 👋',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.isDarkMode 
                                          ? Colors.white 
                                          : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Inicia una conversación con tu doctor',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: themeProvider.isDarkMode 
                                          ? Colors.white70 
                                          : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, idx) {
                                final msg = _messages[idx];
                                final isMe = msg.senderId == widget.currentUserId;
                                
                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment: isMe 
                                        ? MainAxisAlignment.end 
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe) ...[
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: themeProvider.isDarkMode 
                                              ? Color(0xFF8F7193) 
                                              : Color(0xFFA78AAB),
                                          child: Icon(
                                            Icons.medical_services,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: isMe 
                                              ? CrossAxisAlignment.end 
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16, 
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isMe 
                                                    ? Color(0xFF4CAF50)
                                                    : (themeProvider.isDarkMode 
                                                        ? Color(0xFF3A3A3A) 
                                                        : Colors.white),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                  bottomLeft: Radius.circular(isMe ? 20 : 6),
                                                  bottomRight: Radius.circular(isMe ? 6 : 20),
                                                ),
                                                border: !isMe ? Border.all(
                                                  color: themeProvider.isDarkMode 
                                                      ? Colors.white24 
                                                      : Colors.grey.withOpacity(0.2),
                                                ) : null,
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
                                                msg.text,
                                                style: TextStyle(
                                                  color: isMe 
                                                      ? Colors.white
                                                      : (themeProvider.isDarkMode 
                                                          ? Colors.white 
                                                          : Colors.black87),
                                                  fontSize: 16,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              DateFormat('hh:mm a').format(msg.timestamp),
                                              style: TextStyle(
                                                color: themeProvider.isDarkMode 
                                                    ? Colors.white54 
                                                    : Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isMe) ...[
                                        SizedBox(width: 8),
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Color(0xFF4CAF50),
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
              
              // Divisor
              Container(
                height: 1,
                color: themeProvider.isDarkMode 
                    ? Colors.white12 
                    : Colors.grey.withOpacity(0.3),
              ),
              
              // Input para escribir mensaje
              Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode 
                      ? Color(0xFF2D2D2D) 
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.isDarkMode 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode 
                                ? Color(0xFF1A1A1A) 
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: themeProvider.isDarkMode 
                                  ? Colors.white24 
                                  : Colors.transparent,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(
                              color: themeProvider.isDarkMode 
                                  ? Colors.white 
                                  : Colors.black87,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Escribe tu mensaje...',
                              hintStyle: TextStyle(
                                color: themeProvider.isDarkMode 
                                    ? Colors.white54 
                                    : Colors.grey[500],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, 
                                vertical: 12,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF4CAF50).withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: _sendMessage,
                            child: Container(
                              width: 50,
                              height: 50,
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final int senderId;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.senderId,
    required this.timestamp,
  });
}