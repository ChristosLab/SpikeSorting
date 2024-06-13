function out = detrend_var(x, t)
% gam_mdl = fitrgam(table(t, x), 'x ~ t');
% out = var(x - predict(gam_mdl, t));
poly_mdl = polyfit(t, x, 2); %  Quadratic fit to detrend
out = var(x - polyval(poly_mdl, t));
end