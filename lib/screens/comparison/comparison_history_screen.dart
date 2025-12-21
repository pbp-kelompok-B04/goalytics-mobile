import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/comparison_model.dart';
import '../../service/comparison_service.dart';
import 'comparison_screen.dart';
import '../../widgets/bottom_nav.dart';

class ComparisonHistoryScreen extends StatefulWidget {
  const ComparisonHistoryScreen({super.key});

  @override
  State<ComparisonHistoryScreen> createState() => _ComparisonHistoryScreenState();
}

class _ComparisonHistoryScreenState extends State<ComparisonHistoryScreen> {
  List<Comparison> histories = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadHistory();
    });
  }

  Future<void> loadHistory() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    setState(() { isLoading = true; hasError = false; });

    try {
      final SavedComparison data = await ComparisonService.getComparisons(request);
      if (mounted) {
        setState(() { 
          histories = data.comparisons; 
          isLoading = false; 
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { 
          isLoading = false; 
          hasError = true; 
          errorMessage = 'Failed to load comparisons.'; 
        });
      }
    }
  }

  void createNewComparison() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComparisonScreen()),
    );

    if (result == true) {
      loadHistory();
    }
  }

  void editComparison(Comparison c) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComparisonScreen(
        player1Id: c.player1.id, 
        player2Id: c.player2.id, 
        comparisonId: c.id, 
        notes: c.notes
      )),
    );

    if (result == true) {
      loadHistory();
    }
  }

  void viewComparison(Comparison c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComparisonScreen(
        player1Id: c.player1.id, 
        player2Id: c.player2.id, 
        notes: c.notes
      )),
    );
  }

  Future<void> deleteComparison(int id, String p1, String p2) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comparison"),
        content: Text("Delete comparison between $p1 and $p2?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ComparisonService.deleteComparison(comparisonId: id, request: request);
      if (success && mounted) {
        loadHistory();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully"), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ComparisonScreen()),
            );
          },
        ),
        title: const Text("Comparison History", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadHistory, tooltip: 'Refresh'),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewComparison,
        backgroundColor: const Color(0xFF0F172A), 
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : hasError 
              ? Center(child: Text(errorMessage)) 
              : histories.isEmpty 
                  ? _buildEmptyState() 
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: histories.length,
                      itemBuilder: (context, index) => _buildComparisonCard(histories[index]),
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("No comparisons yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          const Text("Start comparing players to build history", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: createNewComparison,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            child: const Text("Start Comparing"),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(Comparison h) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          children: [
                            TextSpan(text: h.player1.name),
                            const TextSpan(text: " vs ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                            TextSpan(text: h.player2.name),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("${h.player1.club} • ${h.player2.club}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(h.createdAt, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    TextButton(onPressed: () => viewComparison(h), child: const Text("View")),
                    TextButton(onPressed: () => editComparison(h), child: const Text("Edit", style: TextStyle(color: Colors.orange))),
                  ],
                )
              ],
            ),
            if(h.notes.isNotEmpty) 
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: Text(h.notes, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700], fontSize: 13)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => deleteComparison(h.id, h.player1.name, h.player2.name),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  child: const Text("Delete"),
                ),
              )
          ],
        ),
      ),
    );
  }
}