TABLE = csvimport('SD_0226_172246.csv');
table_size = size(TABLE);
TABLE_DATA = cell2mat(TABLE(2:table_size(1),1:25));
T_table = TABLE_DATA(:,1); %[s]
%Roll_data = TABLE_DATA(:,5); %[rad]
Roll_data = TABLE_DATA(:,6); %[rad]
%Pitch_data = TABLE_DATA(:,6); %[rad]
Pitch_data = TABLE_DATA(:,5); %[rad]
Yaw_data = TABLE_DATA(:,7); %[rad]

t_out = zeros(size(Roll_data));
psi_out = zeros(size(Roll_data));
theta_out = zeros(size(Roll_data));
phi_out = zeros(size(Roll_data));
Fx_out = zeros(size(Roll_data));
Fy_out = zeros(size(Roll_data));
Depth_out = zeros(size(Roll_data));

dt = 0.01;

index = 1;
while(index<length(Roll_data))
   theta = Pitch_data(index)*(180/pi);
   phi = Roll_data(index)*(180/pi);
   psi = Yaw_data(index)*(180/pi);
   ea = SpinCalc('EA213toEA321',[phi,theta,psi]);
   
   %psi_out(index) = ea(1)*(180/pi);
   if (ea(1)>180)
       ea(1) = ea(1)-360;
   end
   psi_out(index) = ea(1);
   %theta_out(index) = ea(2)*(180/pi);
   if (ea(2)>180)
       ea(2) = ea(2)-360;
   end
   theta_out(index) = ea(2);
   %phi_out(index) = ea(3)*(180/pi);
   if (ea(3)>180)
       ea(3) = ea(3)-360;
   end
   phi_out(index) = ea(3);
   index = index + 1;
   t_out(index) = t_out(index-1) + dt; 
end

output_table = [t_out, Fx_out, Fy_out, Depth_out, psi_out, theta_out, phi_out];

filename = ['control_program.csv'];
headers = {'Time[s]', 'Fx[N]', 'Fy[N]', 'Depth[m]', 'Phi[deg]', 'Theta[deg]',' Psi[deg]'};
csvwrite_with_headers(filename, output_table, headers);

