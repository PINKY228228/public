import re
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from pathlib import Path


class TP2WaveFormPlotly:
    # ------------------------------
    def __init__(self, xlsx_file, col_range, signal_list_file):
        base_dir = Path(__file__).resolve().parent

        self.xls_path = base_dir / xlsx_file
        self.col_start, self.col_end = self._parse_range(col_range)
        self.sheet_signal_map = self._load_signal_map(
            base_dir / signal_list_file
        )

    # ------------------------------
    def _parse_range(self, s):
        a, b = s.split(":")
        return int(a) - 1, int(b) - 1

    # ------------------------------
    def _load_signal_map(self, txt_path: Path):
        m = {}
        with open(txt_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                parts = [p.strip() for p in line.split(",")]
                m[parts[0]] = parts[1:]
        return m

    # ------------------------------
    def _strip_tag(self, s):
        return re.sub(r"\[.*?\]", "", s)

    def _is_input(self, sig):
        # sig が "in" で始まっていれば True、そうでなければ False を返す
        return sig.startswith("in")

    # ------------------------------
    def _append_html(self, html_path: Path, fig, first):
        html = fig.to_html(
            full_html=first,
            include_plotlyjs="cdn" if first else False
        )
        with open(html_path, "w" if first else "a", encoding="utf-8") as f:
            f.write(html)

    # ------------------------------
    def process_html(self, html_file):
        base_dir = Path(__file__).resolve().parent
        html_path = base_dir / html_file

        if html_path.exists():
            html_path.unlink()

        xls = pd.ExcelFile(self.xls_path)
        first = True

        for sheet_name in xls.sheet_names:
            print(f"TC name = {sheet_name}")

            if sheet_name not in self.sheet_signal_map:
                continue

            first = self._process_sheet(
                xls, sheet_name, html_path, first
            )

    # ------------------------------
    def _process_sheet(self, xls, sheet_name, html_path, first):
        df = xls.parse(sheet_name, header=None)

        block = df.iloc[:, self.col_start:self.col_end + 1]
        headers = block.iloc[0]
        data = block.iloc[2:]

        time = data.iloc[:, 0].astype(float)
        comments = data.iloc[:, -1]

        sig_names = headers.iloc[1:-1].tolist()
        sig_data = data.iloc[:, 1:-1]

        targets = self.sheet_signal_map[sheet_name]
        indices = [i for i, s in enumerate(sig_names) if s in targets]

        if not indices:
            return first

        fig = make_subplots(
            rows=len(indices),
            cols=1,
            shared_xaxes=True,
            subplot_titles=[sig_names[i] for i in indices]
        )

        expand_events = []

        for row, idx in enumerate(indices, start=1):
            sig = sig_names[idx]
            y = sig_data.iloc[:, idx]

            fig.add_trace(
                go.Scatter(
                    x=time,
                    y=y,
                    mode="lines+markers",
                    name=sig,
                    line=dict(
                        shape="hv",
                        # sig が入力信号なら青、入力でなければ桃色
                        color="royalblue" if self._is_input(sig) else "pink"
                    )
                ),
                row=row,
                col=1
            )

            for t, c, v in zip(time, comments, y):
                if not isinstance(c, str):
                    continue
                if sig not in c:
                    continue

                if "[拡大]" in c:
                    # コメントに [拡大] が含まれていたら
                    # 「どの信号(sig)を、どの時刻(t)で拡大するか」 を記録
                    expand_events.append((sig, t))

                if "[操作]" in c or "[観点]" in c:
                    fig.add_vline(x=t, line_dash="dash", row=row, col=1)
                    fig.add_annotation(
                        x=t, y=v,
                        text=f"{t:.3f}<br>{self._strip_tag(c)}<br>{sig}={v}",
                        showarrow=True,
                        row=row, col=1
                    )

        fig.update_layout(
            title=f"TC: {sheet_name}",
            height=280 * len(indices),
            showlegend=False
        )

        self._append_html(html_path, fig, first)

        self._write_expand_figures(
            sheet_name, time, sig_names,
            sig_data, expand_events, html_path
        )

        return False

    # ------------------------------
    def _write_expand_figures(
        self, sheet_name, time, sig_names,
        sig_data, expand_events, html_path
    ):
        # 拡大の範囲
        # 中心:t0
        WIDTH = 0.02
        # WIDTH = 0.025

        for sig, t0 in expand_events:
            idx = sig_names.index(sig)
            y = sig_data.iloc[:, idx]
            mask = (time >= t0 - WIDTH) & (time <= t0 + WIDTH)
            # 拡大用Figを生成する
            fig = go.Figure()
            fig.add_trace(
                go.Scatter(
                    x=time[mask],
                    y=y[mask],
                    mode="lines+markers",
                    line=dict(
                        shape="hv",
                        color="royalblue" if self._is_input(sig) else "pink"
                    )    
                )
            )

            # 拡大波形の中心へ破線を追加
            fig.add_vline(
               x=t0,
                line_dash="dash",
                line_width=1,
            )

            fig.update_layout(
                title=f"{sheet_name} 拡大: {sig} @ {t0:.3f}",
                height=400
            )

            self._append_html(html_path, fig, False)