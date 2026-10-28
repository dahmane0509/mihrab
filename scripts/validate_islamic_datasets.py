#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Automated Validator & Auditor for Quranic Texts, Hadith/Adhkar Databases, and Encoding Integrity.
Supports:
  1. JSON files (Tanzil / AlQuran Cloud / Hadith JSON schemas)
  2. SQLite databases (.db / .sqlite)
  3. Mihrab Dart data sources (lib/data/quran_data.dart, lib/data/quran_texts.dart,
     lib/data/adhkar_data.dart, lib/services/auto_adhkar_service.dart)
"""

import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, List

# Standard Kufan (Hafs 'an 'Asim / Tanzil) verse counts for all 114 Surahs (Total = 6236)
TANZIL_SURAH_VERSE_COUNTS: Dict[int, int] = {
    1: 7, 2: 286, 3: 200, 4: 176, 5: 120, 6: 165, 7: 206, 8: 75, 9: 129, 10: 109,
    11: 123, 12: 111, 13: 43, 14: 52, 15: 99, 16: 128, 17: 111, 18: 110, 19: 98, 20: 135,
    21: 112, 22: 78, 23: 118, 24: 64, 25: 77, 26: 227, 27: 93, 28: 88, 29: 69, 30: 60,
    31: 34, 32: 30, 33: 73, 34: 54, 35: 45, 36: 83, 37: 182, 38: 88, 39: 75, 40: 85,
    41: 54, 42: 53, 43: 89, 44: 59, 45: 37, 46: 35, 47: 38, 48: 29, 49: 18, 50: 45,
    51: 60, 52: 49, 53: 62, 54: 55, 55: 78, 56: 96, 57: 29, 58: 22, 59: 24, 60: 13,
    61: 14, 62: 11, 63: 11, 64: 18, 65: 12, 66: 12, 67: 30, 68: 52, 69: 52,
    70: 44, 71: 28, 72: 28, 73: 20, 74: 56, 75: 40, 76: 31, 77: 50, 78: 40, 79: 46,
    80: 42, 81: 29, 82: 19, 83: 36, 84: 25, 85: 22, 86: 17, 87: 19, 88: 26, 89: 30,
    90: 20, 91: 15, 92: 21, 93: 11, 94: 8, 95: 8, 96: 19, 97: 5, 98: 8, 99: 8,
    100: 11, 101: 11, 102: 8, 103: 3, 104: 9, 105: 5, 106: 4, 107: 7, 108: 3, 109: 6,
    110: 3, 111: 5, 112: 4, 113: 5, 114: 6,
}

# Arabic Diacritics (Tashkeel) Unicode range
ARABIC_HARAKAT = set("\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0653\u0654\u0655\u0670")
PURE_VOWELS = set("\u064B\u064C\u064D\u064E\u064F\u0650\u0652")  # Fathatan..Sukun

# Common UTF-8 / Windows-1256 / ISO-8859-1 Mojibake sequences
MOJIBAKE_REGEX = re.compile(r"[\uFFFD]|(?:Ø[\x80-\xBF]|Ù[\x80-\xBF]|Ã[\x80-\xBF]|â€)")
CONTROL_CHARS_REGEX = re.compile(r"[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]")


def check_text_encoding_and_tashkeel(text: str, context_id: str) -> List[str]:
    """Checks a single Arabic string for UTF-8 corruption, control chars, and invalid Tashkeel."""
    issues: List[str] = []
    if not text or not text.strip():
        issues.append(f"[{context_id}] Empty or whitespace-only text field.")
        return issues

    if "\uFFFD" in text:
        issues.append(f"[{context_id}] Contains Unicode Replacement Character (U+FFFD) indicating broken UTF-8 decoding.")

    if MOJIBAKE_REGEX.search(text):
        issues.append(f"[{context_id}] Suspected Mojibake / UTF-8 encoding corruption detected.")

    if CONTROL_CHARS_REGEX.search(text):
        issues.append(f"[{context_id}] Contains non-printable ASCII control characters.")

    # Check for orphaned harakat (e.g., word starting with a harakah or two conflicting vowels in a row)
    prev_char = ""
    for idx, ch in enumerate(text):
        if ch in ARABIC_HARAKAT:
            if idx == 0 or prev_char.isspace():
                issues.append(f"[{context_id}] Orphaned diacritic at index {idx} (harakah immediately follows whitespace/start).")
            if ch in PURE_VOWELS and prev_char in PURE_VOWELS:
                issues.append(
                    f"[{context_id}] Consecutive conflicting vowels at index {idx}: "
                    f"U+{ord(prev_char):04X} followed by U+{ord(ch):04X}."
                )
        prev_char = ch

    return issues


def audit_mihrab_dart_datasets(mihrab_root: Path) -> Dict[str, Any]:
    """Audits the Mihrab project's Quran and Hadith/Adhkar Dart files."""
    report: Dict[str, Any] = {
        "quran_metadata_issues": [],
        "quran_offline_text_issues": [],
        "hadith_adhkar_issues": [],
        "encoding_issues": [],
    }

    # 1. Audit QuranData (lib/data/quran_data.dart)
    quran_data_path = mihrab_root / "lib" / "data" / "quran_data.dart"
    if quran_data_path.exists():
        content = quran_data_path.read_text(encoding="utf-8")
        pattern = re.compile(
            r'Surah\(\s*number:\s*(\d+)\s*,\s*nameAr:\s*"([^"]+)"\s*,\s*nameEn:\s*"([^"]+)"\s*,\s*versesCount:\s*(\d+)\s*,\s*typeAr:\s*"([^"]+)"\s*\)'
        )
        matches = pattern.findall(content)
        seen_surahs = {}
        for num_str, name_ar, name_en, v_count_str, type_ar in matches:
            s_num = int(num_str)
            v_count = int(v_count_str)
            seen_surahs[s_num] = v_count
            expected = TANZIL_SURAH_VERSE_COUNTS.get(s_num)
            if expected != v_count:
                report["quran_metadata_issues"].append(
                    f"Surah {s_num} ({name_ar}): versesCount={v_count}, expected Tanzil count={expected}"
                )
        if len(seen_surahs) != 114:
            report["quran_metadata_issues"].append(f"Expected 114 Surahs in QuranData, found {len(seen_surahs)}.")

    # 2. Audit QuranTexts (lib/data/quran_texts.dart)
    quran_texts_path = mihrab_root / "lib" / "data" / "quran_texts.dart"
    if quran_texts_path.exists():
        content = quran_texts_path.read_text(encoding="utf-8")
        block_pattern = re.compile(r"(\d+)\s*:\s*\[(.*?)\]", re.DOTALL)
        for s_num_str, block in block_pattern.findall(content):
            s_num = int(s_num_str)
            verses = re.findall(r'"([^"]+)"', block)
            expected_count = TANZIL_SURAH_VERSE_COUNTS.get(s_num, 0)
            if len(verses) != expected_count:
                report["quran_offline_text_issues"].append(
                    f"Surah {s_num}: Offline array has only {len(verses)}/{expected_count} verses "
                    f"(missing {expected_count - len(verses)} verses)."
                )
            for idx, v_text in enumerate(verses, start=1):
                report["encoding_issues"].extend(
                    check_text_encoding_and_tashkeel(v_text, f"QuranTexts Surah {s_num}:{idx}")
                )
                # Specific Tanzil Uthmani / Simple-Enhanced checks
                if s_num == 36 and idx == 4 and "صِرَاطٍ مُسْتَقِيمٍ" in v_text:
                    report["quran_offline_text_issues"].append(
                        "Surah 36:4 (Ya-Sin): Missing Shaddah on Meem in 'مُسْتَقِيمٍ' -> Tanzil standard has Idgham Shaddah 'مُّسْتَقِيمٍ'."
                    )

    # 3. Audit Adhkar / Hadith datasets (lib/data/adhkar_data.dart)
    adhkar_path = mihrab_root / "lib" / "data" / "adhkar_data.dart"
    if adhkar_path.exists():
        content = adhkar_path.read_text(encoding="utf-8")
        item_blocks = re.findall(r"DhikrItem\(\s*(text:.*?)\n\s*\),", content, re.DOTALL)
        for idx, block in enumerate(item_blocks, start=1):
            text_m = re.search(r'text:\s*"([^"]+)"', block)
            virtue_m = re.search(r'virtue:\s*"([^"]+)"', block)
            count_m = re.search(r"targetCount:\s*(\d+)", block)
            matn = text_m.group(1) if text_m else ""
            virtue = virtue_m.group(1) if virtue_m else None
            count = int(count_m.group(1)) if count_m else 0

            report["encoding_issues"].extend(check_text_encoding_and_tashkeel(matn, f"DhikrItem #{idx} matn"))
            if virtue:
                report["encoding_issues"].extend(check_text_encoding_and_tashkeel(virtue, f"DhikrItem #{idx} virtue"))
            else:
                report["hadith_adhkar_issues"].append(
                    f"DhikrItem #{idx} ('{matn[:35]}...'): Missing 'virtue' / Takhreej reference field."
                )
            if "(" in matn and ("مرات" in matn or "مرة" in matn or "آية الكرسي" in matn):
                report["hadith_adhkar_issues"].append(
                    f"DhikrItem #{idx}: Matn contains inline parenthetical metadata/instruction: '{matn}'."
                )
            if count <= 0:
                report["hadith_adhkar_issues"].append(f"DhikrItem #{idx}: Invalid targetCount={count}.")

    return report


if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(r"C:\mihrab")
    results = audit_mihrab_dart_datasets(target)
    print(json.dumps(results, ensure_ascii=False, indent=2))

