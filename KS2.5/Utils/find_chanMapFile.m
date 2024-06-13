function chanMapFile = find_chanMapFile(session)
continuous_processor = session.oe_info.continuous(session.daq_continuous_idx);
n_chan = continuous_processor.num_channels;
if strcmp(continuous_processor.source_processor_name, 'Neuropix-PXI')
    xml_ch_map          = get_neuropixels_channel_map_oe(fullfile(session.xml_file.folder, session.xml_file.name));
    channel_index       = nan(size(continuous_processor.channels));
    ephys_channels      = cellfun(@(x) contains('channel_metadata', fieldnames(x)), continuous_processor.channels);
    ephys_channel_index = cellfun(@(x) x.channel_metadata.value, continuous_processor.channels(ephys_channels));
    channel_index(ephys_channels) = ephys_channel_index;
    chanMapFile         = create_channel_map_np(xml_ch_map, channel_index);
    return
end
switch n_chan
    case 1
        chanMapFile = 'tungsten_1.mat';
    case 16
        chanMapFile = 'Linear_16_ch_150_pitch_plexon_V.mat';
    case 32
        chanMapFile = 'Linear_32_ch_75_pitch_plexon_S.mat';
    case 128
        chanMapFile = 'DA128-2_chanMap.mat';
    case num2cell(128 + [1:8])
        chanMapFile = sprintf('DA128-2_chanMap_%dadc.mat', n_chan - 128);
    case 256
        chanMapFile = 'DA128-2X2_chanMap.mat';
    case mat2cell(256 + [1:8])
        chanMapFile = sprintf('DA128-2X2_chanMap_%dadc.mat', n_chan - 256);
end