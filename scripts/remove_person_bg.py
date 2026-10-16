#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
أداة بايثون لتفريغ خلفية الصور وحفظها بصيغة PNG شفافة
Python tool to remove image background and export transparent PNG
"""

import os
import sys
import shutil
from PIL import Image

# ضبط ترميز النصوص لدعم اللغة العربية في سطر الأوامر
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

from rembg import remove, new_session

def remove_background(input_path: str, output_path: str, cropped_output_path: str = None):
    print(f"[*] جاري قراءة الصورة: {input_path}")
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"ملف الصورة غير موجود: {input_path}")

    with Image.open(input_path) as img:
        print(f"[*] أبعاد الصورة الأصلية: {img.size[0]}x{img.size[1]} بكسل")
        print("[*] جاري تفريغ الخلفية بالذكاء الاصطناعي...")
        
        session = new_session("u2net")
        output = remove(img, session=session)
        
        if output.mode != 'RGBA':
            output = output.convert('RGBA')
            
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        output.save(output_path, format="PNG")
        print(f"[✓] تم حفظ الصورة المفرغة بنجاح: {output_path}")

        # إنشاء نسخة مقصوصة تلقائياً حول الشخص بدون المساحات الفارغة الزائدة
        if cropped_output_path:
            bbox = output.getbbox()
            if bbox:
                pad = 20
                width, height = output.size
                crop_box = (
                    max(0, bbox[0] - pad),
                    max(0, bbox[1] - pad),
                    min(width, bbox[2] + pad),
                    min(height, bbox[3] + pad)
                )
                cropped_img = output.crop(crop_box)
                os.makedirs(os.path.dirname(os.path.abspath(cropped_output_path)), exist_ok=True)
                cropped_img.save(cropped_output_path, format="PNG")
                print(f"[✓] تم حفظ النسخة المقصوصة بدقة (Cropped): {cropped_output_path}")

    return output_path

if __name__ == "__main__":
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
        base, _ = os.path.splitext(input_file)
        main_output = sys.argv[2] if len(sys.argv) > 2 else f"{base}_transparent.png"
        main_cropped = sys.argv[3] if len(sys.argv) > 3 else f"{base}_transparent_cropped.png"
    else:
        # الصورة الافتراضية المرفوعة
        input_file = r"C:\Users\amir0509\.gemini\antigravity-ide\brain\ba79fe93-8b95-429b-ab9b-81b15b1e7e02\.user_uploaded\media_1792087388472.jpg"
        main_output = r"c:\mihrab\output\person_transparent.png"
        main_cropped = r"c:\mihrab\output\person_transparent_cropped.png"

    remove_background(input_file, main_output, main_cropped)

    # حفظ نسخة إضافية على سطح المكتب لسهولة الوصول
    desktop_dir = os.path.expanduser(r"~\Desktop")
    if os.path.exists(desktop_dir):
        dest_main = os.path.join(desktop_dir, os.path.basename(main_output))
        dest_cropped = os.path.join(desktop_dir, os.path.basename(main_cropped))
        if os.path.abspath(main_output) != os.path.abspath(dest_main):
            shutil.copy2(main_output, dest_main)
        if os.path.abspath(main_cropped) != os.path.abspath(dest_cropped):
            shutil.copy2(main_cropped, dest_cropped)
        print(f"[✓] تم حفظ نسخة على سطح المكتب: {desktop_dir}")

    print("\n[SUCCESS] تمت العملية بنجاح!")
