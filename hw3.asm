##################################
# Part 1 - String Functions
##################################

is_whitespace:

	beqz $a0, is_whitespace_success # Check
	beq $a0, 0xA, is_whitespace_success
	beq $a0, 0x20, is_whitespace_success
	li $v0, 0 # If not equal, li 0
	j is_whitespace_continue
	is_whitespace_success:
	    li $v0, 1
	is_whitespace_continue: 
	jr $ra

cmp_whitespace:
	addi $sp, $sp, -4
	sw $ra, ($sp) # Register convention
	jal is_whitespace # $a0 is first 
	beq $v0, 1, cmp_whitespace_check # Check reuslt, if 1 -> check second 
	beqz $v0, cmp_whitespace_continue # If 0, just load 0
	cmp_whitespace_check:
	    move $t0, $a0
	    move $a0, $a1
	    jal is_whitespace 
	cmp_whitespace_continue:
	    lw $ra, ($sp)
	    addi $sp, $sp, 4 # Register Convention
	    jr $ra

strcpy:
	addi $sp, $sp, -12
	sw $ra, ($sp) # Register convention
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	move $s0, $a0
	move $s1, $a1
	ble $s0, $s1, strcpy_continue
	li $t3, 0
	strcpy_loop:
	    beq $t3, $a2, strcpy_continue
	    lb $t2, ($s0)
	    sb $t2, ($s1)
	    addi $s0, $s0, 1
	    addi $s1, $s1, 1
	    addi $t3, $t3, 1
	    j strcpy_loop
	strcpy_continue:
	
	lw $ra, ($sp) # Register convention
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	jr $ra

strlen:
	addi $sp, $sp, -12
	sw $ra, ($sp) # Register convention
	sw $s0, 4($sp) # Register convention
	sw $s1, 8($sp) # Register convention
	li $s1, 0
	move $s0, $a0
	strlen_loop:
	    lb $t2, ($s0)
	    move $a0, $t2
	    jal is_whitespace
	    beq $v0, 1, strlen_continue
	    addi $s1, $s1, 1
	    addi $s0, $s0, 2
	    j strlen_loop
	strlen_continue:
	move $v0, $s1
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12 # Register Convention
	jr $ra

##################################
# Part 2 - vt100 MMIO Functions
##################################

set_state_color:
	check_load:
	    beq $a2, 1, highlight_load
	    lbu $t2, ($a0)
	    j set_state_color_continue_1
	    highlight_load:
	        lbu $t2, 1($a0)
	set_state_color_continue_1:
	beqz $a3, set_state_color_0
	beq $a3, 1, set_state_color_1
	beq $a3, 2, set_state_color_2
	set_state_color_0:
		andi $t4, $t2, 0xF0
		andi $t4, $t4, 0x0000
		or $t4, $t4, $a1
		sll $t4, $t4, 4
		andi $t3, $t2, 0x0F # Get first 4 bits -> For
		andi $t3, $t3, 0x0000
		or $t3, $t3, $a1
		or $t2, $t4, $t3
		
		j highlight_check
	set_state_color_1:
		andi $t2, $t2, 0xF0 # Zero out 0f
		andi $t3, $t2, 0x0F # Get first 4 bits -> For
		andi $t3, $t3, 0x0000
		or $t3, $t3, $a1
		or $t3, $t3, $t2
		move $t2, $t3
		j highlight_check
	set_state_color_2:
		andi $t4, $t2, 0xF0
		andi $t4, $t4, 0x0000
		or $t4, $t4, $a1
		# sll, $t4, $t4, 4
		move $t2, $t4
		j highlight_check
		
	highlight_check:
		beq $a2, 1,  highlight_save
		sb $t2, 0($a0)
		j set_state_color_continue
		highlight_save: 
		    sb $t2,1($a0)
	set_state_color_continue:
		jr $ra
	
save_char:
	# 0xA0 * x + 2*y + 0xffff0000
	li $t1, 0xA0
	lbu $t2, 2($a0) # x
	lbu $t3, 3($a0) # Y
	mul $t2, $t1, $t2 # 0xA0 * x
	sll $t3, $t3,1 # y * 2
	
	add $t3, $t3, $t2 #  0xA0 * x + 2*y
	addi $t3, $t3, 0xffff0000 # 0xA0 * x + 2*y + 0xffff0000
	
	sb $a1, 0($t3)
	
	jr $ra
reset:
	li $t1, 0xffff0000 # Base Address
	li $t2, 0 # 0 in each byte
	li $t9, 0xffff0fa0
	lb $t3, ($a0) 
	reset_loop:
	    beq $t1, $t9, reset_done
	    beq $a1, 1, reset_color
	    sb $t2, ($t1)
	    reset_color:
	    	sb $t3, 1($t1)
	    	addi $t1, $t1, 2
	        reset_loop_continue:
	            j reset_loop
	reset_done:
	jr $ra

clear_line:
	li $t1, 0xA0
	move $t2, $a0 # x
	move $t3, $a1 # Y
	mul $t2, $t1, $t2 # 0xA0 * x
	sll $t3, $t3,1 # y * 2
	add $t3, $t3, $t2 #  0xA0 * x + 2*y
	addi $t3, $t3, 0xffff0000 # 0xA0 * x + 2*y + 0xffff0000 -> Current value
	move $t4, $t3
	li $t3, 79
	sll $t3, $t3,1
	add $t3, $t3, $t2
	addi $t5, $t3, 0xffff0000
	li $t6, 0
	clear_line_loop:
	    beq $t4, $t5, clear_line_done
	    sb $t6, ($t4)
	    sb $a2, 1($t4)
	    addi $t4, $t4, 2
	    j clear_line_loop 
	    
	clear_line_done:
	jr $ra

set_cursor:
	li $t1, 0xA0 
	beq $a3, 1, initial_on
	
	
	lbu $t2, 2($a0) # x from struct
	lbu $t3, 3($a0) # y from struct
	mul $t2, $t1, $t2 # 0xA0 * x
	sll $t3, $t3,1 # y * 2
	add $t3, $t3, $t2 #  0xA0 * x + 2*y
	addi $t3, $t3, 0xffff0000 # 0xA0 * x + 2*y + 0xffff0000 -> Current value
	
	# Invert bold bits of 
	lbu $t4, 1($t3)
	xori $t5, $t4, 0x88 
	sb $t5, 1($t3) # Save it back
	
	initial_on: 
	sb $a1, 2($a0)
	sb $a2, 3($a0)
	
	lbu $t2, 2($a0) # x from struct
	lbu $t3, 3($a0) # y from struct
	mul $t2, $t1, $t2 # 0xA0 * x
	sll $t3, $t3,1 # y * 2
	add $t3, $t3, $t2 #  0xA0 * x + 2*y
	addi $t3, $t3, 0xffff0000 # 0xA0 * x + 2*y + 0xffff0000 -> Current value
	
	# Invert bold bits of 
	lbu $t4, 1($t3)
	xori $t5, $t4, 0x88 
	sb $t5, 1($t3) # Save it back
	
	jr $ra

move_cursor:
	# Register Convention
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	li $t0, 0x68 # h
	li $t1, 0x6A # j
	li $t2, 0x6B # k
	li $t3, 0x6C # l
	
	beq $a1, $t0, handle_left
	beq $a1, $t1, handle_down
	beq $a1, $t2, handle_up
	beq $a1, $t3, handle_right
	
	handle_left:
	    move $a1, $s0
	    lb $a1, 2($a0) # load x
	    lb $a2, 3($a0) # load y
	    beqz $a2, move_cursor_continue
	    addi $a2, $a2, -1
	    li $a3, 0
	    jal set_cursor
	    j move_cursor_continue
		
	handle_down:
	    move $a1, $s0
	    lb $a1, 2($a0) # load x
	    lb $a2, 3($a0) # load y
	    beq $a1, 24, move_cursor_continue
	    addi $a1, $a1, 1
	    li $a3, 0
	    jal set_cursor
	    j move_cursor_continue
	
	handle_up:
	move $a1, $s0
	    lb $a1, 2($a0) # load x
	    lb $a2, 3($a0) # load y
	    beqz $a1, move_cursor_continue
	    addi $a1, $a1, -1
	    li $a3, 0
	    jal set_cursor
	    j move_cursor_continue
	
	handle_right: 
	    move $a1, $s0
	    lb $a1, 2($a0) # load x
	    lb $a2, 3($a0) # load y
	    beq $a2, 79, move_cursor_continue
	    addi $a2, $a2, 1
	    li $a3, 0
	    jal set_cursor
	    j move_cursor_continue
	
	move_cursor_continue:
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	#######################
	jr $ra

mmio_streq:
	# Register Convention
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)  
	sw $s2, 12($sp) 
	move $s0, $a0
	move $s1, $a1
	# lw $s2, ($s1)
	beqz $s1, mmio_streq_equal
	mmio_streq_loop:
	    lbu $a0, ($s0)
	    lbu $a1, ($s1)
	    beqz $a0, check_b
	    beq $a0, 0xA, check_b
	    beq $a0, 0x20, check_b
	    addi $s0, $s0, 2
	    addi $s1, $s1, 1
	    beq $a0, $a1, mmio_streq_loop
	    j mmio_streq_equal
	    check_b:
	        jal cmp_whitespace
	        beq $v0, 1, mmio_streq_equal
	mmio_streq_not_equal:
	    li $v0, 0
	mmio_streq_equal:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra

##################################
# Part 3 - UI/UX Functions
##################################

handle_nl:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp) # struct
	sw $s1, 8($sp) # x
	sw $s2, 12($sp) # y
	sw $s3, 16($sp) # color
	
	move $s0, $a0
	lbu $s3, ($s0) # color
	lbu $s1, 2($s0) # x from struct
	lbu $t3, 3($s0) # y from struct
	move $s2, $t3
	mul $t2, $t1, $s1 # 0xA0 * x
	sll $t3, $t3,1 # y * 2
	add $t3, $t3, $t2 #  0xA0 * x + 2*y
	addi $t3, $t3, 0xffff0000 # 0xA0 * x + 2*y + 0xffff0000 -> Current value
	
	li $t0, 0xA
	move $a1, $t0
	jal save_char
	
	move $a0, $s1
	move $a1, $s2
	move $a2, $s3
	jal clear_line
	
	bne $t2, 24, last_row_bypass
	j last_row_continue
	last_row_bypass:
	    addi $s1, $s1, 1
	
	last_row_continue:
	move $a0, $s0
	move $a1, $s1
	li $a2, 0
	li $a3, 0
	jal set_cursor
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

handle_backspace:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp) # struct
	sw $s1, 8($sp) # x
	sw $s2, 12($sp) # y
	
	li $t1, 0xA0
	lbu $t2, 2($a0) # x
	lbu $t3, 3($a0) # Y
	move $s1, $t3
	mul $t2, $t1, $t2 # 0xA0 * x
	sll $t3, $t3,1 # y * 2
	
	add $t3, $t3, $t2 #  0xA0 * x + 2*y
	addi $s2, $t3, 0xffff0000 # 0xA0 * x + 2*y + 0xffff0000
	
	handle_backspace_loop:
	    beq $s1, 80, handle_back_space_continue
	    
	    move $a1, $s2
	    addi $s2, $s2, 2
	    move $a0, $s2
	    li $a2, 1
	    jal strcpy
	    addi $s1, $s1, 1
	    j handle_backspace_loop
	
	handle_back_space_continue:
	li $t3, 79
	sll $t3, $t3, 1
	mul $t2, $t1, $t2 # 0xA0 * x
	add $t3, $t3, $t2 #  0xA0 * x + 2*79k
	addi $t3, $t3, 0xffff0000 # 0xA0 * x + 2*y + 0xffff0000
	li $t5, 0
	sb $t5, ($t3)
	
	lw $ra, ($sp)
	lw $s0, 4($sp) # struct
	lw $s1, 8($sp) # x
	lw $s2, 12($sp) # y
	addi $sp, $sp, 16
	jr $ra

highlight:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp) # struct
	sw $s1, 8($sp) # x
	li $t0, 0xA0
	move $s0, $a0 # x 
	move $s1, $a1 # y
	mul $s0, $s0, $t0 # 0xA0 * x
	sll $s1, $s1,1 # y * 2
	add $s1, $s0, $s1 #  0xA0 * x + 2*y
	addi $s1, $s1, 0xffff0000 # 0xA0 * x + 2*y + 0xffff0000 -> Current value
	
	li $t3, 0
	highlight_loop: 
	    beq $t3, $a3, highlight_done
	    sb $a2, 1($s1)
	    addi $s1, $s1, 2
	    addi $t3, $t3, 1
	    j highlight_loop
	    
	highlight_done:
	lw $ra, 0($sp)
	lw $s0, 4($sp) # struct
	lw $s1, 8($sp) # x
	addi $sp, $sp, 12
	jr $ra

highlight_all:
	# REGISTER CONVENTION
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp) # struct
	sw $s1, 8($sp) # x
	sw $s2, 12($sp) # y
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	move $s0, $a0
	move $s1, $a1
	li $s2, 0xffff0000
	
	li $s6, 0 # x
	li $s7, 0 # y
	
	highlight_all_loop:
	    li $t0, 0xffff0fa0
	    beq $s2, $t0, highlight_loop_continue
	    lb $s4, ($s2)
	    move $a0, $s4
	    jal is_whitespace
	    beq $v0, 0, is_whitespace_false
	    beq $s7, 79, increment_x
	    addi $s2, $s2, 2
	    addi $s7, $s7, 1
	    
	    j highlight_inner_continue
	    increment_x: 
	    	addi $s6, $s6, 1
	    	addi $s2, $s2, 2
	    	li $s7, 0
	    highlight_inner_continue:
	    j highlight_all_loop
	    is_whitespace_false:
	    move $s3, $s1
	    dict_loop:
	    	lbu $t1, ($s2) 
	    	beqz $t1, dict_loop_done 
	    	move $a0, $s2
	    	lw $t2, ($s3)
	    	# move $a1, $s3
	    	move $a1, $t2
	    	beqz $t2, dict_loop_done
	    	jal mmio_streq
	    	beq $v0, 1, highlight_keyword
	    	addi $s3, $s3, 4
	    	j dict_loop
	    	
	    	highlight_keyword:
	    	    move $a0, $s2
	    	    jal strlen
	    	    move $a0, $s6
	    	    move $a1, $s7
	    	    move $a2, $s0
	    	    move $a3, $v0
	    	    jal highlight
	    	    
	    	dict_loop_done: 
	    	    move $s3, $s1
	    	    lbu $s4, ($s2)
	    	    move $a0, $s4
	    	    jal is_whitespace
	    	    beqz $v0, increment_display
	    	    j highlight_all_loop
	    	    increment_display: 
	    	        addi $s2, $s2, 2
	    	        addi $s7, $s7, 1
	    	        
	    	        j dict_loop_done
	    	    
	highlight_loop_continue:
	lw $ra, 0($sp)
	lw $s0, 4($sp) # struct
	lw $s1, 8($sp) # x
	lw $s2, 12($sp) # y
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36
	jr $ra