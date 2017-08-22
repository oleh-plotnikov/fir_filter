onbreak resume
onerror resume
vsim -novopt work.filter_mlab_tb
add wave sim:/filter_mlab_tb/u_filter_mlab/i_clk
add wave sim:/filter_mlab_tb/u_filter_mlab/i_clk_enable
add wave sim:/filter_mlab_tb/u_filter_mlab/i_reset_n
add wave sim:/filter_mlab_tb/u_filter_mlab/filter_in
add wave sim:/filter_mlab_tb/u_filter_mlab/filter_out
add wave sim:/filter_mlab_tb/filter_out_ref
run -all
