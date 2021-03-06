clear;
tau_cf= 4;
K=6; M=20; nbrOfRealizations = 1; D_sqr = 1000;
taud_sc = 20; tauu_sc = 20; BW = 20e6; NF_dB = 9;
AVErhod_cf = 200; AVErhou_cf = 100; AVErhop_cf = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DistanceControl = 'Uni'; % Control two solutions creat uniformly distributed
% 'Halton' use Halton sequenc, and 'Uni' use makdedist Uniformly-distribution
ShadowingControl = 'uncorrelated'; % Control two shadowing correlation model: 'uncorrelated' or 'correlated'
PowerControl = 'No'; % Two Power Control Mode: 'No' = without Power Control / 'Yes' = Max-Min Power Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[d_MK xM yM xK yK] = functionDistance(M, K, D_sqr, DistanceControl, nbrOfRealizations);
figure(1)
scatter(xM,yM,'^')
hold on
for i=1:length(xK)
    scatter(xK(i),yK(i))
    text(xK(i)+10,yK(i)+10,int2str(i))
end

[Beta PL z_MK] = functionLargeScaleFading(d_MK, M, K, ShadowingControl, nbrOfRealizations);
 % Beta = ones(M, K, nbrOfRealizations); % beta_mk = 1
[NoisePower rhod_cf rhou_cf rhop_cf rhod_sc rhou_sc rhoup_sc rhodp_sc] = functionNormalizedTransmitSNRs(M, K, BW, NF_dB, AVErhod_cf, AVErhou_cf, AVErhop_cf);
[Hchannel Gchannel Wnoise] = functionGchannelGenerating(M, K, tau_cf, Beta, nbrOfRealizations);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pilot = [[1 0 0 0];[0 1 0 0 ];[0 0 1 0];[0 0 0 0]] %generate pilot
pilot = functionRandomPilotAssignment(tau_cf, tau_cf, nbrOfRealizations)
%generate map 
matrix = [];
for i=1:K
    repeat = 4^(i-1);
    repeat_1 = repmat(1,repeat,1);
    repeat_2 = repmat(2,repeat,1);
    repeat_3 = repmat(3,repeat,1);
    repeat_4 = repmat(4,repeat,1);
    repeat_col = [repeat_1;repeat_2;repeat_3;repeat_4];
    repeat_col = repmat(repeat_col,(4^K / length(repeat_col)),1);
    matrix = [repeat_col,matrix];
end
rate = [];
fitness = [];
for i=1:4^6
   fit = fitness_rate(matrix(i,:),pilot,M, K, PowerControl,Beta, tau_cf,rhod_cf, rhop_cf, Gchannel, Wnoise, nbrOfRealizations);
   fitness = [fitness fit];
end
max(fitness)
