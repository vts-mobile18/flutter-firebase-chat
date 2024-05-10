final class Chat {
  final String id;
  final List<String> imageUrls;
  final String name;
  final String text;
  final String date;
  final bool hasUnreadMessages;
  final Map members;

  Chat({
    required this.id,
    required this.imageUrls,
    required this.name,
    required this.text,
    required this.date,
    required this.hasUnreadMessages,
    required this.members
  });
}