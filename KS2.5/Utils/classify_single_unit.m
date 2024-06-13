function MatData = classify_single_unit(MatData, varargin)
p = inputParser;
p.addParameter('ks_only', 0);
p.addParameter('amp_rms', 5);
p.addParameter('isi_violation', 1);
p.parse(varargin{:});
MatData.single_units = or(MatData.ks_label == 2, (~p.Results.ks_only) & and((MatData.amp_rms >= p.Results.amp_rms), (MatData.isi_violation <= p.Results.isi_violation)));
MatData.single_unit_criteria = p.Results;
end