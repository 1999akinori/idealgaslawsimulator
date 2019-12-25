# set the working dir, where all compiled verilog goes
vlib work

vlog changeMoles.v checkCollision.v DataPathPart3.v lab7part3.v posCounters.v rom361x3.v

vsim -L altera_mf_ver L7P3


#log all signals and add some signals to waveform window
log {/*}

# add wave {/*} would add all items in top level simulation module
add wave {/*}


#force {clk} 0 0ns, 1 10ns -r {20 ns}
#force {Reset_n} 1 0ns, 0 100ns
#force {Reset_n} 1 120ns
#force {up} 0 0ns, 1 300ns
#force {up} 0 400ns
#force {enable} 0 0ns, 1 170 ns
#run 2000ns

force {clk} 0 0ns, 1 10ns -r {20 ns}
force {Reset_nFSM} 1 0ns, 0 100ns
force {Reset_nFSM} 1 120ns
force {xComp} 1
force {yComp} 1
force {Incr} 0 0ns, 1 196ns
force {Incr} 0 249ns
force {Decr} 0 300ns
force {Decr} 0 0ns, 1 400ns
force {Decr} 0 430ns

run 2000ns