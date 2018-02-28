TABLE = csvimport('SD_0227_181651.csv');
table_size = size(TABLE);
TABLE_DATA = cell2mat(TABLE(2:table_size(1),1:9));
T_table = TABLE_DATA(:,1); %[s]
Q1 = TABLE_DATA(:,2); %[rad]
Q2 = TABLE_DATA(:,3); %[rad]
Q3 = TABLE_DATA(:,4); %[rad]
Q4 = TABLE_DATA(:,5); %[rad]

t_out = zeros(size(Q1));
phi_out = zeros(size(Q1));
phi_offset = 0;
theta_out = zeros(size(Q1));
theta_offset = 0;
psi_out = zeros(size(Q1));
psi_offset = 0;
Fx_out = zeros(size(Q1));
Fy_out = zeros(size(Q1));
Depth_out = zeros(size(Q1));

phi = 0;
theta = 90;
psi = 0;

DCM = [cos(psi)*cos(theta) -sin(psi)*cos(phi)+cos(psi)*sin(theta)*sin(phi)  sin(psi)*sin(phi)+cos(psi)*cos(phi)*sin(theta)
       sin(psi)*cos(theta) cos(psi)*cos(phi)+sin(phi)*sin(theta)*sin(psi)   -cos(psi)*sin(phi)+sin(theta)*sin(psi)*cos(phi)
       -sin(theta)         cos(theta)*sin(phi)                              cos(theta)*cos(phi)                            ];

ea_deg_old = zeros(1,3);

dt = 0.01;

index = 1;
while(index<length(Q1))
   q = [Q1, Q2, Q3, Q4];
   ea_raw = quatern2euler(q(index,:))';
   
   ea = DCM\ea_raw;
   
   ea_deg = ea.*(180/pi); %convert to degrees
   
   if (abs(ea_deg(1))>100)
       if ((sign(ea_deg(1))==1)&&(sign(ea_deg_old(1))==-1))
           phi_offset = phi_offset - 360;
       end
       if ((sign(ea_deg(1))==-1)&&(sign(ea_deg_old(1))==1))
           phi_offset = phi_offset + 360;
       end
   end
   phi_out(index) = ea_deg(1) + phi_offset;
   
   if (abs(ea_deg(2))>100)
       if ((sign(ea_deg(2))==1)&&(sign(ea_deg_old(2))==-1))
           theta_offset = theta_offset - 360;
       end
       if ((sign(ea_deg(2))==-1)&&(sign(ea_deg_old(2))==1))
           theta_offset = theta_offset + 360;
       end
   end
   theta_out(index) = ea_deg(2) + theta_offset;
   
   if (abs(ea_deg(3))>100)
       if ((sign(ea_deg(3))==1)&&(sign(ea_deg_old(3))==-1))
           psi_offset = psi_offset - 360;
       end
       if ((sign(ea_deg(3))==-1)&&(sign(ea_deg_old(3))==1))
           psi_offset = psi_offset + 360;
       end
   end
   psi_out(index) = ea_deg(3) + psi_offset;
   ea_deg_old = ea_deg;
   index = index + 1;
   t_out(index) = t_out(index-1) + dt; 
end

output_table = [t_out, Fx_out, Fy_out, Depth_out, psi_out, theta_out, phi_out];

filename = 'control_program.csv';
headers = {'Time[s]', 'Fx[N]', 'Fy[N]', 'Depth[m]', 'Phi[deg]', 'Theta[deg]',' Psi[deg]'};
csvwrite_with_headers(filename, output_table, headers);

