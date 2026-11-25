// محرك «حفّار الماس» ⛏️: شبكة حفر نقية بلا واجهة — تُختبر وحدها.
// القواعد (مبسطة لعمر 5 سنوات):
// - الأرنب يتحرك خلية واحدة؛ التراب يُحفر بالمرور عليه.
// - الماس يُجمع بالمرور عليه؛ وبعد جمع كل الماس يفتح باب الخروج.
// - الصخرة لا تُحفر ولا يُمر من خلالها؛ وإن أُزيل التراب أسفلها تسقط
//   خلية خلية حتى تستقر — لكنها لا تسقط أبداً على الأرنب
//   (الأرنب قوي يحملها!)؛ بل تنتظر حتى يبتعد.
// - القنفذ النائم خلية مسدودة لا تُحفر ولا يُمر من خلالها.
enum DiggerCell { dirt, empty, rock, diamond, hedgehog, exit }

enum DiggerDirection { up, down, left, right }

extension DiggerDirectionDelta on DiggerDirection {
  (int, int) get delta => switch (this) {
        DiggerDirection.up => (-1, 0),
        DiggerDirection.down => (1, 0),
        DiggerDirection.left => (0, -1),
        DiggerDirection.right => (0, 1),
      };
}

/// مرحلة حفر: 9 صفوف × 7 أعمدة.
/// الرموز: # تراب، . فارغ، R صخرة، D ماس، H قنفذ نائم، E باب الخروج، P الأرنب.
class DiggerLevel {
  final int number;
  final String name;
  final List<String> rows;
  final int seconds;
  const DiggerLevel({
    required this.number,
    required this.name,
    required this.rows,
    this.seconds = 120,
  });

  /// عدد الماس في الخريطة.
  int get diamondCount {
    var count = 0;
    for (final line in rows) {
      for (var i = 0; i < line.length; i++) {
        if (line[i] == 'D') count++;
      }
    }
    return count;
  }
}

class DiggerState {
  final List<List<DiggerCell>> grid;
  int playerRow;
  int playerCol;
  int collected = 0;
  final int total;
  bool completed = false;

  DiggerState({
    required this.grid,
    required this.playerRow,
    required this.playerCol,
    required this.total,
  });

  int get rows => grid.length;
  int get cols => grid.first.length;
  bool get exitOpen => collected >= total;
  DiggerCell cellAt(int r, int c) => grid[r][c];
}

class DiggerEngine {
  /// يحلل خريطة المرحلة إلى حالة أولية.
  static DiggerState parse(DiggerLevel level) {
    final grid = <List<DiggerCell>>[];
    var pr = 0;
    var pc = 0;
    var total = 0;
    for (var r = 0; r < level.rows.length; r++) {
      final row = <DiggerCell>[];
      final line = level.rows[r];
      for (var c = 0; c < line.length; c++) {
        switch (line[c]) {
          case '#':
            row.add(DiggerCell.dirt);
          case '.':
            row.add(DiggerCell.empty);
          case 'R':
            row.add(DiggerCell.rock);
          case 'D':
            row.add(DiggerCell.diamond);
            total++;
          case 'H':
            row.add(DiggerCell.hedgehog);
          case 'E':
            row.add(DiggerCell.exit);
          case 'P':
            row.add(DiggerCell.empty);
            pr = r;
            pc = c;
          default:
            row.add(DiggerCell.dirt);
        }
      }
      grid.add(row);
    }
    return DiggerState(
      grid: grid,
      playerRow: pr,
      playerCol: pc,
      total: total,
    );
  }

  /// يحرك الأرنب خلية واحدة في الاتجاه؛ يعيد false إن كانت الحركة ممنوعة
  /// (خارج الشبكة، أو صخرة، أو قنفذ، أو باب مغلق).
  static bool move(DiggerState s, DiggerDirection dir) {
    if (s.completed) return false;
    final (dr, dc) = dir.delta;
    final r = s.playerRow + dr;
    final c = s.playerCol + dc;
    if (r < 0 || r >= s.rows || c < 0 || c >= s.cols) return false;
    final cell = s.grid[r][c];
    switch (cell) {
      case DiggerCell.rock:
      case DiggerCell.hedgehog:
        return false;
      case DiggerCell.exit:
        if (!s.exitOpen) return false;
        s.playerRow = r;
        s.playerCol = c;
        s.completed = true;
        return true;
      case DiggerCell.diamond:
        s.collected++;
        s.grid[r][c] = DiggerCell.empty;
      case DiggerCell.dirt:
        s.grid[r][c] = DiggerCell.empty;
      case DiggerCell.empty:
        break;
    }
    s.playerRow = r;
    s.playerCol = c;
    applyGravity(s);
    return true;
  }

  /// الجاذبية: كل صخرة فوق خلية فارغة تسقط خلية، وتُعاد حتى تستقر.
  /// الصخرة لا تسقط أبداً على الخلية التي يقف عليها الأرنب.
  static void applyGravity(DiggerState s) {
    var moved = true;
    while (moved) {
      moved = false;
      for (var r = s.rows - 2; r >= 0; r--) {
        for (var c = 0; c < s.cols; c++) {
          if (s.grid[r][c] != DiggerCell.rock) continue;
          final below = s.grid[r + 1][c];
          final playerBelow = s.playerRow == r + 1 && s.playerCol == c;
          if (below == DiggerCell.empty && !playerBelow) {
            s.grid[r + 1][c] = DiggerCell.rock;
            s.grid[r][c] = DiggerCell.empty;
            moved = true;
          }
        }
      }
    }
  }
}
