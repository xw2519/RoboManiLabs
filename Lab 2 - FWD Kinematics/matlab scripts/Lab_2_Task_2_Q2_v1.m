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

%% ---- Generate the required calliberated sine wave values for DXL_ID1 ---- %%

% Sine wave generation
SINE_X_AXIS                 = linspace(0, 2*pi, 500); % Divide 2pi x-axis into steps
SINE_Y_VALUES               = sin(SINE_X_AXIS);
SINE_Y_DYNAMIXEL_FORMAT     = 2046 + 1354*sin(SINE_X_AXIS); % Caliberate to center around 12 o'clock (encoder count 2046)

% scatter(SINE_X_AXIS, SINE_Y_DYNAMIXEL_FORMAT)

%% ---- Generate the required calliberated cosine wave values for DXL_ID2 ---- %%

% Cosine wave generation
COSINE_X_AXIS                 = linspace(0, 2*pi, 500); % Divide 2pi x-axis into steps
COSINE_Y_VALUES               = cos(COSINE_X_AXIS);
COSINE_Y_DYNAMIXEL_FORMAT     = 2046 + 1354*cos(COSINE_X_AXIS); % Caliberate to center around 12 o'clock (encoder count 2046)

% scatter(COSINE_X_AXIS, COSINE_Y_DYNAMIXEL_FORMAT)

%% ---- Initialize PortHandler Structs and Connect to Servo ---- %%
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

% Put actuator into Position Control Mode
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_OPERATING_MODE, 3);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_OPERATING_MODE, 3);

% Enable Dynamixel Torque for two servos
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);        

dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);

if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
else
    fprintf('Dynamixel has been successfully connected \n');
end

%% ---- Limit the motion range of the servos ---- %%

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

%% ---- Servo motions ---- %%

assert(length(SINE_Y_DYNAMIXEL_FORMAT) == length(COSINE_Y_DYNAMIXEL_FORMAT)) % Ensure length of two arrays are the same

for j = 1:10
    for i = 1:length(SINE_Y_DYNAMIXEL_FORMAT)
        write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID1, ADDR_PRO_GOAL_POSITION, SINE_Y_DYNAMIXEL_FORMAT(i));
        write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID2, ADDR_PRO_GOAL_POSITION, COSINE_Y_DYNAMIXEL_FORMAT(i));

        if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
            printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
        elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
            printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
        end
    end
end

%% ---- Disable Dynamixel Torque and Close Port ---- %%

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
