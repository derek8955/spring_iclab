wvExit
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      wvSetPosition -win $_nWave1 {("G1" 7)}
wvSetPosition -win $_nWave1 {("G1" 7)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/finish_cross} \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/wen_ans} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 )} 
wvSetPosition -win $_nWave1 {("G1" 7)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectGroup -win $_nWave1 {G2}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 2 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 2 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 2 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 2 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 2 6 7 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 2 7 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 2 )} 
wvSetRadix -win $_nWave1 -1Com
wvSetRadix -win $_nWave1 -2Com
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/wen_ans} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetCursor -win $_nWave1 219309.978709 -snap {("G1" 1)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvSetPosition -win $_nWave1 {("G2" 4)}
wvSetPosition -win $_nWave1 {("G2" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/wen_ans} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 3 4 )} 
wvSetPosition -win $_nWave1 {("G2" 4)}
wvGetSignalClose -win $_nWave1
wvSetRadix -win $_nWave1 -2Com
wvSelectSignal -win $_nWave1 {( "G2" 3 4 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetCursor -win $_nWave1 216042.393817 -snap {("G1" 3)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/wen_ans} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
{/TESTBED/U_TMIP/addr_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSetPosition -win $_nWave1 {("G1" 5)}
wvSetPosition -win $_nWave1 {("G3" 1)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 1)}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSelectGroup -win $_nWave1 {G4}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSetCursor -win $_nWave1 216900.292553 -snap {("G3" 2)}
wvSetCursor -win $_nWave1 216862.444079 -snap {("G3" 2)}
wvSetCursor -win $_nWave1 216837.211764 -snap {("G1" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 213758.869240 -snap {("G3" 2)}
wvSetCursor -win $_nWave1 215285.424344 -snap {("G2" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetCursor -win $_nWave1 216143.323080 -snap {("G3" 2)}
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
{/TESTBED/U_TMIP/wen_ans} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/pos_cnt\[7:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
{/TESTBED/U_TMIP/addr_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetPosition -win $_nWave1 {("G3" 2)}
wvGetSignalClose -win $_nWave1
wvSetPosition -win $_nWave1 {("G4" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetCursor -win $_nWave1 218578.241552 -snap {("G3" 2)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSetPosition -win $_nWave1 {("G4" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
{/TESTBED/U_TMIP/wen_ans} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
{/TESTBED/U_TMIP/addr_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_cnt\[7:0\]} \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSetPosition -win $_nWave1 {("G4" 2)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetCursor -win $_nWave1 219991.251236 -snap {("G3" 3)}
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 228756.957735 -snap {("G4" 2)}
wvSetCursor -win $_nWave1 230393.273413 -snap {("G4" 2)}
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetCursor -win $_nWave1 231150.242886 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 303179.673109 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 303949.258740 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 303116.592320 -snap {("G2" 1)}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 297552.866692 -snap {("G2" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 296997.755745 -snap {("G3" 3)}
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetCursor -win $_nWave1 298385.533112 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 299230.815691 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 300025.633637 -snap {("G3" 0)}
wvSetCursor -win $_nWave1 300013.017480 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 300782.603111 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 298435.997744 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 302347.006689 -snap {("G1" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 300946.613163 -snap {("G3" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 301577.421058 -snap {("G4" 2)}
wvSetCursor -win $_nWave1 302422.703636 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 305627.207739 -snap {("G4" 2)}
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 306598.651896 -snap {("G4" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 540861.779616 -snap {("G4" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 2026389.138461 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 2025581.704357 -snap {("G4" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 2108714.615135 -snap {("G4" 1)}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 2112802.250290 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 2108765.079766 -snap {("G2" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G5" 0)}
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSelectSignal -win $_nWave1 {( "G3" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvGetSignalOpen -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G5" 3)}
wvSetPosition -win $_nWave1 {("G5" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSelectSignal -win $_nWave1 {( "G5" 1 2 3 )} 
wvSetPosition -win $_nWave1 {("G5" 3)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G5" 1 2 3 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectGroup -win $_nWave1 {G6}
wvSetCursor -win $_nWave1 2112802.250290 -snap {("G2" 1)}
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSetCursor -win $_nWave1 2108866.009029 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 2109559.897713 -snap {("G1" 3)}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSetCursor -win $_nWave1 219234.281762 -snap {("G3" 1)}
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSetCursor -win $_nWave1 364080.390459 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 363992.077354 -snap {("G1" 3)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvGetSignalClose -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G5" 6)}
wvSetPosition -win $_nWave1 {("G5" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
{/TESTBED/U_TMIP/max_value\[39:0\]} \
{/TESTBED/U_TMIP/max_x\[3:0\]} \
{/TESTBED/U_TMIP/max_y\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSelectSignal -win $_nWave1 {( "G5" 4 5 6 )} 
wvSetPosition -win $_nWave1 {("G5" 6)}
wvGetSignalClose -win $_nWave1
wvSetPosition -win $_nWave1 {("G5" 4)}
wvSetPosition -win $_nWave1 {("G6" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G6" 3)}
wvSetPosition -win $_nWave1 {("G6" 3)}
wvSelectSignal -win $_nWave1 {( "G6" 1 2 3 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectGroup -win $_nWave1 {G7}
wvSelectSignal -win $_nWave1 {( "G6" 1 )} 
wvSetRadix -win $_nWave1 -2Com
wvSetCursor -win $_nWave1 359664.735199 -snap {("G7" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G6" 4)}
wvSetPosition -win $_nWave1 {("G6" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/TESTBED/U_TMIP/max_value\[39:0\]} \
{/TESTBED/U_TMIP/max_x\[3:0\]} \
{/TESTBED/U_TMIP/max_y\[3:0\]} \
{/TESTBED/U_TMIP/act\[0:15\]} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
}
wvSelectSignal -win $_nWave1 {( "G6" 4 )} 
wvSetPosition -win $_nWave1 {("G6" 4)}
wvGetSignalClose -win $_nWave1
wvSelectGroup -win $_nWave1 {G6}
wvSelectSignal -win $_nWave1 {( "G6" 1 )} 
wvSetCursor -win $_nWave1 2108096.423398 -snap {("G7" 0)}
wvSetCursor -win $_nWave1 1528724.604766 -snap {("G6" 1)}
wvSetCursor -win $_nWave1 1520829.413161 -snap {("G1" 2)}
wvSelectSignal -win $_nWave1 {( "G5" 2 )} 
wvSetCursor -win $_nWave1 1520009.362898 -snap {("G5" 3)}
wvSelectSignal -win $_nWave1 {( "G5" 3 )} 
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSelectSignal -win $_nWave1 {( "G5" 3 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetCursor -win $_nWave1 1520110.292161 -snap {("G3" 2)}
wvSetCursor -win $_nWave1 1520804.180845 -snap {("G3" 2)}
wvSetCursor -win $_nWave1 1520804.180845 -snap {("G1" 3)}
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSetCursor -win $_nWave1 2112718.437464 -snap {("G2" 2)}
wvSetCursor -win $_nWave1 2113652.033148 -snap {("G1" 2)}
wvSetCursor -win $_nWave1 2113576.336200 -snap {("G1" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 2114396.386464 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 2113563.720043 -snap {("G2" 2)}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G6" 5)}
wvSetPosition -win $_nWave1 {("G6" 5)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/TESTBED/U_TMIP/max_value\[39:0\]} \
{/TESTBED/U_TMIP/max_x\[3:0\]} \
{/TESTBED/U_TMIP/max_y\[3:0\]} \
{/TESTBED/U_TMIP/act\[0:15\]} \
{/TESTBED/U_TMIP/flag_cross_finish} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
}
wvSelectSignal -win $_nWave1 {( "G6" 5 )} 
wvSetPosition -win $_nWave1 {("G6" 5)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 2112831.982886 -snap {("G6" 5)}
wvSetCursor -win $_nWave1 2113664.649306 -snap {("G1" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSetCursor -win $_nWave1 2112768.902096 -snap {("G5" 1)}
wvSetCursor -win $_nWave1 2113727.730096 -snap {("G1" 0)}
wvSetCursor -win $_nWave1 2113778.194727 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2113576.336201 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 2114421.618780 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 2113576.336201 -snap {("G1" 3)}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G6" 6)}
wvSetPosition -win $_nWave1 {("G6" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/TESTBED/U_TMIP/max_value\[39:0\]} \
{/TESTBED/U_TMIP/max_x\[3:0\]} \
{/TESTBED/U_TMIP/max_y\[3:0\]} \
{/TESTBED/U_TMIP/act\[0:15\]} \
{/TESTBED/U_TMIP/flag_cross_finish} \
{/TESTBED/U_TMIP/tmp_ans_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
}
wvSelectSignal -win $_nWave1 {( "G6" 6 )} 
wvSetPosition -win $_nWave1 {("G6" 6)}
wvGetSignalClose -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G6" 6 )} 
wvSelectSignal -win $_nWave1 {( "G6" 6 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetPosition -win $_nWave1 {("G7" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G7" 2)}
wvSetPosition -win $_nWave1 {("G7" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/TESTBED/U_TMIP/max_value\[39:0\]} \
{/TESTBED/U_TMIP/max_x\[3:0\]} \
{/TESTBED/U_TMIP/max_y\[3:0\]} \
{/TESTBED/U_TMIP/act\[0:15\]} \
{/TESTBED/U_TMIP/flag_cross_finish} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
{/TESTBED/U_TMIP/tmp_ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/max_pos\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G8" \
}
wvSelectSignal -win $_nWave1 {( "G7" 2 )} 
wvSetPosition -win $_nWave1 {("G7" 2)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G7" 2 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetCursor -win $_nWave1 1528830.034309 -snap {("G6" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 2114379.985458 -snap {("G1" 3)}
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G7" 3)}
wvSetPosition -win $_nWave1 {("G7" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/TESTBED/U_TMIP/max_value\[39:0\]} \
{/TESTBED/U_TMIP/max_x\[3:0\]} \
{/TESTBED/U_TMIP/max_y\[3:0\]} \
{/TESTBED/U_TMIP/act\[0:15\]} \
{/TESTBED/U_TMIP/flag_cross_finish} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
{/TESTBED/U_TMIP/tmp_ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/max_pos\[3:0\]} \
{/TESTBED/U_TMIP/out_valid} \
}
wvAddSignal -win $_nWave1 -group {"G8" \
}
wvSelectSignal -win $_nWave1 {( "G7" 3 )} 
wvSetPosition -win $_nWave1 {("G7" 3)}
wvGetSignalClose -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G7" 2 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 2)}
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G7" 3)}
wvSetPosition -win $_nWave1 {("G7" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/TESTBED/U_TMIP/max_value\[39:0\]} \
{/TESTBED/U_TMIP/max_x\[3:0\]} \
{/TESTBED/U_TMIP/max_y\[3:0\]} \
{/TESTBED/U_TMIP/act\[0:15\]} \
{/TESTBED/U_TMIP/flag_cross_finish} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
{/TESTBED/U_TMIP/tmp_ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/out_valid} \
{/TESTBED/U_TMIP/max_pos\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G8" \
}
wvSelectSignal -win $_nWave1 {( "G7" 3 )} 
wvSetPosition -win $_nWave1 {("G7" 3)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G7" 3 )} 
wvSetRadix -win $_nWave1 -format UDec
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/U_TMIP"
wvSetPosition -win $_nWave1 {("G7" 4)}
wvSetPosition -win $_nWave1 {("G7" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/U_TMIP/ans_data\[39:0\]} \
{/TESTBED/U_TMIP/ans_input\[39:0\]} \
{/TESTBED/U_TMIP/clk} \
{/TESTBED/U_TMIP/finish_cross} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/U_TMIP/cur_cross_state\[3:0\]} \
{/TESTBED/U_TMIP/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/U_TMIP/inner_cnt\[3:0\]} \
{/TESTBED/U_TMIP/img_data\[15:0\]} \
{/TESTBED/U_TMIP/kernel\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/TESTBED/U_TMIP/pos_img\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/TESTBED/U_TMIP/ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/ans_wen} \
{/TESTBED/U_TMIP/img_addr\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/TESTBED/U_TMIP/max_value\[39:0\]} \
{/TESTBED/U_TMIP/max_x\[3:0\]} \
{/TESTBED/U_TMIP/max_y\[3:0\]} \
{/TESTBED/U_TMIP/act\[0:15\]} \
{/TESTBED/U_TMIP/flag_cross_finish} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
{/TESTBED/U_TMIP/tmp_ans_addr\[7:0\]} \
{/TESTBED/U_TMIP/out_valid} \
{/TESTBED/U_TMIP/max_pos\[7:0\]} \
{/TESTBED/U_TMIP/out_img_pos\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G8" \
}
wvSelectSignal -win $_nWave1 {( "G7" 4 )} 
wvSetPosition -win $_nWave1 {("G7" 4)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G7" 4 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSetCursor -win $_nWave1 2305651.046083 -snap {("G1" 1)}
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetCursor -win $_nWave1 2113532.193784 -snap {("G2" 2)}
wvSetCursor -win $_nWave1 2113721.436152 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2114491.021783 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2114465.789468 -snap {("G1" 3)}
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 4)}
wvSelectSignal -win $_nWave1 {( "G7" 4 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 3)}
wvSelectSignal -win $_nWave1 {( "G6" 3 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 3)}
wvSelectSignal -win $_nWave1 {( "G6" 2 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 3)}
wvSelectSignal -win $_nWave1 {( "G6" 1 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 3)}
wvSelectSignal -win $_nWave1 {( "G7" 1 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 2)}
wvSelectSignal -win $_nWave1 {( "G7" 1 )} 
wvSelectSignal -win $_nWave1 {( "G7" 2 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G6" 2 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G6" 1 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G5" 3 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G5" 2 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G8" 0)}
wvSetPosition -win $_nWave1 {("G7" 1)}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G5" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G5" 1)}
wvSetCursor -win $_nWave1 2113759.284626 -snap {("G5" 2)}
wvSetCursor -win $_nWave1 2114528.870257 -snap {("G5" 1)}
wvSetCursor -win $_nWave1 2030353.864837 -snap {("G5" 2)}
wvGetSignalOpen -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 2318431.015932 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2317573.117196 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2315920.400513 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2316816.147723 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2317648.814143 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2318443.632090 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 2114427.742904 -snap {("G5" 2)}
wvSetCursor -win $_nWave1 2317623.581827 -snap {("G2" 2)}
