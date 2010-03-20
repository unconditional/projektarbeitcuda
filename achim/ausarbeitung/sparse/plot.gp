plot "sparse_traversed.csv" using 1:2 with linespoints title "Matlab" , "sparse_traversed.csv" using 1:3 with linespoints title "CPU" 3 3, "sparse_traversed.csv" using 1:4 with linespoints title "GPU(16x1)", "sparse_traversed.csv" using 1:5 with linespoints title "GPU(1x16)", "sparse_traversed.csv" using 1:6 with linespoints title "GPU(16x16)"

