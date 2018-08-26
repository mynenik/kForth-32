\ keysymdef.4th
\
\ From /usr/include/X11/keysymdef.h
\
\  Copyright 1987, 1994, 1998  The Open Group
\
\ Permission to use, copy, modify, distribute, and sell this software and its
\ documentation for any purpose is hereby granted without fee, provided that
\ the above copyright notice appear in all copies and that both that
\ copyright notice and this permission notice appear in supporting
\ documentation.
\

base @
hex

ffffff  constant  XK_VoidSymbol         \ Void symbol

[DEFINED] XK_MISCELLANY  [IF]

\  TTY function keys, cleverly chosen to map to ASCII, for convenience of
\  programming, but could have been arbitrary (at the cost of lookup
\  tables in client code).


ff08  constant  XK_BackSpace                       \ Back space, back char 
ff09  constant  XK_Tab                           
ff0a  constant  XK_Linefeed                        \ Linefeed, LF 
ff0b  constant  XK_Clear                         
ff0d  constant  XK_Return                          \ Return, enter
ff13  constant  XK_Pause                           \ Pause, hold
ff14  constant  XK_Scroll_Lock                   
ff15  constant  XK_Sys_Req                       
ff1b  constant  XK_Escape                        
ffff  constant  XK_Delete                          \ Delete, rubout


\ International & multi-key character composition

ff20  constant  XK_Multi_key                       \ Multi-key character compose
ff37  constant  XK_Codeinput                     
ff3c  constant  XK_SingleCandidate               
ff3d  constant  XK_MultipleCandidate             
ff3e  constant  XK_PreviousCandidate             

\ Japanese keyboard support 

ff21  constant  XK_Kanji                           \ Kanji, Kanji convert
ff22  constant  XK_Muhenkan                        \ Cancel Conversion
ff23  constant  XK_Henkan_Mode                     \ Start/Stop Conversion
ff23  constant  XK_Henkan                          \ Alias for Henkan_Mode
ff24  constant  XK_Romaji                          \ to Romaji
ff25  constant  XK_Hiragana                        \ to Hiragana
ff26  constant  XK_Katakana                        \ to Katakana
ff27  constant  XK_Hiragana_Katakana               \ Hiragana/Katakana toggle
ff28  constant  XK_Zenkaku                         \ to Zenkaku
ff29  constant  XK_Hankaku                         \ to Hankaku
ff2a  constant  XK_Zenkaku_Hankaku                 \ Zenkaku/Hankaku toggle
ff2b  constant  XK_Touroku                         \ Add to Dictionary
ff2c  constant  XK_Massyo                          \ Delete from Dictionary
ff2d  constant  XK_Kana_Lock                       \ Kana Lock
ff2e  constant  XK_Kana_Shift                      \ Kana Shift
ff2f  constant  XK_Eisu_Shift                      \ Alphanumeric Shift
ff30  constant  XK_Eisu_toggle                     \ Alphanumeric toggle
ff37  constant  XK_Kanji_Bangou                    \ Codeinput
ff3d  constant  XK_Zen_Koho                        \ Multiple/All Candidate(s)
ff3e  constant  XK_Mae_Koho                        \ Previous Candidate

\ Cursor control & motion

ff50  constant  XK_Home                          
ff51  constant  XK_Left                            \ Move left, left arrow 
ff52  constant  XK_Up                              \ Move up, up arrow 
ff53  constant  XK_Right                           \ Move right, right arrow 
ff54  constant  XK_Down                            \ Move down, down arrow 
ff55  constant  XK_Prior                           \ Prior, previous 
ff55  constant  XK_Page_Up                       
ff56  constant  XK_Next                            \ Next 
ff56  constant  XK_Page_Down                     
ff57  constant  XK_End                             \ EOL 
ff58  constant  XK_Begin                           \ BOL 


\ Misc functions

ff60  constant  XK_Select                          \ Select, mark
ff61  constant  XK_Print                         
ff62  constant  XK_Execute                         \ Execute, run, do
ff63  constant  XK_Insert                          \ Insert, insert here
ff65ff60  constant  XK_Undo                          
ff66  constant  XK_Redo                            \ Redo, again
ff67  constant  XK_Menu                          
ff68  constant  XK_Find                            \ Find, search
ff69  constant  XK_Cancel                          \ Cancel, stop, abort, exit
ff6a  constant  XK_Help                            \ Help
ff6b  constant  XK_Break                         
ff7e  constant  XK_Mode_switch                     \ Character set switch
ff7e  constant  XK_script_switch                   \ Alias for mode_switch
ff7f  constant  XK_Num_Lock                      


\ Keypad functions, keypad numbers cleverly chosen to map to ASCII

ff80  constant  XK_KP_Space                        \ Space
ff89  constant  XK_KP_Tab                        
ff8d  constant  XK_KP_Enter                        \ Enter
ff91  constant  XK_KP_F1                           \ PF1, KP_A, ... 
ff92  constant  XK_KP_F2                         
ff93  constant  XK_KP_F3                         
ff94  constant  XK_KP_F4                         
ff95  constant  XK_KP_Home                       
ff96  constant  XK_KP_Left                       
ff97  constant  XK_KP_Up                         
ff98  constant  XK_KP_Right                      
ff99  constant  XK_KP_Down                       
ff9a  constant  XK_KP_Prior                      
ff9a  constant  XK_KP_Page_Up                    
ff9b  constant  XK_KP_Next                       
ff9b  constant  XK_KP_Page_Down                  
ff9c  constant  XK_KP_End                        
ff9d  constant  XK_KP_Begin                      
ff9e  constant  XK_KP_Insert                     
ff9f  constant  XK_KP_Delete                     
ffbd  constant  XK_KP_Equal                        \ Equals
ffaa  constant  XK_KP_Multiply                   
ffab  constant  XK_KP_Add                        
ffac  constant  XK_KP_Separator                    \ Separator, often comma
ffad  constant  XK_KP_Subtract                   
ffae  constant  XK_KP_Decimal                    
ffaf  constant  XK_KP_Divide                     

ffb0  constant  XK_KP_0                          
ffb1  constant  XK_KP_1                          
ffb2  constant  XK_KP_2                          
ffb3  constant  XK_KP_3                          
ffb4  constant  XK_KP_4                          
ffb5  constant  XK_KP_5                          
ffb6  constant  XK_KP_6                          
ffb7  constant  XK_KP_7                          
ffb8  constant  XK_KP_8                          
ffb9  constant  XK_KP_9                          


\  Auxiliary functions; note the duplicate definitions for left and right
\  function keys;  Sun keyboards and a few other manufacturers have such
\  function key groups on the left and/or right sides of the keyboard.
\  We've not found a keyboard with more than 35 function keys total.
\ 

ffbe  constant  XK_F1
ffbf  constant  XK_F2                            
ffc0  constant  XK_F3                            
ffc1  constant  XK_F4                            
ffc2  constant  XK_F5                            
ffc3  constant  XK_F6                            
ffc4  constant  XK_F7                            
ffc5  constant  XK_F8                            
ffc6  constant  XK_F9                            
ffc7  constant  XK_F10                           
ffc8  constant  XK_F11                           
ffc8  constant  XK_L1                            
ffc9  constant  XK_F12                           
ffc9  constant  XK_L2                            
ffca  constant  XK_F13                           
ffca  constant  XK_L3                            
ffcb  constant  XK_F14                           
ffcb  constant  XK_L4                            
ffcc  constant  XK_F15                           
ffcc  constant  XK_L5                            
ffcd  constant  XK_F16                           
ffcd  constant  XK_L6                            
ffce  constant  XK_F17                           
ffce  constant  XK_L7                            
ffcf  constant  XK_F18                           
ffcf  constant  XK_L8                            
ffd0  constant  XK_F19                           
ffd0  constant  XK_L9                            
ffd1  constant  XK_F20                           
ffd1  constant  XK_L10                           
ffd2  constant  XK_F21                           
ffd2  constant  XK_R1                            
ffd3  constant  XK_F22                           
ffd3  constant  XK_R2                            
ffd4  constant  XK_F23                           
ffd4  constant  XK_R3                            
ffd5  constant  XK_F24                           
ffd5  constant  XK_R4                            
ffd6  constant  XK_F25                           
ffd6  constant  XK_R5                            
ffd7  constant  XK_F26                           
ffd7  constant  XK_R6                            
ffd8  constant  XK_F27                           
ffd8  constant  XK_R7                            
ffd9  constant  XK_F28                           
ffd9  constant  XK_R8                            
ffda  constant  XK_F29                           
ffda  constant  XK_R9                            
ffdb  constant  XK_F30                           
ffdb  constant  XK_R10                           
ffdc  constant  XK_F31                           
ffdc  constant  XK_R11                           
ffdd  constant  XK_F32                           
ffdd  constant  XK_R12                           
ffde  constant  XK_F33                           
ffde  constant  XK_R13                           
ffdf  constant  XK_F34                           
ffdf  constant  XK_R14                           
ffe0  constant  XK_F35                           
ffe0  constant  XK_R15                           

\ Modifiers

ffe1  constant  XK_Shift_L                  \ Left shift
ffe2  constant  XK_Shift_R                  \ Right shift
ffe3  constant  XK_Control_L                \ Left control
ffe4  constant  XK_Control_R                \ Right control
ffe5  constant  XK_Caps_Lock                \ Caps lock
ffe6  constant  XK_Shift_Lock               \ Shift lock

ffe7  constant  XK_Meta_L                   \ Left meta
ffe8  constant  XK_Meta_R                   \ Right meta
ffe9  constant  XK_Alt_L                    \ Left alt
ffea  constant  XK_Alt_R                    \ Right alt
ffeb  constant  XK_Super_L                  \ Left super
ffec  constant  XK_Super_R                  \ Right super
ffed  constant  XK_Hyper_L                  \ Left hyper
ffee  constant  XK_Hyper_R                  \ Right hyper
[THEN]   \ XK_MISCELLANY


\
\ Keyboard (XKB) Extension function and modifier keys
\ (from Appendix C of "The X Keyboard Extension: Protocol Specification")
\ Byte 3 = 0xfe
\

[DEFINED] XK_XKB_KEYS  [IF]
fe01  constant  XK_ISO_Lock                      
fe02  constant  XK_ISO_Level2_Latch              
fe03  constant  XK_ISO_Level3_Shift              
fe04  constant  XK_ISO_Level3_Latch              
fe05  constant  XK_ISO_Level3_Lock               
fe11  constant  XK_ISO_Level5_Shift              
fe12  constant  XK_ISO_Level5_Latch              
fe13  constant  XK_ISO_Level5_Lock               
ff7e  constant  XK_ISO_Group_Shift                 \ Alias for mode_switch
fe06  constant  XK_ISO_Group_Latch               
fe07  constant  XK_ISO_Group_Lock                
fe08  constant  XK_ISO_Next_Group                
fe09  constant  XK_ISO_Next_Group_Lock           
fe0a  constant  XK_ISO_Prev_Group                
fe0b  constant  XK_ISO_Prev_Group_Lock           
fe0c  constant  XK_ISO_First_Group               
fe0d  constant  XK_ISO_First_Group_Lock          
fe0e  constant  XK_ISO_Last_Group                
fe0f  constant  XK_ISO_Last_Group_Lock           

fe20  constant  XK_ISO_Left_Tab                  
fe21  constant  XK_ISO_Move_Line_Up              
fe22  constant  XK_ISO_Move_Line_Down            
fe23  constant  XK_ISO_Partial_Line_Up           
fe24  constant  XK_ISO_Partial_Line_Down         
fe25  constant  XK_ISO_Partial_Space_Left        
fe26  constant  XK_ISO_Partial_Space_Right       
fe27  constant  XK_ISO_Set_Margin_Left           
fe28  constant  XK_ISO_Set_Margin_Right          
fe29  constant  XK_ISO_Release_Margin_Left       
fe2a  constant  XK_ISO_Release_Margin_Right      
fe2b  constant  XK_ISO_Release_Both_Margins      
fe2c  constant  XK_ISO_Fast_Cursor_Left          
fe2d  constant  XK_ISO_Fast_Cursor_Right         
fe2e  constant  XK_ISO_Fast_Cursor_Up            
fe2f  constant  XK_ISO_Fast_Cursor_Down          
fe30  constant  XK_ISO_Continuous_Underline      
fe31  constant  XK_ISO_Discontinuous_Underline   
fe32  constant  XK_ISO_Emphasize                 
fe33  constant  XK_ISO_Center_Object             
fe34  constant  XK_ISO_Enter                     

fe50  constant  XK_dead_grave                    
fe51  constant  XK_dead_acute                    
fe52  constant  XK_dead_circumflex               
fe53  constant  XK_dead_tilde                    
fe54  constant  XK_dead_macron                   
fe55  constant  XK_dead_breve                    
fe56  constant  XK_dead_abovedot                 
fe57  constant  XK_dead_diaeresis                
fe58  constant  XK_dead_abovering                
fe59  constant  XK_dead_doubleacute              
fe5a  constant  XK_dead_caron                    
fe5b  constant  XK_dead_cedilla                  
fe5c  constant  XK_dead_ogonek                   
fe5d  constant  XK_dead_iota                     
fe5e  constant  XK_dead_voiced_sound             
fe5f  constant  XK_dead_semivoiced_sound         
fe60  constant  XK_dead_belowdot                 
fe61  constant  XK_dead_hook                     
fe62  constant  XK_dead_horn                     
fe63  constant  XK_dead_stroke                   
fe64  constant  XK_dead_abovecomma               
fe64  constant  XK_dead_psili                      \ alias for dead_abovecomma
fe65  constant  XK_dead_abovereversedcomma       
fe66  constant  XK_dead_dasia                      \ alias for dead_abovereversedcomma
fe66  constant  XK_dead_doublegrave              
fe67  constant  XK_dead_belowring                
fe68  constant  XK_dead_belowmacron              
fe69  constant  XK_dead_belowcircumflex          
fe6a  constant  XK_dead_belowtilde               
fe6b  constant  XK_dead_belowbreve               
fe6c  constant  XK_dead_belowdiaeresis           
fe6d  constant  XK_dead_invertedbreve            
fe6e  constant  XK_dead_belowcomma               
fe6f  constant  XK_dead_currency                 

\ dead vowels for universal syllable entry
fe80  constant  XK_dead_a                        
fe81  constant  XK_dead_A                        
fe82  constant  XK_dead_e                        
fe83  constant  XK_dead_E                        
fe84  constant  XK_dead_i                        
fe85  constant  XK_dead_I                        
fe86  constant  XK_dead_o                        
fe87  constant  XK_dead_O                        
fe88  constant  XK_dead_u                        
fe89  constant  XK_dead_U                        
fe8a  constant  XK_dead_small_schwa              
fe8b  constant  XK_dead_capital_schwa            

fed0  constant  XK_First_Virtual_Screen          
fed1  constant  XK_Prev_Virtual_Screen           
fed2  constant  XK_Next_Virtual_Screen           
fed4  constant  XK_Last_Virtual_Screen           
fed5  constant  XK_Terminate_Server              

fe70  constant  XK_AccessX_Enable                
fe71  constant  XK_AccessX_Feedback_Enable       
fe72  constant  XK_RepeatKeys_Enable             
fe73  constant  XK_SlowKeys_Enable               
fe74  constant  XK_BounceKeys_Enable             
fe75  constant  XK_StickyKeys_Enable             
fe76  constant  XK_MouseKeys_Enable              
fe77  constant  XK_MouseKeys_Accel_Enable        
fe78  constant  XK_Overlay1_Enable               
fe79  constant  XK_Overlay2_Enable               
fe7a  constant  XK_AudibleBell_Enable            

fee0  constant  XK_Pointer_Left                  
fee1  constant  XK_Pointer_Right                 
fee2  constant  XK_Pointer_Up                    
fee3  constant  XK_Pointer_Down                  
fee4  constant  XK_Pointer_UpLeft                
fee5  constant  XK_Pointer_UpRight               
fee6  constant  XK_Pointer_DownLeft              
fee7  constant  XK_Pointer_DownRight             
fee8  constant  XK_Pointer_Button_Dflt           
fee9  constant  XK_Pointer_Button1               
feea  constant  XK_Pointer_Button2               
feeb  constant  XK_Pointer_Button3               
feec  constant  XK_Pointer_Button4               
feed  constant  XK_Pointer_Button5               
feee  constant  XK_Pointer_DblClick_Dflt         
feef  constant  XK_Pointer_DblClick1             
fef0  constant  XK_Pointer_DblClick2             
fef1  constant  XK_Pointer_DblClick3             
fef2  constant  XK_Pointer_DblClick4             
fef3  constant  XK_Pointer_DblClick5             
fef4  constant  XK_Pointer_Drag_Dflt             
fef5  constant  XK_Pointer_Drag1                 
fef6  constant  XK_Pointer_Drag2                 
fef7  constant  XK_Pointer_Drag3                 
fef8  constant  XK_Pointer_Drag4                 
fefd  constant  XK_Pointer_Drag5                 

fef9  constant  XK_Pointer_EnableKeys            
fefa  constant  XK_Pointer_Accelerate            
fefb  constant  XK_Pointer_DfltBtnNext           
fefc  constant  XK_Pointer_DfltBtnPrev           
[THEN]   \ XK_XKB_KEYS 

\  3270 Terminal Keys
\  Byte 3 = 0xfd

[DEFINED] XK_3270  [IF]
fd01  constant  XK_3270_Duplicate                
fd02  constant  XK_3270_FieldMark                
fd03  constant  XK_3270_Right2                   
fd04  constant  XK_3270_Left2                    
fd05  constant  XK_3270_BackTab                  
fd06  constant  XK_3270_EraseEOF                 
fd07  constant  XK_3270_EraseInput               
fd08  constant  XK_3270_Reset                    
fd09  constant  XK_3270_Quit                     
fd0a  constant  XK_3270_PA1                      
fd0b  constant  XK_3270_PA2                      
fd0c  constant  XK_3270_PA3                      
fd0d  constant  XK_3270_Test                     
fd0e  constant  XK_3270_Attn                     
fd0f  constant  XK_3270_CursorBlink              
fd10  constant  XK_3270_AltCursor                
fd11  constant  XK_3270_KeyClick                 
fd12  constant  XK_3270_Jump                     
fd13  constant  XK_3270_Ident                    
fd14  constant  XK_3270_Rule                     
fd15  constant  XK_3270_Copy                     
fd16  constant  XK_3270_Play                     
fd17  constant  XK_3270_Setup                    
fd18  constant  XK_3270_Record                   
fd19  constant  XK_3270_ChangeScreen             
fd1a  constant  XK_3270_DeleteWord               
fd1b  constant  XK_3270_ExSelect                 
fd1c  constant  XK_3270_CursorSelect             
fd1d  constant  XK_3270_PrintScreen              
fd1e  constant  XK_3270_Enter                    
[THEN]   \ XK_3270 

\  Latin 1
\  (ISO/IEC 8859-1 = Unicode U+0020..U+00FF)
\  Byte 3 = 0

[DEFINED] XK_LATIN1 [IF]
0020  constant  XK_space                    \ U+0020 SPACE
0021  constant  XK_exclam                   \ U+0021 EXCLAMATION MARK
0022  constant  XK_quotedbl                 \ U+0022 QUOTATION MARK
0023  constant  XK_numbersign               \ U+0023 NUMBER SIGN
0024  constant  XK_dollar                   \ U+0024 DOLLAR SIGN
0025  constant  XK_percent                  \ U+0025 PERCENT SIGN
0026  constant  XK_ampersand                \ U+0026 AMPERSAND
0027  constant  XK_apostrophe               \ U+0027 APOSTROPHE
0027  constant  XK_quoteright               \ deprecated
0028  constant  XK_parenleft                \ U+0028 LEFT PARENTHESIS
0029  constant  XK_parenright               \ U+0029 RIGHT PARENTHESIS
002a  constant  XK_asterisk                 \ U+002A ASTERISK
002b  constant  XK_plus                     \ U+002B PLUS SIGN
002c  constant  XK_comma                    \ U+002C COMMA
002d  constant  XK_minus                    \ U+002D HYPHEN-MINUS
002e  constant  XK_period                   \ U+002E FULL STOP
002f  constant  XK_slash                    \ U+002F SOLIDUS
0030  constant  XK_0                        \ U+0030 DIGIT ZERO
0031  constant  XK_1                        \ U+0031 DIGIT ONE
0032  constant  XK_2                        \ U+0032 DIGIT TWO
0033  constant  XK_3                        \ U+0033 DIGIT THREE
0034  constant  XK_4                        \ U+0034 DIGIT FOUR
0035  constant  XK_5                        \ U+0035 DIGIT FIVE
0036  constant  XK_6                        \ U+0036 DIGIT SIX
0037  constant  XK_7                        \ U+0037 DIGIT SEVEN
0038  constant  XK_8                        \ U+0038 DIGIT EIGHT
0039  constant  XK_9                        \ U+0039 DIGIT NINE
003a  constant  XK_colon                    \ U+003A COLON
003b  constant  XK_semicolon                \ U+003B SEMICOLON
003c  constant  XK_less                     \ U+003C LESS-THAN SIGN
003d  constant  XK_equal                    \ U+003D EQUALS SIGN
003e  constant  XK_greater                  \ U+003E GREATER-THAN SIGN
003f  constant  XK_question                 \ U+003F QUESTION MARK
0040  constant  XK_at                       \ U+0040 COMMERCIAL AT
0041  constant  XK_A                        \ U+0041 LATIN CAPITAL LETTER A
0042  constant  XK_B                        \ U+0042 LATIN CAPITAL LETTER B
0043  constant  XK_C                        \ U+0043 LATIN CAPITAL LETTER C
0044  constant  XK_D                        \ U+0044 LATIN CAPITAL LETTER D
0045  constant  XK_E                        \ U+0045 LATIN CAPITAL LETTER E
0046  constant  XK_F                        \ U+0046 LATIN CAPITAL LETTER F
0047  constant  XK_G                        \ U+0047 LATIN CAPITAL LETTER G
0048  constant  XK_H                        \ U+0048 LATIN CAPITAL LETTER H
0049  constant  XK_I                        \ U+0049 LATIN CAPITAL LETTER I
004a  constant  XK_J                        \ U+004A LATIN CAPITAL LETTER J
004b  constant  XK_K                        \ U+004B LATIN CAPITAL LETTER K
004c  constant  XK_L                        \ U+004C LATIN CAPITAL LETTER L
004d  constant  XK_M                        \ U+004D LATIN CAPITAL LETTER M
004e  constant  XK_N                        \ U+004E LATIN CAPITAL LETTER N
004f  constant  XK_O                        \ U+004F LATIN CAPITAL LETTER O
0050  constant  XK_P                        \ U+0050 LATIN CAPITAL LETTER P
0051  constant  XK_Q                        \ U+0051 LATIN CAPITAL LETTER Q
0052  constant  XK_R                        \ U+0052 LATIN CAPITAL LETTER R
0053  constant  XK_S                        \ U+0053 LATIN CAPITAL LETTER S
0054  constant  XK_T                        \ U+0054 LATIN CAPITAL LETTER T
0055  constant  XK_U                        \ U+0055 LATIN CAPITAL LETTER U
0056  constant  XK_V                        \ U+0056 LATIN CAPITAL LETTER V
0057  constant  XK_W                        \ U+0057 LATIN CAPITAL LETTER W
0058  constant  XK_X                        \ U+0058 LATIN CAPITAL LETTER X
0059  constant  XK_Y                        \ U+0059 LATIN CAPITAL LETTER Y
005a  constant  XK_Z                        \ U+005A LATIN CAPITAL LETTER Z
005b  constant  XK_bracketleft              \ U+005B LEFT SQUARE BRACKET
005c  constant  XK_backslash                \ U+005C REVERSE SOLIDUS
005d  constant  XK_bracketright             \ U+005D RIGHT SQUARE BRACKET
005e  constant  XK_asciicircum              \ U+005E CIRCUMFLEX ACCENT
005f  constant  XK_underscore               \ U+005F LOW LINE
0060  constant  XK_grave                    \ U+0060 GRAVE ACCENT
0060  constant  XK_quoteleft                \ deprecated
0061  constant  XK_a                        \ U+0061 LATIN SMALL LETTER A
0062  constant  XK_b                        \ U+0062 LATIN SMALL LETTER B
0063  constant  XK_c                        \ U+0063 LATIN SMALL LETTER C
0064  constant  XK_d                        \ U+0064 LATIN SMALL LETTER D
0065  constant  XK_e                        \ U+0065 LATIN SMALL LETTER E
0066  constant  XK_f                        \ U+0066 LATIN SMALL LETTER F
0067  constant  XK_g                        \ U+0067 LATIN SMALL LETTER G
0068  constant  XK_h                        \ U+0068 LATIN SMALL LETTER H
0069  constant  XK_i                        \ U+0069 LATIN SMALL LETTER I
006a  constant  XK_j                        \ U+006A LATIN SMALL LETTER J
006b  constant  XK_k                        \ U+006B LATIN SMALL LETTER K
006c  constant  XK_l                        \ U+006C LATIN SMALL LETTER L
006d  constant  XK_m                        \ U+006D LATIN SMALL LETTER M
006e  constant  XK_n                        \ U+006E LATIN SMALL LETTER N
006f  constant  XK_o                        \ U+006F LATIN SMALL LETTER O
0070  constant  XK_p                        \ U+0070 LATIN SMALL LETTER P
0071  constant  XK_q                        \ U+0071 LATIN SMALL LETTER Q
0072  constant  XK_r                        \ U+0072 LATIN SMALL LETTER R
0073  constant  XK_s                        \ U+0073 LATIN SMALL LETTER S
0074  constant  XK_t                        \ U+0074 LATIN SMALL LETTER T
0075  constant  XK_u                        \ U+0075 LATIN SMALL LETTER U
0076  constant  XK_v                        \ U+0076 LATIN SMALL LETTER V
0077  constant  XK_w                        \ U+0077 LATIN SMALL LETTER W
0078  constant  XK_x                        \ U+0078 LATIN SMALL LETTER X
0079  constant  XK_y                        \ U+0079 LATIN SMALL LETTER Y
007a  constant  XK_z                        \ U+007A LATIN SMALL LETTER Z
007b  constant  XK_braceleft                \ U+007B LEFT CURLY BRACKET
007c  constant  XK_bar                      \ U+007C VERTICAL LINE
007d  constant  XK_braceright               \ U+007D RIGHT CURLY BRACKET
007e  constant  XK_asciitilde               \ U+007E TILDE

00a0  constant  XK_nobreakspace             \ U+00A0 NO-BREAK SPACE
00a1  constant  XK_exclamdown               \ U+00A1 INVERTED EXCLAMATION MARK
00a2  constant  XK_cent                     \ U+00A2 CENT SIGN
00a3  constant  XK_sterling                 \ U+00A3 POUND SIGN
00a4  constant  XK_currency                 \ U+00A4 CURRENCY SIGN
00a5  constant  XK_yen                      \ U+00A5 YEN SIGN
00a6  constant  XK_brokenbar                \ U+00A6 BROKEN BAR
00a7  constant  XK_section                  \ U+00A7 SECTION SIGN
00a8  constant  XK_diaeresis                \ U+00A8 DIAERESIS
00a9  constant  XK_copyright                \ U+00A9 COPYRIGHT SIGN
00aa  constant  XK_ordfeminine              \ U+00AA FEMININE ORDINAL INDICATOR
00ab  constant  XK_guillemotleft            \ U+00AB LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
00ac  constant  XK_notsign                  \ U+00AC NOT SIGN
00ad  constant  XK_hyphen                   \ U+00AD SOFT HYPHEN
00ae  constant  XK_registered               \ U+00AE REGISTERED SIGN
00af  constant  XK_macron                   \ U+00AF MACRON
00b0  constant  XK_degree                   \ U+00B0 DEGREE SIGN
00b1  constant  XK_plusminus                \ U+00B1 PLUS-MINUS SIGN
00b2  constant  XK_twosuperior              \ U+00B2 SUPERSCRIPT TWO
00b3  constant  XK_threesuperior            \ U+00B3 SUPERSCRIPT THREE
00b4  constant  XK_acute                    \ U+00B4 ACUTE ACCENT
00b5  constant  XK_mu                       \ U+00B5 MICRO SIGN
00b6  constant  XK_paragraph                \ U+00B6 PILCROW SIGN
00b7  constant  XK_periodcentered           \ U+00B7 MIDDLE DOT
00b8  constant  XK_cedilla                  \ U+00B8 CEDILLA
00b9  constant  XK_onesuperior              \ U+00B9 SUPERSCRIPT ONE
00ba  constant  XK_masculine                \ U+00BA MASCULINE ORDINAL INDICATOR

[THEN]

base !



