onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cordic_testbench/clk
add wave -noupdate /cordic_testbench/rst
add wave -noupdate /cordic_testbench/angulo
add wave -noupdate /cordic_testbench/x_out
add wave -noupdate /cordic_testbench/y_out
add wave -noupdate /cordic_testbench/z_out
add wave -noupdate -radix decimal /cordic_testbench/uut/z
add wave -noupdate /cordic_testbench/pronto
add wave -noupdate /cordic_testbench/angulo_real
add wave -noupdate /cordic_testbench/cosseno
add wave -noupdate /cordic_testbench/seno
add wave -noupdate /cordic_testbench/dif_angulo_original
add wave -noupdate /cordic_testbench/tam_palavra
add wave -noupdate /cordic_testbench/casas_decimais
add wave -noupdate /cordic_testbench/qtd_tabela
add wave -noupdate /cordic_testbench/clk_period
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {107 ns} 0} {{Cursor 2} {46613 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 161
configure wave -valuecolwidth 183
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {46494 ns} {47802 ns}
