import 'dart:math';

import 'package:rpg_game/models/Character.dart';
import 'package:rpg_game/models/unit.dart';

class Monster extends Unit {
  final int maxAttack; // 최대 공격력만 저장

  Monster(String name, int health, this.maxAttack)
    : super(name, health, maxAttack, 0);

  int generateAttack() {
    // 몬스터의 공격력 생성
    return Random().nextInt(maxAttack + 1);
  }

  void attackCharacter(Character character) {
    int generatedAttack = max(
      Random().nextInt(maxAttack + 1),
      character.defense,
    );
    int damage = generatedAttack - character.defense;
    if (damage < 0) damage = 0; // 플레이어의 방어력보다 낮은 공격력은 0으로 처리

    character.health -= damage;
    if (character.health < 0) character.health = 0;

    print('\n${name}의 턴 ');
    showStatus();
    print(
      '\n$name이(가) ${character.name}에게 $damage 데미지를 입혔습니다. '
      '(공격력: $generatedAttack)',
    );
  }

  @override
  void showStatus() {
    print('\n[몬스터] 이름: $name | 체력: $health | 공격력 범위: 0 ~ $maxAttack');
  }
}
