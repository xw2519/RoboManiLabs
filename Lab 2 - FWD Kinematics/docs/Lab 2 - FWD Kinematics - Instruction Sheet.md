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

Forward Kinematics is the ability to calculate the pose of different parts of a robot based on the joint 
angles. In this task we are going to learn how to calculate the position of the centre of the hole at 
the end of the robot, in Cartesian space. We will be doing this using frames and transformation 
matrices. 

<center>
    Show the GTAs when you are done
</center>

**Tasks**:
1. Create some code (based on Task 1) that reads the Dynamixel encoders and converts these into angles (in both degrees and radians). 
   - Check the datasheet to see how many encoder counts are in a revolution. 
   - You probably want to display the angle data in degrees in the Command Window while moving the robot by hand (with the torque disabled) to make sure the angle values look correct. 

<par>

2. Looking at the slides of lecture 3, write out a 2D transformation matrix and name it *T_0*. This will be the base frame. 
    - *T_0* should consist of a rotation matrix *R_0* and a position matrix *P_0*. 

<par> 

3. Consider the positions of the robot frames from the lecture. Create a transformation matrix for each one, using the naming convention *T_n*, where *n* is the frame number.
    - Consider which frames are translated from prior frames and modify their position matrix (the link lengths are written on the robot).  
    - Consider which frames are rotated from the prior frames and include the relevant theta angle in the rotation matrix (note that this should be in radians) 

<par>

4. Now sequentially combine the transformation matrices to determine the position of the end of link 1 (the elbow joint) and the end of link 2 (which we can call the tool). 
    - Again, stream these to the command window as you move the robot around make sure the values make sense.

<par>

5.  Now save the $X-Y$ values of the tool over a given period of time as you move the robot around. Use the plot command in Matlab to plot $X$ against $Y$ (e.g. `plot(x,y)`). You can use the 'axis square' command to fix any linear distortion from plotting.  

<par>

6. Try and draw a square (with around 7-10cm width) by manually moving the tool. Does the resultant trajectory look how you anticipated?  

<par>

7. Use *title(xxx)* to set the title of the figure to your group’s name.


---

## Task 4 (Bonus) – Moving in a Square 

Simplified tool control.

<center>
    Show the GTAs when you are done and take a video of your robot moving to upload to Blackboard
</center>

**Tasks**:
1. Set your previous code to also display the encoder counts in addition to $XY$
   
<par>

2. Try and draw a square again by manually moving the robot with the torque disabled. In each corner pause your motion make a note of the encoder values.  

<par>

3. Repeat Task 1 but for your sequence of encoder values, use the encoder values for the corners of the square.

<par>

4. How much like a square is the resultant robot motion? Are the lines the tool makes between the points straight? Discuss why the tool path appears as it does? 

