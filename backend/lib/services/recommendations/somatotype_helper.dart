// ignore_for_file: depend_on_referenced_packages


// The _SomatotypeProfile class is moved here to be self-contained.
class SomatotypeProfile {
  final double ectomorph;
  final double mesomorph;
  final double endomorph;

  SomatotypeProfile({
    this.ectomorph = 0,
    this.mesomorph = 0,
    this.endomorph = 0,
  });

  /// Returns the dominant somatotype if its value is above a certain threshold.
  /// Otherwise, returns null, indicating a mixed type.
  String? getDominantTypeWithThreshold({double threshold = 70.0}) {
    if (ectomorph >= threshold) return 'Эктоморф';
    if (mesomorph >= threshold) return 'Мезоморф';
    if (endomorph >= threshold) return 'Эндоморф';
    return null;
  }

  @override
  String toString() {
    return 'Эктоморф: ${ectomorph.toStringAsFixed(0)}%, Мезоморф: ${mesomorph.toStringAsFixed(0)}%, Эндоморф: ${endomorph.toStringAsFixed(0)}%';
  }
}


String getSomatotypeHelpTextForRecommendation(SomatotypeProfile profile) {
  final dominantType = profile.getDominantTypeWithThreshold();

  if (dominantType == null) {
    return '''

---
**Соматотип: Смешанный/невыраженный**
**Характеристики:**
- У вас нет одного ярко выраженного соматотипа. Это означает, что вы сочетаете в себе черты разных типов телосложения, что является нормой.
- Ваш профиль: ${profile.toString()}
''';
  }

  String header = '';
  String characteristics = '';

  switch (dominantType) {
    case 'Эктоморф':
      header = '**Доминирующий соматотип: Эктоморф**';
      characteristics = '''
      **Характеристики:**
      - **Предрасположенность:** Худощавое телосложение, тонкие кости, узкие плечи.
      - **Метаболизм:** Ускоренный, что затрудняет набор мышечной и жировой массы.
      ''';
      break;
    case 'Мезоморф':
      header = '**Доминирующий соматотип: Мезоморф**';
      characteristics = '''
      **Характеристики:**
      - **Предрасположенность:** Атлетическое телосложение, от природы развитая мускулатура.
      - **Метаболизм:** Сбалансированный, легко набирает мышечную массу и быстро теряет жир.
      ''';
      break;
    case 'Эндоморф':
      header = '**Доминирующий соматотип: Эндоморф**';
      characteristics = '''
      **Характеристики:**
      - **Предрасположенность:** Округлые формы, крупное телосложение, широкие кости.
      - **Метаболизм:** Замедленный, имеется склонность к накоплению жира.
      ''';
      break;
    default:
      // This case is now unlikely but kept for safety.
      return '';
  }

  return '''

---
$header
$characteristics
''';
}

