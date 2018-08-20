# mmio_streq Test #1-4
# MMIO-like Memory for strings are stored in __mmio_streq_#
# ASCII versions of the strings are stored in __mmio_streq_#_normal

# Test 1
__mmio_streq_1_normal: .ascii " "
.space 10
__mmio_streq_1: .byte 0x20,0x0F
.space 10

# Test 2
__mmio_streq_2_normal: .ascii "helloworld\n"
.space 10
__mmio_streq_2: .byte 0x68,0x0F, 0x65,0x0F, 0x6C,0x0F, 0x6C,0x0F, 0x6F,0x0F, 0x77,0x0F, 0x6F,0x0F, 0x72,0x0F, 0x6C,0x0F, 0x64,0x0F, 0x20,0x0F
.space 10

# Test 3
__mmio_streq_3_normal: .ascii "cafebabe\0"
.space 10
__mmio_streq_3: .byte 0x64,0x0F, 0x65,0x0F, 0x61,0x0F, 0x64,0x0F, 0x62,0x0F, 0x65,0x0F, 0x65,0x0F, 0x66,0x0F, 0x00,0x0F
.space 10

# Test 4
__mmio_streq_4_normal: .ascii "helloworldcafebabe "
.space 10
__mmio_streq_4: .byte 0x68,0x0F, 0x65,0x0F, 0x6C,0x0F, 0x6C,0x0F, 0x6F,0x0F, 0x77,0x0F, 0x6F,0x0F, 0x72,0x0F, 0x6C,0x0F, 0x64,0x0F, 0x20,0x0F
.space 10