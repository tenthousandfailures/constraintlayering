vlib work
# vdel -all -lib work
vlog \
    +cover \
    layer.sv

vsim -coverage TB; run 2000; quit -sim
