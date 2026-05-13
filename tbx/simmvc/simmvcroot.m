function f = simmvcroot()
%SIMMVCROOT Return the toolbox root folder.

% Copyright 2025-2026 The MathWorks, Inc.

arguments ( Output )
    f(1, 1) string {mustBeFolder}
end % arguments ( Output )

f = fileparts( mfilename( "fullpath" ) );

end % simmvcroot