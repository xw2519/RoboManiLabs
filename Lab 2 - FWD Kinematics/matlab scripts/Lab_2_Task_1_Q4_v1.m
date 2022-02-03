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
% Control table address is different in every Dynamixel model

ADDR_PRO_TORQUE_ENABLE       = 64;  % Torque Enable(64) determines Torque ON/OFF. Writing ‘1’ to Toque Enable’s address will turn on the Torque           
ADDR_PRO_GOAL_POSITION       = 116; % Sets desired position
ADDR_PRO_PRESENT_POSITION    = 132; % Present position of the servo
ADDR_PRO_OPERATING_MODE      = 11;  % Sets between Current, Velocity, Position Control Mode 

%% ---- Other Settings ---- %%

% Protocol version
PROTOCOL_VERSION            = 2.0;          % See which protocol version is used in the Dynamixel

% Default setting
DXL_ID1                     = 12;          % Dynamixel ID: 1
DXL_ID2                     = 14;          % Dynamixel ID: 1
BAUDRATE                    = 115200;
DEVICENAME                  = 'COM5';       % Check which port is being used on your controller
                                            % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'
                                            
                                            
TORQUE_ENABLE               = 1;            % Value for enabling the torque
TORQUE_DISABLE              = 0;            % Value for disabling the torque
DXL_MINIMUM_POSITION_VALUE  = -150000;      % Dynamixel will rotate between this value
DXL_MAXIMUM_POSITION_VALUE  = 150000;       % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
DXL_MOVING_STATUS_THRESHOLD = 20;           % Dynamixel moving status threshold

ESC_CHARACTER               = 'e';          % Key for escaping loop

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

% Plotting variables
CURRENT_PLOT                = [];
X_AXIS_COUNTER              = 0;
h                           = figure;
ax                          = gca(h);

%% ------------------ %%

% Initialize PortHandler Structs
% Set the port path
% Get methods and members of PortHandlerLinux or PortHandlerWindows
port_num = portHandler(DEVICENAME);

% Initialize PacketHandler Structs
packetHandler();

index = 1;
dxl_comm_result = COMM_TX_FAIL;           % Communication result

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

% Put actuator into Position Control Mode
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_OPERATING_MODE, 3);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_OPERATING_MODE, 3);

% Enable Dynamixel Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);

% Goal position
dxl_1_goal_position = [600, 2000 ,3400];   
dxl_2_goal_position = [3400, 2000, 600];         

dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);

if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
else
    fprintf('Dynamixel has been successfully connected \n');
end

% Sending a sequence of three position demands to both Dynamixels simultaneously 
% Write goal position 1
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_GOAL_POSITION, typecast(int32(dxl_1_goal_position(1)), 'uint32'));
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_GOAL_POSITION, typecast(int32(dxl_2_goal_position(1)), 'uint32'));
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
end

pause(2)

% Write goal position 2
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_GOAL_POSITION, typecast(int32(dxl_1_goal_position(2)), 'uint32'));
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_GOAL_POSITION, typecast(int32(dxl_2_goal_position(2)), 'uint32'));
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
end

pause(2)

% Write goal position 3
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_GOAL_POSITION, typecast(int32(dxl_1_goal_position(3)), 'uint32'));
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_GOAL_POSITION, typecast(int32(dxl_2_goal_position(3)), 'uint32'));
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
end

pause(2)

% Disable Dynamixel Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_TORQUE_ENABLE, TORQUE_DISABLE);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_TORQUE_ENABLE, TORQUE_DISABLE);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end

pause(2)

% Close port
closePort(port_num);
fprintf('Port Closed \n');

% Unload Library
unloadlibrary(lib_name);

close all;
clear all;
