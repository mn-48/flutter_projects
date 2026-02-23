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
  final int n = 64;
  List<int> soldiers = [];
  int currentIndex = 0;
  List<int> eliminated = [];
  String lastAction = "Start the circle!";
  int roundCount = 1;

  @override
  void initState() {
    super.initState();
    soldiers = List.generate(n, (i) => i + 1);
  }

  void _nextStep() {
    if (soldiers.length > 1) {
      setState(() {
        int killer = soldiers[currentIndex];
        int killIndex = (currentIndex + 1) % soldiers.length;
        int victim = soldiers[killIndex];

        if (victim < killer) roundCount++;

        lastAction = "Soldier $killer killed $victim";
        eliminated.add(victim);
        soldiers.removeAt(killIndex);

        // After removal, currentIndex points to the next killer
        currentIndex = killIndex % soldiers.length;

        // Check if we just found the final survivor
        if (soldiers.length == 1) {
          lastAction = "WINNER: Soldier #${soldiers[0]}!";
          _showWinnerDialog(soldiers[0]);
        }
      });
    }
  }

  void _showWinnerDialog(int winner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Final Survivor Found!"),
        content: Text(
          "Soldier #$winner has survived the Josephus problem in $roundCount rounds.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text("Restart Game"),
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      soldiers = List.generate(n, (i) => i + 1);
      eliminated = [];
      currentIndex = 0;
      roundCount = 1;
      lastAction = "Start the circle!";
    });
  }

  @override
  Widget build(BuildContext context) {
    // For 121 soldiers, we need smaller nodes to prevent "Bad Circle" overlapping
    final double nodeSize = n > 50 ? 20.0 : 40.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Josephus Survivor"),
        backgroundColor: Colors.green[900],
      ),
      body: Column(
        children: [
          _buildHeader(),
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
                    30;

                return Stack(
                  children: [
                    // Visual Circle Path
                    Center(
                      child: Container(
                        width: radius * 2,
                        height: radius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                      ),
                    ),
                    // Survivor Highlight in the center
                    if (soldiers.length == 1)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 60,
                            ),
                            Text(
                              "WINNER\n#${soldiers[0]}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Positioning soldiers
                    ...List.generate(n, (index) {
                      int num = index + 1;
                      bool isDead = eliminated.contains(num);
                      bool isCurrent =
                          soldiers.isNotEmpty && soldiers[currentIndex] == num;
                      bool isFinalWinner =
                          soldiers.length == 1 && soldiers[0] == num;

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
                          isFinalWinner: isFinalWinner,
                          size: nodeSize,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatText("Round", "$roundCount"),
          _StatText("Alive", "${soldiers.length}"),
          if (soldiers.length == 1)
            const Text(
              "SURVIVOR FOUND!",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _StatText(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(25),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            lastAction,
            style: TextStyle(
              fontSize: 16,
              color: soldiers.length == 1 ? Colors.green : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: _reset, child: const Text("Reset")),
              ElevatedButton(
                onPressed: soldiers.length > 1 ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
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
  final bool isFinalWinner;
  final double size;

  const _SoldierNode({
    required this.number,
    required this.isDead,
    required this.isCurrent,
    required this.isFinalWinner,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isFinalWinner ? size * 1.5 : size,
      height: isFinalWinner ? size * 1.5 : size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDead
            ? Colors.transparent
            : (isFinalWinner
                  ? Colors.orange
                  : (isCurrent ? Colors.blue : Colors.green[800])),
        border: Border.all(
          color: isDead
              ? Colors.grey[200]!
              : (isFinalWinner
                    ? Colors.red
                    : (isCurrent ? Colors.yellow : Colors.white)),
          width: isCurrent || isFinalWinner ? 3 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: isDead
          ? const SizedBox()
          : Text(
              "$number",
              style: TextStyle(
                color: Colors.white,
                fontSize: size < 25 ? 8 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
