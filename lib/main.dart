import 'package:flutter/material.dart';
import 'package:vedantio/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class WordSearchScreen extends StatefulWidget {
  const WordSearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WordSearchScreenState createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  int rows = 0;
  int columns = 0;
  String searchWord = '';
  List<List<Color>> gridColors = [];
  List<List<String>> gridContent = [];
  List<Offset> highlightedCells = [];

  TextEditingController searchWordController = TextEditingController();
  TextEditingController alphabetsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Search'),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Enter number of rows'),
                onChanged: (value) {
                  setState(() {
                    rows = int.tryParse(value) ?? 0;
                  });
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Enter number of columns'),
                onChanged: (value) {
                  setState(() {
                    columns = int.tryParse(value) ?? 0;
                  });
                },
              ),
              TextField(
                controller: alphabetsController,
                decoration: const InputDecoration(
                    labelText: 'Enter alphabets for the grid (row by row)'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  generateGrid(alphabetsController.text);
                },
                child: const Text('Generate Grid'),
              ),
              const SizedBox(height: 16.0),
              if (gridColors.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: rows * columns,
                      itemBuilder: (context, index) {
                        int row = index ~/ columns;
                        int column = index % columns;
                        return GestureDetector(
                          onTap: () {
                            // Handle grid cell tap if needed
                          },
                          child: Container(
                            color: highlightedCells.contains(
                                    Offset(row.toDouble(), column.toDouble()))
                                ? Colors.yellow
                                : gridColors[row][column],
                            child: Center(
                              child: Text(
                                gridContent[row][column],
                                style: TextStyle(
                                  color: highlightedCells.contains(Offset(
                                          row.toDouble(), column.toDouble()))
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: searchWordController,
                      decoration:
                          const InputDecoration(labelText: 'Enter search word'),
                      onChanged: (value) {
                        setState(() {
                          searchWord = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: searchWordInGrid,
                      child: const Text('Search Word'),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: refresh,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void generateGrid(String inputAlphabets) {
    // Check if the number of alphabets provided matches the grid size
    if (inputAlphabets.length != rows * columns) {
      // Handle error: Number of alphabets does not match grid size
      return;
    }

    gridColors.clear();
    gridContent.clear();

    int index = 0;
    for (int i = 0; i < rows; i++) {
      List<Color> rowColors = [];
      List<String> rowContent = [];
      for (int j = 0; j < columns; j++) {
        Color color = Colors.grey; // Set all grid cells to grey color
        String content =
            inputAlphabets[index]; // Assign alphabet from input string
        index++;
        rowColors.add(color);
        rowContent.add(content);
      }
      gridColors.add(rowColors);
      gridContent.add(rowContent);
    }
    setState(() {});
  }

  void searchWordInGrid() {
    if (searchWord.isEmpty) return;
    highlightedCells.clear();
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (gridContent[i][j] == searchWord[0]) {
          // If the first character matches, check all 8 directions
          for (int k = 0; k < 8; k++) {
            if (checkWord(i, j, 1, 0, k) ||
                checkWord(i, j, 0, 1, k) ||
                checkWord(i, j, -1, 0, k) ||
                checkWord(i, j, 0, -1, k) || // Up
                checkWord(i, j, 1, 1, k) || // Diagonal Down Right
                checkWord(i, j, -1, 1, k) || // Diagonal Up Right
                checkWord(i, j, 1, -1, k) || // Diagonal Down Left
                checkWord(i, j, -1, -1, k)) {
              // Diagonal Up Left
              return;
            }
          }
        }
      }
    }
  }

  bool checkWord(int row, int column, int dx, int dy, int dir) {
    int r = row;
    int c = column;
    for (int i = 0; i < searchWord.length; i++) {
      if (r < 0 ||
          r >= rows ||
          c < 0 ||
          c >= columns ||
          gridContent[r][c] != searchWord[i]) {
        return false;
      }
      r += dx;
      c += dy;
    }

    // If the word is found, mark the cells
    setState(() {
      r = row;
      c = column;
      for (int i = 0; i < searchWord.length; i++) {
        highlightedCells.add(Offset(r.toDouble(), c.toDouble()));
        r += dx;
        c += dy;
      }
    });
    return true;
  }

  void refresh() {
    setState(() {
      highlightedCells.clear();
      searchWord = '';
      searchWordController.clear();
    });
  }
}
