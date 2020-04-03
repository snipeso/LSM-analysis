clear
clc
close all

filepath = 'C:\Users\colas\Projects\LSM-analysis\Questionnaires\CSVs';
filename = 'Fixation_All.csv';

Answers = readtable(fullfile(filepath, filename));