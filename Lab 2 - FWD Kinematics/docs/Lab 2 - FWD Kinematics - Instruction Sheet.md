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


---

## Task 3 – Frame Assignment and Forward Kinematics  



---

## Task 4 (Bonus) – Moving in a Square 
