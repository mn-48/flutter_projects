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
  final int n = 120;
  final double radius = 250; // Increased radius for 120 soldiers

  List<int> soldiers = [];
  int currentIndex = 0;
  List<int> eliminated = [];

  // New variables for status tracking
  String lastAction = "Press the button to start";
  int roundCount = 0;

  @override
  void initState() {
    super.initState();
    soldiers = List.generate(n, (i) => i + 1);
  }

  void _nextStep() {
    if (soldiers.length > 1) {
      setState(() {
        roundCount++;
        int killer = soldiers[currentIndex];
        int killIndex = (currentIndex + 1) % soldiers.length;
        int victim = soldiers[killIndex];

        // Update the status message
        lastAction = "Round $roundCount: Soldier $killer killed $victim";

        eliminated.add(victim);
        soldiers.removeAt(killIndex);

        // Update current index for the next killer
        currentIndex = killIndex % soldiers.length;
      });
    } else {
      setState(() {
        lastAction = "Game Over! Soldier ${soldiers[0]} is the winner!";
      });
    }
  }

  void _reset() {
    setState(() {
      soldiers = List.generate(n, (i) => i + 1);
      eliminated = [];
      currentIndex = 0;
      lastAction = "Press the button to start";
      roundCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Josephus Problem (n=120, k=2)"),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Survival Status
          Text(
            soldiers.length > 1
                ? "Soldiers remaining: ${soldiers.length}"
                : "Survivor Found!",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // The Interactive Circle
          Expanded(
            child: InteractiveViewer(
              // Added this so you can zoom in/out on the 120 soldiers
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.1,
              maxScale: 2.0,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(n, (index) {
                      int soldierNum = index + 1;
                      bool isDead = eliminated.contains(soldierNum);
                      bool isCurrentKiller =
                          soldiers.isNotEmpty &&
                          soldiers[currentIndex] == soldierNum;

                      final double angle = (index * 2 * math.pi) / n;
                      final double x = radius * math.cos(angle);
                      final double y = radius * math.sin(angle);

                      return Positioned(
                        left: radius + x + 25,
                        top: radius + y + 25,
                        child: _SoldierNode(
                          number: soldierNum,
                          isDead: isDead,
                          isCurrent: isCurrentKiller,
                          totalN: n,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Round Info Box
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey[200],
            child: Column(
              children: [
                Text(
                  lastAction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: soldiers.length == 1
                        ? Colors.red
                        : Colors.blueGrey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Control Buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text("Reset Game"),
                ),
                ElevatedButton(
                  onPressed: soldiers.length > 1 ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text("Next Step"),
                ),
              ],
            ),
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
  final int totalN;

  const _SoldierNode({
    required this.number,
    required this.isDead,
    required this.isCurrent,
    required this.totalN,
  });

  @override
  Widget build(BuildContext context) {
    // Making nodes smaller if total N is high
    double size = totalN > 50 ? 25 : 45;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDead
            ? Colors.grey[300]
            : (isCurrent ? Colors.blue : const Color(0xFF1B5E20)),
        border: isCurrent ? Border.all(color: Colors.yellow, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        "$number",
        style: TextStyle(
          color: isDead ? Colors.grey[500] : Colors.white,
          fontSize: totalN > 50 ? 8 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
