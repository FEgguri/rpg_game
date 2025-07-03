// main.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

abstract class Unit {
  //플레이어와 몬스터의 공통 속성을 정의햄
  String name;
  int health;
  int attack;
  int defense;

  Unit(this.name, this.health, this.attack, this.defense);

  void showStatus();
}

class Character extends Unit {
  //Unit 추상클래스를 상속
  Character(String name, int health, int attack, int defense)
    : super(name, health, attack, defense); //unit클래스의 속성 초기화

  void attackMonster(Monster monster) {
    //몬스터를 공격
    monster.health -= attack;
    if (monster.health < 0) monster.health = 0;
    print('$name이(가) ${monster.name}에게 $attack의 데미지를 입혔습니다');
  }

  void defend(Monster monster) {
    int incomingAttack = monster.generateAttack(defense);
    int recovery = incomingAttack - defense;

    if (recovery > 0) {
      health += recovery;
      print('${monster.name}이(가) $incomingAttack로 공격했지만,');
      print('$name이(가) 방어하여 체력을 $recovery 회복했습니다!');
    } else {
      print('${monster.name}의 공격을 완벽히 막아냈습니다!');
    }
  }

  @override
  void showStatus() {
    print('[캐릭터] 이름: $name | 체력: $health | 공격력: $attack | 방어력: $defense');
  }
}

class Monster extends Unit {
  final int maxAttack; // 최대 공격력만 저장

  Monster(String name, int health, this.maxAttack, int playerDefense)
    : super(name, health, 0, 0); // 기본 공격력과 방어력은 0으로 처리

  int generateAttack(int playerDefense) {
    return max(Random().nextInt(maxAttack + 1), playerDefense + 1);
  }

  void attackCharacter(Character character) {
    int generatedAttack = max(
      Random().nextInt(maxAttack + 1),
      character.defense,
    );
    int damage = generatedAttack - character.defense;
    if (damage < 0) damage = 0;

    character.health -= damage;
    if (character.health < 0) character.health = 0;

    print(
      '$name이(가) ${character.name}에게 $damage 데미지를 입혔습니다. '
      '(공격력: $generatedAttack)',
    );
  }

  @override
  void showStatus() {
    print('[몬스터] 이름: $name | 체력: $health | 공격력 범위: 0 ~ $maxAttack');
  }
}

class Game {
  late Character character;
  List<Monster> monsters = [];
  int defeatedCount = 0;

  void startGame() {
    loadCharacter();
    loadMonsters();

    while (character.health > 0 && monsters.isNotEmpty) {
      Monster monster = getRandomMonster();
      print('=== 전투 시작 ===');

      while (character.health > 0 && monster.health > 0) {
        character.showStatus();
        monster.showStatus();

        print('행동을 선택하세요: 1) 몬스터 때리기  2) 방어하기');
        stdout.write('>> ');
        String? choice = stdin.readLineSync();

        if (choice == '1') {
          character.attackMonster(monster);
          if (monster.health > 0) {
            monster.attackCharacter(character);
          }
        } else if (choice == '2') {
          character.defend(monster);
        } else {
          print('잘못된 입력입니다.');
          continue;
        }
      }

      if (character.health <= 0) {
        print('당신의 캐릭터가 사망했습니다. 게임 오버!');
        saveResult('패배');
        return;
      } else {
        print('${monster.name}을(를) 물리쳤습니다!');
        monsters.remove(monster);
        defeatedCount++;
      }

      if (monsters.isEmpty) {
        print('모든 몬스터를 물리쳤습니다. 게임 승리!');
        saveResult('승리');
        return;
      }

      stdout.write('다음 몬스터와 싸우시겠습니까? (y/n): ');
      String? input = stdin.readLineSync();
      if (input?.toLowerCase() != 'y') {
        print('게임을 종료합니다.');
        saveResult('중단');
        return;
      } else {
        print('다음 몬스터와 전투를 시작합니다.');
      }
    }
  }

  void loadCharacter() {
    stdout.write('캐릭터 이름을 입력하세요: ');
    String? name = stdin.readLineSync(encoding: utf8);
    //print('디버그: 입력한 이름 = [$name]');
    if (name == null || !RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
      print('잘못된 이름입니다. 한글 또는 영어만 사용할 수 있습니다.');
      exit(1);
    }

    try {
      final file = File('lib/characters.txt');
      final contents = file.readAsStringSync();
      final stats = contents.split(',');
      if (stats.length != 3) throw FormatException('형식 오류');

      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);

      character = Character(name, health, attack, defense);
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  void loadMonsters() {
    try {
      final file = File('lib/monsters.txt');
      final lines = file.readAsLinesSync(encoding: utf8);

      for (var line in lines) {
        final parts = line.split(',');
        if (parts.length != 3) continue;

        String name = parts[0];
        int health = int.parse(parts[1]);
        int maxAttack = int.parse(parts[2]);

        monsters.add(Monster(name, health, maxAttack, character.defense));
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  Monster getRandomMonster() {
    final rand = Random();
    return monsters[rand.nextInt(monsters.length)];
  }

  void saveResult(String result) {
    stdout.write('결과를 저장하시겠습니까? (y/n): ');
    String? input = stdin.readLineSync();
    if (input?.toLowerCase() == 'y') {
      final file = File('result.txt');
      file.writeAsStringSync(
        '이름: ${character.name}, 남은 체력: ${character.health}, 결과: $result',
      );
      print('결과가 저장되었습니다.');
    }
  }
}
