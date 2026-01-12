from .TP2WaveFormPlotly import TP2WaveFormPlotly
#from TP2WaveFormPlotly import TP2WaveFormPlotly

def main():
    editor = TP2WaveFormPlotly("TV4.xlsx", "1:5", "TV4.txt")
    #editor = TP2WaveFormPlotly("TV4.xlsx", "1:5", "TV4a.txt")
    editor.process_html("results.html")

if __name__ == "__main__":
    main()
