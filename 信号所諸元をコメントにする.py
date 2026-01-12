
# make_results.py
import csv
from pathlib import Path
from openpyxl import Workbook
from openpyxl.comments import Comment

def read_csv_rows(path: Path):
    """
    pip install openpyxl
    諸元.txt（CSV）を読み込み、行のリストを返す。
    [諸元.txt形式]
    信号名
    信号名日本語
    単位
    min
    max
    LSB
    初期値
    (例)
    a,b,c
    日本語,日本語,日本語
    [],[],[]
    0,0,0
    10,100,0.1
    1,1,0.1
    0:不定 1:OK,0,0
    """
    encodings_to_try = ["utf-8-sig", "utf-8", "cp932"]
    last_err = None
    for enc in encodings_to_try:
        try:
            with path.open("r", encoding=enc, newline="") as f:
                reader = csv.reader(f)
                rows = [row for row in reader if row]  # 空行除外
                return rows
        except Exception as e:
            last_err = e
    raise RuntimeError(f"ファイルの読み込みに失敗しました: {path}\n{last_err}")

def build_comment_text(rows, col_idx):
    """
    VBSのコメント相当のテキストを作成。
    rows[0] がヘッダー、rows[1]～rows[6] がコメント情報を想定。
    足りない場合は空文字を補う。
    """
    def get(r, c):
        try:
            return rows[r][c]
        except Exception:
            return ""
    return (
        f"信号名日本語: {get(1, col_idx)}\n"
        f"単位: {get(2, col_idx)}\n"
        f"min: {get(3, col_idx)}\n"
        f"max: {get(4, col_idx)}\n"
        f"LSB: {get(5, col_idx)}\n"
        f"初期値: {get(6, col_idx)}"
    )

def main():
    # スクリプトと同じフォルダの諸元.txtを対象
    script_dir = Path(__file__).resolve().parent
    csv_path = script_dir / "諸元.txt"
    out_path = script_dir / "results.xlsx"

    if not csv_path.exists():
        raise FileNotFoundError(f"入力ファイルが見つかりません: {csv_path}")

    rows = read_csv_rows(csv_path)
    if not rows:
        raise ValueError("CSV（諸元.txt）にデータがありません。")

    header = rows[0]
    col_count = len(header)

    wb = Workbook()
    ws = wb.active

    # 1行目のセルへヘッダー、コメントを設定
    for j in range(col_count):
        cell = ws.cell(row=1, column=j + 1, value=header[j])

        comment_text = build_comment_text(rows, j)
        comment = Comment(comment_text, author="")
        comment.width = 200   # コメント枠の幅
        comment.height = 200  # コメント枠の高さ
        cell.comment = comment

    wb.save(out_path)
    print(f"Excelファイルへの転記が完了しました: {out_path}")

if __name__ == "__main__":
    main()