function [Index1, Index2] = GetBestElectrode(EEG, Channels)
% Channels should be list of electrodes in the order in which you'd prefer
% them. This provides the index of the first that is present in the data

Index1 = [];
Index2 = [];

Channels = string(Channels);

EEG_Channels = {EEG.chanlocs.labels};

switch size(Channels, 2)
    case 1
        
        
        if isempty(intersect(EEG_Channels, Channels))
            warning(['No channels were found for ', EEG.filename])
            return
        end
        
        
        for Indx_Ch = Channels
            if ismember(Indx_Ch, EEG_Channels)
                Index1 = find(strcmp(EEG_Channels, Indx_Ch)); % TODO: eventually make more succint
                
                if Indx_Ch ~= Channels(1)
                    disp(['Using ch ', Indx_Ch, ' instead of ', Channels(1), ' for ' EEG.filename])
                end
                return
            end
        end
        
    case 2 % if paired electrodes are provided
        
%         if isempty(intersect(EEG_Channels, Channels(:, 1))) && isempty(intersect(EEG_Channels, Channels(:, 2)))
%             warning(['No channels were found for ', EEG.filename])
%         end
%         
        
%         for Indx_Ch = 1:size(Channels, 1) % loop through first column
% %             if ismember(Channels(Indx_Ch, 1), EEG_Channels) % if there's a match, return that one
% %                 Index1 = find(strcmp(EEG_Channels, Channels(Indx_Ch, 1)));
% %                 if ismember(Channels(Indx_Ch, 2), EEG_Channels)
% %                     
% %                     Index2 = find(strcmp(EEG_Channels, Channels(Indx_Ch, 2)));
% %                 else 
% %                     for Indx_Ch2 = 1:size(Channels, 2) % loop through first column
% %                         if ismember(Channels(Indx_Ch2, 2), EEG_Channels) % if there's a match, return that one
% %                             Index2 = find(strcmp(EEG_Channels, Channels(Indx_Ch2, 2)));
% %                             break
% %                         end
% %                     end
% %                 end
% %                 if Indx_Ch ~= Channels(1)
% %                     disp(['Using ch ', EEG_Channels{Index1}, '&', EEG_Channels{Index2}, ' instead of ', Channels(1), ' for ' EEG.filename])
% %                 end
%                 
%             end
%         end
        
    otherwise
        error('wrong size of matrix')
end

