% MV Portfolio Optimization
clear
MTickers = xlsread('C:\Users\...', 'cotas')
MReturns = price2ret(MTickers, [], 'Periodic')
ExpReturns = mean(MReturns)
Upside = xlsread('C:\Users\...', 'alvos')
ExpCovariance = cov(MReturns)

size = size(MReturns)
size = size(2) + 1
[num, txt, raw] = xlsread('C:\Users\', 'cotas')
Names = txt(1, 2:size)

bounds = xlsread('C:\Users\...', 'bounds')
p = Portfolio('assetmean', Upside, 'assetcovar', ExpCovariance, 'lowerbound', bounds(1, :), 'upperbound', bounds(2, :))
p = Portfolio(p, 'lowerbudget', 1, 'upperbudget', 1)
p = Portfolio(p, 'assetnames', Names)
plotFrontier(p)
pwgt = estimateFrontier(p, 100)

pnames=cell(1, 100)
for i = 1:100
    pnames{i} = sprintf('Port%d', i)
end

Port = dataset([{pwgt}, pnames], 'obsnames', p.AssetList)
[ersk, eret] = estimatePortMoments(p, pwgt)
disp([ersk, eret])

rf = ((1.120805) ^ (182 / 252) - 1) 
p = Portfolio(p, 'riskfreerate', rf)

clf
portfolioexamples_plot('Asset Risks and Returns', ...
	{'line', ersk, eret, {'RiskyFrontier'}}, ...
    {'scatter', 0, rf, {'LFT'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

q = setBudget(p, 0, 1);
qwgt = estimateFrontier(q, 100);
[qrsk, qret] = estimatePortMoments(q, qwgt);

clf
portfolioexamples_plot('Asset Risks and Returns', ...
	{'line', ersk, eret, {'Frontier'}}, ...
    {'line', qrsk, qret, [], [], 1}, ...
    {'scatter', 0, rf, {'LFT'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

frontports = ([ersk, eret])
sharpe = cell(100, 1)
for i = 1:100
    sharpe{i, 1} = (frontports(i, 2) - rf) / frontports(i, 1)
end