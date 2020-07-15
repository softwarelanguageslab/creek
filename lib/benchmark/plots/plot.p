# set terminal pdf 
# set output 'graph.pdf' 
set terminal pdf
set output output

# Set legend on left top
set key left top

# Separator for CSV file.
set datafile separator','


plot csvfile using x:5:8:7 with yerrorbars title '95% confidence' lt rgb "violet",\
     csvfile using x:5 with lines title 'Execution Time (ms)'

# Sources 
# https://stackoverflow.com/questions/25512006/gnuplot-smooth-confidence-interval-lines-as-opposed-to-error-bars 
# http://gnuplot.sourceforge.net/docs_4.2/node140.html
# https://gnuplot.programmingpedia.net/en/tutorial/4013/using-script-files
# https://riptutorial.com/gnuplot/example/12382/plot-a-single-data-file