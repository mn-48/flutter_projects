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
  final int n = 120; // Total soldiers
  final double radius = 130;

  List<int> soldiers = [];
  int currentIndex = 0;
  List<int> eliminated = [];

  @override
  void initState() {
    super.initState();
    // Fill list with 1 to n
    soldiers = List.generate(n, (i) => i + 1);
  }

  void _nextStep() {
    if (soldiers.length > 1) {
      setState(() {
        // k=2 logic: The current soldier survives, the NEXT one is eliminated.
        // The index of the person to be killed:
        int killIndex = (currentIndex + 1) % soldiers.length;

        // Add to eliminated list for visual grey-out
        eliminated.add(soldiers[killIndex]);

        // Remove the soldier
        soldiers.removeAt(killIndex);

        // The next person to start the count is the one after the killed person
        // Since we removed an element, the 'killIndex' now points to the next person automatically
        currentIndex = killIndex % soldiers.length;
      });
    }
  }

  void _reset() {
    setState(() {
      soldiers = List.generate(n, (i) => i + 1);
      eliminated = [];
      currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Josephus Problem (k=2)"),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            soldiers.length > 1
                ? "Eliminating..."
                : "Survivor: Soldier #${soldiers[0]}",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: soldiers.length > 1 ? Colors.black : Colors.red,
            ),
          ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Draw the Circle
                  ...List.generate(n, (index) {
                    int soldierNum = index + 1;
                    bool isDead = eliminated.contains(soldierNum);
                    bool isCurrent =
                        soldiers.isNotEmpty &&
                        soldiers[currentIndex] == soldierNum;

                    final double angle = (index * 2 * math.pi) / n;
                    final double x = radius * math.cos(angle);
                    final double y = radius * math.sin(angle);

                    return Positioned(
                      left: radius + x + 20,
                      top: radius + y + 20,
                      child: _SoldierNode(
                        number: soldierNum,
                        isDead: isDead,
                        isCurrent: isCurrent,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _reset, child: const Text("Reset")),
                ElevatedButton(
                  onPressed: soldiers.length > 1 ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Next Step (Kill Neighbor)"),
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

  const _SoldierNode({
    required this.number,
    required this.isDead,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDead
            ? Colors.grey[300]
            : (isCurrent ? Colors.blue : const Color(0xFF1B5E20)),
        border: isCurrent ? Border.all(color: Colors.yellow, width: 3) : null,
        boxShadow: isDead
            ? []
            : [const BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      alignment: Alignment.center,
      child: Text(
        "$number",
        style: TextStyle(
          color: isDead ? Colors.grey[600] : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
