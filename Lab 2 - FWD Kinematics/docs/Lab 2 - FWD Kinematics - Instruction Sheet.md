# Lab 2 - FWD Kinematics

This lab interacts with a ‘real’ robotic system – a planar RR robot. RR means  that it has two rotational joints.

---

## Task 1 – Control Two Dynamixels Simultaneously 

In this task we are going to move two Dynamixels simultaneously. Edit your code from last week to communicate with both simultaneously. Note that the IDs of the Dynamixels are printed underneath them. 

**Tasks**:
1. Start by reading the encoders of both Dynamixels and printing these to the Matlab terminal  

<par>

2. Add the following code after you open the port to prevent the Dynamixels from exceeding the motion limit when moving
```
    % ----- SET MOTION LIMITS ----------- % 
    
    ADDR_MAX_POS = 48; 
    ADDR_MIN_POS = 52; 
    
    MAX_POS = 3400; 
    MIN_POS = 600; 
    
    % Set max position limit 
    write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_MAX_POS, MAX_POS); 
    write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_MAX_POS, MAX_POS); 
    
    % Set min position limit 
    write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_MIN_POS, MIN_POS); 
    write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_MIN_POS, MIN_POS); 
    
    % ---------------------------------- % 
```
3. Sending a sequence of three position demands to both Dynamixels simultaneously (so both Dynamixels get the same position demand at the same point in the sequence). Remember to include a pause command after each position demand to make sure the Dynamixels have time to complete the motion. 

<par>

4. Now try sending a sequence of three different position demands to both Dynamixels separately.  

**Analysis**: 

Notice:
 - Motion seems quite ‘violent’ for big motions.
 - Base seems to try and move around on the table.

1. Discuss why you think this is and the effect this has on larger robots.
2. Discuss how you could try and improve this.

---

## Task 2 – Trajectory Tracking 

Consider a co-ordinated joint motion.

<center>
    Show the GTAs when you are done
</center>

**Tasks**:
1.  Without connecting the Dynamixels, use Matlab to generate a sine wave function over a given number of time steps (for example 400 steps). 
    - The output of a sine function will naturally oscillate between -1 and 1. Modify the function to produce an output of $\pm$ 500 encoder counts centred around 12 o'clock on the servos (encoder count 2046).  
    - You should store your sine function as an array of values
    -  Use of `for` loop to step through each value of the sine wave, sending it to the two Dynamixels.

<par>

2.  Now try and get the two actuators to follow two different trajectories. For example, a sine wave and an inverted sine wave or a sine wave and a cosine wave. 

**Analysis**: 
1.  You may notice that the motion is a bit jerky in places. Discuss with your group why you think this may be.
---

## Task 3 – Frame Assignment and Forward Kinematics  



---

## Task 4 (Bonus) – Moving in a Square 
