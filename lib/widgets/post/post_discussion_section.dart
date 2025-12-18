import 'package:flutter/material.dart';
import 'package:goalytics_mobile/models/forum/forum_models.dart';
import 'package:goalytics_mobile/widgets/post/post_comment_tile.dart';

class PostDiscussionSection extends StatelessWidget {
  const PostDiscussionSection({
    super.key,
    required this.commentController,
    required this.onSendComment,
    required this.sendingComment,
    required this.comments,
    required this.commentCount,
    required this.collapsedReplies,
    required this.onToggleReplies,
    required this.onLikeComment,
    required this.onReplyComment,
    required this.onEditComment,
    required this.onDeleteComment,
  });

  final TextEditingController commentController;
  final VoidCallback onSendComment;
  final bool sendingComment;
  final List<ForumComment> comments;
  final int commentCount;
  final Set<int> collapsedReplies;
  final void Function(int id) onToggleReplies;
  final ValueChanged<ForumComment> onLikeComment;
  final ValueChanged<ForumComment> onReplyComment;
  final ValueChanged<ForumComment> onEditComment;
  final ValueChanged<ForumComment> onDeleteComment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Discussion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Join the conversation and share your thoughts.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  '$commentCount COMMENTS',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CommentForm(
            controller: commentController,
            onSend: onSendComment,
            sending: sendingComment,
          ),
          const SizedBox(height: 12),
          _CommentList(
            comments: comments,
            collapsedReplies: collapsedReplies,
            onToggleReplies: onToggleReplies,
            onLike: onLikeComment,
            onReply: onReplyComment,
            onEdit: onEditComment,
            onDelete: onDeleteComment,
          ),
        ],
      ),
    );
  }
}

class _CommentForm extends StatelessWidget {
  const _CommentForm({
    required this.controller,
    required this.onSend,
    required this.sending,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ADD A COMMENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 4,
            minLines: 2,
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: sending ? null : onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: sending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 16),
              label: Text(sending ? 'Posting...' : 'Post Comment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentList extends StatelessWidget {
  const _CommentList({
    required this.comments,
    required this.collapsedReplies,
    required this.onToggleReplies,
    required this.onLike,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ForumComment> comments;
  final Set<int> collapsedReplies;
  final void Function(int id) onToggleReplies;
  final ValueChanged<ForumComment> onLike;
  final ValueChanged<ForumComment> onReply;
  final ValueChanged<ForumComment> onEdit;
  final ValueChanged<ForumComment> onDelete;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'No comments yet. Be the first to comment!',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return Column(
      children: comments
          .map(
            (c) => PostCommentTile(
              comment: c,
              onLike: onLike,
              onReply: onReply,
              onEdit: onEdit,
              onDelete: onDelete,
              onToggleReplies: onToggleReplies,
              collapsedReplies: collapsedReplies,
            ),
          )
          .toList(growable: false),
    );
  }
}
