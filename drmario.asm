
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
    lb $t9, pill_orient         # Load pill orientation
    lb $t5, pill_x              # Load current X position
    addi $t6, $t5, 1            # Calculate next X position
    addi $t6, $t6, 1            # If vertical, add width for right edge
    lw $t7, BOTTLE_RIGHT        # Load right boundary
    xori $t9, $t9, 1
    bne $t9, $zero, rotate_colour_swap_skip # if we roate and our orientation goes back to zero, we know we have to swap the colours of the current pill, if not, we skip the swapping 
        lb $t0, pill_colour_1   # Swap Colours
        lb $t1, pill_colour_2   # |
        sb $t0, pill_colour_2   # |
        sb $t1, pill_colour_1   # |
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
        


