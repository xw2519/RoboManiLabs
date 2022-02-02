%% ---- Transformation Matrix: Robot Base Frame - Frame 0 ---- %%
R_0 = [ 0 0; 
        0 0;
        0 0 ];
   
P_0 = [ 0; 
        0;
        0 ];
   
T_0 = [R_0, P_0];

%% ---- Transformation Matrix: Shoulder Frame - Frame 1 - Rotation ---- %%
% R_0_1 = [ cosd(45) -sind(45); 
%           sind(45) cosd(45);
%           0 0                 ];
   
% P_0_1 = [ 0; 
%           0;
%           0 ];
   
% T_0_1 = [R_0_1, P_0_1];

T_0_1 = trot2(45, 'deg');

%% ---- Transformation Matrix: Shoulder Distal / Elbow - Frame 2 - Translation ---- %%
% R_1_2 = [ 1 0; 
%           0 1
%           0 0 ];
   
% P_1_2 = [ 80*cosd(45); 
%           80*sind(45); 
%           1            ];
   
% T_1_2 = [R_1_2, P_1_2];

T_1_2 = transl2(80, 0);

%% ---- Transformation Matrix: Elbow Frame - Frame 3 - Rotation ---- %%
% R_2_3 = [ cosd(90) -sind(90); 
%           sind(90) cosd(90);
%           0 0                 ];
   
% P_2_3 = [ 0; 
%           0;
%           0 ];
   
% T_2_3 = [R_2_3, P_2_3];

T_2_3 = trot2(90, 'deg');

%% ---- Transformation Matrix: Tool Frame - Frame 4 - Translation ---- %%
% R_3_4 = [ 1 0; 
%           0 1
%           0 0 ];
   
% P_3_4 = [ 80*cosd(90); 
%           80*sind(90); 
%           1            ];
   
% T_3_4 = [R_3_4, P_3_4];

T_3_4 = transl2(60, 0);

BaseToShoulderDistal = T_0_1 * T_1_2 * T_2_3 * T_3_4;

disp(BaseToShoulderDistal);


