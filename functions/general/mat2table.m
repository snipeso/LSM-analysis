function Table = mat2table(Matrix, RowNames, ColNames, RowTitle, ColTitle, DataTitle)
% converts a matrix into a table
% if ColTitle is left empty, then columns are kept as table columns

Table = table();

[Tot_R, Tot_C] = size(Matrix);

if ~isempty(ColTitle)
    for Indx_C = 1:Tot_C
        T = table();
        T.(RowTitle) = RowNames(:);
        T.(ColTitle) = repmat(ColNames(Indx_C), Tot_R, 1);
        T.(DataTitle) = Matrix(:, Indx_C);
        Table = [Table; T];
    end
    
    Table.Properties.VariableNames = {RowTitle, ColTitle, DataTitle};
    
else
    
    for Indx_C = 1:Tot_C
        Table.(RowTitle) = RowNames(:);
        Table.(ColNames{Indx_C}) = Matrix(:, Indx_C);
    end
    
    
end