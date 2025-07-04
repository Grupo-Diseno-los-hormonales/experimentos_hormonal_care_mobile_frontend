import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/doctor_chat_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/communication/data/data_sources/remote/communication_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  _ConversationListScreenState createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final CommunicationApi _communicationService = CommunicationApi();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final conversations = await _communicationService.getMyConversations();
      
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
            title: const Text(
              'Mensajes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: themeProvider.isDarkMode 
                ? Color(0xFF8F7193) 
                : Color(0xFFA78AAB),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadConversations,
              ),
            ],
          ),
          body: _buildBody(themeProvider),
        );
      },
    );
  }

  Widget _buildBody(ThemeProvider themeProvider) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: themeProvider.isDarkMode 
              ? Color(0xFF8F7193) 
              : Color(0xFFA78AAB),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline, 
              size: 64, 
              color: themeProvider.isDarkMode 
                  ? Colors.white54 
                  : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Error cargando conversaciones',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode 
                    ? Colors.white 
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14, 
                color: themeProvider.isDarkMode 
                    ? Colors.white70 
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadConversations,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode 
                    ? Color(0xFF8F7193) 
                    : Color(0xFFA78AAB),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline, 
              size: 64, 
              color: themeProvider.isDarkMode 
                  ? Colors.white54 
                  : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay conversaciones',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode 
                    ? Colors.white 
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia una conversación con un doctor',
              style: TextStyle(
                fontSize: 14, 
                color: themeProvider.isDarkMode 
                    ? Colors.white70 
                    : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: themeProvider.isDarkMode 
          ? Color(0xFF8F7193) 
          : Color(0xFFA78AAB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildConversationCard(conversation, themeProvider);
        },
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation, ThemeProvider themeProvider) {
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    final lastActivity = DateTime.parse(conversation['lastActivityAt'] ?? DateTime.now().toIso8601String());
    
    // Encontrar el otro participante (asumiendo que es el doctor)
    final otherParticipant = participants.isNotEmpty ? participants.first : null;
    final participantType = otherParticipant?['type'] ?? 'Doctor';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? Color(0xFF2D2D2D) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode 
              ? Colors.white24 
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToChat(conversation),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar del doctor con gradiente
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.isDarkMode
                          ? [Color(0xFF8F7193), Color(0xFFA788AB)]
                          : [Color(0xFFA78AAB), Color(0xFF8F7193)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (themeProvider.isDarkMode 
                            ? Color(0xFF8F7193) 
                            : Color(0xFFA78AAB)).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      participantType[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información de la conversación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Dr. $participantType',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode 
                                    ? Colors.white 
                                    : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode 
                                  ? Color(0xFF4A4A4A) 
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatTime(lastActivity),
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.isDarkMode 
                                    ? Colors.white70 
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Conversación activa',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode 
                                    ? Colors.white70 
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: themeProvider.isDarkMode 
                                ? Colors.white54 
                                : Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  void _navigateToChat(Map<String, dynamic> conversation) {
    // Extraer información del doctor de los participantes
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    final doctorParticipant = participants.isNotEmpty ? participants.first : null;
    
    if (doctorParticipant != null) {
      final doctorData = {
        'id': doctorParticipant['userId'],
        'fullName': 'Doctor ${doctorParticipant['type']}',
        'specialty': doctorParticipant['type'],
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorChatScreen(
            doctor: doctorData,
            currentUserId: conversation['participants']
                .firstWhere((p) => p['userId'] != doctorParticipant['userId'])['userId'],
          ),
        ),
      ).then((_) {
        _loadConversations();
      });
    }
  }
}