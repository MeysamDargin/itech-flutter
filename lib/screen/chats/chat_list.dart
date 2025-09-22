import 'package:flutter/material.dart';
// import 'package:itech/screen/chats/chats.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chats'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          _buildChatTile(
            context,
            name: 'M.Reza Behzadi',
            avatar: 'assets/img/g.png',
            lastMessage: 'Hello, how are you?',
            time: '11:30 AM',
            isOnline: true,
          ),
          _buildChatTile(
            context,
            name: 'Ali Hosseini',
            avatar: 'assets/img/g.png',
            lastMessage: 'See you tomorrow!',
            time: 'Yesterday',
            isOnline: false,
          ),
          _buildChatTile(
            context,
            name: 'Sara Ahmadi',
            avatar: 'assets/img/g.png',
            lastMessage: 'Thanks for your help',
            time: '2d ago',
            isOnline: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.message),
        onPressed: () {
          // Start new chat
        },
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required String name,
    required String avatar,
    required String lastMessage,
    required String time,
    required bool isOnline,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(radius: 25, backgroundImage: AssetImage(avatar)),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        lastMessage,
        style: TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder:
        //         (context) => ChatScreen(
        //           recipientName: name,
        //           recipientAvatar: avatar,
        //           lastSeen: isOnline ? 'Online' : 'Last seen 25 mins ago',
        //         ),
        //   ),
        // );
      },
    );
  }
}
