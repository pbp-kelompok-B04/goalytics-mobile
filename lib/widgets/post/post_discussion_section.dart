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

  // Colors based on Tailwind Slate
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate900 = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24), // p-6
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // rounded-3xl
        border: Border.all(color: slate200), // border-slate-200
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000), // shadow-sm (subtle)
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Discussion',
                      style: TextStyle(
                        fontSize: 20, // text-xl
                        fontWeight: FontWeight.w600, // font-semibold
                        color: slate900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Join the conversation and share your thoughts.',
                      style: TextStyle(
                        fontSize: 14, // text-sm
                        color: slate500, // text-slate-500
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: slate50, // bg-slate-50
                  borderRadius: BorderRadius.circular(50), // rounded-full
                  border: Border.all(color: slate200),
                ),
                child: Text(
                  '$commentCount Comments', // Just number mostly, or number + label
                  style: const TextStyle(
                    fontSize: 12, // text-xs
                    fontWeight: FontWeight.w600, // font-semibold
                    color: slate400, // text-slate-400
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24), // mb-6 (Header to form)

          // --- COMMENT FORM ---
          _CommentForm(
            controller: commentController,
            onSend: onSendComment,
            sending: sendingComment,
          ),

          const SizedBox(height: 16), // space-y-4 (Form to list)

          // --- COMMENT LIST ---
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

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate900 = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    // rounded-3xl border border-slate-200 bg-slate-50/70 p-5
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: slate50.withOpacity(0.7), 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label: text-xs font-semibold uppercase tracking-wide text-slate-400
          const Text(
            'ADD A COMMENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: slate400,
            ),
          ),
          const SizedBox(height: 12), // space-y-3
          
          // TextArea: rounded-2xl bg-white
          TextField(
            controller: controller,
            maxLines: 4,
            minLines: 3,
            style: const TextStyle(fontSize: 14, color: slate700),
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: const TextStyle(color: slate400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              // border-slate-200
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: slate200),
              ),
              // focus:border-slate-400
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: slate400),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Button: rounded-2xl bg-slate-900 text-white shadow-md
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: sending ? null : onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: slate900,
                foregroundColor: Colors.white,
                elevation: 4, // shadow-md
                shadowColor: slate900.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(
                sending ? 'Posting...' : 'Post Comment',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate500 = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    // Empty state: rounded-3xl border border-slate-200 bg-slate-50 py-10
    if (comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: slate50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: slate200),
        ),
        child: const Center(
          child: Text(
            'No comments yet. Be the first to comment!',
            style: TextStyle(
              fontSize: 14,
              color: slate500,
            ),
          ),
        ),
      );
    }

    return Column(
      children: comments
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // space-y-4
              child: PostCommentTile(
                comment: c,
                onLike: onLike,
                onReply: onReply,
                onEdit: onEdit,
                onDelete: onDelete,
                onToggleReplies: onToggleReplies,
                collapsedReplies: collapsedReplies,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}