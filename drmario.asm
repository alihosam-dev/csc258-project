################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Chet Petro, 1010380320
# Student 2: Name, Student Number (if applicable)
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
FRAME_RATE: .word 33 # Frame rate in 1/(frame rate) where frame rate is fps 

# Game Colours
BOTTLE_COLOUR: .word 0x808080

PILL_RED: .word 0xFF0000
PILL_BLUE: .word 0x0000FF
PILL_YELLOW: .word 0xFFFF00


##############################################################################
# Mutable Data
##############################################################################

pill_x: .byte 15 # X coord of pill in pixels
pill_y: .byte 8 # Y coord of pill in pixels
pill_orient: .byte 0 # orientation of pill, 0 = horizontal, 1 = vertical



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


game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	
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
    
# draw_pill(colour1, colour2)
# draws a pill at at (pill_x, pill_y) in pixels with specified colours with orientation specified by pill_orient
# $a0 - colour of first square
# $a1 - colour of second sqare
draw_pill:
    lw $t0, ADDR_DSPL       # current address to draw in $t0
    lb $t9, pill_x          # load current x pos
    lb $t8, pill_y          # load current y pos
    lb $t7, pill_orient     # load current orientation
    sll $t9, $t9, 2         # x offset in $t9
    sll $t8, $t8, 7         # y offset in $t8
    add $t0, $t0, $t9       # add x offset
    add $t0, $t0, $t8       # add y offset
    sw $a0, 0($t0)          # draw square 1
    beq $t7, $zero, draw_pill_is_hor    # if pill_orient is horizontal, jump to horizontal branch, else draw vertical
        addi $t0, $t0, -128                 # go to square above
        j draw_pill_end                     # return
    draw_pill_is_hor:                   # else branch
        addi $t0, $t0, 4                    # go to sqare beside
        j draw_pill_end                     # return
    draw_pill_end:
        sw $a1, 0($t0) # draw sqare 2
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

