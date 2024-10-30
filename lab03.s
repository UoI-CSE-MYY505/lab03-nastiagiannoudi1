# Conversion of RGB888 image to RGB565
# lab03 of MYY505 - Computer Architecture
# Department of Computer Engineering, University of Ioannina
# Aris Efthymiou

# This directive declares subroutines. Do not remove it!
.globl rgb888_to_rgb565, showImage

.data

image888:  # A rainbow-like image Red->Green->Blue->Red
    .byte 255, 0,     0
    .byte 255,  85,   0
    .byte 255, 170,   0
    .byte 255, 255,   0
    .byte 170, 255,   0
    .byte  85, 255,   0
    .byte   0, 255,   0
    .byte   0, 255,  85
    .byte   0, 255, 170
    .byte   0, 255, 255
    .byte   0, 170, 255
    .byte   0,  85, 255
    .byte   0,   0, 255
    .byte  85,   0, 255
    .byte 170,   0, 255
    .byte 255,   0, 255
    .byte 255,   0, 170
    .byte 255,   0,  85
    .byte 255,   0,   0
# repeat the above 5 times
    .byte 255, 0,     0, 255,  85,   0, 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0, 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0, 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0, 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0, 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0

image565:
    .zero 512  # leave a 0.5Kibyte free space

.text
# -------- This is just for fun.
# Ripes has a LED matrix in the I/O tab. To enable it:
# - Go to the I/O tab and double click on LED Matrix.
# - Change the Height and Width (at top-right part of I/O window),
#     to the size of the image888 (6, 19 in this example)
# - This will enable the LED matrix
# - Uncomment the following and you should see the image on the LED matrix!
#    la   a0, image888
#    li   a1, LED_MATRIX_0_BASE
#    li   a2, LED_MATRIX_0_WIDTH
#    li   a3, LED_MATRIX_0_HEIGHT
#    jal  ra, showImage
# ----- This is where the fun part ends!

    la   a0, image888
    la   a3, image565
    li   a1, 19 # width
    li   a2,  6 # height
    jal  ra, rgb888_to_rgb565

    addi a7, zero, 10 
    ecall

# ----------------------------------------
# Subroutine showImage
# a0 - image to display on Ripes' LED matrix
# a1 - Base address of LED matrix
# a2 - Width of the image and the LED matrix
# a3 - Height of the image and the LED matrix
# Caution: Assumes the image and LED matrix have the
# same dimensions!
showImage:
    add  t0, zero, zero # row counter
showRowLoop:
    bge  t0, a3, outShowRowLoop
    add  t1, zero, zero # column counter
showColumnLoop:
    bge  t1, a2, outShowColumnLoop
    lbu  t2, 0(a0) # get red
    lbu  t3, 1(a0) # get green
    lbu  t4, 2(a0) # get blue
    slli t2, t2, 16  # place red at the 3rd byte of "led" word
    slli t3, t3, 8   #   green at the 2nd
    or   t4, t4, t3  # combine green, blue
    or   t4, t4, t2  # Add red to the above
    sw   t4, 0(a1)   # let there be light at this pixel
    addi a0, a0, 3   # move on to the next image pixel
    addi a1, a1, 4   # move on to the next LED
    addi t1, t1, 1
    j    showColumnLoop
outShowColumnLoop:
    addi t0, t0, 1
    j    showRowLoop
outShowRowLoop:
    jalr zero, ra, 0

# ----------------------------------------

rgb888_to_rgb565:
   # Save registers to the stack for use in the subroutine
    addi sp, sp, -16
    sw ra, 12(sp)     
    sw s0, 8(sp)         
    sw s1, 4(sp)         
    sw s2, 0(sp)     

    # Copy parameters into temporary registers
    mv s0, a0           
    mv s1, a3            
    mv s2, a1            
    mv s3, a2            

    # Initialize row and column counters
    li t0, 0             
    li t1, 0             

loop_rows:
    bge t0, s3, end      

    # Initialize columns for each row
    li t1, 0            

loop_columns:
    bge t1, s2, next_row 

    # Calculate address for the current RGB888 pixel
    mul t2, t0, s2       
    add t2, t2, t1       
    slli t2, t2, 1       
    add  t2, t2, t2      
    add t2, s0, t2       

    # Load R, G, B values from RGB888
    lbu t3, 0(t2)       
    lbu t4, 1(t2)       
    lbu t5, 2(t2)       
    
    # Convert to RGB565 format
    # R -> 5 bits (R[7:3])
    srli t3, t3, 3       
    slli t3, t3, 11     
    # G -> 6 bits (G[7:2])
    srli t4, t4, 2       
    slli t4, t4, 5       

    # B -> 5 bits (B[7:3])
    srli t5, t5, 3       

    # Combine R, G, B into RGB565 format
    or t6, t3, t4        
    or t6, t6, t5    

    # Store RGB565 pixel in the output array
    sh t6, 0(s1)         
    addi s1, s1, 2       

    # Move to the next pixel in the current row
    addi t1, t1, 1       
    j loop_columns       

next_row:
    # Move to the next row
    addi t0, t0, 1       
    j loop_rows          

end:
    # Restore registers from the stack
    lw ra, 12(sp)        
    lw s0, 8(sp)         
    lw s1, 4(sp)         
    lw s2, 0(sp)         
    addi sp, sp, 16      
    # Return to the caller
    jalr zero, ra, 0

