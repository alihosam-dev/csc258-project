
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
#2
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
    lw $t0, GAME_BOARD       # Load the base address of the display
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
    lw $t0, GAME_BOARD       # Load the base address of the display
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
    bne $t1, $t2, skip_movement # If not background color, skip movement
    j move_down_continue

check_down_double_horizontal:
    # Check the first (left) segment
    add $t7, $t6, 128       # Offset for pixels below
    add $t0, $t0, $t7       # Base + offset for below row
    add $t0, $t0, $t5       # Add X offset for first pixel
    lw $t1, 0($t0)          # Load color of first pixel
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If first pixel is not background, skip

    # Check the second (right) segment
    add $t0, $t0, 4         # Offset for the right segment
    lw $t1, 0($t0)          # Load color of second pixel
    bne $t1, $t2, skip_movement # If second pixel is not background, skip
    j move_down_continue

check_down_double_vertical:
    # Check the bottommost segment of the vertical pill
    add $t7, $t6, 128       # Offset for bottommost pixel
    add $t0, $t0, $t7       # Base + offset for below pixel
    add $t0, $t0, $t5       # Add X offset
    lw $t1, 0($t0)          # Load pixel color
    lw $t2, BACKGROUND_COLOUR
    bne $t1, $t2, skip_movement # If not background color, skip movement
    j move_down_continue

move_down_continue:
    lb $t4, pill_y          # Load current Y position
    addi $t4, $t4, 1        # Increase Y position
    sb $t4, pill_y          # Save updated Y position
    jr $ra                  # Return

move_left:
    lw $t0, ADDR_DSPL       # Load the base address of the display
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
    lw $t3, ADDR_DSPL
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
    lw $t0, ADDR_DSPL       # Load the base address of the display
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
# XXXXXXXX (xxxxxxxx) (yyyyyyyy) X(p)(s)(o)(22)(11)
# xxxxxxxx - pill_x
# yyyyyyyy - pill_y
# p - signifies this is a valid pill and not and empty place in memory (ie, if there is a pill in this location, it will always be 1)
# s - pill_single
# o - pill_orient
# 22 - pill_colour_2
# 11 - pill_colour_1
save_to_game_board:
    lw $t0, GAME_BOARD  # Load the address of the game_board in $t0
    addi $t1, $zero, 16777215  # Set $t1 to 128, this is the save data that we will be creating
    
    lb $t2, pill_x          # load pill_x into $t2
    sll $t2, $t2, 16         # Shift left 16 so it matches to the correct position
    andi $t1, $t2, 16777215      # Save pill_x into the data
    
    lb $t2, pill_y          # load pill_y into $t2
    sll $t2, $t2, 8         # Shift left 8 so it matches to the correct position
    andi $t1, $t2, 16777215      # Save pill_y into the data
    
    lb $t2, pill_single     # load pill_single into $t2
    sll $t2, $t2, 5         # Shift left 5 so it matches to the correct position
    andi $t1, $t2, 16777215      # Save pill_single into the data
    
    lb $t2, pill_orient     # load pill_orient into $t2
    sll $t2, $t2, 4         # Shift left 4 so it matches to the correct position
    andi $t1, $t2, 16777215      # Save pill_orient into the data
    
    lb $t2, pill_colour_2   # load pill_colour_2 into $t2
    sll $t2, $t2, 2         # Shift left 2 so it matches to the correct position
    andi $t1, $t2, 16777215      # Save pill_colour_2 into the data
    
    lb $t2, pill_colour_1   # load pill_colour_1 into $t2
    andi $t1, $t2, 16777215      # Save pill_colour_2 into the data
    
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
    andi $t2, $t1, 1        # Store pill_orient data into $t2
    sb $t2, pill_single     # save data
    
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


    
