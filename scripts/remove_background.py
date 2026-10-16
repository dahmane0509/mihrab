#!/usr/bin/env python3
"""
أداة بايثون لتفريغ خلفيات الصور وحفظها بصيغة PNG شفافة
Background Removal Tool in Python with RGBA PNG export.
"""

import os
import sys

# ضمان دعم الترميز UTF-8 في بيئة ويندوز لطباعة النصوص التوضيحية
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

from PIL import Image

def remove_background_ai(input_path: str, output_path: str):
    """
    تفريغ خلفية الصورة باستخدام الذكاء الاصطناعي (rembg)
    Remove image background using rembg (deep learning).
    """
    try:
        from rembg import remove
        print(f"[AI] جاري تفريغ الخلفية بالذكاء الاصطناعي للصورة: {input_path}")
        with Image.open(input_path) as img:
            result = remove(img)
            # التأكد من حفظها بنظام RGBA وبصيغة PNG
            if result.mode != 'RGBA':
                result = result.convert('RGBA')
            os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
            result.save(output_path, format="PNG")
            print(f"[OK] تم حفظ الصورة المفرغة بنجاح في: {output_path}")
            return True
    except ImportError:
        print("[WARN] مكتبة rembg غير مثبتة، الانتقال لطريقة المعالجة البديلة...")
        return False
    except Exception as e:
        print(f"[ERROR] حدث خطأ أثناء التفريغ بالذكاء الاصطناعي: {e}")
        return False

def remove_background_color_threshold(input_path: str, output_path: str, bg_color='white', tolerance=30):
    """
    طريقة بديلة لتفريغ الخلفيات ذات اللون الأحادي (أبيض أو أسود) باستخدام Pillow
    Fallback method to remove solid backgrounds (white/black) using PIL.
    """
    print(f"[COLOR] جاري تفريغ الخلفية بناءً على اللون ({bg_color}) للصورة: {input_path}")
    with Image.open(input_path) as img:
        img = img.convert("RGBA")
        datas = img.getdata()

        new_data = []
        for item in datas:
            r, g, b, a = item
            if bg_color == 'white':
                # إذا كان اللون قريباً من الأبيض
                if r >= (255 - tolerance) and g >= (255 - tolerance) and b >= (255 - tolerance):
                    new_data.append((255, 255, 255, 0))  # شفاف
                else:
                    new_data.append(item)
            elif bg_color == 'black':
                # إذا كان اللون قريباً من الأسود
                if r <= tolerance and g <= tolerance and b <= tolerance:
                    new_data.append((0, 0, 0, 0))  # شفاف
                else:
                    new_data.append(item)
            else:
                new_data.append(item)

        img.putdata(new_data)
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        img.save(output_path, "PNG")
        print(f"[OK] تم تفريغ الخلفية وحفظ النتيجة في: {output_path}")
        return True

def process_image(input_path: str, output_path: str = None):
    if not os.path.exists(input_path):
        print(f"[ERROR] خطأ: ملف الصورة غير موجود: {input_path}")
        return False

    if not output_path:
        base, _ = os.path.splitext(input_path)
        output_path = f"{base}_transparent.png"

    # 1. المحاولة الأولى باستخدام الذكاء الاصطناعي (أعلى دقة للخلفيات المعقدة والشعارات)
    success = remove_background_ai(input_path, output_path)

    # 2. إذا فشل الذكاء الاصطناعي، استخدام معالجة الألوان المباشرة
    if not success:
        print("[INFO] محاولة التفريغ عبر كشف لون الخلفية التلقائي...")
        # فحص لون زوايا الصورة لتخمين ما إذا كانت بيضاء أو سوداء
        with Image.open(input_path) as test_img:
            rgb_test = test_img.convert("RGB")
            corner = rgb_test.getpixel((5, 5))
            is_white = sum(corner) > 600
            bg_target = 'white' if is_white else 'black'
            remove_background_color_threshold(input_path, output_path, bg_color=bg_target, tolerance=35)

    return True

if __name__ == "__main__":
    if len(sys.argv) > 1:
        inp = sys.argv[1]
        out = sys.argv[2] if len(sys.argv) > 2 else None
        process_image(inp, out)
    else:
        # مسار افتراضي لشعار التطبيق إذا لم يُحدد مسار
        default_candidates = [
            r"c:\mihrab\assets\icon\logo_master.jpg",
            r"c:\mihrab\assets\icon\logo_white.png",
            r"c:\mihrab\assets\icon\app_icon.png"
        ]
        chosen = None
        for cand in default_candidates:
            if os.path.exists(cand):
                chosen = cand
                break
        
        if chosen:
            print(f"[INFO] لم يتم تمرير مسار صورة، سيتم استخدام الصورة الافتراضية: {chosen}")
            out_file = os.path.join(os.path.dirname(chosen), "output_transparent.png")
            process_image(chosen, out_file)
        else:
            print("الاستخدام: python remove_background.py <مسار_الصورة> [مسار_الحفظ]")
