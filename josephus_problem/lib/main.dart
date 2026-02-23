import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JosephusSimulation(),
    ),
  );
}

class JosephusSimulation extends StatefulWidget {
  const JosephusSimulation({super.key});
  @override
  State<JosephusSimulation> createState() => _JosephusSimulationState();
}

class _JosephusSimulationState extends State<JosephusSimulation> {
  int n = 12;
  final TextEditingController _inputController = TextEditingController();

  List<int> soldiers = [];
  int currentIndex = 0;
  List<int> eliminated = [];
  String lastAction = "Enter n and press Start!";
  int roundCount = 1;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    _inputController.text = n.toString();
    _initializeGame();
  }

  void _initializeGame() {
    soldiers = List.generate(n, (i) => i + 1);
    eliminated = [];
    currentIndex = 0;
    roundCount = 1;
    _isStarted = false;
    lastAction = "Press Start to begin!";
  }

  void _confirmAndStart() {
    int? newN = int.tryParse(_inputController.text);
    if (newN != null && newN > 1 && newN <= 500) {
      setState(() {
        n = newN;
        _initializeGame();
        _isStarted = true;
        lastAction = "The battle has begun!";
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _nextStep() {
    if (soldiers.length > 1 && _isStarted) {
      setState(() {
        int killer = soldiers[currentIndex];
        int killIndex = (currentIndex + 1) % soldiers.length;
        int victim = soldiers[killIndex];

        // FIXED ROUND LOGIC:
        // If the index of the victim is 0, it means the 'sword'
        // just crossed the starting point of the current list.
        if (killIndex == 0) {
          roundCount++;
        }

        lastAction = "Soldier $killer killed $victim";
        eliminated.add(victim);
        soldiers.removeAt(killIndex);

        // After removal, if the killer was the last person in the list,
        // the next killer will be at index 0 (the start of the list).
        currentIndex = killIndex % soldiers.length;
      });
    }

    if (soldiers.length == 1) {
      setState(() {
        lastAction = "SURVIVOR: #${soldiers[0]}!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic node size
    final double nodeSize = n > 100 ? 12.0 : (n > 50 ? 20.0 : 35.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text("Josephus Simulation"),
      ),
      body: Column(
        children: [
          _buildTopPanel(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final center = Offset(
                  constraints.maxWidth / 2,
                  constraints.maxHeight / 2,
                );
                final radius =
                    (math.min(constraints.maxWidth, constraints.maxHeight) /
                        2) -
                    40;

                return Stack(
                  children: [
                    Center(
                      child: Container(
                        width: radius * 2,
                        height: radius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                    ),
                    if (soldiers.length == 1)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 50,
                            ),
                            Text(
                              "#${soldiers[0]} WINNER",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ...List.generate(n, (index) {
                      int num = index + 1;
                      bool isDead = eliminated.contains(num);
                      bool isCurrent =
                          _isStarted &&
                          soldiers.isNotEmpty &&
                          soldiers[currentIndex] == num;

                      final double angle =
                          (index * 2 * math.pi / n) - (math.pi / 2);
                      final double x =
                          center.dx + radius * math.cos(angle) - (nodeSize / 2);
                      final double y =
                          center.dy + radius * math.sin(angle) - (nodeSize / 2);

                      return Positioned(
                        left: x,
                        top: y,
                        child: _SoldierNode(
                          number: num,
                          isDead: isDead,
                          isCurrent: isCurrent,
                          size: nodeSize,
                          showText: n < 80,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildTopPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green[50],
      child: Row(
        children: [
          const Text("n: ", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
            ),
          ),
          const Spacer(),
          _StatTile("Round", _isStarted ? "$roundCount" : "-"),
          _StatTile("Alive", "${soldiers.length}"),
        ],
      ),
    );
  }

  Widget _StatTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            lastAction,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isStarted || soldiers.length == 1)
                ElevatedButton(
                  onPressed: _confirmAndStart,
                  child: Text(
                    soldiers.length == 1 ? "Reset" : "Confirm & Start",
                  ),
                )
              else
                OutlinedButton(
                  onPressed: _initializeGame,
                  child: const Text("Reset"),
                ),
              ElevatedButton(
                onPressed: (_isStarted && soldiers.length > 1)
                    ? _nextStep
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Next Step"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoldierNode extends StatelessWidget {
  final int number;
  final bool isDead;
  final bool isCurrent;
  final double size;
  final bool showText;
  const _SoldierNode({
    required this.number,
    required this.isDead,
    required this.isCurrent,
    required this.size,
    required this.showText,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDead
            ? Colors.transparent
            : (isCurrent ? Colors.blue : Colors.green[800]),
        border: Border.all(
          color: isCurrent
              ? Colors.yellow
              : (isDead ? Colors.grey[200]! : Colors.white),
          width: isCurrent ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: isDead || !showText
          ? null
          : Text(
              "$number",
              style: TextStyle(
                color: Colors.white,
                fontSize: size / 2.5,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
