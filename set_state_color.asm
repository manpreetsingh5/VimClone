# grading test for set_state_color
.data

.align 2
__state_1: .byte 0xF0, 0x0F, 0x04, 0x22 #cursor at (4,34)
.space 10

# expected state for set_state_color test 1
__state_1_test1_sol: .byte 0x05, 0x0F, 0x04, 0x22

# expected state for set_state_color test 2
__state_1_test2_sol: .byte 0xF0, 0x4B, 0x04, 0x22

# expected state for set_state_color test 3
__state_1_test3_sol: .byte 0x00, 0x0F, 0x04, 0x22

# expected state for set_state_color test 4
__state_1_test4_sol: .byte 0xF0, 0x4F, 0x04, 0x22

# expected state for set_state_color test 5
__state_1_test5_sol: .byte 0xF5, 0x0F, 0x04, 0x22

# expected state for set_state_color test 6
__state_1_test6_sol: .byte 0xF0, 0x0B, 0x04, 0x22
