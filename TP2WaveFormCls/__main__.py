from .TP2WaveFormPlotly import TP2WaveFormPlotly
#from TP2WaveFormPlotly import TP2WaveFormPlotly

def main():
# Pylance
# Python
# Python Debugger
# Python Environments    
# cd C:\$\mbd\utility
# python -m TP2WaveFormCls
# VSCで実行
# [前提]C:\$\mbd\utility\.vscode\launch.json
#  PS C:\$\mbd\utility> 
# 実行とデバックで▶ TP2WaveFormCls (module)があることを確認し再生ボタンを押下  
    editor = TP2WaveFormPlotly("TV4.xlsx", "1:5", "TV4.txt")
    #editor = TP2WaveFormPlotly("TV4.xlsx", "1:5", "TV4a.txt")
    editor.process_html("results.html")

if __name__ == "__main__":
    main()
