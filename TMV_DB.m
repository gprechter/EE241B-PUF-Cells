PUF_DATA = csvread('puf_out_1024_2GHzclk_10Gnoise_diff.csv');
%PUF_DATA = csvread('puf_vth_data.csv');
PUF_count = size(PUF_DATA, 2)/2;
PUF_data = PUF_DATA(:, 2*[1:PUF_count]);
PUF_data = PUF_data >= 0.5;

tmv =7;
tmv_count = floor(size(PUF_data,1)/tmv);

tmv_out = zeros(tmv_count,PUF_count);
DB = zeros(1,PUF_count);
for j = 1: PUF_count
    for i = 1:tmv_count
        tmv_out(i,j) = sum(PUF_data((i-1)*tmv+1:i*tmv,j));
        if tmv_out(i,j)>tmv/2
            tmv_out(i,j) = 1;
        else
            tmv_out(i,j) = 0;
        end
    end
%     if sum(tmv_out(:,j)) ~= tmv_count && sum(tmv_out(:,j)) ~= 0
%         DB(j) = 1;
%     end
    if sum(tmv_out(1:10,j)) ~= 10 && sum(tmv_out(:,j)) ~= 0
        DB(j) = 1;
    end

end

DB_count = sum(DB);
% PUF_field_data = tmv_out(10, :);
% CL_PUF_data = tmv_out(1, 1:128);
% 
% writematrix(PUF_field_data, 'PUF_data.csv');
% writematrix(CL_PUF_data, 'CL_PUF_data.csv');
% save('PUF_data.csv', 'PUF_field_data');
% save('tmv_out', tmv_out);

%% unstable bits vs no. of evaluations plot

eval = size(PUF_data, 1);

unstable_count = zeros(eval, 1);
unstable_puf = zeros(1, PUF_count);
for i = 2:eval
    for j = 1:PUF_count
        if PUF_data(i,j) ~= PUF_data(i-1,j)
            unstable_puf(j) = 1;
        end
    end
    unstable_count(i) = sum(unstable_puf);
end

unstable_count = unstable_count/PUF_count;
unstable_CL_PUF = zeros(eval,1);

plot([1:eval], unstable_count, '-b',[1:eval], unstable_CL_PUF, '-g', 'LineWidth',3);


ylabel('Unstable bits (%)','FontSize',20,'FontWeight','Bold');
xlabel('# of PUF evaluations', 'FontSize',20,'FontWeight','Bold');

legend('Raw PUF','with PUF bias rinforcement');
legend1 = legend(gca);
set(legend1,'FontSize',14);

ax = gca;
ax.LineWidth = 1.5;
ax.FontSize=15;
ax.FontWeight='bold';
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.Box='on';

%% DB count vs TMV width data

db_cnt_hybrid = [228 170 105 78 16]/1024;
db_cnt_DH = [20 16 12 8 0]/128;
db_cnt_vth = [7 6 4 2 1]/128;

tmv_width = [3 7 15 31 63];

plot(tmv_width, db_cnt_hybrid, '-ob',tmv_width, db_cnt_DH, '->r',tmv_width, db_cnt_vth, '-sk', 'LineWidth',3);


ylabel('Dark Bits (%)','FontSize',20,'FontWeight','Bold');
xlabel('TMV Width', 'FontSize',20,'FontWeight','Bold');

legend('Hybrid PUF', 'Dely-hardened PUF', 'Threshold-PUF');
legend1 = legend(gca);
set(legend1,'FontSize',14);

ax = gca;
ax.LineWidth = 1.5;
ax.FontSize=15;
ax.FontWeight='bold';
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.Box='on';

%% Performance w/ cap value in CL-PUF

unstable_cnt = [9 6 1 0 0 0 0]/128*100;
cap_value = [0.1 1 10 100 1000 10000 1e5]*1e-3;

semilogx(cap_value, unstable_cnt, '-ob', 'LineWidth',3);


ylabel('Unstable Bits (%)','FontSize',20,'FontWeight','Bold');
xlabel('Load Capacitor (CL) (fF)', 'FontSize',20,'FontWeight','Bold');


ax = gca;
ax.LineWidth = 1.5;
ax.FontSize=15;
ax.FontWeight='bold';
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.Box='on';

%% Bit Error rate
eval = size(PUF_data, 1);
golden_key = tmv_out(1,:);
golden_key_raw = PUF_data(1,:);
golden_key_DB = DB;

in_field_raw = PUF_data;
in_field_tmv = tmv_out(11, :);
in_field_tmvdb = tmv_out(14, :);


% Finding Raw BER
BER_raw = 0;
for i=2:eval
    for j=1:PUF_count
       if golden_key_raw(j) ~= in_field_raw(i,j)
            BER_raw = BER_raw +1;
       end
    end
end
BER_raw = BER_raw/(PUF_count*(eval-1));

% Finding BER w/ TMV
BER_tmv = 0;
key_length_tmv = PUF_count;
for i=1:PUF_count
%    if golden_key_DB(i) == 0
        if golden_key(i) ~= in_field_tmv(i)
            BER_tmv = BER_tmv +1;
        end
%    end
end
BER_tmv = BER_tmv/key_length_tmv;

% Finding BER w/ TMV_DB
BER_tmvdb = 0;
key_length_tmvdb = PUF_count - DB_count;
for i=1:PUF_count
    if golden_key_DB(i) == 0
        if golden_key(i) ~= in_field_tmvdb(i)
            BER_tmvdb = BER_tmvdb+1;
        end
    end
end
BER_tmvdb = BER_tmvdb/key_length_tmvdb;

%%
% Finding BER w/ TMV_DB
BER_tmvdb = 0;
key_length_tmvdb = PUF_count - DB_count;
for i=1:PUF_count
    if golden_key_DB(i) == 0
        if tmv_out(1,i) ~= tmv_out(12,i)
            BER_tmvdb = BER_tmvdb+1;
            a=1;
        end
        b=1;
    end
end
BER_tmvdb = BER_tmvdb/key_length_tmvdb;