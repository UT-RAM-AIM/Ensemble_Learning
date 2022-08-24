%% Create figure from paper
% Variables ==============================================================
% accuracy1:        array of accuracies of 70 CNNs on Set4
%
% mv_accuracy:      accuracy of Majority Voting on Set4
%
% dt_accuracy:      accuracy of Decision Tree on Set4
%
% svm_accuracy:     accuracy of Support Vector Machine on Set4
%
% mi_accuracy:      accuracy of Multi-Input DNN on Set4
%
%% =======================================================================
figure()
h = histfit(accuracy1, 10);
h(1).FaceColor = [1 0.41 0.16];     % colors of bars
h(1).FaceAlpha = 0.5;
h(2).Color = [0 0 0];        % colors of density line
h(2).LineWidth = 4;

pd = fitdist(accuracy1, 'Normal');

xlim([0.5 1.0])

xlabel('Accuracy')
ylabel('Number of CNNs')

%% add confidence intervals
alpha = 0.05;          % significance level
mu = pd.mu;               % mean
sigma = pd.sigma;             % std
% percentiles
perc_25 = prctile(accuracy1, 25);
perc_95 = prctile(accuracy1, 95);

av = xline([mu],'--',{'Mean'});
av.LabelVerticalAlignment = 'bottom';
av.LabelHorizontalAlignment = 'center';
av.Color = [.2 .2 .2];
av.LineWidth = 2;
av.FontName = 'Times New Roman';
av.FontSize = 16;
av.Interpreter = 'latex';
p25 = xline([perc_25],'--',{'25th Percentile'});
p25.LabelVerticalAlignment = 'bottom';
p25.LabelHorizontalAlignment = 'center';
p25.Color = [.2 .2 .2];
p25.LineWidth = 2;
p25.FontName = 'Times New Roman';
p25.FontSize = 16;
p25.Interpreter = 'latex';
p95 = xline([perc_95],'--',{'95th Percentile'});
p95.LabelVerticalAlignment = 'bottom';
p95.LabelHorizontalAlignment = 'center';
p95.Color = [.2 .2 .2];
p95.LineWidth = 2;
p95.FontName = 'Times New Roman';
p95.FontSize = 16;
p95.Interpreter = 'latex';

base = xline([0.6257], '-', {'Base Network'}); 
base.Color = [0 0.45 0.74];
base.Alpha = 0.9;
base.LineWidth = 2;
base.FontName = 'Times New Roman';
base.FontSize = 16;
base.Interpreter = 'latex';
base.LabelHorizontalAlignment = 'center';

%% Other accuracies
mv_accuracy = 0.7183;
mv = xline([mv_accuracy],'-',{'Majority Voting'});
mv.Color = [0.49 0.18 0.56];
mv.Alpha = 0.9;
mv.LineWidth = 2;
mv.FontName = 'Times New Roman';
mv.FontSize = 16;
mv.Interpreter = 'latex';
mv.LabelHorizontalAlignment = 'center';
dt_accuracy = 0.7013;
dt = xline([dt_accuracy],'-',{'Decision Tree'});
dt.Color = [0.49 0.18 0.56];
dt.Alpha = 0.9;
dt.LineWidth = 2;
dt.FontName = 'Times New Roman';
dt.FontSize = 16;
dt.Interpreter = 'latex';
dt.LabelHorizontalAlignment = 'center';
svm_accuracy = 0.7410;
svm = xline([svm_accuracy],'-',{'Support Vector Machine'});
svm.Color = [0.49 0.18 0.56];
svm.Alpha = 0.9;
svm.LineWidth = 2;
svm.FontName = 'Times New Roman';
svm.FontSize = 16;
svm.Interpreter = 'latex';
svm.LabelHorizontalAlignment = 'center';
mi_accuracy = 0.6510;
mi = xline([mi_accuracy],'-',{'Multi-Input DNN'});
mi.Color = [0.49 0.18 0.56];
mi.Alpha = 0.9;
mi.LineWidth = 2;
mi.FontName = 'Times New Roman';
mi.FontSize = 16;
mi.Interpreter = 'latex';
mi.LabelHorizontalAlignment = 'center';