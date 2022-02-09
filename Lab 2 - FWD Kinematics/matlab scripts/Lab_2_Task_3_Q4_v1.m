% Read the position of the dynamixel horn with the torque off and converts
% the position value to angles (both degrees and radians)
clc;
clear all;

lib_name = '';

if strcmp(computer, 'PCWIN')
  lib_name = 'dxl_x86_c';
elseif strcmp(computer, 'PCWIN64')
  lib_name = 'dxl_x64_c';
elseif strcmp(computer, 'GLNX86')
  lib_name = 'libdxl_x86_c';
elseif strcmp(computer, 'GLNXA64')
  lib_name = 'libdxl_x64_c';
elseif strcmp(computer, 'MACI64')
  lib_name = 'libdxl_mac_c';
end

% Load Libraries
if ~libisloaded(lib_name)
    [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
end

%% ---- Control Table Addresses ---- %%

ADDR_PRO_TORQUE_ENABLE       = 64;           % Control table address is different in Dynamixel model
ADDR_PRO_GOAL_POSITION       = 116; 
ADDR_PRO_PRESENT_POSITION    = 132; 
ADDR_PRO_OPERATING_MODE      = 11;

%% ---- Transformation Matrices ---- %%

R_0 = [ 1 0 0; 
        0 1 0;
        0 0 1 ];
   
P_0 = [ 1 0 0; 
        0 1 0;
        0 0 1 ];
   
T_0 = R_0 * P_0;

%% ---- Other Settings ---- %%

% Protocol version
PROTOCOL_VERSION            = 2.0;          % See which protocol version is used in the Dynamixel

% Default setting
DXL_ID1                     = 11;          % Dynamixel ID: 1
DXL_ID2                     = 12;          % Dynamixel ID: 1
BAUDRATE                    = 115200;
DEVICENAME                  = 'COM3';       % Check which port is being used on your controller
                                            % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'
                                            
TORQUE_ENABLE               = 1;            % Value for enabling the torque
TORQUE_DISABLE              = 0;            % Value for disabling the torque
DXL_MINIMUM_POSITION_VALUE  = -150000;      % Dynamixel will rotate between this value
DXL_MAXIMUM_POSITION_VALUE  = 150000;       % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
DXL_MOVING_STATUS_THRESHOLD = 20;           % Dynamixel moving status threshold

ESC_CHARACTER               = 'e';          % Key for escaping loop

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

%% ---- Initialize PortHandler Structs and Connect to Servo ---- %%
% Set the port path
% Get methods and members of PortHandlerLinux or PortHandlerWindows
port_num = portHandler(DEVICENAME);

% Initialize PacketHandler Structs
packetHandler();

index = 1;
dxl_comm_result = COMM_TX_FAIL;           % Communication result
dxl_goal_position = [DXL_MINIMUM_POSITION_VALUE DXL_MAXIMUM_POSITION_VALUE];         % Goal position

dxl_error = 0;                              % Dynamixel error
dxl_present_position = 0;                   % Present position

% Open port
if (openPort(port_num))
    fprintf('Port Open\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to open the port\n');
    input('Press any key to terminate...\n');
    return;
end

% Set port baudrate
if (setBaudRate(port_num, BAUDRATE))
    fprintf('Baudrate Set\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to change the baudrate!\n');
    input('Press any key to terminate...\n');
    return;
end

dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);

if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
else
    fprintf('Dynamixel has been successfully connected \n');
end

%% ----- SET MOTION LIMITS ----------- %%
  
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

%% ---- Set initial state of servo to default (0) position ---- %%

% Put actuator into Position Control Mode
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_OPERATING_MODE, 3);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_OPERATING_MODE, 3);


% Enable Dynamixel Torque for two servos
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);    




write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_GOAL_POSITION, 3416.0);
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_GOAL_POSITION, 1132.0);

if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
end

pause(2)

%% ---- Switch Servo Torque Off to Allow Manual Tracking---- %%

% Put actuator into Position Control Mode
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_OPERATING_MODE, 3);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_OPERATING_MODE, 3);

% Disable Dynamixel Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_TORQUE_ENABLE, 0);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_TORQUE_ENABLE, 0);

dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);

if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
else
    fprintf('Dynamixel has been successfully connected \n');
end

%% ---- Track Servo Position and Convert Into Angles and Radians ---- %%
% Loop until 'e' is pressed to exit loop
while 1
    % Read present servo position
    dxl_ID1_present_position = read4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_PRESENT_POSITION);
    dxl_ID2_present_position = read4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_PRESENT_POSITION);
    
    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);

    if dxl_comm_result ~= COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
    elseif dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
    end
    
    % Convert to angles in degrees and radians
    % 0.088 [°] <------> 0 ~ 4,095(1 rotation)
    % Round to nearest integer
    dxl_ID1_angle_degree = (0.088 * typecast(single(dxl_ID1_present_position), 'single'));
    dxl_ID2_angle_degree = (0.088 * typecast(single(dxl_ID2_present_position), 'single'));
    
    dxl_ID1_angle_degree_caliberated = dxl_ID1_angle_degree - 180;
    dxl_ID2_angle_degree_caliberated = dxl_ID2_angle_degree - 180;
    dxl_ID1_angle_radian_caliberated = deg2rad(dxl_ID1_angle_degree_caliberated);
    dxl_ID2_angle_radian_caliberated = deg2rad(dxl_ID2_angle_degree_caliberated);
    
    % Print out readings and conversions
    fprintf('[ID:%03d] Position: %.1f - Angle(Deg): %.4f - Angle(Rad): %.4f\n', DXL_ID1, typecast(uint32(dxl_ID1_present_position), 'int32'), dxl_ID1_angle_degree_caliberated, dxl_ID1_angle_radian_caliberated);
    fprintf('[ID:%03d] Position: %.1f - Angle(Deg): %.4f - Angle(Rad): %.4f\n', DXL_ID2, typecast(uint32(dxl_ID2_present_position), 'int32'), dxl_ID2_angle_degree_caliberated, dxl_ID2_angle_radian_caliberated);
    
    % Calculate the transformation matrices 
    % Frame 1 - Rotation
    R_0_1 = [ cosd(dxl_ID2_angle_degree_caliberated) -sind(dxl_ID2_angle_degree_caliberated) 0;
              sind(dxl_ID2_angle_degree_caliberated)  cosd(dxl_ID2_angle_degree_caliberated) 0;
                                0                                       0                    1; ];
   
    P_0_1 = [ 1 0 0; 
              0 1 0;
              0 0 1 ];

    T_0_1 = R_0_1 * P_0_1;
    
    % Frame 2 - Translation
    R_1_2 = [ 1 0 0; 
              0 1 0;
              0 0 1 ];
   
    P_1_2 = [ 1 0  0; 
              0 1 80; 
              0 0  1  ];

    T_1_2 = R_1_2 * P_1_2;
    
    % Frame 3 - Rotation
    R_2_3 = [ cosd(dxl_ID1_angle_degree_caliberated) -sind(dxl_ID1_angle_degree_caliberated) 0; 
              sind(dxl_ID1_angle_degree_caliberated)  cosd(dxl_ID1_angle_degree_caliberated) 0;
                                0                                       0                    1; ];

    P_2_3 = [ 1 0 0; 
              0 1 0;
              0 0 1 ];

    T_2_3 = R_2_3 * P_2_3;
    
    % Frame 4 - Translation
    R_3_4 = [ 1 0 0; 
              0 1 0;
              0 0 1 ];

    P_3_4 = [ 1 0  0; 
              0 1 60; 
              0 0  1 ];

    T_3_4 = R_3_4 * P_3_4;
    
    BaseToShoulderDistal = T_0_1 * T_1_2;
    BaseToTool = T_0_1 * T_1_2 * T_2_3 * T_3_4;
    
    disp('BaseToShoulderDistal matrix:')
    disp(BaseToShoulderDistal)
    
    disp('BaseToTool matrix:')
    disp(BaseToTool)
end

%% ---- Disable Dynamixel Torque and Close Port ---- %%
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_DISABLE);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end

% Close port
closePort(port_num);
fprintf('Port Closed \n');

% Unload Library
unloadlibrary(lib_name);

close all;
clear all;