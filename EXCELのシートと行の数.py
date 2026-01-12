import os
import pandas as pd
import tkinter as tk
from tkinter import filedialog
#前提
#pip install pandas openpyxl xlrd
#実行
#cd C:\path\to\script
#エクスプローラからpyをダブルクリック
#実行したフォルダにresults.txtが生成される

# ===== フォルダ選択ダイアログ =====
#GUIアプリケーションを開始する宣言
#Tkinterでウィンドウやダイアログを使うため、“元締め”を作る
root = tk.Tk()
root.withdraw()  # メインウィンドウを表示しない

#Tkinterアプリの 子ウィンドウ
TARGET_DIR = filedialog.askdirectory(
    title="Excelファイルが入っているフォルダを選択してください"
)

if not TARGET_DIR:
    print("フォルダが選択されなかったため終了します。")
    exit()

OUTPUT_CSV = "results.csv"

results = []

# ===== Excelファイル走査 =====
for filename in os.listdir(TARGET_DIR):
    if not filename.lower().endswith((".xlsx", ".xls")):
        continue

    file_path = os.path.join(TARGET_DIR, filename)

    try:
        # Excelファイルを開く
        xls = pd.ExcelFile(file_path)

        for sheet_name in xls.sheet_names:
            df = pd.read_excel(
                xls,
                sheet_name=sheet_name,
                header=None
            )

            results.append({
                "file_name": filename,
                "sheet_name": sheet_name,
                "row_count": len(df)
            })

    except Exception as e:
        results.append({
            "file_name": filename,
            "sheet_name": "ERROR",
            "row_count": "",
            "error": str(e)
        })

# ===== CSV出力 =====
df_results = pd.DataFrame(results)
df_results.to_csv(OUTPUT_CSV, index=False, encoding="utf-8-sig")

print(f"完了: {OUTPUT_CSV} を出力しました")
