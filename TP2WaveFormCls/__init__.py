# __init__.py
#外部ファイルはすべて Path(__file__) 基準で解決する
class TP2WaveFormPlotly:
    def __init__(self, xlsx_file, sheet_range, signal_list_file):
        base_dir = Path(__file__).resolve().parent
        self.xls_path = base_dir / xlsx_file
        self.sheet_signal_map = self._load_signal_map(signal_list_file)
        ...
