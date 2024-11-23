
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
GAME_BOARD: .space 4096 # Allocate 4096 bytes for the game board (32x32) x 4 (for each word)

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
pill_colour_1: .byte 0 # colour of square 1 of pill (0-2)
pill_colour_2: .byte 0 # colour of square 2 of pill (0-2) 
pill_x: .byte 15 # X coord of pill in pixels
pill_y: .byte 8 # Y coord of pill in pixels
pill_orient: .byte 0 # orientation of pill, 0 = horizontal, 1 = vertical
pill_single: .byte 1 # is the pill only a single square (0=no, 1=yes)
pill_is_colliding: .byte 0 # 1 if the pill is colliding, 0 if not
pill_valid: .byte 0      # 1 if the pill is a pill, 0 if the pulled pill is not a pill
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
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 11
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 17
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 11
    addi $a1, $zero, 24
    addi $a2, $zero, 10
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 13
    addi $a1, $zero, 4
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 18
    addi $a1, $zero, 4
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 14
    addi $a1, $zero, 5
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 17
    addi $a1, $zero, 5
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 11
    addi $a1, $zero, 8
    addi $a2, $zero, 16
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 20
    addi $a1, $zero, 8
    addi $a2, $zero, 16
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    
    # Adding the bottle bounds to the game board
    # Draw the bottle
    la $t0, GAME_BOARD
    addi $a0, $zero, 11
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 17
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 11
    addi $a1, $zero, 24
    addi $a2, $zero, 10
    lw $a3, BOTTLE_COLOUR
    jal draw_hor_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 13
    addi $a1, $zero, 4
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 18
    addi $a1, $zero, 4
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 14
    addi $a1, $zero, 5
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 17
    addi $a1, $zero, 5
    addi $a2, $zero, 2
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 11
    addi $a1, $zero, 8
    addi $a2, $zero, 16
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 20
    addi $a1, $zero, 8
    addi $a2, $zero, 16
    lw $a3, BOTTLE_COLOUR
    jal draw_vert_line
    
    # Draw the Initial viruses
    
    addi $a3, $zero, 3
    jal draw_random_virus
    
    # Draw The Initial Capsule
    
    # basic start data
    addi $t0, $zero, 15
    sb $t0, pill_x
    addi $t0, $zero, 8
    sb $t0, pill_y
    sb $zero, pill_orient
    sb $zero, pill_single
    
    # get random colour (0-2), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    sb $a0, pill_colour_1
    
    # get random colour (0-2), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    sb $a0, pill_colour_2
    
    
    
    jal draw_pill
    

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
    lb $t2, pill_x
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
# t0 is the address of where we're writing to (gameboard or display)
draw_hor_line:
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
# t0 is the address of where we're writing to (gameboard or display)
draw_vert_line:
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
        
        
        
# draw_random_virus(number_of_viruses)
# draws number_of_viruses viruses on the screen
# $a3 - number_of_viruses
draw_random_virus:
    beq $a3, $zero, draw_random_virus_end
    
    # get random x offset in pixels (0-7), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 8
    syscall
    addi $t0, $a0, 12 # store x location in $t0
    sb $t0, pill_x
    
    # get random y offset in pixels (0-7), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 8
    syscall
    addi $t0, $a0, 16   # store y location in $t0
    sb $t0, pill_y
    
    sb $zero, pill_orient # set standard orientation and single status for virus
    addi $t0, $zero, 1
    sb $t0, pill_single
    
    # get random colour (0-2), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    sb $a0, pill_colour_1
    
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
    jal draw_pill
    lw $ra, 0($sp)				# Pop $ra off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    
    addi $a3, $a3, -1
    j draw_random_virus
    
    draw_random_virus_end:
        jr $ra 
        
        
# draw_pill()
# draws a pill at at (pill_x, pill_y) in pixels with specified colours (pill_colour_1, pill_colour_2) with orientation specified by pill_orient
draw_pill:
    lw $t0, ADDR_DSPL       # current address to draw in $t0
    lb $t9, pill_x          # load current x pos
    lb $t8, pill_y          # load current y pos
    lb $t7, pill_orient     # load current orientation
    lb $t3, pill_single     # load current single status
    sll $t9, $t9, 2         # x offset in $t9
    sll $t8, $t8, 7         # y offset in $t8
    add $t0, $t0, $t9       # add x offset
    add $t0, $t0, $t8       # add y offset
    
    lb $t6, pill_colour_1   # load square 1 colour in $t6 (0-2)
    sll $t6, $t6, 2         # multiply colour offset by 4
    la $t4, PILL_RED        # Load the address of PILL_RED in $t4
    add $t6, $t6, $t4       # Sets $t6 to the right location in memory
    lw $t6, 0($t6)          # Load the correct colour into $t6
    
    lb $t5, pill_colour_2   # load square 2 colour in $t5
    sll $t5, $t5, 2         # multiply colour offset by 4
    la $t4, PILL_RED        # Load the address of PILL_RED in $t4
    add $t5, $t5, $t4       # Sets $t5 to the right location in memory
    lw $t5, 0($t5)          # Load the correct colour into $t5
    
    sw $t6, 0($t0)          # draw square 1
    bne $t3, $zero, draw_pill_end       # Dont draw the second sqaure if we only have a single pixel
    beq $t7, $zero, draw_pill_is_hor    # if pill_orient is horizontal, jump to horizontal branch, else draw vertical
        addi $t0, $t0, -128                 # go to square above
        sw $t5, 0($t0)                      # draw sqare 2
        j draw_pill_end                     # return
    draw_pill_is_hor:                   # else branch
        addi $t0, $t0, 4                    # go to sqare beside
        sw $t5, 0($t0)                      # draw sqare 2
        j draw_pill_end                     # return
    draw_pill_end:
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
    la $t0, GAME_BOARD      # Load the base address of the display
    lb $t9, pill_orient     # Load current pill orientation
    lb $t5, pill_x          # Load current X position
    lb $t6, pill_y          # Load current Y position
    lb $t3, pill_single     # Load pill_single variable
    sll $t5, $t5, 2         # Calculate X offset
    sll $t6, $t6, 7         # Calculate Y offset

    # If pill is single, rotation is always valid
    bne $t3, $zero, rotate_continue

    # Check collision for horizontal-to-vertical rotation
    beq $t9, $zero, check_horizontal_to_vertical

    # Check collision for vertical-to-horizontal rotation
    j check_vertical_to_horizontal

check_horizontal_to_vertical:
    sub $t7, $t6, 128       # Offset for pixel above the left segment
    add $t0, $t0, $t7       # Base + offset for above pixel
    add $t0, $t0, $t5       # Add X offset
    lw $t1, 0($t0)          # Load pixel color
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If not background color, skip rotation
    j rotate_continue

check_vertical_to_horizontal:
    add $t7, $t5, 4         # Offset for pixel to the right of the bottom segment
    add $t0, $t0, $t7       # Base + offset for right pixel
    add $t0, $t0, $t6       # Add Y offset
    lw $t1, 0($t0)          # Load pixel color
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If not background color, skip rotation
    j rotate_continue

rotate_continue:
    # Perform rotation
    lb $t9, pill_orient     # Load current pill orientation
    xori $t9, $t9, 1        # Toggle orientation (0 <-> 1)
    sb $t9, pill_orient     # Save new orientation

    # Swap colors for proper orientation
    lb $t0, pill_colour_1   # Load pill_colour_1
    lb $t1, pill_colour_2   # Load pill_colour_2
    sb $t0, pill_colour_2   # Store pill_colour_1 into pill_colour_2
    sb $t1, pill_colour_1   # Store pill_colour_2 into pill_colour_1
    jr $ra                  # Return

move_down:
    la $t0, GAME_BOARD       # Load the base address of the display
    lb $t9, pill_orient     # Load pill orientation
    lb $t5, pill_x          # Load current X position
    lb $t6, pill_y          # Load current Y position
    lb $t3, pill_single     # Load pill_single variable
    sll $t5, $t5, 2         # Calculate X offset
    sll $t6, $t6, 7         # Calculate Y offset

    # Single pill
    bne $t3, $zero, check_down_single
    # Double pill (horizontal or vertical)
    beq $t9, $zero, check_down_double_horizontal
    j check_down_double_vertical

check_down_single:
    add $t7, $t6, 128       # Offset for pixel below
    add $t0, $t0, $t7       # Base + offset for below pixel
    add $t0, $t0, $t5       # Add X offset
    lw $t1, 0($t0)          # Load pixel color
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, change_pill_collision # If not background color, skip movement
    j move_down_continue
    
check_down_double_horizontal:
    # Check the first (left) segment
    add $t7, $t6, 128       # Offset for pixels below
    add $t0, $t0, $t7       # Base + offset for below row
    add $t0, $t0, $t5       # Add X offset for first pixel
    lw $t1, 0($t0)          # Load color of first pixel
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, change_pill_collision # If first pixel is not background, skip

    # Check the second (right) segment
    add $t0, $t0, 4         # Offset for the right segment
    lw $t1, 0($t0)          # Load color of second pixel
    bne $t1, $t2, change_pill_collision # If second pixel is not background, skip
    j move_down_continue

check_down_double_vertical:
    # Check the bottommost segment of the vertical pill
    add $t7, $t6, 128       # Offset for bottommost pixel
    add $t0, $t0, $t7       # Base + offset for below pixel
    add $t0, $t0, $t5       # Add X offset
    lw $t1, 0($t0)          # Load pixel color
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, change_pill_collision # If not background color, skip movement
    j move_down_continue


change_pill_collision:
    li $t3, 1
    sb $t3, pill_is_colliding
    j skip_movement

move_down_continue:
    lb $t4, pill_y          # Load current Y position
    addi $t4, $t4, 1        # Increase Y position
    sb $t4, pill_y          # Save updated Y position
    jr $ra                  # Return

move_left:
    la $t0, GAME_BOARD     # Load the base address of the display
    lb $t9, pill_orient     # Load pill orientation
    lb $t5, pill_x          # Load current X position
    lb $t6, pill_y          # Load current Y position
    lb $t3, pill_single     # Load pill_single variable
    sll $t5, $t5, 2         # Calculate X offset
    sll $t6, $t6, 7         # Calculate Y offset

    # Single pill
    bne $t3, $zero, check_left_single
    # Double pill (horizontal or vertical)
    beq $t9, $zero, check_left_double_horizontal
    j check_left_double_vertical

check_left_single:
    sub $t7, $t5, 4         # Offset for pixel to the left
    add $t0, $t0, $t7       # Base + offset for left pixel
    add $t0, $t0, $t6       # Add Y offset
    lw $t1, 0($t0)          # Load pixel color
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If not background color, skip movement
    j move_left_continue

check_left_double_horizontal:
    sub $t7, $t5, 4         # Offset for leftmost pixel
    add $t0, $t0, $t7       # Base + offset for first pixel
    add $t0, $t0, $t6       # Add Y offset
    lw $t1, 0($t0)          # Load color of first pixel
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If first pixel is not background, skip

    sub $t7, $t7, 128       # Offset for second pixel (above first pixel)
    la $t3, GAME_BOARD
    add $t0, $t3, $t7 # Reset base + offset for second pixel
    lw $t1, 0($t0)          # Load color of second pixel
    beq $t1, $t2, skip_movement # If second pixel is not background, skip
    j move_left_continue

check_left_double_vertical:
    sub $t7, $t5, 4         # Offset for left pixel
    add $t0, $t0, $t7       # Base + offset for first pixel
    add $t0, $t0, $t6       # Add Y offset for first pixel
    lw $t1, 0($t0)          # Load color of first pixel
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If first pixel is not background, skip

    sub $t0, $t0, 128       # Offset for second pixel (below first pixel)
    lw $t1, 0($t0)          # Load color of second pixel
    bne $t1, $t2, skip_movement # If second pixel is not background, skip
    j move_left_continue

move_left_continue:
    lb $t4, pill_x          # Load current X position
    addi $t4, $t4, -1       # Decrease X position
    sb $t4, pill_x          # Save updated X position
    jr $ra                  # Return

move_right:
    la $t0, GAME_BOARD       # Load the base address of the display
    lb $t9, pill_orient     # Load pill orientation
    lb $t5, pill_x          # Load current X position
    lb $t6, pill_y          # Load current Y position
    lb $t3, pill_single     # Load pill_single variable
    sll $t5, $t5, 2         # Calculate X offset
    sll $t6, $t6, 7         # Calculate Y offset

    # Single pill
    bne $t3, $zero, check_right_single
    # Double pill (horizontal or vertical)
    beq $t9, $zero, check_right_double_horizontal
    j check_right_double_vertical

check_right_single:
    add $t7, $t5, 4         # Offset for pixel to the right
    add $t0, $t0, $t7       # Base + offset for right pixel
    add $t0, $t0, $t6       # Add Y offset
    lw $t1, 0($t0)          # Load pixel color
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If not background color, skip movement
    j move_right_continue

check_right_double_horizontal:
    add $t7, $t5, 8         # Offset for rightmost pixel
    add $t0, $t0, $t7       # Base + offset for first pixel
    add $t0, $t0, $t6       # Add Y offset
    lw $t1, 0($t0)          # Load color of first pixel
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If first pixel is not background, skip

    j move_right_continue

check_right_double_vertical:
    addi $t7, $t5, 4         # Offset for right pixel
    add $t0, $t0, $t7       # Base + offset for first pixel
    add $t0, $t0, $t6       # Add Y offset for first pixel
    lw $t1, 0($t0)          # Load color of first pixel
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If first pixel is not background, skip

    addi $t0, $t0, -128       # Offset for second pixel (above first pixel)
    lw $t1, 0($t0)          # Load color of second pixel
    bne $t1, $t2, skip_movement # If second pixel is not background, skip
    j move_right_continue

move_right_continue:
    lb $t4, pill_x          # Load current X position
    addi $t4, $t4, 1        # Increase X position
    sb $t4, pill_x          # Save updated X position
    jr $ra                  # Return

skip_movement:
    jr $ra                  # Return without updating position

# save_to_game_board()
# Saves the current pill information to the GAME_BOARD
# pill information is stored in the gameboard as follows:
# XXXXXX(cc) (xxxxxxxx) (yyyyyyyy) X(p)(s)(o)(22)(11)
# cc - the actual colour of that square location
# xxxxxxxx - pill_x
# yyyyyyyy - pill_y
# p - signifies this is a valid pill and not and empty place in memory (ie, if there is a pill in this location, it will always be 1)
# s - pill_single
# o - pill_orient
# 22 - pill_colour_2
# 11 - pill_colour_1
save_to_game_board:
    lw $t0, GAME_BOARD  # Load the address of the game_board in $t0
    addi $t1, $zero, 128  # Set $t1 to 128, this is the save data that we will be creating
    
    lb $t2, pill_colour_1    # load pill_colour_1 into $t2
    sll $t2, $t2, 16         # Shift left 24 so it matches to the correct position
    andi $t1, $t2, 67108863      # Save pill_colour_1 into the data
    
    lb $t2, pill_x          # load pill_x into $t2
    sll $t2, $t2, 16         # Shift left 16 so it matches to the correct position
    andi $t1, $t2, 67108863      # Save pill_x into the data
    
    lb $t2, pill_y          # load pill_y into $t2
    sll $t2, $t2, 8         # Shift left 8 so it matches to the correct position
    andi $t1, $t2, 67108863      # Save pill_y into the data
    
    lb $t2, pill_single     # load pill_single into $t2
    sll $t2, $t2, 5         # Shift left 5 so it matches to the correct position
    andi $t1, $t2, 67108863      # Save pill_single into the data
    
    lb $t2, pill_orient     # load pill_orient into $t2
    sll $t2, $t2, 4         # Shift left 4 so it matches to the correct position
    andi $t1, $t2, 67108863      # Save pill_orient into the data
    
    lb $t2, pill_colour_2   # load pill_colour_2 into $t2
    sll $t2, $t2, 2         # Shift left 2 so it matches to the correct position
    andi $t1, $t2, 67108863      # Save pill_colour_2 into the data
    
    lb $t2, pill_colour_1   # load pill_colour_1 into $t2
    andi $t1, $t2, 67108863      # Save pill_colour_2 into the data
    
    # Save the finished data into the gameboard based on pill_x and pill_y
    lb $t9, pill_x          # load current x pos
    lb $t8, pill_y          # load current y pos
    sll $t9, $t9, 2         # x offset in $t9
    sll $t8, $t8, 7         # y offset in $t8
    add $t0, $t0, $t9       # add x offset
    add $t0, $t0, $t8       # add y offset
    sw $t1, 0($t0)          # Save the data into the GAME_BOARD Array
    
    lb $t2, pill_single     # load pill_single into $t2
    bne $t2, $zero, save_to_game_board_end # if there is only one pill to save to the game board, end
    lb $t2, pill_colour_2    # load pill_colour_2 into $t2
    sll $t2, $t2, 16         # Shift left 24 so it matches to the correct position
    andi $t1, $t2, 67108863      # Save pill_colour_2 into the data
    
    lb $t2, pill_orient    # load pill_orient into $t2
    beq $t2, $zero, save_to_game_board_pill_hor #if the pill is horizontal, save the right square with the same information
        # pill is vertical
        
        addi $t0, $t0, -128 
        sw $t1, 0($t0)
        j save_to_game_board_end
    save_to_game_board_pill_hor:
        addi $t0, $t0, 4
        sw $t1, 0($t0)
        j save_to_game_board_end
    save_to_game_board_end:
        jr $ra  #return
        
# remove_from_game_board()
# renoves the current pill from the GAME_BOARD
remove_from_game_board:
    lw $t0, GAME_BOARD  # Load the address of the game_board in $t0
    
    # remove current pill on gameboard based on pill_x and pill_y
    lb $t9, pill_x          # load current x pos
    lb $t8, pill_y          # load current y pos
    sll $t9, $t9, 2         # x offset in $t9
    sll $t8, $t8, 7         # y offset in $t8
    add $t0, $t0, $t9       # add x offset
    add $t0, $t0, $t8       # add y offset
    sw $zero, 0($t0)        # remove pill in the GAME_BOARD Array
    
    lb $t2, pill_single     # load pill_single into $t2
    bne $t2, $zero, remove_from_game_board_end # if there is only one pill to save to the game board, end
    lb $t2, pill_orient    # load pill_orient into $t2
    beq $t2, $zero, remove_from_game_board_pill_hor #if the pill is horizontal, remove the right square 
        # pill is vertical
        addi $t0, $t0, -128 
        sw $zero, 0($t0)
        j save_to_game_board_end
    remove_from_game_board_pill_hor:
        addi $t0, $t0, 4
        sw $zero, 0($t0)
        j remove_from_game_board_end
    remove_from_game_board_end:
        jr $ra  #return
    
# get_from_game_board(x_cord, y_cord):
# Gets the pixel at the (x_cord, y_cord) pixel location in the gameboard and updates all of the pill variables to match
# $a0, x_cord (in pixels)
# $a1, y_cord (in pixels)
get_from_game_board:
    lw $t0, GAME_BOARD  # Load the address of the game_board in $t0
    sll $t9, $a0, 2         # x offset in $t9
    sll $t8, $a1, 7         # y offset in $t8
    add $t0, $t0, $t9       # add x offset
    add $t0, $t0, $t8       # add y offset
    
    lw $t1, 0($t0)                          # Load the pill data into $t1 at the specific pixel coords
    sb $zero, pill_valid                    # not sure if we have a valid pill or not
    sb $zero, pill_is_colliding             # set the current pill to not be colliding
    beq $t1, $zero, get_from_game_board_end # pill data cannot be all zeros because of the p signifier bit 
    
    andi $t2, $t1, 3        # Store pill_colour_1 data into $t2
    sb $t2, pill_colour_1   # save data
    
    srl $t1, $t1, 2         # Shift data so pill_colour_2 is next
    andi $t2, $t1, 3        # Store pill_colour_2 data into $t2
    sb $t2, pill_colour_2   # save data
    
    srl $t1, $t1, 1         # Shift data so pill_orient is next
    andi $t2, $t1, 1        # Store pill_orient data into $t2
    sb $t2, pill_orient     # save data
    
    srl $t1, $t1, 1         # Shift data so pill_single is next
    andi $t2, $t1, 1        # Store pill_single data into $t2
    sb $t2, pill_single     # save data
    
    srl $t1, $t1, 1         # Shift data so pill_valid is next
    andi $t2, $t1, 1        # Store pill_single data into $t2
    sb $t2, pill_valid      # save data
    
    srl $t1, $t1, 9         # Shift data so pill_y is next
    andi $t2, $t1, 255      # Store pill_y data into $t2
    sb $t2, pill_y          # save data
    
    srl $t1, $t1, 8         # Shift data so pill_x is next
    andi $t2, $t1, 255      # Store pill_x data into $t2
    sb $t2, pill_x          # save data
    
    get_from_game_board_end:
        jr $ra  #return

# draw_from_game_board()
# Iterates through the GAME_BOARD grid defined by bottle boundaries and draws pills or background.
draw_from_game_board:
    # Load bottle boundaries
    lw $t0, BOTTLE_TOP         # Load top boundary (y start)
    lw $t1, BOTTLE_BOTTOM      # Load bottom boundary (y end)
    lw $t2, BOTTLE_LEFT        # Load left boundary (x start)
    lw $t3, BOTTLE_RIGHT       # Load right boundary (x end)
    lw $t4, BACKGROUND_COLOUR  # Load background colour (black)

    # Outer loop: Iterate through rows (y-coordinates)
    move $t5, $t0              # Initialize row counter (current_y = top)
draw_from_game_board_row_loop:
    beq $t5, $t1, draw_from_game_board_end # Stop when we reach bottom boundary

    # Inner loop: Iterate through columns (x-coordinates)
    move $t6, $t2              # Initialize column counter (current_x = left)
draw_from_game_board_col_loop:
    beq $t6, $t3, draw_from_game_board_next_row # Move to the next row when at the right boundary

    # Retrieve game board data for (current_x, current_y)
    addi $a0, $t6, 0           # $a0 = current_x
    addi $a1, $t5, 0           # $a1 = current_y
    jal get_from_game_board    # Load pill data into pill_* variables

    # Check if there's a pill at this location
    lb $t7, pill_single        # Load pill_single (non-zero if there's a pill)
    beq $t7, $zero, draw_background # If no pill, draw background

    # Set pill_x and pill_y to the current position
    sb $t6, pill_x             # pill_x = current_x
    sb $t5, pill_y             # pill_y = current_y

    # Draw the pill
    jal draw_pill
    j draw_from_game_board_next_col # Move to the next column

draw_background:
    # Draw a black square at (current_x, current_y)
    lw $t8, GAME_BOARD          # Load game board
    sll $t9, $t6, 2            # Calculate x offset
    sll $t2, $t5, 7           # Calculate y offset
    add $t8, $t8, $t9          # Add x offset
    add $t8, $t8, $t2         # Add y offset
    sw $t4, 0($t8)             # Write black (BACKGROUND_COLOUR) to the screen

draw_from_game_board_next_col:
    addi $t6, $t6, 1           # Increment column counter
    j draw_from_game_board_col_loop # Repeat inner loop

draw_from_game_board_next_row:
    addi $t5, $t5, 1           # Increment row counter
    j draw_from_game_board_row_loop # Repeat outer loop

draw_from_game_board_end:
    jr $ra                     # Return


# detect_matches()
# detects the 4+ vertical and horizontal matches
# moves the pills to the correct location following the matches
detect_matches:
    lw $t0, GAME_BOARD  # Load the address of the game board in $t0
    
    addi $t1, $zero, 12  # Set $t1 to the current x offset that we are checking (in px)
    addi $t2, $zero, 9  # Set $t2 to the current y offset that we are checking (in px)
    detect_matches_row:
        addi $t9, $zero, 25 # store 25 in $t9
        bge $t2, $t9, detect_matches_end   # while y <= 15 (25 - 9 = 16)
        detect_matches_row_square:
            addi $t9, $zero, 20 #store 20 in $t9
            bge $t1, $t9, detect_matches_row_end   # while x <= 7 (20 - 12 = 8)
            sll $t9, $t1, 2
            sll $t8, $t2, 7
            add $t7, $t9, $t0
            add $t7, $t7, $t8
            lw $t7, 0($t7)
            beq $t7, $zero, detect_matches_row_end # ... and board[x,y] != black
            
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
            
            add $a0, $t1, $zero        # set the first argument of the function (x)
            add $a1, $t2, $zero        # set the second argument of the function (y)
            add $a2, $t0, $zero        # set the second argument of the function (board)
            jal detect_horizontal_connection
            add $t3, $zero, $v0         # save the returned connection length value from the horizontal function in $t3 (in px)
            
            lw $t2, 0($sp)				# Pop y off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t1, 0($sp)				# Pop x off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t0, 0($sp)				# Pop board off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $ra, 0($sp)				# Pop $ra off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
            
            add $a0, $t1, $zero        # set the first argument of the function (x)
            add $a1, $t2, $zero        # set the second argument of the function (y)
            add $a2, $t0, $zero        # set the second argument of the function (board)
            jal detect_vertical_connection
            add $t4, $zero, $v0         # save the returned connection length value from the vertical function in $t4 (in px)
            
            lw $t2, 0($sp)				# Pop y off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t1, 0($sp)				# Pop x off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t0, 0($sp)				# Pop board off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $ra, 0($sp)				# Pop $ra off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            
            add $t5, $zero, $zero      # iteratior initialized to zero in $t5
            detect_matches_horziontal_clear_loop:
                bge $t5, $t3, detect_matches_vertical_clear_loop # while i < horizontal connection length
                
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t3, 0($sp)              # Push horizontal match onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t4, 0($sp)              # Push vertical match onto the stack, to keep it safe
                
                add $a0, $t1, $t5          # set the first argument of the function (x + i)
                add $a1, $t2, $zero        # set the second argument of the function (y)
                add $a2, $t0, $zero        # set the second argument of the function (board)
                jal clear_pill
                
                lw $t4, 0($sp)				# Pop vertical match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t3, 0($sp)				# Pop horizontal match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t2, 0($sp)				# Pop y off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t1, 0($sp)				# Pop x off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t0, 0($sp)				# Pop board off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $ra, 0($sp)				# Pop $ra off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                
                addi $t5, $t5, 1            # i += 1
                j detect_matches_horziontal_clear_loop
            
            detect_matches_vertical_clear_loop:
                bge $t5, $t4, detect_matches_clear_end # while i < vertical connection length
                
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t3, 0($sp)              # Push horizontal match onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t4, 0($sp)              # Push vertical match onto the stack, to keep it safe
                
                add $a0, $t1, $zero         # set the first argument of the function (x)
                add $a1, $t2, $t5           # set the second argument of the function (y + i)
                add $a2, $t0, $zero        # set the second argument of the function (board)
                jal clear_pill
                
                lw $t4, 0($sp)				# Pop vertical match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t3, 0($sp)				# Pop horizontal match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t2, 0($sp)				# Pop y off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t1, 0($sp)				# Pop x off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t0, 0($sp)				# Pop board off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $ra, 0($sp)				# Pop $ra off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                
                addi $t5, $t5, 1            # i += 1
                j detect_matches_vertical_clear_loop
        
        detect_matches_clear_end:
            addi $t9, $zero, 12  # load the left bound of x
            beq $t1, $t9, detect_matches_left_skip # if x != 0
            
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t3, 0($sp)              # Push horizontal match onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t4, 0($sp)              # Push vertical match onto the stack, to keep it safe
            
            addi $a0, $t1, -1           # set the first argument of the function (x - 1)
            add $a1, $t2, $zero         # set the second argument of the function (y)
            jal drop_pill_and_above
            
            lw $t4, 0($sp)				# Pop vertical match off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t3, 0($sp)				# Pop horizontal match off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t2, 0($sp)				# Pop y off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t1, 0($sp)				# Pop x off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t0, 0($sp)				# Pop board off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $ra, 0($sp)				# Pop $ra off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            
            addi $t5, $zero, 0          # set $t5 to be the iterator starting at 0
            detect_matches_vetical_left_loop:
                bge $t5, $t4, detect_matches_left_skip # while i < length of vertical match
                
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t3, 0($sp)              # Push horizontal match onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t4, 0($sp)              # Push vertical match onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t5, 0($sp)              # Push iterator onto the stack, to keep it safe
                
                addi $a0, $t1, -1           # set the first argument of the function (x - 1)
                add $a1, $t2, $t5         # set the second argument of the function (y + i)
                jal drop_pill_and_above
                
                lw $t5, 0($sp)				# Pop iterator off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t4, 0($sp)				# Pop vertical match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t3, 0($sp)				# Pop horizontal match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t2, 0($sp)				# Pop y off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t1, 0($sp)				# Pop x off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t0, 0($sp)				# Pop board off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $ra, 0($sp)				# Pop $ra off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                
                j detect_matches_vetical_left_loop
                
        detect_matches_left_skip:
            addi $t9, $zero, 19     # load the right bound of x + horizontal match
            add $t8, $t1, $t3       # load x + r into $t8
            bge $t8, $t9, detect_matches_right_skip # if x + r < 8
            
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t3, 0($sp)              # Push horizontal match onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t4, 0($sp)              # Push vertical match onto the stack, to keep it safe
            
            add $a0, $t1, $t3            # set the first argument of the function (x + r)
            add $a1, $t2, $zero          # set the second argument of the function (y)
            jal drop_pill_and_above
            
            lw $t4, 0($sp)				# Pop vertical match off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t3, 0($sp)				# Pop horizontal match off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t2, 0($sp)				# Pop y off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t1, 0($sp)				# Pop x off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t0, 0($sp)				# Pop board off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $ra, 0($sp)				# Pop $ra off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            
            addi $t5, $zero, 0          # set $t5 to be the iterator starting at 0
            detect_matches_vetical_right_loop:
                bge $t5, $t4, detect_matches_right_skip # while i < length of vertical match
                
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t3, 0($sp)              # Push horizontal match onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t4, 0($sp)              # Push vertical match onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t5, 0($sp)              # Push iterator onto the stack, to keep it safe
                
                add $a0, $t1, $t3            # set the first argument of the function (x + r)
                add $a1, $t2, $t5           # set the second argument of the function (y + i)
                jal drop_pill_and_above
                
                lw $t5, 0($sp)				# Pop iterator off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t4, 0($sp)				# Pop vertical match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t3, 0($sp)				# Pop horizontal match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t2, 0($sp)				# Pop y off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t1, 0($sp)				# Pop x off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t0, 0($sp)				# Pop board off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $ra, 0($sp)				# Pop $ra off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                
                j detect_matches_vetical_right_loop
        
        detect_matches_right_skip:
            addi $t9, $zero, 8  # load the top bound of y
            ble $t2, $t9, detect_matches_row_end # if y > 0
            
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t3, 0($sp)              # Push horizontal match onto the stack, to keep it safe
            addi $sp, $sp, -4           # Move stack pointer to empty location
            sw $t4, 0($sp)              # Push vertical match onto the stack, to keep it safe
            
            addi $a0, $t1, 0           # set the first argument of the function (x)
            addi $a1, $t2, -1         # set the second argument of the function (y - 1)
            jal drop_pill_and_above
            
            lw $t4, 0($sp)				# Pop vertical match off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t3, 0($sp)				# Pop horizontal match off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t2, 0($sp)				# Pop y off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t1, 0($sp)				# Pop x off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $t0, 0($sp)				# Pop board off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            lw $ra, 0($sp)				# Pop $ra off the stack
            addi $sp, $sp, 4			# Move stack pointer to top element on stack
            
            addi $t5, $zero, 0          # set $t5 to be the iterator starting at 0
            detect_matches_horizontal_loop:
                bge $t5, $t3, detect_matches_row_end # while i < length of horizontal match
                
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t0, 0($sp)              # Push board onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t1, 0($sp)              # Push x onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t2, 0($sp)              # Push y onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t3, 0($sp)              # Push horizontal match onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t4, 0($sp)              # Push vertical match onto the stack, to keep it safe
                addi $sp, $sp, -4           # Move stack pointer to empty location
                sw $t5, 0($sp)              # Push iterator onto the stack, to keep it safe
                
                add $a0, $t1, $t5            # set the first argument of the function (x + i)
                addi $a1, $t2, -1         # set the second argument of the function (y - 1)
                jal drop_pill_and_above
                
                lw $t5, 0($sp)				# Pop iterator off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t4, 0($sp)				# Pop vertical match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t3, 0($sp)				# Pop horizontal match off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t2, 0($sp)				# Pop y off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t1, 0($sp)				# Pop x off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $t0, 0($sp)				# Pop board off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                lw $ra, 0($sp)				# Pop $ra off the stack
                addi $sp, $sp, 4			# Move stack pointer to top element on stack
                
                j detect_matches_horizontal_loop
            
            
        detect_matches_row_end:
            addi $t1, $zero, 12  # set x back to zeroth position
            addi $t2, $t2, 1    # move y to the next row
            j detect_matches_row # start checking matches in the next row
        
    detect_matches_end:
        jr $ra  #return
            
# detect_horizontal_connection(x, y, board) -> connection length
# Detect the length of the horizontal connection for a given x and y value
# $a0 - x value in px
# $a1 - y value in px
# $a2 - top left square of the game board
# $v0 - return value, length of connection in px
detect_horizontal_connection:
    addi $t0, $zero, 0  # current length of the connection in  $t0
    sll $t9, $a0, 2     # multiply the x value by 4
    sll $t8, $a1, 7     # multiply the y valye by 128
    add $t1, $a2, $t9   # make $t1 the position of the square we start off at
    add $t1, $t1, $t8
    lw $t1, 0($t1)  # make $t1 the the full square information
    and $t1, $t1, 50331712  # bit mask to only grab the colour (also grabs wether it is a pill or not)
    
    detect_horizontal_connection_loop:
        addi $t9, $zero, 8 #store 8 in $t9
        bge $a0, $t9, detect_horizontal_connection_loop_end   # while x <= 7
        sll $t9, $a0, 2     # multiply the x value by 4
        sll $t8, $a1, 7     # multiply the y valye by 128
        add $t2, $a2, $t9   # make $t2 the position of the square we are currently at
        add $t2, $t2, $t8
        lw $t2, 0($t2)  # make $t2 the colour we are currently at
        bne $t1, $t2, detect_horizontal_connection_loop_end # ... and display[x,y] == colour
        addi $a0, $a0, 1    # move to the next pixel
        addi $t0, $t0, 1    # increase our current length by 1
        j detect_horizontal_connection_loop # continue looping
        
    detect_horizontal_connection_loop_end:
        addi $t9, $zero, 3 #store 4 in $t9
        ble $t0, $t9, detect_horizontal_connection_end  # if current length >= 4
        addi $v0, $t0, 0  # return current length
        jr $ra
        
    detect_horizontal_connection_end:
        addi $v0, $zero, 0  # return 0
        jr $ra
        
# detect_horizontal_connection(x, y, board) -> connection length
# Detect the length of the horizontal connection for a given x and y value
# $a0 - x value in px
# $a1 - y value in px
# $a2 - top left square of the game board
# $v0 - return value, length of connection in px
detect_vertical_connection:
    addi $t0, $zero, 0  # current length of the connection in  $t0
    sll $t9, $a0, 2     # multiply the x value by 4
    sll $t8, $a1, 7     # multiply the y value by 128
    add $t1, $a2, $t9   # make $t1 the position of the square we start off at
    add $t1, $t1, $t8
    lw $t1, 0($t1)  # make $t1 the the full square information
    and $t1, $t1, 50331712  # bit mask to only grab the colour (also grabs wether it is a pill or not)
    
    detect_vertical_connection_loop:
        addi $t9, $zero, 16 #store 8 in $t9
        bge $a1, $t9, detect_vertical_connection_loop_end   # while y <= 15
        sll $t9, $a0, 2     # multiply the x value by 4
        sll $t8, $a1, 7     # multiply the y valye by 128
        add $t2, $a2, $t9   # make $t2 the position of the square we are currently at
        add $t2, $t2, $t8
        lw $t2, 0($t2)  # make $t2 the colour we are currently at
        bne $t1, $t2, detect_vertical_connection_loop_end # ... and display[x,y] == colour
        addi $a1, $a1, 1    # move to the next pixel down
        addi $t0, $t0, 1    # increase our current length by 1
        j detect_vertical_connection_loop # continue looping
        
    detect_vertical_connection_loop_end:
        addi $t9, $zero, 3 #store 4 in $t9
        ble $t0, $t9, detect_vertical_connection_end  # if current length >= 4
        addi $v0, $t0, 0  # return current length
        jr $ra
        
    detect_vertical_connection_end:
        addi $v0, $zero, 0  # return 0
        jr $ra

# clear_pill(x, y, board)
# this pill has been cleared by the player, remove it from the gameboard accourdinly and update the pill information to reflect it
# $a0 - x value in px
# $a1 - y value in px
# $a2 - top left square of the game board (0,0) on the playable surface
clear_pill:
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $a0, 0($sp)              # Push x onto the stack, to keep it safe
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $a1, 0($sp)              # Push y onto the stack, to keep it safe
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $a2, 0($sp)              # Push board onto the stack, to keep it safe
    
    jal get_from_game_board
    
    lw $a2, 0($sp)				# Pop board off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    lw $a1, 0($sp)				# Pop y off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    lw $a0, 0($sp)				# Pop x off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    lw $ra, 0($sp)				# Pop $ra off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    
    lb $t0, pill_single         # load pill_single into $t0
    bne $t0, $zero, clear_pill_end # if pill is not single
    
    lb $t0, pill_x         # load pill_x into $t0
    lb $t1, pill_y         # load pill_y into $t1
    
    bne $t0, $a0, pill_clear_not_main_location
    bne $t1, $a1, pill_clear_not_main_location  # if pill_x == x && pill_y == y
    
    # adjust new single_pill
    addi $t0, $t0, 1
    lb $t9, pill_orient
    sub $t0, $t0, $t9
    sb $t0, pill_x
    
    sub $t1, $t1, $t9
    sb $t1, pill_y
    
    addi $t9, $zero, 1
    sb $t9, pill_single
    
    lb $t0, pill_colour_2   # set pill colour 1 to colour 2
    sb $t0, pill_colour_1
    
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
    
    jal save_to_game_board
    
    lw $ra, 0($sp)				# Pop $ra off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    
    j clear_pill_end
    
    pill_clear_not_main_location:
        addi $t9, $zero, 1
        sb $t9, pill_single
        
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
        
        jal save_to_game_board
        
        lw $ra, 0($sp)				# Pop $ra off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        
        j clear_pill_end

    clear_pill_end:
        sll $t9, $a0, 2     # multiply the x value by 4
        sll $t8, $a1, 7     # multiply the y value by 128
        add $t1, $a2, $t9   # make $t1 the position of the square we start off at
        add $t1, $t1, $t8
        sw $zero, 0($t1)    # board[x,y] = empty
        jr $ra
        
# drop_pill_and_above(x,y)
# drops the pill at the x and y location and also all of the pills above that pill
# $a0 - x location in px
# $a1 - y location in px
drop_pill_and_above:
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
    
    jal get_from_game_board
    
    lw $ra, 0($sp)				# Pop $ra off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack

    lb $t0, pill_valid
    beq $t0, $zero, drop_pill_and_above_not_valid   # if pill is valid
    
    drop_pill_and_above_move_down:
        lb $t0, pill_is_colliding
        bne $t0, $zero, drop_pill_and_above_move_down_done # while pill is not colliding
        jal move_down # move the pill down
        j drop_pill_and_above_move_down
        
    drop_pill_and_above_move_down_done:
        lb $t0, pill_single
        bne $t0, $zero, drop_pill_and_above_not_single # if pill is single
        
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a0, 0($sp)              # Push x onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a1, 0($sp)              # Push y onto the stack, to keep it safe
        
        addi $a0, $a0, 0            
        addi $a1, $a1, -1            
        jal drop_pill_and_above     # drop_pill_and_above(x, y - 1)
        
        lw $a1, 0($sp)				# Pop y off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $a0, 0($sp)				# Pop x off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $ra, 0($sp)				# Pop $ra off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        
        jr $ra  # return
        
    drop_pill_and_above_not_single:
        lb $t0, pill_orient
        bne $t0, $zero, drop_pill_and_above_not_horizontal  #if pill is horizontal
        
         addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a0, 0($sp)              # Push x onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a1, 0($sp)              # Push y onto the stack, to keep it safe
        
        addi $a0, $a0, 0            
        addi $a1, $a1, -1            
        jal drop_pill_and_above     # drop_pill_and_above(x, y - 1)
        
        lw $a1, 0($sp)				# Pop y off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $a0, 0($sp)				# Pop x off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $ra, 0($sp)				# Pop $ra off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a0, 0($sp)              # Push x onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a1, 0($sp)              # Push y onto the stack, to keep it safe
        
        addi $a0, $a0, 1            
        addi $a1, $a1, -1            
        jal drop_pill_and_above     # drop_pill_and_above(x + 1, y - 1)
        
        lw $a1, 0($sp)				# Pop y off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $a0, 0($sp)				# Pop x off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $ra, 0($sp)				# Pop $ra off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        
        jr $ra  # return
        
    drop_pill_and_above_not_horizontal:
        # pill is vertical
        
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a0, 0($sp)              # Push x onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a1, 0($sp)              # Push y onto the stack, to keep it safe
        
        addi $a0, $a0, 0            
        addi $a1, $a1, -2            
        jal drop_pill_and_above     # drop_pill_and_above(x, y - 2)
        
        lw $a1, 0($sp)				# Pop y off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $a0, 0($sp)				# Pop x off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $ra, 0($sp)				# Pop $ra off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
            
    drop_pill_and_above_not_valid:
        jr $ra