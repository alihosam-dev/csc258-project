
    .data
BOTTLE_TOP: .word 8            # Top boundary of the bottle (y-coordinate)
BOTTLE_BOTTOM: .word 24        # Bottom boundary of the bottle (y-coordinate)
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
FRAME_RATE: .word 16 # Frame rate in 1/(frame rate) x 100 where frame rate is fps 
GAME_BOARD: .space 4096 # Allocate 4096 bytes for the game board (32x32) x 4 (for each word)

# Game Colours
BOTTLE_COLOUR: .word 0x808080
BACKGROUND_COLOUR: .word 0x000000
PILL_RED: .word 0xFF0000
PILL_BLUE: .word 0x0000FF
PILL_YELLOW: .word 0xFFFF00
VIRUS_RED: .word 0xA83832
VIRUS_BLUE: .word 0x323AA8
VIRUS_YELLOW: .word 0xA89E32 
PREV_CAPSULE_X: .word 15     # Previous X position of capsule
PREV_CAPSULE_Y: .word 5      # Previous Y position of capsule

gravity_speed_increaser: .word 300
gravity_speed_counter: .word 0

# frame data
INPUT_FRAME_DELAY: .byte 2

##############################################################################
# Mutable Data
##############################################################################

# Game State Data 
game_state: .byte 0     # represents what state the game is currently in
                        # 0 - Start screen
                        # 1 - playing
                        # 2 - paused
                        # 3 - end screen
total_virus: .byte 1

# Pill Data
pill_colour_1: .byte 0 # colour of square 1 of pill (0-2)
pill_colour_2: .byte 0 # colour of square 2 of pill (0-2) 
pill_x: .byte 15 # X coord of pill in pixels
pill_y: .byte 8 # Y coord of pill in pixels
pill_orient: .byte 0 # orientation of pill, 0 = horizontal, 1 = vertical
pill_single: .byte 1 # is the pill only a single square (0=no, 1=yes)
pill_is_colliding: .byte 0 # 1 if the pill is colliding, 0 if not
pill_valid: .byte 0      # 1 if the pill is a pill, 0 if the pulled pill is not a pill
pill_is_virus: .byte 0  # 1 if the pill is a virus, 0 if not

# Virus Data
intitial_virus_count: .byte 4

# Frame Counter
input_frame_counter: .byte 0  # current frame 

# Gravity data
gravity_clock: .byte 20  
gravity_counter: .byte 0

# Start Menu Values
start_menu_selector_x: .byte 8 
start_menu_selector_y: .byte 4

##############################################################################
# Code
##############################################################################s
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    
    jal game_state_0_init
    
game_loop:
    lb $t0, game_state
    addi $t1, $zero, 0
    bne $t0, $t1, game_state_0_skip
    # Game State 0
    
    # Check for keypress
    lw $t0, ADDR_KBRD          # Load keyboard base address
    lw $t1, 0($t0)             # Read keyboard state
    beq $t1, $zero, menu_input_skip  # If no key is pressed, continue loop
    
    lw $t2, 4($t0)             # Load key code
    
    addi $sp, $sp, -4           
    sw $t2, 0($sp)  
    
    # Remove the selector
    lw $t0, ADDR_DSPL
    lb $a0, start_menu_selector_x
    lb $a1, start_menu_selector_y
    addi $a2, $zero, 2
    li $a3, 0x000000
    jal draw_hor_line
    
    lw $t2, 0($sp)  
    addi $sp, $sp, 4       
    
    lb $t8, start_menu_selector_x
    lb $t9, start_menu_selector_y
    
    # Handle input
    li $t3, 0x64               # ASCII for 'd'
    bne $t2, $t3, menu_d_skip
    li $t5, 4 
    bne $t9, $t5, menu_d_not_row_1
    addi $t8, $t8, 7
    sb $t8, start_menu_selector_x
    
    lb $t9, gravity_speed_increaser
    addi $t9, $t9, 100
    sb $t9, gravity_speed_increaser
    
    lb $t9, intitial_virus_count
    addi $t9, $t9, 6
    sb $t9, intitial_virus_count
    
    lb $t9, gravity_clock
    addi $t9, $t9, -4
    sb $t9, gravity_clock
    
    
    menu_d_not_row_1:
    li $t5, 12 
    bne $t9, $t5, menu_d_not_row_2
    lb $t6, intitial_virus_count
    addi $t6, $t6, 2
    sb $t6, intitial_virus_count
    menu_d_not_row_2:
    li $t5, 20 
    bne $t9, $t5, menu_d_not_row_3
    lb $t6, gravity_clock
    addi $t6, $t6, 4
    sb $t6, gravity_clock
    menu_d_not_row_3:
    
    menu_d_skip:
    li $t3, 0x61               # ASCII for 'a'
    bne $t2, $t3, menu_a_skip
    li $t5, 4 
    bne $t9, $t5, menu_a_not_row_1
    addi $t8, $t8, -7
    sb $t8, start_menu_selector_x
    
    lb $t9, gravity_speed_increaser
    addi $t9, $t9, -100
    sb $t9, gravity_speed_increaser
    
    lb $t9, intitial_virus_count
    addi $t9, $t9, -6
    sb $t9, intitial_virus_count
    
    lb $t9, gravity_clock
    addi $t9, $t9, 4
    sb $t9, gravity_clock
    
    menu_a_not_row_1:
    li $t5, 12 
    bne $t9, $t5, menu_a_not_row_2
    lb $t6, intitial_virus_count
    addi $t6, $t6, -2
    sb $t6, intitial_virus_count
    menu_a_not_row_2:
    li $t5, 20 
    bne $t9, $t5, menu_a_not_row_3
    lb $t6, gravity_clock
    addi $t6, $t6, -4
    sb $t6, gravity_clock
    menu_a_not_row_3:
    
    menu_a_skip:
    li $t3, 0x73               # ASCII for 's'
    bne $t2, $t3, menu_s_skip
    addi $t9, $t9, 8
    li $t6, 8
    sb $t6, start_menu_selector_x
    sb $t9, start_menu_selector_y
    
    li $t6, 20
    ble $t9, $t6, menu_update_game_state_skip
    lb $t0, game_state
    addi $t0, $t0, 1
    sb $t0, game_state
    menu_update_game_state_skip:  
    menu_s_skip:
    
    menu_input_skip:
    
    # Draw the selector
    lw $t0, ADDR_DSPL
    lb $a0, start_menu_selector_x
    lb $a1, start_menu_selector_y
    addi $a2, $zero, 2
    li $a3, 0xFFFFFF
    jal draw_hor_line
    
    # Remove Virus Value
    lw $t0, ADDR_DSPL
    li $a0, 13
    li $a1, 15
    li $a2, 20
    li $a3, 0
    jal draw_hor_line
    
    # Remove Virus Value
    lw $t0, ADDR_DSPL
    li $a0, 13
    li $a1, 23
    li $a2, 20
    li $a3, 0
    jal draw_hor_line
    
    # Draw Virus Value
    lw $t0, ADDR_DSPL
    li $a0, 13
    li $a1, 15
    lb $t1, intitial_virus_count
    srl $a2, $t1, 1
    li $a3, 0xFFFFFF
    jal draw_hor_line
    
    # Draw Virus Value
    lw $t0, ADDR_DSPL
    li $a0, 13
    li $a1, 23
    lb $t1, gravity_clock
    srl $a2, $t1, 2
    li $a3, 0xFFFFFF
    jal draw_hor_line
    
    li $v0, 32          # Sleep
    lw $a0, FRAME_RATE  # sleep for frame rate amount of time
    syscall 
    
    lb $t0, game_state
    beq $t0, $zero, menu_change_game_state_skip
    
    jal game_state_1_init
    
    menu_change_game_state_skip:
    j game_loop
    
    
    game_state_0_skip:
    addi $t1, $zero, 1
    bne $t0, $t1, game_state_1_skip
    # Game State 1

    lb $t9, total_virus
    bne $t9, $zero, level_complete_skip
    # move back to menu
    
    jal game_state_0_init
    lb $t0, game_state
    addi $t0, $t0, -1
    sb $t0, game_state
    
    # Level Complete Sound
    li $v0, 31
    li $a0, 95
    li $a1, 50
    li $a2, 110
    li $a3, 2000
    syscall
    j game_loop
    
    level_complete_skip:
    
    lb $t9, input_frame_counter
    lb $t8, INPUT_FRAME_DELAY
    ble $t9, $t8, input_frame_skip
    sb $zero, input_frame_counter
    
    #update gravity speed if needed
    lw $t9, gravity_speed_counter
    lw $t8, gravity_speed_increaser
    bne $t9, $t8, gravity_speed_skip
    sw $zero, gravity_speed_counter
    lb $t7, gravity_clock
    addi $t7, $t7, -1
    bne $t7, $zero, gravity_min_skip
    addi $t7, $zero, 1
    gravity_min_skip:
    sb $t7, gravity_clock
    gravity_speed_skip:
    lw $t9, gravity_speed_counter
    addi $t9, $t9, 1
    sw $t9, gravity_speed_counter
    
    # Check for keypress
    lw $t0, ADDR_KBRD          # Load keyboard base address
    lw $t1, 0($t0)             # Read keyboard state
    beq $t1, $zero, move_right_skip  # If no key is pressed, continue loop
    
    # Save the current position as the previous position
    lb $t2, pill_x
    sw $t2, PREV_CAPSULE_X
    lb $t3, pill_y
    sw $t3, PREV_CAPSULE_Y
    
    # Get the key code
    lw $t2, 4($t0)             # Load key code
    
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $t2, 0($sp)  
    
    jal remove_from_game_board
    
    lw $t2, 0($sp)  
    addi $sp, $sp, 4           # Move stack pointer to t2
    
    # Check for 'q' (quit)
    li $t3, 0x71               # ASCII for 'w'
    bne $t2, $t3, quit_skip
    li $v0, 10
    syscall
    quit_skip:
    
    # Check for 'w' (up)
    li $t3, 0x77               # ASCII for 'w'
    bne $t2, $t3, rotate_skip
    
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $t2, 0($sp) 
    
    jal rotate
    
    lw $t2, 0($sp)  
    addi $sp, $sp, 4           # Move stack pointer to t2
    
     # Rotate Sound
    li $v0, 31
    li $a0, 90
    li $a1, 50
    li $a2, 120
    li $a3, 100
    syscall
    rotate_skip:
    
    # Check for 's' (down)
    li $t3, 0x73               # ASCII for 's'
    bne $t2, $t3, move_down_skip
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $t2, 0($sp) 

    jal move_down
    
    lw $t2, 0($sp)  
    addi $sp, $sp, 4           # Move stack pointer to t2
    
    # Move_down Sound
    li $v0, 31
    li $a0, 40
    li $a1, 50
    li $a2, 70
    li $a3, 100
    syscall
    
    move_down_skip:

    # Check for 'a' (left)
    li $t3, 0x61               # ASCII for 'a'
    bne $t2, $t3, move_left_skip
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $t2, 0($sp) 
    
    jal move_left
    
    lw $t2, 0($sp)  
    addi $sp, $sp, 4           # Move stack pointer to t2
    
    move_left_skip:

    # Check for 'd' (right)
    li $t3, 0x64               # ASCII for 'd'
    bne $t2, $t3, move_right_skip
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $t2, 0($sp) 
    
    jal move_right

    lw $t2, 0($sp)  
    addi $sp, $sp, 4           # Move stack pointer to t2
    
    move_right_skip:
    
    lb $t9, gravity_clock
    lb $t8, gravity_counter
    ble $t8, $t9, gravity_skip 
    #gravity
    sb $zero, gravity_counter
    jal remove_from_game_board
    jal move_down
    gravity_skip:
	lb $t8, gravity_counter
	addi $t8, $t8, 1
	sb $t8, gravity_counter
	
	jal save_to_game_board
    
    input_frame_skip:
    lb $t9, input_frame_counter
    addi $t9, $t9, 1
    sb $t9, input_frame_counter
    lb $t0, pill_is_colliding
    beq $t0, $zero, pill_colliding_skip
    jal detect_matches
    # get total virsus
    jal get_total_virus
    jal new_pill
    
    pill_colliding_skip:

    jal draw_from_game_board
    
    li $v0, 32          # Sleep
    lw $a0, FRAME_RATE  # sleep for frame rate amount of time
    syscall 
    
    # 5. Go back to Step 1
    j game_loop
    
    game_state_1_skip:
    
    
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
        
        
        
# add_random_virus(number_of_viruses)
# adds number_of_viruses viruses to the gameboard
# $a3 - number_of_viruses
add_random_virus:
    beq $a3, $zero, add_random_virus_end
    
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
    sb $t0, pill_is_virus
    
    # get random colour (0-2), store in $a0
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    sb $a0, pill_colour_1
    
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
    
    jal save_to_game_board
    
    lw $ra, 0($sp)				# Pop $ra off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    
    addi $a3, $a3, -1
    j add_random_virus
    
    add_random_virus_end:
        jr $ra 
        
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
    bne $t9, $zero, rotate_continue_flip_skip
    lb $t0, pill_colour_1   # Load pill_colour_1
    lb $t1, pill_colour_2   # Load pill_colour_2
    sb $t0, pill_colour_2   # Store pill_colour_1 into pill_colour_2
    sb $t1, pill_colour_1   # Store pill_colour_2 into pill_colour_1
    rotate_continue_flip_skip:
    jr $ra                  # Return

move_down:
    la $t0, GAME_BOARD       # Load the base address of the display
    lb $t9, pill_orient     # Load pill orientation
    lb $t5, pill_x          # Load current X position
    lb $t6, pill_y          # Load current Y position
    lb $t3, pill_single     # Load pill_single variable
    lb $t7, pill_is_virus
    sll $t5, $t5, 2         # Calculate X offset
    sll $t6, $t6, 7         # Calculate Y offset
    
    bne $t7, $zero, change_pill_collision # if the pill is a virus, dont move it down
    
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
# XXXXXX(cc) (xxxxxxxx) (yyyyyyyy) (v)(p)(s)(o)(22)(11)
# cc - the actual colour of that square location
# xxxxxxxx - pill_x
# yyyyyyyy - pill_y
# v - pill_is_virus
# p - signifies this is a valid pill and not and empty place in memory (ie, if there is a pill in this location, it will always be 1)
# s - pill_single
# o - pill_orient
# 22 - pill_colour_2
# 11 - pill_colour_1
save_to_game_board:
    la $t0, GAME_BOARD  # Load the address of the game_board in $t0
    addi $t1, $zero, 64 # Set $t1 to 64, this is the save data that we will be creating
    
    lb $t2, pill_colour_1    # load pill_colour_1 into $t2
    sll $t2, $t2, 24         # Shift left 24 so it matches to the correct position
    add $t1, $t2, $t1       # Save to data
    
    lb $t2, pill_x          # load pill_x into $t2
    sll $t2, $t2, 16         # Shift left 16 so it matches to the correct position
    add $t1, $t2, $t1       # Save to data
    
    lb $t2, pill_y          # load pill_y into $t2
    sll $t2, $t2, 8         # Shift left 8 so it matches to the correct position
    add $t1, $t2, $t1       # Save to data
    
    lb $t2, pill_is_virus   # load pill_is_virus into $t2
    sll $t2, $t2, 7         # Shift left 4 so it matches to the correct position
    add $t1, $t2, $t1       # Save to data
    
    lb $t2, pill_single     # load pill_single into $t2
    sll $t2, $t2, 5         # Shift left 5 so it matches to the correct position
    add $t1, $t2, $t1       # Save to data
    
    lb $t2, pill_orient     # load pill_orient into $t2
    sll $t2, $t2, 4         # Shift left 4 so it matches to the correct position
    add $t1, $t2, $t1       # Save to data
    
    lb $t2, pill_colour_2   # load pill_colour_2 into $t2
    sll $t2, $t2, 2         # Shift left 2 so it matches to the correct position
    add $t1, $t2, $t1       # Save to data
    
    lb $t2, pill_colour_1   # load pill_colour_1 into $t2
    add $t1, $t2, $t1       # Save to data
    
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
    andi $t1, $t1, 16777215     # remove current saved colour in
    sll $t2, $t2, 24         # Shift left 24 so it matches to the correct position
    add $t1, $t2, $t1       # Save to data
    
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
    la $t0, GAME_BOARD  # Load the address of the game_board in $t0
    
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
    la $t0, GAME_BOARD  # Load the address of the game_board in $t0
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
    
    srl $t1, $t1, 2         # Shift data so pill_orient is next
    andi $t2, $t1, 1        # Store pill_orient data into $t2
    sb $t2, pill_orient     # save data
    
    srl $t1, $t1, 1         # Shift data so pill_single is next
    andi $t2, $t1, 1        # Store pill_single data into $t2
    sb $t2, pill_single     # save data
    
    srl $t1, $t1, 1         # Shift data so pill_valid is next
    andi $t2, $t1, 1        # Store pill_single data into $t2
    sb $t2, pill_valid      # save data
    
    srl $t1, $t1, 1         # Shift data so pill_valid is next
    andi $t2, $t1, 1        # Store pill_is_virus data into $t2
    sb $t2, pill_is_virus     # save data
    
    srl $t1, $t1, 1         # Shift data so pill_y is next
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
    lw $t0, BOTTLE_TOP         # Load top boundary (y start)    curr y
    lw $t1, BOTTLE_BOTTOM      # Load bottom boundary (y end)   
    lw $t2, BOTTLE_LEFT        # Load left boundary (x start)   curr x
    lw $t3, BOTTLE_RIGHT       # Load right boundary (x end)
    
    # Outer loop: Iterate through rows (y-coordinates)
    draw_from_game_board_row_loop:
        beq $t0, $t1, draw_from_game_board_end # Stop when we reach bottom boundary
        
        # Inner loop: Iterate through columns (x-coordinates)
        draw_from_game_board_col_loop:
            beq $t2, $t3, draw_from_game_board_next_row # Move to the next row when at the right boundary
            
            la $t8, GAME_BOARD
            sll $t9, $t2, 2            # Calculate x offset
            sll $t7, $t0, 7           # Calculate y offset
            add $t8, $t8, $t9          # Add x offset
            add $t8, $t8, $t7         # Add y offset
            lw $t7, 0($t8)          # load the value at the x and y from gameboard
           
            # check if it is a pill
            andi $t9, $t7, 64
            beq $t9, $zero, draw_from_game_board_background # if it is a pill
            
            # get colour of square
            la $t9, PILL_RED
            # check if it is a virus
            andi $t6, $t7, 128
            beq $t6, $zero, draw_from_game_board_virus_skip
            addi $t9, $t9, 12
            draw_from_game_board_virus_skip:
            srl $t7, $t7, 24
            sll $t7, $t7, 2
            add $t9, $t9, $t7
            lw $t4, 0($t9)  # t9 stores colour of pill
            
            j draw_from_game_board_draw
            
            draw_from_game_board_background:
                lw $t4, BACKGROUND_COLOUR  # Save 
                
            draw_from_game_board_draw:
                lw $t8, ADDR_DSPL          # Load game board
                sll $t9, $t2, 2            # Calculate x offset
                sll $t7, $t0, 7           # Calculate y offset
                add $t8, $t8, $t9          # Add x offset
                add $t8, $t8, $t7         # Add y offset
                sw $t4, 0($t8)              # draw the colour
                addi $t2, $t2, 1    # move to the next pixel
                
                j draw_from_game_board_col_loop
                
        draw_from_game_board_next_row:
            lw $t2, BOTTLE_LEFT        # Load left boundary (x start)   curr x
            addi $t0, $t0, 1            # increase the row by 1
            j draw_from_game_board_row_loop
            
    draw_from_game_board_end:
        jr $ra

# detect_matches()
# detects the 4+ vertical and horizontal matches
# moves the pills to the correct location following the matches
detect_matches:
    la $t0, GAME_BOARD  # Load the address of the game board in $t0
    
    addi $t1, $zero, 12  # Set $t1 to the current x offset that we are checking (in px)
    addi $t2, $zero, 9  # Set $t2 to the current y offset that we are checking (in px)
    detect_matches_row:
        addi $t9, $zero, 24 # store 25 in $t9
        bge $t2, $t9, detect_matches_end   # while y <= 15 (25 - 9 = 16)
        detect_matches_row_square:
            addi $t9, $zero, 20 #store 20 in $t9
            bge $t1, $t9, detect_matches_row_end   # while x <= 7 (20 - 12 = 8)
            
            sll $t9, $t1, 2
            sll $t8, $t2, 7
            add $t7, $t9, $t0
            add $t7, $t7, $t8
            lw $t7, 0($t7)
            beq $t7, $zero, detect_matches_row_square_end #  if board[x,y] != black
            
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
            
            # Check if there is a match, if not, jump to the end
            add $t9, $t3, $t4
            beq $t9, $zero, detect_matches_row_square_end
            
            # Play match sound
            li $v0, 31
            li $a0, 90
            li $a1, 50
            li $a2, 50
            li $a3, 100
            syscall
            
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
            
            add $t5, $zero, $zero      # iteratior initialized to zero in $t5
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
            
            addi $a0, $t1, 0           # set the first argument of the function (x)
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
                
                addi $t5, $t5, 1
                
                j detect_matches_vetical_left_loop
                
        detect_matches_left_skip:
        
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
                
                addi $a0, $t1, 1            # set the first argument of the function (x + 1)
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
                
                addi $t5, $t5, 1
                
                j detect_matches_vetical_right_loop
        
        detect_matches_right_skip:
            
            addi $t5, $zero, 0          # set $t5 to be the iterator starting at 0
            detect_matches_horizontal_loop:
                bge $t5, $t3, detect_matches_row_square_end # while i < length of horizontal match
                
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
                
                addi $t5, $t5, 1
                
                j detect_matches_horizontal_loop
            
        detect_matches_row_square_end:
            addi $t1, $t1, 1    # x += 1
            j detect_matches_row_square
        
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
        addi $t9, $zero, 20 #store 8 in $t9
        bge $a0, $t9, detect_horizontal_connection_loop_end   # while x <= 7
        sll $t9, $a0, 2     # multiply the x value by 4
        sll $t8, $a1, 7     # multiply the y valye by 128
        add $t2, $a2, $t9   # make $t2 the position of the square we are currently at
        add $t2, $t2, $t8
        lw $t2, 0($t2)  # make $t2 the colour we are currently at
        and $t2, $t2, 50331712  # bit mask to only grab the colour (also grabs wether it is a pill or not)
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
        addi $t9, $zero, 24 #store 8 in $t9
        bge $a1, $t9, detect_vertical_connection_loop_end   # while y <= 15
        sll $t9, $a0, 2     # multiply the x value by 4
        sll $t8, $a1, 7     # multiply the y valye by 128
        add $t2, $a2, $t9   # make $t2 the position of the square we are currently at
        add $t2, $t2, $t8
        lw $t2, 0($t2)  # make $t2 the colour we are currently at
        and $t2, $t2, 50331712  # bit mask to only grab the colour (also grabs wether it is a pill or not)
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
    
    # set a0 and a1 to new pill
    lb $a0, pill_x
    lb $a1, pill_y
    
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $a0, 0($sp)              # Push x onto the stack, to keep it safe
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $a1, 0($sp)              # Push y onto the stack, to keep it safe
  
    jal remove_from_game_board     
    
    lw $a1, 0($sp)				# Pop y off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    lw $a0, 0($sp)				# Pop x off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    lw $ra, 0($sp)				# Pop $ra off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    
    drop_pill_and_above_move_down:
        lb $t0, pill_is_colliding
        bne $t0, $zero, drop_pill_and_above_move_down_done # while pill is not colliding
        
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
        
        jal move_down # move the pill down
        
        lw $ra, 0($sp)				# Pop $ra off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        
        j drop_pill_and_above_move_down
        
    drop_pill_and_above_move_down_done:
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a0, 0($sp)              # Push x onto the stack, to keep it safe
        addi $sp, $sp, -4           # Move stack pointer to empty location
        sw $a1, 0($sp)              # Push y onto the stack, to keep it safe
      
        jal save_to_game_board   
        
        lw $a1, 0($sp)				# Pop y off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $a0, 0($sp)				# Pop x off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        lw $ra, 0($sp)				# Pop $ra off the stack
        addi $sp, $sp, 4			# Move stack pointer to top element on stack
        
        lb $t0, pill_single
        beq $t0, $zero, drop_pill_and_above_not_single # if pill is single
        
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

# new_pill()
# updates the pill information with information for a new pill the player can use
new_pill:
    # basic start data
    addi $t0, $zero, 15
    sb $t0, pill_x
    addi $t0, $zero, 8
    sb $t0, pill_y
    sb $zero, pill_orient
    sb $zero, pill_single
    sb $zero, pill_is_colliding
    addi $t0, $zero, 1
    sb $t0, pill_valid
    sb $zero, pill_is_virus
    
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
    
    jr $ra
    
# game_state_0_init
# Initilaze game state 0
game_state_0_init:
    li $t0, 300
    sw $t0, gravity_speed_increaser
    li $t0, 4
    sb $t0, intitial_virus_count
    li $t0, 20
    sb $t0, gravity_clock
    li $t0, 8
    sb $t0, start_menu_selector_x
    li $t0, 4
    sb $t0, start_menu_selector_y

    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 0
    addi $a1, $zero, 0
    addi $a2, $zero, 1024
    lw $a3, BACKGROUND_COLOUR
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 7
    addi $a1, $zero, 5
    addi $a2, $zero, 4
    li $a3, 0x57D138
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 7
    addi $a1, $zero, 6
    addi $a2, $zero, 4
    li $a3, 0x57D138
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 7
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    li $a3, 0x57D138
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 7
    addi $a1, $zero, 8
    addi $a2, $zero, 4
    li $a3, 0x57D138
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 14
    addi $a1, $zero, 5
    addi $a2, $zero, 4
    li $a3, 0xD1A138
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 14
    addi $a1, $zero, 6
    addi $a2, $zero, 4
    li $a3, 0xD1A138
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 14
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    li $a3, 0xD1A138
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 14
    addi $a1, $zero, 8
    addi $a2, $zero, 4
    li $a3, 0xD1A138
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 21
    addi $a1, $zero, 5
    addi $a2, $zero, 4
    li $a3, 0xD12A32
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 21
    addi $a1, $zero, 6
    addi $a2, $zero, 4
    li $a3, 0xD12A32
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 21
    addi $a1, $zero, 7
    addi $a2, $zero, 4
    li $a3, 0xD12A32
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 21
    addi $a1, $zero, 8
    addi $a2, $zero, 4
    li $a3, 0xD12A32
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 6
    addi $a1, $zero, 13
    addi $a2, $zero, 6
    lw $a3, VIRUS_BLUE
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 8
    addi $a1, $zero, 14
    addi $a2, $zero, 2
    lw $a3, VIRUS_BLUE
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 8
    addi $a1, $zero, 15
    addi $a2, $zero, 2
    lw $a3, VIRUS_BLUE
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 6
    addi $a1, $zero, 16
    addi $a2, $zero, 6
    lw $a3, VIRUS_BLUE
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 7
    addi $a1, $zero, 17
    addi $a2, $zero, 4
    lw $a3, VIRUS_BLUE
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 7
    addi $a1, $zero, 15
    addi $a2, $zero, 1
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 10
    addi $a1, $zero, 15
    addi $a2, $zero, 1
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 8
    addi $a1, $zero, 17
    addi $a2, $zero, 2
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 9
    addi $a1, $zero, 21
    addi $a2, $zero, 2
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 8
    addi $a1, $zero, 22
    addi $a2, $zero, 2
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 7
    addi $a1, $zero, 23
    addi $a2, $zero, 2
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 9
    addi $a1, $zero, 24
    addi $a2, $zero, 2
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 8
    addi $a1, $zero, 25
    addi $a2, $zero, 2
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 7
    addi $a1, $zero, 26
    addi $a2, $zero, 2
    lw $a3, PILL_YELLOW
    jal draw_hor_line
    
    lw $ra, 0($sp)				# Pop $ra off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    
    jr $ra
    
# game_state_1_init
# Initilaze game state 1
game_state_1_init:
    addi $sp, $sp, -4           # Move stack pointer to empty location
    sw $ra, 0($sp)              # Push $ra onto the stack, to keep it safe
    
    # Clear Screen and gameboard
    lw $t0, ADDR_DSPL
    addi $a0, $zero, 0
    addi $a1, $zero, 0
    addi $a2, $zero, 1024
    lw $a3, BACKGROUND_COLOUR
    jal draw_hor_line
    
    la $t0, GAME_BOARD
    addi $a0, $zero, 0
    addi $a1, $zero, 0
    addi $a2, $zero, 1024
    lw $a3, BACKGROUND_COLOUR
    jal draw_hor_line
    
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
    addi $a2, $zero, 10
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
    
    # Add the Initial viruses
    
    lb $a3, intitial_virus_count
    jal add_random_virus
    
    # get total virsus
    jal get_total_virus
    
    # Add The Initial Capsule
    jal new_pill
    jal save_to_game_board
    
    lw $ra, 0($sp)				# Pop $ra off the stack
    addi $sp, $sp, 4			# Move stack pointer to top element on stack
    
    jr $ra

# get_total_virus()
# gets the total number of viruses on the screen
# updates the total_virus variable
get_total_virus:
    sb $zero, pill_is_virus
    lb $t0, BOTTLE_LEFT # curr x
    lb $t1, BOTTLE_TOP  # curr y
    addi $t4, $zero, 0  # number of viruses found
    
    get_total_virus_row:
    lb $t3, BOTTLE_BOTTOM
    beq $t1, $t3, get_total_virus_end   # while y < bottom
        
        get_total_virus_row_square:
        lb $t2, BOTTLE_RIGHT
        beq $t0, $t2, get_total_virus_row_end    # while x < right
        
            addi $sp, $sp, -4
            sw $ra, 0($sp)
            addi $sp, $sp, -4
            sw $t0, 0($sp)
            addi $sp, $sp, -4
            sw $t1, 0($sp)
            addi $sp, $sp, -4
            sw $t4, 0($sp)
            
            move $a0, $t0   
            move $a1, $t1
            jal get_from_game_board
            
            lw $t4, 0($sp)				
            addi $sp, $sp, 4
            lw $t1, 0($sp)				
            addi $sp, $sp, 4
            lw $t0, 0($sp)				
            addi $sp, $sp, 4
            lw $ra, 0($sp)				
            addi $sp, $sp, 4
            
            lb $t5, pill_is_virus
            beq $t5, $zero, get_total_virus_row_square_end
            addi $t4, $t4, 1
            sb $zero, pill_is_virus
        get_total_virus_row_square_end:
            addi $t0, $t0, 1
            j get_total_virus_row_square
        
    get_total_virus_row_end:
        lb $t0, BOTTLE_LEFT # reset x
        addi $t1, $t1, 1
        j get_total_virus_row
    
    get_total_virus_end:
        sb $t4, total_virus
        
        jr $ra