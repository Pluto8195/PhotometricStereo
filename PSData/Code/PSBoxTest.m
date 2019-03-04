% Run all the tests in current directory.
%
%   Author: Ying Xiong.
%   Created: Feb 08, 2014.

curPath = fileparts(mfilename('fullpath'));
testScripts = dir(fullfile(curPath, '*Test.m'));

for i = 1:length(testScripts)
  if (~strcmp(testScripts(i).name, [mfilename, '.m']))   % not this file.
    fprintf('Running %s...\n', testScripts(i).name);
    run(testScripts(i).name);
  end
end
