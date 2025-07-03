import 'package:rpg_game/models/unit.dart';

import 'Monster.dart';

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
    int incomingAttack = monster.generateAttack();
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
