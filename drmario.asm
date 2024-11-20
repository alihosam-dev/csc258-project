
    .data
BOTTLE_TOP: .word 8            # Top boundary of the bottle (y-coordinate)
BOTTLE_BOTTOM: .word 23        # Bottom boundary of the bottle (y-coordinate)
BOTTLE_LEFT: .word 12          # Left boundary of the bottle (x-coordinate)
BOTTLE_RIGHT: .word 20         # Right boundary of the bottle (x-coordinate)
CAPSULE_WIDTH: .word 2         # Width of the pill in horizontal orientation
CAPSULE_HEIGHT: .word 2        # Height of the pill in vertical orientation
################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Chet Petro, 1010380320
# Student 2: Ali Elbadrawy, 1009795072 (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       1
# - Unit height in pixels:      1
# - Display width in pixels:    32
# - Display height in pixels:   32
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL: .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD: .word 0xffff0000

# Game Config
FRAME_RATE: .word 100 # Frame rate in 1/(frame rate) where frame rate is fps 

# Game Colours
BOTTLE_COLOUR: .word 0x808080
BACKGROUND_COLOUR: .word 0x000000
PILL_RED: .word 0xFF0000
PILL_BLUE: .word 0x0000FF
PILL_YELLOW: .word 0xFFFF00
PREV_CAPSULE_X: .word 15     # Previous X position of capsule
PREV_CAPSULE_Y: .word 5      # Previous Y position of capsule

##############################################################################
# Mutable Data
##############################################################################

# Pill Data
pill_colour_1: .word 0xFF0000 # colour of square 1 of pill
pill_colour_2: .word 0xFF0000 # colour of square 2 of pill
pill_x: .byte 15 # X coord of pill in pixels
pill_y: .byte 8 # Y coord of pill in pixels
pill_orient: .byte 0 # orientation of pill, 0 = horizontal, 1 = vertical

# Virus Data
intitial_virus_count: .byte 3

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    
    # Draw the bottle
    addi $a0, $zero, 11
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    addi $a0, $zero, 17
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    addi $a0, $zero, 11
    addi $a1, $zero, 24
    addi $a2, $zero, 10
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    addi $a0, $zero, 13
    addi $a1, $zero, 4
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    addi $a0, $zero, 18
    addi $a1, $zero, 4
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    addi $a0, $zero, 14
    addi $a1, $zero, 5
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    addi $a0, $zero, 17
    addi $a1, $zero, 5
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    addi $a0, $zero, 11
    addi $a1, $zero, 8
    addi $a2, $zero, 16
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    addi $a0, $zero, 20
    addi $a1, $zero, 8
    addi $a2, $zero, 16
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    # Draw The Initial Capsule
    # get random colour (0-2), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    addi $t1, $zero, 1 # load 1 into $t1
    bne $zero, $a0, pill_1_not_red # if a0 == 0
        lw $t3, PILL_RED # load red into $t3
        sw $t3, pill_colour_1
        j pill_1_end
    pill_1_not_red:
    
    bne $t1, $a0, pill_1_not_blue # if a0 == 1
        lw $t3, PILL_BLUE # load blue into $t3
        sw $t3, pill_colour_1
        j pill_1_end
    pill_1_not_blue:
    
    # Draw yellow virus (not blue or red)
    lw $t3, PILL_YELLOW # load yellow into $t3
    sw $t3, pill_colour_1
    pill_1_end:
    
    # get random colour (0-2), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    addi $t1, $zero, 1 # load 1 into $t1
    bne $zero, $a0, pill_2_not_red # if a0 == 0
        lw $t3, PILL_RED # load red into $t3
        sw $t3, pill_colour_2
        j pill_1_end
    pill_2_not_red:
    
    bne $t1, $a0, pill_2_not_blue # if a0 == 1
        lw $t3, PILL_BLUE # load blue into $t3
        sw $t3, pill_colour_2
        j pill_2_end
    pill_2_not_blue:
    
    # Draw yellow virus (not blue or red)
    lw $t3, PILL_YELLOW # load yellow into $t3
    sw $t3, pill_colour_2
    pill_2_end:    
	jal draw_pill
    
    # Draws $a0 amournt of the intitial viruses
    lb $a3, intitial_virus_count
    jal draw_random_virus


game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	
	# Check for keypress
    lw $t0, ADDR_KBRD          # Load keyboard base address
    lw $t1, 0($t0)             # Read keyboard state
    beq $t1, $zero, game_loop  # If no key is pressed, continue loop

    # Save the current position as the previous position
    lw $t2, pill_x
    sw $t2, PREV_CAPSULE_X
    lb $t3, pill_y
    sw $t3, PREV_CAPSULE_Y

    # Get the key code
    lw $t2, 4($t0)             # Load key code
    
    jal remove_pill
    
    # Check for 'w' (up)
    li $t3, 0x77               # ASCII for 'w'
    bne $t2, $t3, rotate_skip
    jal rotate
    rotate_skip:

    # Check for 's' (down)
    li $t3, 0x73               # ASCII for 's'
    bne $t2, $t3, move_down_skip
    jal move_down
    move_down_skip:

    # Check for 'a' (left)
    li $t3, 0x61               # ASCII for 'a'
    bne $t2, $t3, move_left_skip
    jal move_left
    move_left_skip:

    # Check for 'd' (right)
    li $t3, 0x64               # ASCII for 'd'
    bne $t2, $t3, move_right_skip
    jal move_right
    move_right_skip:
	
	draw_capsule:
	# Draw The Current Capsule
	lw $a0, PILL_RED
	lw $a1, PILL_YELLOW
	
	
	jal draw_pill
	
	
	# 4. Sleep
    
    li $v0, 32          # Sleep
    lw $a0, FRAME_RATE  # sleep for frame rate amount of time
    syscall 
    
    # 5. Go back to Step 1
    j game_loop

    
    

# draw_hor_line(start_x_pos, start_y_pos, length, colour)
# draws a horizontal line starting at pixel (x,y) for a specified length of a certain colour
# $a0 - line start x pos (in pixels)
# $a1 - line start y pos (in pixels)
# $a2 - length to draw (in pixels)
# #a3 - colour to draw the line (in hex)
draw_hor_line:
    lw $t0, ADDR_DSPL               # current address to draw in $t0
    sll $t9, $a0, 2                 # initial x offset
    sll $t8, $a1, 7                 # inital y offset
    add $t0, $t0, $t9               # add x offset
    add $t0, $t0, $t8               # add y offset
    add $t1, $zero, $zero           # set then current length in $t1 (init to 0)
    draw_hor_line_loop:             # Start of loop
        beq $t1, $a2, draw_hor_line_end # Check if the current length is equal to the desired length
        sw $a3, 0($t0)              # Draw the square on the screen
        addi $t1, $t1, 1            # increment the current length by 1
        addi $t0, $t0, 4            # increment the offset of the pixel
        j draw_hor_line_loop
    draw_hor_line_end:
        jr $ra # return
    
# draw_vert_line(start_x_pos, start_y_pos, length, colour)
# draws a vertical line starting at pixel (x,y) for a specified length of a certain colour
# $a0 - line start x pos (in pixels)
# $a1 - line start y pos (in pixels)
# $a2 - length to draw (in pixels)
# #a3 - colour to draw the line (in hex)
draw_vert_line:
    lw $t0, ADDR_DSPL                       # current address to draw in $t0
    sll $t9, $a0, 2                         # initial x offset
    sll $t8, $a1, 7                         # inital y offset
    add $t0, $t0, $t9                       # add x offset
    add $t0, $t0, $t8                       # add y offset
    add $t1, $zero, $zero                   # set then current length in $t1 (init to 0)
    draw_vert_line_loop:                    # Start of loop
        beq $t1, $a2, draw_vert_line_end        # Check if the current length is equal to the desired length
        sw $a3, 0($t0)                          # Draw the square on the screen
        addi $t1, $t1, 1                        # increment the current length by 1
        addi $t0, $t0, 128                      # increment the offset of the pixel
        j draw_vert_line_loop
    draw_vert_line_end:
        jr $ra # return
        
# draw_random_virus(virus_number)
# draws a random coloured virus on the screen where there is not already a virus
# a3 - number of viruses to draw
draw_random_virus:
    lw $t0, ADDR_DSPL   # current address to draw in $t0
    # get random x offset in pixels (0-7), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 8
    syscall
    addi $t9, $a0, 12 # store x location in $t9
    # get random y offset in pixels (0-7), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 8
    syscall
    addi $t8, $a0, 16   # store y location in $t8
    sll $t9, $t9, 2     # initial x offset
    sll $t8, $t8, 7     # inital y offset
    add $t0, $t0, $t9   # add x offset
    add $t0, $t0, $t8   # add y offset
    # Get colour of current address
    # check if that colour is not the background colour, if it is, jump back to draw_random_virus (not implimented yet, might just not impliment it)
    # get random colour (0-2), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    
    addi $t1, $zero, 1 # load 1 into $t1

    bne $zero, $a0, draw_random_virus_not_red # if a0 == 0
        lw $t3, PILL_RED # load red into $t3
        sw $t3, 0($t0) # Draw virus
        j draw_random_virus_end
    draw_random_virus_not_red:
    
    bne $t1, $a0, draw_random_virus_not_blue # if a0 == 1
        lw $t3, PILL_BLUE # load blue into $t3
        sw $t3, 0($t0) # Draw virus
        j draw_random_virus_end
    draw_random_virus_not_blue:
    
    # Draw yellow virus (not blue or red)
    lw $t3, PILL_YELLOW # load yellow into $t3
    sw $t3, 0($t0) # Draw virus
    draw_random_virus_end:
        addi $a3, $a3, -1 # drawed a virus so reduce the amount to draw by 1
        bne $a3, $zero, draw_random_virus
        jr $ra # return
    
# draw_pill()
# draws a pill at at (pill_x, pill_y) in pixels with specified colours (pill_colour_1, pill_colour_2) with orientation specified by pill_orient
draw_pill:
    lw $t0, ADDR_DSPL       # current address to draw in $t0
    lb $t9, pill_x          # load current x pos
    lb $t8, pill_y          # load current y pos
    lb $t7, pill_orient     # load current orientation
    sll $t9, $t9, 2         # x offset in $t9
    sll $t8, $t8, 7         # y offset in $t8
    add $t0, $t0, $t9       # add x offset
    add $t0, $t0, $t8       # add y offset
    lw $t6, pill_colour_1   # load square 1 colour in $t6
    lw $t5, pill_colour_2   # load square 2 colour in $t5
    sw $t6, 0($t0)          # draw square 1
    beq $t7, $zero, draw_pill_is_hor    # if pill_orient is horizontal, jump to horizontal branch, else draw vertical
        addi $t0, $t0, -128                 # go to square above
        j draw_pill_end                     # return
    draw_pill_is_hor:                   # else branch
        addi $t0, $t0, 4                    # go to sqare beside
        j draw_pill_end                     # return
    draw_pill_end:
        sw $t5, 0($t0) # draw sqare 2
        jr $ra # return
    
# remove_pill()
# removes the pill at (pill_x, pill_y) based on its current orientation pill_orient
remove_pill:
    lw $t0, ADDR_DSPL       # current address to draw in $t0
    lb $t9, pill_x          # load current x pos
    lb $t8, pill_y          # load current y pos
    lb $t7, pill_orient     # load current orientation
    sll $t9, $t9, 2         # x offset in $t9
    sll $t8, $t8, 7         # y offset in $t8
    add $t0, $t0, $t9       # add x offset
    add $t0, $t0, $t8       # add y offset
    sw $zero, 0($t0)        # remove the first square
    beq $t7, $zero, remove_pill_is_hor    # if pill_orient is horizontal, jump to horizontal branch, else draw vertical
        addi $t0, $t0, -128                 # go to square above
        j remove_pill_end                   # return
    remove_pill_is_hor:                   # else branch
        addi $t0, $t0, 4                    # go to sqare beside
        j remove_pill_end                   # return
    remove_pill_end:
        sw $zero, 0($t0) # remove sqare 2
        jr $ra # return
        

rotate:
    lb $t9, pill_orient         # Load pill orientation
    lb $t5, pill_x          # Load current X position
    addi $t6, $t5, 1            # Calculate next X position
    addi $t6, $t6, 1            # If vertical, add width for right edge
    lw $t7, BOTTLE_RIGHT        # Load right boundary
    xori $t9, $t9, 1
    bne $t9, $zero, rotate_colour_swap_skip # if we roate and our orientation goes back to zero, we know we have to swap the colours of the current pill, if not, we skip the swapping 
        lw $t0, pill_colour_1   # Swap Colours
        lw $t1, pill_colour_2   # |
        sw $t0, pill_colour_2   # |
        sw $t1, pill_colour_1   # |
    rotate_colour_swap_skip:
    sb $t9, pill_orient
    bgt $t6, $t7, move_left # Check right boundary for vertical
    jr $ra

move_down:

    # Boundary check for moving down
    lb $t9, pill_orient         # Load pill orientation
    lb $t5, pill_y           # Load current Y position
    addi $t6, $t5, 1            # Calculate next Y position
    beq $t9, $zero, check_down_horizontal # If horizontal, check bottom edge
    lb $t8, CAPSULE_HEIGHT+2      # Load capsule height for vertical
    add $t6, $t6, $t8           # Calculate bottom edge for vertical orientation
    lw $t7, BOTTLE_BOTTOM       # Load bottom boundary
    bgt $t6, $t7, skip_movement # If next Y exceeds bottom boundary, skip movement
    j move_down_continue

check_down_horizontal:
    lw $t7, BOTTLE_BOTTOM       # Load bottom boundary
    bgt $t6, $t7, skip_movement # If next Y exceeds bottom boundary, skip movement

move_down_continue:
    lb $t4, pill_y          # Load Y position
    addi $t4, $t4, 1           # Increase Y
    sb $t4, pill_y          # Store updated Y
    jr $ra

move_left:

    # Boundary check for moving left
    lb $t9, pill_orient         # Load pill orientation
    lb $t5, pill_x           # Load current X position
    addi $t6, $t5, -1           # Calculate next X position
    lw $t7, BOTTLE_LEFT         # Load left boundary
    bge $t6, $t7, move_left_continue # If within left boundary, allow movement
    j skip_movement             # Otherwise, skip movement

move_left_continue:
    lb $t4, pill_x         # Load X position
    addi $t4, $t4, -1          # Decrease X
    sb $t4, pill_x          # Store updated X
    jr $ra

move_right:

    # Boundary check for moving right
    lb $t9, pill_orient         # Load pill orientation
    lb $t5, pill_x          # Load current X position
    addi $t6, $t5, 1            # Calculate next X position
    beq $t9, $zero, check_right_horizontal # If horizontal, check right edge
    addi $t6, $t6, 1            # If vertical, add width for right edge
    lw $t7, BOTTLE_RIGHT        # Load right boundary
    bgt $t6, $t7, skip_movement # Check right boundary for vertical
    j move_right_continue 

check_right_horizontal:
    lw $t8, CAPSULE_WIDTH       # Load capsule width
    add $t6, $t6, $t8           # Add width to calculate right edge
    lw $t7, BOTTLE_RIGHT        # Load right boundary
    bgt $t6, $t7, skip_movement # If next X exceeds right boundary, skip movement

move_right_continue:
    lb $t4, pill_x         # Load X position
    addi $t4, $t4, 1           # Increase X
    sb $t4, pill_x          # Store updated X
    jr $ra


skip_movement:
    # If movement is invalid, skip updating the position
    jr $ra

