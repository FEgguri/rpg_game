// main.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:rpg_game/models/Character.dart';
import 'package:rpg_game/models/Monster.dart';

class Game {
  // RPG 게임 클래스
  // 게임의 주요 로직을 포함
  late Character character; // 플레이어 캐릭터
  List<Monster> monsters = []; // 몬스터 목록
  int defeatedCount = 0; // 물리친 몬스터 수

  void startGame() {
    // 게임 시작 메서드
    loadCharacter();
    loadMonsters();

    while (character.health > 0 && monsters.isNotEmpty) {
      // 몬스터가 남아있고 캐릭터가 살아있는 동안 반복
      Monster monster = getRandomMonster();
      print('\n=== 몬스터 등장 ===');
      print('\n=== ${monster.name}이 나타났다!! ===');
      print(
        '=== ${monster.name} - 체력 : ${monster.health} , 공격력 : ${monster.attack} ===',
      );
      print('\n\n=== 전투 시작 ===');

      while (character.health > 0 && monster.health > 0) {
        // 캐릭터와 몬스터가 모두 살아있는 동안 전투 진행

        // monster.showStatus();
        print('\n${character.name}의 턴');
        character.showStatus();
        stdout.write('행동을 선택하세요: 1) 몬스터 때리기  2) 방어하기 >> ');
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
        // 캐릭터가 사망한 경우
        print('당신의 캐릭터가 사망했습니다. 게임 오버!');
        saveResult('패배');
        return;
      } else {
        // 몬스터가 사망한 경우
        print('${monster.name}을(를) 물리쳤습니다!');
        monsters.remove(monster);
        defeatedCount++;
      }

      if (monsters.isEmpty) {
        // 모든 몬스터를 물리친 경우
        print('모든 몬스터를 물리쳤습니다. 게임 승리!');
        saveResult('승리');
        return;
      }

      while (true) {
        stdout.write('다음 몬스터와 싸우시겠습니까? (y/n): ');
        String? input = stdin.readLineSync();

        if (input?.toLowerCase() == 'n') {
          print('게임을 종료합니다.');
          saveResult('중단');
          return;
        } else if (input?.toLowerCase() == 'y') {
          print('다음 몬스터와 전투를 시작합니다.');
          break; // 다음 전투로 진행
        } else {
          print('잘못된 입력입니다. y 또는 n을 입력해주세요.');
          //  다시 입력받음
        }
      }
    }
  }

  void loadCharacter() {
    // 캐릭터 데이터를 불러오는 메서드
    stdout.write('캐릭터 이름을 입력하세요: ');
    String? name = stdin.readLineSync(encoding: utf8);
    //print('디버그: 입력한 이름 = [$name]');
    if (name == null || !RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
      // 한글 또는 영어만 허용
      print('잘못된 이름입니다. 한글 또는 영어만 사용할 수 있습니다.');
      exit(1);
    }

    try {
      // 캐릭터 데이터를 파일에서 읽어오기
      final file = File('lib/characters.txt');
      final contents = file.readAsStringSync(); // 파일의 내용을 문자열로 읽어오기
      final stats = contents.split(',');
      if (stats.length != 3)
        throw FormatException('형식 오류'); // 파일의 형식이 잘못된 경우 예외 발생

      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);

      character = Character(name, health, attack, defense); // 캐릭터 객체 생성
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  void loadMonsters() {
    // 몬스터 데이터를 불러오는 메서드
    try {
      final file = File('lib/monsters.txt');
      final lines = file.readAsLinesSync(encoding: utf8);

      for (var line in lines) {
        final parts = line.split(',');
        if (parts.length != 3) continue;

        String name = parts[0];
        int health = int.parse(parts[1]);
        int maxAttack = int.parse(parts[2]);

        monsters.add(Monster(name, health, maxAttack));
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  Monster getRandomMonster() {
    // 몬스터 목록에서 랜덤으로 하나를 선택하는 메서드
    final rand = Random();
    return monsters[rand.nextInt(monsters.length)];
  }

  void saveResult(String result) {
    // 게임 결과를 파일에 저장하는 메서드
    stdout.write('결과를 저장하시겠습니까? (y/n): ');
    String? input = stdin.readLineSync();
    if (input?.toLowerCase() == 'y') {
      // 사용자가 결과를 저장하기로 선택한 경우
      final file = File('result.txt');
      file.writeAsStringSync(
        '이름: ${character.name}, 남은 체력: ${character.health}, 결과: $result',
      );
      print('결과가 저장되었습니다.');
    }
  }
}
